{% unless site.github%}
{% if page.toc %}
## [目录]({{ '/' | relative_url }})

{{content | toc_only}}
{% endif %}
{% endunless%}

## [订阅RSS]({{ '/feed.xml' | relative_url }})

## 实用工具

- [综合搜索]({{ '/tool/search-compare.html' | relative_url }})

## [关于作者]({{ '/about.html' | relative_url }})

- [GitHub](https://github.com/chungkwong)
- [GitLab](https://gitlab.com/chungkwong)
- [Maven](http://mvnrepository.com/artifact/com.github.chungkwong)



