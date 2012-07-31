So I came across a massive problem when creating a HTTP Request for downloading images where it would not download the image properly and just fail decoding the downloaded stream.

This simple code fixes all that:

```java
class PatchInputStream extends FilterInputStream
{
	public PatchInputStream(InputStream in)
	{
		super(in);
	}

	public long skip(long amount) throws IOException
	{
		long skipCount = 0L;
		while (skipCount < amount)
		{
			long totalSkipped = in.skip(amount - skipCount);
			if (totalSkipped == 0L)
			{
				break;
			}

			skipCount += totalSkipped;
		}

		return skipCount;
	}
}
```

To use it simply call a new PatchInputStream for the input stream of the request. For example

```java
final InputStream bis = new java.net.URL(url[0]).
final Bitmap bm = BitmapFactory.decodeStream(new PatchInputStream(bis));
bis.close();
```