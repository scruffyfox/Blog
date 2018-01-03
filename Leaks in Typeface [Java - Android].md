Yesterday I ran into an issue with my [custom text view](https://github.com/scruffyfox/X-Library/blob/master/src/x/ui/XUITextView.java#L218) where it allows you to specify a font asset in XML rather than code (but applies anyway) which has a leak in Android's core OS ([details here](http://code.google.com/p/android/issues/detail?id=9904))

The simple work around provided by [Brian Gibson](https://plus.google.com/104297959989061792307/posts) and [Chris Newby](https://plus.google.com/115966214384887886006/posts) has proved very reliable.

```java
public class Typefaces
{
	private static final String TAG = "Typefaces";
	private static final Hashtable<String, Typeface> cache = new Hashtable<String, Typeface>();
	public static Typeface get(Context c, String assetPath)
	{
		synchronized (cache)
		{
			if (!cache.containsKey(assetPath))
			{
				try
				{
					Typeface t = Typeface.createFromAsset(c.getAssets(), assetPath);
					cache.put(assetPath, t);
				}
				catch (Exception e)
				{
					Log.e(TAG, "Could not get typeface '" + assetPath + "' because " + e.getMessage());
					return null;
				}
			}

			return cache.get(assetPath);
		}
	}
}
```

Essentially, it adds a static cache of all of the assets created, so every textview you instanciate, will only leak once (extremely useful for things like list views where your textview is reused) 