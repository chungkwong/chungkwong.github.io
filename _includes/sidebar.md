{% unless site.github%}
{% if page.toc %}
## [目录]({{ '/' | relative_url }})

{{content | toc_only}}
{% endif %}
{% endunless%}

{% comment %}
{% if page.ads %}
## 延伸阅读
<ul>
{% for ad in page.ads %}
  <li>{{ad}}</li>
{% endfor %}
</ul>
{% endif %}
{% endcomment %}

## [订阅RSS]({{ '/feed.xml' | relative_url }})

## 实用工具

<ul>
{% for page in site.pages %}
  {%- if page.navigatable -%}
  <li><a href="{{ page.url | relative_url }}">{{ page.title }}</a></li>
  {%- endif -%}
{% endfor %}
<li><a href="https://www.viewfact.org">睇料搜索</a></li>
</ul>

## [关于作者]({{ '/about.html' | relative_url }})

- [GitHub](https://github.com/chungkwong)
- [Maven](http://mvnrepository.com/artifact/com.github.chungkwong)
- [ORCID](https://orcid.org/0000-0002-2242-0351)

