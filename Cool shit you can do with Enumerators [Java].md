Enumerators are amazing. You can do so much with them, they're really powerful and flexible. The only down side (which is also an upside) is that they don't actually have values.

If you look at traditional Android source codes, you'll notice that there's a lot of integer variables such as 

Gravity.LEFT, Intent.FLAG_CLEAR_TASK etc, these are integers because you can do [bitwise operations](http://blog.callumtaylor.net/understandingbitwiseparametersjava) on them, but sometimes you don't need to.

An example of when you wouldn't need to do this is in my [custom switch view](https://github.com/scruffyfox/X-Library/blob/master/src/x/ui/XUISwitchView.java), this has 3 possible states, and as you should know, a boolean only has 2 states. Here in this class, we have SwitchState which has OFF, ON and BOTH.

Here is an example of a super simple enum:

```java
public enum SwitchState
{
	ON,
	OFF,
	BOTH;
}
```

We can do loads of operations and comparisons on this like

`if (myEnumObject == SwitchState.ON) { … }`

We can also do alot of advance things on enums, like adding parameters to each value.

```java
public enum SwitchState
{
	ON("on"),
	OFF("off"),
	BOTH("");
	
	private String mLabel;
	private StwitchState(String label)
	{
		this.mLabel = label;
	}
	
	public String getLabel()
	{
		return mLabel;
	}
}
```

Here, we have a param on each of the items, and the syntax is a little weird here, but when `ON("on")` is created, it actually calls a private initialiser inside the enum (hence the `private SwitchState(String label)`). the `String label` part refers to the `("on")` part of the value.

After you've done that, you can create getters and what not for `mLabel`.

You could even create a method that finds an enum based on the label 

```java
public SwitchState getEnumFromLabel(String label)
{
	SwitchState[] vals = values();
	for (SwitchState val : vals)
	{
		if (val.getLabel().equals(label)) return val;
	}
	
	return null;
}
```