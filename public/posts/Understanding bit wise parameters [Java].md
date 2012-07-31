You would have seen bit wise parameters a lot in Java, especially Android.

An example of what I mean is the setGravity(int gravity) method in every view available to Android. Allough there is only one parameter available for passing, you can still ‘stack’ multiple options into that integer, another example of this is say you want the gravity to be top right, you would pass "Gravity.TOP | Gravity.RIGHT". This essentially adds together the 2 values (0×00000030 | 0×00000005 = 0×00000035). That’s the easy part. The hard part is when you want to emulate this in your own custom views or methods.

Doing this is not tricky in the slightest, but it can get trivial if you don’t know what’s happening or how it works.

One fundamental rules to this style of coding is to use powers of 2 for each value and to not use values that cross over in the column of values. For example try not to have values such as 0×0001 and 0×0011 unless they are related. An example of related values are the gravity values CENTER, CENTER_VERTICAL and CENTER_HORIZONTAL.

CENTER (0×11) is a product of both CENTER_HORIZONTAL (0×01) and CENTER_VERTICAL(0×10), so it makes sense to have CENTER as the product of 0×01 and 0×10. You could pass these values either as CENTER, or CENTER_VERTICAL | CENTER_HORIZONTAL and they will have the same value.

Now the way you code this on the other side to get the value back from the parameter is quite simple, but very effective. You want to have the basic rule that you only change the values that that parameter affects and to not use else statements, but separate ifs.

The pseudocode of this is

```java
if ((BIT_VALUE & PARAMETER) == BIT_VALUE)
{
	//DO STUFF
}
```

What this essentially does is check the original value with the passed parameter by checking the exact values. Say you have 0×10 and you pass 0×11, when you & them together you get 0×10 which is part of our original value, but if you did the same with 0×01 and 0×10, the value would be 0×01 which means its not part of the original value.

Here’s an example of this using Gravity in my XUITabHost view (source code can be found here)

```java
int mWidth = 0, mHeight = 0, marginLeft = 0, marginTop = 0;

//	Center gravity
if ((Gravity.CENTER & child.getParams().gravity) == Gravity.CENTER)
{
	marginLeft = (tabWidth - mWidth) / 2;
	marginTop = (tabHeight - mHeight) / 2;

	if ((Gravity.CENTER_HORIZONTAL & child.getParams().gravity) == Gravity.CENTER_HORIZONTAL)
	{
		marginLeft = (tabWidth - mWidth) / 2;
	}

	if ((Gravity.CENTER_VERTICAL & child.getParams().gravity) == Gravity.CENTER_VERTICAL)
	{
		marginTop = (tabHeight - mHeight) / 2;
	}
}	

//	Left gravity
if ((Gravity.LEFT & child.getParams().gravity) == Gravity.LEFT)
{
	marginLeft = 0;
}

//	Right gravity
if ((Gravity.RIGHT & child.getParams().gravity) == Gravity.RIGHT)
{
	marginLeft = (tabWidth - mWidth);
}

//	Top gravity
if ((Gravity.TOP & child.getParams().gravity) == Gravity.TOP)
{
	marginTop = 3;
}

//	Bottom gravity
if ((Gravity.BOTTOM & child.getParams().gravity) == Gravity.BOTTOM)
{
	marginTop = (tabHeight - mHeight) - 3;
}

layout(marginLeft, marginTop, marginLeft + mWidth, marginTop + mHeight);
```