{% highlight bash %}
## Makefile for an adv3Lite library game

-I liblite
-D LANGUAGE=english
-Fy obj
-Fo obj
## These paths will vary,
## based on your frobtads installation prefix.
## This template assumes the prefix was /usr/local
-FI /usr/local/share/frobtads/tads3/include
-FL /usr/local/share/frobtads/tads3/lib
-we
-v
-d

##sources
-lib system
-lib adv3Lite/adv3Lite
-source gameMain.t

-res
GameInfo.txt
{% endhighlight %}