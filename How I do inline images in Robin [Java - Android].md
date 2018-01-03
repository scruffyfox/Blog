I have decided to release the way I do inline images, because its a really cool UI feature and I think everyone should be able to know and use if it they want.

You can download the test project which includes all the code over at [https://github.com/scruffyfox/robin-inline-images](https://github.com/scruffyfox/robin-inline-images)

Firstly, the logic.

## Logic

The way the inline images work is very straight forward, but a real bitch to actually perfect. In Android, there is a method in View you can call which details the position of the view relative to the window and to the screen. We use the `getLocationInWindow` method which gives us the location of the view relative to the window (duh)

Using this, we can calculate how far the list view has scrolled and to offset the imageview to it appears to stay in the same position.

We also need to have a custom list view which has a bunch of scroll listeners added in so we can hook into it and listen for any scroll changes.

I have an extra custom library file in there called `dimension` which is just a proxy for calculating actual dimensions, screen sizes etc.

## Code

This is where the magic happens

```java
int[] pos = new int[2];
getLocationInWindow(pos);
mMaxScrollSize = (mScaledImageHeight - getHeight()) / 2;

if (pos[1] < mDimension.getScreenHeight() && pos[1] + getHeight() > 0)
{
	mTop = pos[1] + (mDimension.getScreenHeight() - mImageHeight);

	int y = (pos[1] - (int)(mScaledImageHeight / 1.5)) + (mContext.getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE ? (int)(mDimension.getScreenHeight() / 1.5) : 0);
	scrollTo(0, y);

	if (y < -mMaxScrollSize)
	{
		scrollTo(0, -mMaxScrollSize);
	}

	if (y + getHeight() > -mMaxScrollSize + mScaledImageHeight)
	{
		scrollTo(0, mMaxScrollSize);
	}
}
```

Literally all we do, is offset the scroll position of the imageview to the scroll position of the list, and if the list scrolls past the bottom or top of the image bounds, it is stuck to the list and moved with the list. The values can be tweeked for mTop to adjust the position of the image, the idea is the image bitmap is roughly in the center of the screen (hence the little orientation hack for landscape, to offset the image so you can preview more)