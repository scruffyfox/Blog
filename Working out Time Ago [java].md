Here is a quick snippet of a method converted from Javascript ([source](https://gist.github.com/1333916/c47a3b1cdcab3e0bf2b22ddd4a7720e63e166c89)) to work out the time since a timestamp relative to now. Useful for social network posts etc.

```java
/**
 * Converts a timestamp to how long ago syntax
 * @param time The time in seconds 
 * @return The formatted time
 */
public static String timeAgo(int time)
{
	Unit[] units = new Unit[]
	{
		new Unit("s", 60, 1),
		new Unit("m", 3600, 60),
		new Unit("h", 86400, 3600),
		new Unit("d", 604800, 86400),
		new Unit("w", 2629743, 604800),
		new Unit("m", 31556926, 2629743),
		new Unit("y", 0, 31556926)
	};

	long currentTime = System.currentTimeMillis();
	int difference = (int)((currentTime / 1000) - (time));

	if (difference < 5)
	{
		return "now";
	}

	int i = 0;
	Unit unit = null;
	while ((unit = units[i++]) != null) 
	{
	    if (difference < unit.limit || unit.limit == 0)
	    {
	    	int newDiff =  (int)Math.floor(difference / unit.inSeconds);
	    	return newDiff + "" + unit.name;
	    }
	}

	return "";
}

static class Unit
{
	public String name;
	public int limit;
	public int inSeconds;

	public Unit(String name, int limit, int inSeconds)
	{
		this.name = name;
		this.limit = limit;
		this.inSeconds = inSeconds;
	}
}
```

Calling `timeAgo(1234567890)` returns something like `1y`. You can customise it to include "ago" or rename the name strings to their longer version `s = seconds, m = minutes etc`

**Update** Fixed changed `currentTime < 5` to `difference < 5`