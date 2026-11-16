(function () {
  "use strict";

  var images = document.querySelectorAll(".moment-content img");

  if (!images.length || typeof HTMLDialogElement === "undefined") {
    return;
  }

  var dialog = document.createElement("dialog");

  if (typeof dialog.showModal !== "function") {
    return;
  }

  dialog.className = "moment-lightbox";
  dialog.setAttribute("aria-label", "Image preview");
  dialog.innerHTML =
    '<div class="moment-lightbox-content">' +
    '<button class="moment-lightbox-close" type="button" aria-label="Close image preview">&times;</button>' +
    '<button class="moment-lightbox-prev" type="button" aria-label="Previous image">&#8249;</button>' +
    '<img alt="">' +
    '<button class="moment-lightbox-next" type="button" aria-label="Next image">&#8250;</button>' +
    '<span class="moment-lightbox-counter" aria-live="polite"></span>' +
    "</div>";
  document.body.appendChild(dialog);

  var content = dialog.querySelector(".moment-lightbox-content");
  var preview = dialog.querySelector("img");
  var closeButton = dialog.querySelector(".moment-lightbox-close");
  var previousButton = dialog.querySelector(".moment-lightbox-prev");
  var nextButton = dialog.querySelector(".moment-lightbox-next");
  var counter = dialog.querySelector(".moment-lightbox-counter");
  var currentImages = [];
  var currentIndex = 0;
  var closingTimer;
  var openingFrame;
  var imageAnimation;
  var triggerImage;
  var scrollPosition = 0;
  var bodyTop = "";
  var touchStart;
  var suppressClickUntil = 0;
  var isClosing = false;
  var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

  function lockScroll() {
    scrollPosition = window.scrollY;
    bodyTop = document.body.style.top;
    document.body.style.top = -scrollPosition + "px";
    document.body.classList.add("lightbox-open");
  }

  function unlockScroll() {
    document.body.classList.remove("lightbox-open");
    document.body.style.top = bodyTop;
    window.scrollTo({ top: scrollPosition, behavior: "instant" });
  }

  function animateImage(direction) {
    if (imageAnimation) {
      imageAnimation.cancel();
    }
    if (!reduceMotion.matches && typeof preview.animate === "function") {
      imageAnimation = preview.animate([
        { opacity: 0.25, transform: "translateX(" + (direction * 18) + "px) scale(0.985)" },
        { opacity: 1, transform: "translateX(0) scale(1)" }
      ], { duration: 200, easing: "ease-out" });
    }
  }

  function updatePreview() {
    var image = currentImages[currentIndex];
    var hasMultipleImages = currentImages.length > 1;

    preview.src = image.currentSrc || image.src;
    preview.alt = image.alt || "Image preview";
    counter.textContent = hasMultipleImages ? (currentIndex + 1) + " / " + currentImages.length : "";
    counter.hidden = !hasMultipleImages;
    previousButton.hidden = !hasMultipleImages;
    nextButton.hidden = !hasMultipleImages;

    [-1, 1].forEach(function (step) {
      if (hasMultipleImages) {
        var neighbor = currentImages[(currentIndex + step + currentImages.length) % currentImages.length];
        var preload = new Image();
        preload.src = neighbor.currentSrc || neighbor.src;
      }
    });
  }

  function closePreview() {
    if (!dialog.open || isClosing) {
      return;
    }
    isClosing = true;
    touchStart = null;
    window.cancelAnimationFrame(openingFrame);
    if (imageAnimation) {
      imageAnimation.cancel();
    }
    window.clearTimeout(closingTimer);
    dialog.classList.remove("is-visible");
    closingTimer = window.setTimeout(function () {
      if (dialog.open) {
        dialog.close();
      }
    }, reduceMotion.matches ? 0 : 180);
  }

  function openPreview(image) {
    var entry = image.closest(".moment-entry");

    if (!entry || dialog.open) {
      return;
    }
    triggerImage = image;
    isClosing = false;
    currentImages = Array.prototype.slice.call(entry.querySelectorAll(".moment-content img"));
    currentIndex = currentImages.indexOf(image);
    updatePreview();
    dialog.showModal();
    lockScroll();
    // Commit the initial state before starting the opening transition.
    dialog.getBoundingClientRect();
    openingFrame = window.requestAnimationFrame(function () {
      if (dialog.open && !isClosing) {
        dialog.classList.add("is-visible");
      }
    });
    closeButton.focus({ preventScroll: true });
  }

  function movePreview(step) {
    if (!dialog.open || isClosing || currentImages.length < 2) {
      return;
    }
    currentIndex = (currentIndex + step + currentImages.length) % currentImages.length;
    updatePreview();
    animateImage(step);
  }

  images.forEach(function (image) {
    image.setAttribute("tabindex", "0");
    image.setAttribute("role", "button");
    image.setAttribute("aria-label", image.alt ? "Preview " + image.alt : "Preview image");
    image.addEventListener("click", function (event) {
      event.preventDefault();
      openPreview(image);
    });
    image.addEventListener("keydown", function (event) {
      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault();
        openPreview(image);
      }
    });
  });

  closeButton.addEventListener("click", closePreview);
  previousButton.addEventListener("click", function () {
    movePreview(-1);
  });
  nextButton.addEventListener("click", function () {
    movePreview(1);
  });
  content.addEventListener("touchstart", function (event) {
    touchStart = null;
    if (event.touches.length === 1 && !event.target.closest("button") && (!window.visualViewport || window.visualViewport.scale === 1)) {
      var touch = event.touches[0];
      touchStart = { x: touch.clientX, y: touch.clientY, id: touch.identifier };
    }
  }, { passive: true });
  content.addEventListener("touchend", function (event) {
    if (!touchStart || event.touches.length > 0) {
      touchStart = null;
      return;
    }
    var touch = event.changedTouches[0];
    var deltaX = touch.clientX - touchStart.x;
    var deltaY = touch.clientY - touchStart.y;
    var validTouch = touch.identifier === touchStart.id;
    touchStart = null;

    if (validTouch && Math.abs(deltaX) > 45 && Math.abs(deltaX) > Math.abs(deltaY) * 1.5) {
      suppressClickUntil = Date.now() + 400;
      movePreview(deltaX > 0 ? -1 : 1);
    }
  }, { passive: true });
  content.addEventListener("touchcancel", function () {
    touchStart = null;
  }, { passive: true });
  dialog.addEventListener("click", function (event) {
    if (Date.now() >= suppressClickUntil && (event.target === dialog || event.target === content)) {
      closePreview();
    }
  });
  dialog.addEventListener("keydown", function (event) {
    if (event.key === "ArrowLeft") {
      event.preventDefault();
      movePreview(-1);
    } else if (event.key === "ArrowRight") {
      event.preventDefault();
      movePreview(1);
    }
  });
  dialog.addEventListener("cancel", function (event) {
    event.preventDefault();
    closePreview();
  });
  dialog.addEventListener("close", function () {
    window.clearTimeout(closingTimer);
    window.cancelAnimationFrame(openingFrame);
    dialog.classList.remove("is-visible");
    preview.removeAttribute("src");
    currentImages = [];
    currentIndex = 0;
    unlockScroll();
    isClosing = false;
    if (triggerImage && triggerImage.isConnected) {
      triggerImage.focus({ preventScroll: true });
    }
  });
}());
