I’ve come across this problem when trying to manipulate the pixel data in a WriteableBitmap variable because of the way the colour int is structured. Instead of using a UINT32, it uses a standard int, but the alpha channel makes the int negative. This can be quite frustrating when trying to change the colour, because you can’t straight up us 0xFF000000 and you can’t use -0×000000.

Here’s a quick tip on how to get the right colour and to assign the right colour data to the pixel array.

```java
uint pixel = unchecked((uint)colourList[index]);

double r = (pixel >> 16) & 255;
double g = (pixel >> 8 ) & 255;
double b = (pixel) & 255;

// Here we do our manipulations...
double factor = 1.5;
uint newR = (uint)Math.Round(r * factor);
uint newG = (uint)Math.Round(g * factor);
uint newB = (uint)Math.Round(b * factor);

// compose
colourList[index] = makeARGB(255, newR, newG, newB);
```

Now makeARGB is a custom method I wrote to just generate the int from the argb because they removed it from the Color class in Silverlight. for some stupid reason.

```java
public int makeARGB(uint a, uint r, uint g, uint b)
{
	return unchecked((int)((a << 24) | (r << 16) | (g << 8 ) | b));
}
```

Use these methods and your life will be 100x easier with WriteableBitmaps.