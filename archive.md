---
layout: page
title: Archive
permalink: /archive/
---

{% assign posts_by_year = site.posts | group_by_exp: "post", "post.date | date: '%Y'" %}

{% if posts_by_year.size > 0 %}
  {% for year in posts_by_year %}
## {{ year.name }} ({{ year.items | size }})

  <ol class="archive-list">
    {% for post in year.items %}
    <li>
      <time datetime="{{ post.date | date: '%Y-%m-%d' }}">{{ post.date | date: "%Y-%m-%d" }}</time>
      <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
    </li>
    {% endfor %}
  </ol>
  {% endfor %}
{% else %}
No archive entries yet.
{% endif %}
