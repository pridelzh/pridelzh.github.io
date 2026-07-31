---
layout: page
title: Categories
permalink: /categories/
---

## AI

{% for area in site.research_categories %}
  {% assign category_posts = site.categories[area] %}
### <span id="{{ area | slugify }}">{{ area }}</span> ({{ category_posts | size }})

  {% if category_posts.size > 0 %}
  <ol class="category-posts">
    {% for post in category_posts %}
    <li>
      <time datetime="{{ post.date | date: '%Y-%m-%d' }}">{{ post.date | date: "%Y-%m-%d" }}</time>
      <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
    </li>
    {% endfor %}
  </ol>
  {% else %}
  <p>No notes in this area yet.</p>
  {% endif %}
{% endfor %}
