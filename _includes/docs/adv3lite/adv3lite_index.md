::: {.flex-container}
{% for item in site.data.docs.adv3lite.index.table %}
::: {.flex-item .book}
[![](../../../assets/images/adv3lite/{{item.cover}})]({{item.url}})
:::
::: {.flex-item .blurb}
## {{item.title}}
#### {{item.author}}
{{item.description | markdownify}}
:::
{% endfor %}
:::