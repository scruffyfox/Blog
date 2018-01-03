With my projects I do alot of debugging and outputting and when the projects get really big, theres A LOT of out put. And its extremely tedious to go through and find each output and remove it.

I know in PHP theres a variable (`__LINE__`) which tells you what line number the code is currently on so I wondered if I could do something similar in Java, turns out, yes.

All we literally do is fake an exception which then gives us a stack trace of the error which returns all origins and paths of what was called before the exception

```java
private static String getCallingMethodInfo()
{
	Throwable fakeException = new Throwable();
	StackTraceElement[] stackTrace = fakeException.getStackTrace();

	if (stackTrace != null && stackTrace.length >= 2)
	{
		StackTraceElement s = stackTrace[2];
		if (s != null)
		{
			return s.getFileName() + "(" + s.getMethodName() + ":" + s.getLineNumber() + "):";
		}
	}

	return null;
}
```

[Credit: http://another-lazy-blogger.blogspot.co.uk/2008/04/i-was-wondering-around-in-huge-code.html](http://another-lazy-blogger.blogspot.co.uk/2008/04/i-was-wondering-around-in-huge-code.html)