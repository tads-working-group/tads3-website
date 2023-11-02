{% highlight bash %}
## Makefile for an adv3 standard library game

-D LANGUAGE=en_us
-D MESSAGESTYLE=neu
-Fy obj
-Fo obj
## These paths will vary,
## based on your frobtads installation prefix:
## This template assumes the prefix was /usr/local
-FI /usr/local/share/frobtads/tads3/include
-FL /usr/local/share/frobtads/tads3/lib
-we
-v
-d

##sources
-lib system
-lib adv3/adv3
-source gameMain.t

-res
GameInfo.txt
{% endhighlight %}