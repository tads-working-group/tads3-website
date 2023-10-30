For {{ selected_os }}, you will need to install FrobTADS,
which provides you with many of the crucial tools necessary for
creating TADS games outside of Windows.

{% if selected_os == "MacOS" %}
{% include quickstart/frobtads-macos.html %}
{% else %}
{% include quickstart/frobtads-linux.html %}
{% endif %}