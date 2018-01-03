Serialisation is always such a tricky thing to do in any language. More so in Android because of the lack of libraries/support on how to actually do it.

Over the past i've come across a few libraries, one of which was the closest at being the one I would use for everything, and it's called [kryo](https://code.google.com/p/kryo/). Kryo was very good. The implementation was nice and the speeds were very convincing against all the other serialisers I had found, but one problem I had (well two) was that it lacked documentation for new users and I just couldn't get it working correctly in Android.

It would work fine for single fragments, but as soon as I added more than 3 fragments to a view pager, it would not save the objects correctly (and this was after 2 weeks of attempts).

Before we get into my solution, lets look at the common serialising methods.

## Serializable/Externalizable

This is the most common form of serialisation in Android (and java). The implementation is very simple, you implement the interface `Serializable` and the rest is handled for you.

Example:

```java
public class Test implements Serializable
{
	private int id;
	private String name;
}
```

To read/write

```java
// Write to byte array so it can be written to disk
Test data = new Test();
ByteArrayOutputStream bos = new ByteArrayOutputStream();
ObjectOutput out = new ObjectOutputStream(bos);
out.writeObject(data);

// Read back from disk as byte array and convert back to object
byte[] data … //read from disk
ObjectInputStream input = new ObjectInputStream(new ByteArrayInputStream(data));
Test objectData = (Test)input.readObject();
```

### Upsides

1. Its very easy and minimal effort is required.

### Downsides

1. Its slow
2. Its very hard to maintain if you change the structure of your class
3. [It was pointed out](http://www.reddit.com/r/androiddev/comments/1x3m9y/i_wrote_a_small_blog_post_on_serialisation/cf7xduf) that you shouldn't ever use `Serializable`

You can override a couple methods to speed it up and handle the downsides such as `private void writeObject(java.io.ObjectOutputStream stream) throws IOException` and ` private void readObject(java.io.ObjectInputStream stream) throws IOException, ClassNotFoundException`

## JSON

Another good form of serialisation is JSON. Simply converting your object to a JSON structure and storing that string to disk. You can use GSON to do this and it's quite powerful.

Example:

```java
public class Test
{
	private int id;
	private String name;
}
```

To serialise/deserialise

```java
// Write to string so it can be written to disk
String json = new Gson().toJson(new Test());

// Read back from disk as string and convert back to object
String data … //read from disk
Test objectData = new Gson().fromJson(data, Test.class);
```

### Upsides

1. Easy to implement
2. Easy to debug the serialised outcome

### Downsides

1. Insecure, very easy for people to see the content cached
2. Slow, especially for large objects
3. Can get very complicated for large data structures

## My Solution

Before I get into my solution, lets talk about `Parcelable` real quick. If you're an experience Android developer you'll know about `Parcelable` and how fun they are, if not here's the TL;DR.

### Parcelable

When passing data from one activity to another, you can put data in a `Bundle` object. But if you want to pass a custom object, it either has to be `serializable`, or `Parcelable`. `Serializable` is slow, `Parcelable` is fast and designed specifically for this task (not disk caching) so we use it when we can to make our app hundreds of milliseconds quicker.

`Parcelable` can get quite messy when you have to implement it for every class you get, but my solution ties `Parcelable` and `Serializable` nicely together so you get the speed of `Parcelable` when passing data between activities, and the convenience of `Serializable` when saving to disk (plus a couple optimisations to make `Serializable` faster)

### Solution

The basic principle is, we have two delegation classes that deal with reading/writing. I've called these `SerialWriterUtil` and `SerialReaderUtil` The gist is, when calling to serialise, or to parcel, you call this util class and pass the object you're dealing with, in the case of `Parcelable` its `Parcel` and for `Serializable` I use a raw output/input stream.

SerialReaderUtil.java

```java
public class SerialReaderUtil
{
	private Parcel parcelObject;
	private DataInputStream streamInputObject;

	public SerialReaderUtil(Parcel parcel)
	{
		this.parcelObject = parcel;
	}

	public SerialReaderUtil(DataInputStream stream)
	{
		this.streamInputObject = stream;
	}

	public boolean readBoolean() throws IOException, IllegalAccessException
	{
		if (parcelObject != null)
		{
			return parcelObject.readByte() == (byte)1 ? true : false;
		}
		else if (streamInputObject != null)
		{
			return streamInputObject.readBoolean();
		}
		else
		{
			throw new IllegalAccessException("No object to read from");
		}
	}

	public byte readByte() throws IOException, IllegalAccessException
	{
		if (parcelObject != null)
		{
			return parcelObject.readByte();
		}
		else if (streamInputObject != null)
		{
			return streamInputObject.readByte();
		}
		else
		{
			throw new IllegalAccessException("No object to read from");
		}
	}

	public int readInt() throws IOException, IllegalAccessException
	{
		if (parcelObject != null)
		{
			return parcelObject.readInt();
		}
		else if (streamInputObject != null)
		{
			return streamInputObject.readInt();
		}
		else
		{
			throw new IllegalAccessException("No object to read from");
		}
	}

	public long readLong() throws IOException, IllegalAccessException
	{
		if (parcelObject != null)
		{
			return parcelObject.readLong();
		}
		else if (streamInputObject != null)
		{
			return streamInputObject.readLong();
		}
		else
		{
			throw new IllegalAccessException("No object to read from");
		}
	}

	public double readDouble() throws IOException, IllegalAccessException
	{
		if (parcelObject != null)
		{
			return parcelObject.readDouble();
		}
		else if (streamInputObject != null)
		{
			return streamInputObject.readDouble();
		}
		else
		{
			throw new IllegalAccessException("No object to read from");
		}
	}

	public float readFloat() throws IOException, IllegalAccessException
	{
		if (parcelObject != null)
		{
			return parcelObject.readFloat();
		}
		else if (streamInputObject != null)
		{
			return streamInputObject.readFloat();
		}
		else
		{
			throw new IllegalAccessException("No object to read from");
		}
	}

	public String readString() throws IOException, IllegalAccessException
	{
		if (parcelObject != null)
		{
			return parcelObject.readString();
		}
		else if (streamInputObject != null)
		{
			boolean isNull = streamInputObject.readBoolean();
			return isNull ? null : streamInputObject.readUTF();
		}
		else
		{
			throw new IllegalAccessException("No object to read from");
		}
	}
}
```

SerialWriterUtil.java

```java
public class SerialWriterUtil
{
	private Parcel parcelObject;
	private DataOutputStream streamOutputObject;

	public SerialWriterUtil(Parcel parcel)
	{
		this.parcelObject = parcel;
	}

	public SerialWriterUtil(DataOutputStream stream)
	{
		this.streamOutputObject = stream;
	}

	public void writeBoolean(boolean value) throws IOException, IllegalAccessException
	{
		if (parcelObject != null)
		{
			parcelObject.writeByte(value ? (byte)1 : (byte)0);
		}
		else if (streamOutputObject != null)
		{
			streamOutputObject.writeBoolean(value);
		}
		else
		{
			throw new IllegalAccessException("No object to read from");
		}
	}

	public void writeByte(byte value) throws IOException, IllegalAccessException
	{
		if (parcelObject != null)
		{
			parcelObject.writeByte(value);
		}
		else if (streamOutputObject != null)
		{
			streamOutputObject.writeByte(value);
		}
		else
		{
			throw new IllegalAccessException("No object to read from");
		}
	}

	public void writeInt(int value) throws IOException, IllegalAccessException
	{
		if (parcelObject != null)
		{
			parcelObject.writeInt(value);
		}
		else if (streamOutputObject != null)
		{
			streamOutputObject.writeInt(value);
		}
		else
		{
			throw new IllegalAccessException("No object to read from");
		}
	}

	public void writeLong(long value) throws IOException, IllegalAccessException
	{
		if (parcelObject != null)
		{
			parcelObject.writeLong(value);
		}
		else if (streamOutputObject != null)
		{
			streamOutputObject.writeLong(value);
		}
		else
		{
			throw new IllegalAccessException("No object to read from");
		}
	}

	public void writeDouble(double value) throws IOException, IllegalAccessException
	{
		if (parcelObject != null)
		{
			parcelObject.writeDouble(value);
		}
		else if (streamOutputObject != null)
		{
			streamOutputObject.writeDouble(value);
		}
		else
		{
			throw new IllegalAccessException("No object to read from");
		}
	}

	public void writeFloat(float value) throws IOException, IllegalAccessException
	{
		if (parcelObject != null)
		{
			parcelObject.writeFloat(value);
		}
		else if (streamOutputObject != null)
		{
			streamOutputObject.writeFloat(value);
		}
		else
		{
			throw new IllegalAccessException("No object to read from");
		}
	}

	public void writeString(String value) throws IOException, IllegalAccessException
	{
		if (parcelObject != null)
		{
			parcelObject.writeString(value);
		}
		else if (streamOutputObject != null)
		{
			streamOutputObject.writeBoolean(value == null);

			if (value != null)
			{
				streamOutputObject.writeUTF(value);
			}
		}
		else
		{
			throw new IllegalAccessException("No object to read from");
		}
	}
}
```

These two classes are very straight forward. Depending on what you initialised the util with, determines on what object it writes to. This example has the standard primitive types but you can extend it to add more objects specific to your data structure.

Example class with read/write:

```java
public class Test implements Parcelable
{
	private int id;
	private String name;
	
	public Test()
	{
	}

	@Override public int describeContents()
	{
		return 0;
	}
	
	public int getVersion()
	{
		return 1;
	}
	
	public Test read(SerialReaderUtil util)
	{
		try
		{
			int version = util.readInt();

			if (version == getVersion())
			{
				this.id = util.readInt();
				this.name = util.readString();

				return this;
			}
		}
		catch (Exception e)
		{
			// Handle if a problem occured
			e.printStackTrace();
		}

		return null;
	}

	public void write(SerialWriterUtil util)
	{
		try
		{
			util.writeInt(getVersion());
			util.writeInt(id);
			util.writeString(name);
		}
		catch (Exception e)
		{
			// Handle if a problem occured
			e.printStackTrace();
		}
	}
	
	public Test createFrom(Parcel parcel)
	{
		return read(new SerialReaderUtil(parcel));
	}
	
	@Override public void writeToParcel(Parcel dest, int flags)
	{
		write(new SerialWriterUtil(dest));
	}

	public static final Parcelable.Creator<Test> CREATOR = new Creator<Test>()
	{
		@Override public Test[] newArray(int size)
		{
			return new Test[size];
		}

		@Override public Test createFromParcel(Parcel source)
		{
			return new Test().createFrom(source);
		}
	};
}
```

This is a very basic example of the read/write method implementations. These methods are called from the `Parcelable`, and also can be called when serialising them to a stream when writing to disk, for example

```java
RandomAccessFile file = new RandomAccessFile("filename", "rw");
FileOutputStream fos = new FileOutputStream(file.getFD());
BufferedOutputStream bos = new BufferedOutputStream(fos, 1024 * 8);
DataOutputStream dos = new DataOutputStream(bos);

new Test().write(dos);
```

or reading, for example

```java
RandomAccessFile file = new RandomAccessFile("filename", "rw");
FileInputStream fis = new FileInputStream(file.getFD());
BufferedInputStream bis = new BufferedInputStream(fis, 1024 * 8);
DataInputStream dis = new DataInputStream(bis);

Test object = new Test();
object.read(dis);
```

### Upsides

1. Its faster than `Serializable`
2. It follows the same pattern as if you were using `Parcelable` (I.E. You have to call the read/write from parcel anyway, so you're not duplicating code)
3. Allows for easier versioning

### Downsides

1. It requires a little more work to get your head around
2. Can be fiddly to debug

Note that my method doesn't use `Serializable` because it read/writes directly to an input/output stream.

### Versioning

Its fairly easy to version this, as you can see in my test object I have a "getVersion" method. You can increment this and check it against the version stored in the cached data to allow for easier migration handling, I.E if the version is older and you've removed a key, add in an extra read so it reads the correct data from the stream.

### Extending

This is a very rough example. In my implementation I have an interface which I use to allow ambiguity when reading/writing different objects from cache without having to explicitly define what the class type is.

TSerializable.java

```java
public interface TSerializable
{
	public void writeToBuffer(DataOutputStream buffer);
	public Object readFromBuffer(DataInputStream buffer);
}
```

Then in my models I use

```java
public abstract Model read(SerialReaderUtil util);
public abstract void write(SerialWriterUtil util);
	
public Model createFrom(Parcel parcel)
{
	return read(new SerialReaderUtil(parcel));
}

public void writeToParcel(Parcel dest, int flags)
{
	write(new SerialWriterUtil(dest));
}

@Override public Model readFromBuffer(DataInputStream buffer)
{
	return read(new SerialReaderUtil(buffer));
}

@Override public void writeToBuffer(DataOutputStream buffer)
{
	write(new SerialWriterUtil(buffer));
}
```

### Additional objects

In this example I only use primitives, but in my own code I have a few additional, one of which is very useful, is the ability to write objects that extend the super class which implements `TSerializable` to allow custom object nesting.

```java
public <T extends Model> T readModel(Class<T> model) throws IOException, IllegalAccessException
{
	try
	{
		boolean isNull = readBoolean();
		return isNull ? null : model.cast(model.newInstance().read(this));
	}
	catch (InstantiationException e)
	{
		e.printStackTrace();
	}

	return null;
}

public void writeModel(Model value) throws IOException, IllegalAccessException
{
	writeBoolean(value == null);

	if (value != null)
	{
		value.write(this);
	}
}
```

These work very nicely because they just call the read/write methods which are already part of the object class, so you end up always reading/writing primitives, no matter how deep your nested objects go.

### Conclusion

I spent a good week writing this and trying different methods and found this worked the best for me. It's still in development and not yet perfected. I may upload an example project to show my whole implementation.

Any suggestions/feedback/changes that should be made, let me know, i'd be more than happy to change things if it means making it faster/better/more secure.

### Edits

1. Clarified a couple differences between my method and `Serializable`