---
layout: page
title: Moments
description: Short notes and everyday moments, separate from the research blog.
permalink: /moments/
---

<div class="moments-feed">
  {% assign moments = site.data.moments.moments | sort: "date" | reverse %}
  {% if moments.size > 0 %}
    <ol class="moment-list">
      {% for moment in moments %}
        <li class="moment-entry">
          <time class="moment-date" datetime="{{ moment.date | date_to_xmlschema }}">
            {{ moment.date | date: "%B %-d, %Y · %H:%M" }}
          </time>
          {% assign rendered_content = moment.content | markdownify %}
          {% assign rendered_content = rendered_content | replace: 'src="assets/images/', 'src="/assets/images/' %}
          {% assign rendered_content = rendered_content | replace: 'src="../assets/images/', 'src="/assets/images/' %}
          <div class="moment-content prose">{{ rendered_content }}</div>
        </li>
      {% endfor %}
    </ol>
  {% else %}
    <p class="empty-state">
      No moments yet. Add an entry to <code>_data/moments.yml</code> to share a thought or a bit of daily life.
    </p>
  {% endif %}
</div>
