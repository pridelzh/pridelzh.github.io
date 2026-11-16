const assert = require('node:assert/strict');
const fs = require('node:fs/promises');
const http = require('node:http');
const path = require('node:path');
const { test } = require('node:test');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');

const root = path.resolve(__dirname, '..');
const picture = (name) => `<img src="/photo/${name}.svg" alt="${name}">`;
const entry = (names) => `<li class="moment-entry"><div class="moment-content"><p>${names.map(picture).join('')}</p></div></li>`;
const fixture = `<!doctype html><html><head><meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="/assets/css/style.css"></head><body>
  <div class="site-shell" style="padding-top:12rem;padding-bottom:80rem">
  <ol class="moment-list">${entry(['a1', 'a2', 'a3'])}${entry(['b1', 'b2'])}${entry(['single'])}</ol></div>
  <script src="/assets/js/moments-lightbox.js" defer></script></body></html>`;

test('Moments image preview in Chromium', async (t) => {
  const server = http.createServer(async (request, response) => {
    try {
      if (request.url === '/') {
        response.setHeader('Content-Type', 'text/html; charset=utf-8');
        response.end(fixture);
      } else if (request.url.startsWith('/photo/')) {
        response.setHeader('Content-Type', 'image/svg+xml');
        response.end('<svg xmlns="http://www.w3.org/2000/svg" width="600" height="900"><rect width="600" height="900" fill="#7b2136"/></svg>');
      } else if (['/assets/css/style.css', '/assets/js/moments-lightbox.js'].includes(request.url)) {
        response.setHeader('Content-Type', request.url.endsWith('.js') ? 'text/javascript' : 'text/css');
        response.end(await fs.readFile(path.join(root, request.url)));
      } else {
        response.writeHead(404).end();
      }
    } catch (error) {
      response.writeHead(500).end(error.message);
    }
  });
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  const browser = await chromium.launch({
    headless: true,
    ...(process.env.BROWSER_EXECUTABLE ? { executablePath: process.env.BROWSER_EXECUTABLE } : {})
  });
  const base = `http://127.0.0.1:${server.address().port}`;
  const context = await browser.newContext({ viewport: { width: 1280, height: 900 } });
  const page = await context.newPage();
  const errors = [];
  page.on('pageerror', (error) => errors.push(error.message));
  const thumbnails = page.locator('.moment-content img');
  const counter = page.locator('.moment-lightbox-counter');
  const waitClosed = (target = page) => target.waitForFunction(() => !document.querySelector('dialog').open);

  try {
    await page.goto(base);
    await thumbnails.first().waitFor();
    await t.test('buttons and arrow keys wrap within the selected moment', async () => {
      await thumbnails.nth(1).click();
      assert.equal(await counter.textContent(), '2 / 3');
      await page.locator('.moment-lightbox-next').click();
      assert.equal(await counter.textContent(), '3 / 3');
      await page.keyboard.press('ArrowRight');
      assert.equal(await counter.textContent(), '1 / 3');
      await page.keyboard.press('ArrowLeft');
      assert.equal(await counter.textContent(), '3 / 3');
      assert.match(await page.locator('dialog img').getAttribute('src'), /a3.svg$/);
      await page.keyboard.press('Escape');
      await waitClosed();
      assert.equal(await thumbnails.nth(1).evaluate((image) => document.activeElement === image), true);
      await thumbnails.nth(3).click();
      assert.equal(await counter.textContent(), '1 / 2');
      await page.locator('.moment-lightbox-prev').click();
      assert.match(await page.locator('dialog img').getAttribute('src'), /b2.svg$/);
      await page.locator('.moment-lightbox-close').click();
      await waitClosed();
    });

    await t.test('keyboard opening, modal focus and single-image controls', async () => {
      await thumbnails.last().focus();
      await page.keyboard.press('Enter');
      assert.equal(await page.locator('.moment-lightbox-next').isVisible(), false);
      assert.equal(await page.locator('.moment-lightbox-prev').isVisible(), false);
      assert.equal(await counter.isVisible(), false);
      await page.keyboard.press('Tab');
      await page.keyboard.press('Tab');
      assert.equal(await page.evaluate(() => document.querySelector('dialog').contains(document.activeElement)), true);
      await page.keyboard.press('Escape');
      await waitClosed();
      await page.keyboard.press('Space');
      assert.equal(await page.locator('dialog').evaluate((dialog) => dialog.open), true);
      await page.keyboard.press('Escape');
      await waitClosed();
    });

    await t.test('blank-area dismissal restores scroll and opening does animate', async () => {
      await page.evaluate(() => window.scrollTo(0, 100));
      await thumbnails.first().click();
      await page.waitForFunction(() => getComputedStyle(document.querySelector('.moment-lightbox-content')).opacity === '1');
      assert.equal(await page.evaluate(() => getComputedStyle(document.body).position), 'fixed');
      assert.notEqual(await page.locator('.moment-lightbox-content').evaluate((element) => getComputedStyle(element).transitionDuration), '0s');
      await page.mouse.click(100, 200);
      await waitClosed();
      assert.equal(await page.evaluate(() => window.scrollY), 100);
      assert.equal(await page.evaluate(() => document.body.style.top), '');
    });

    await t.test('reduced motion disables both opening and switching animation', async () => {
      await page.emulateMedia({ reducedMotion: 'reduce' });
      await thumbnails.first().click();
      await page.keyboard.press('ArrowRight');
      assert.equal(await page.locator('.moment-lightbox-content').evaluate((element) => getComputedStyle(element).transitionDuration), '0s');
      assert.equal(await page.locator('dialog img').evaluate((image) => image.getAnimations().length), 0);
      await page.keyboard.press('Escape');
      await waitClosed();
    });

    await t.test('phone swipes, pinch protection and portrait/landscape sizing', async () => {
      const mobile = await browser.newContext({ viewport: { width: 390, height: 844 }, isMobile: true, hasTouch: true });
      const phone = await mobile.newPage();
      phone.on('pageerror', (error) => errors.push(error.message));
      await phone.goto(base);
      await phone.locator('.moment-content img').first().tap();
      await phone.waitForFunction(() => getComputedStyle(document.querySelector('.moment-lightbox-content')).opacity === '1');
      const session = await mobile.newCDPSession(phone);
      const swipe = async (start, end) => {
        await session.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: start.x, y: start.y }] });
        await session.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [{ x: end.x, y: end.y }] });
        await session.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
      };
      await swipe({ x: 300, y: 400 }, { x: 80, y: 400 });
      assert.equal(await phone.locator('.moment-lightbox-counter').textContent(), '2 / 3');
      await swipe({ x: 80, y: 400 }, { x: 300, y: 400 });
      assert.equal(await phone.locator('.moment-lightbox-counter').textContent(), '1 / 3');
      await swipe({ x: 190, y: 400 }, { x: 195, y: 500 });
      assert.equal(await phone.locator('.moment-lightbox-counter').textContent(), '1 / 3');
      await session.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: 100, y: 400 }, { x: 250, y: 400 }] });
      await session.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
      assert.equal(await phone.locator('.moment-lightbox-counter').textContent(), '1 / 3');
      for (const viewport of [{ width: 320, height: 568 }, { width: 390, height: 844 }, { width: 844, height: 390 }]) {
        await phone.setViewportSize(viewport);
        const bounds = await phone.evaluate(() => {
          const dialog = document.querySelector('dialog');
          const image = dialog.querySelector('img').getBoundingClientRect();
          return { width: innerWidth, height: innerHeight, image: image.toJSON(), buttons: Array.from(dialog.querySelectorAll('button'), (button) => button.getBoundingClientRect().toJSON()) };
        });
        assert.ok(bounds.image.left >= 0 && bounds.image.right <= bounds.width);
        assert.ok(bounds.image.top >= 0 && bounds.image.bottom <= bounds.height);
        for (const button of bounds.buttons) {
          assert.ok(button.width >= 44 && button.height >= 44);
          assert.ok(button.left >= 0 && button.right <= bounds.width);
          assert.ok(button.top >= 0 && button.bottom <= bounds.height);
        }
      }
      await phone.locator('.moment-lightbox-close').tap();
      await waitClosed(phone);
      assert.equal(await phone.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true);
      await mobile.close();
    });

    assert.deepEqual(errors, []);
  } finally {
    await browser.close();
    await new Promise((resolve) => server.close(resolve));
  }
});
