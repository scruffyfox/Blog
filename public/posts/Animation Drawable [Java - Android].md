Having to do this has cropped up a couple times when developing Android apps, and to be honest, its a bit of a pain in the arse to get working right.

Firstly you need to have your frames set up as drawables. Secondly you need to create a new drawable XML file.

Here’s an example of my drawable with 6 frames and their duration

```xml
<?xml version="1.0" encoding="utf-8"?>
<animation-list xmlns:android="http://schemas.android.com/apk/res/android" android:id="@+id/holo_animation" android:oneshot="false">
	<item android:drawable="@drawable/holo_title_frame_1" android:duration="10" />
	<item android:drawable="@drawable/holo_title_frame_2" android:duration="10" />
	<item android:drawable="@drawable/holo_title_frame_3" android:duration="10" />
	<item android:drawable="@drawable/holo_title_frame_4" android:duration="10" />
	<item android:drawable="@drawable/holo_title_frame_5" android:duration="10" />
	<item android:drawable="@drawable/holo_title_frame_6" android:duration="10" />
</animation-list>
```

Once you create that you need to add it as a source to your image view. Note: animation drawables only work for ImageViews. Don’t ask why. It’s bollocks.

Now in code, you have to manually start the animation because Android is a little bit wank.

You can’t start it in the onCreate method, so you need to do it in the onWindowFocusChanged method.

```java
@Override public void onWindowFocusChanged(boolean hasFocus)
{
	ImageView what_title = (ImageView)findViewById(R.id.what_title);

	if (what_title != null)
	{
		AnimationDrawable d = (AnimationDrawable)what_title.getDrawable();
		d.setCallback(what_title);
		d.setVisible(true, true);
	}

	super.onWindowFocusChanged(hasFocus);
}
```

Here we get the image view, get the drawable as animation drawable, set the callback to be the image then set the visibility and restart to true. The image view will now animate.

Or if you wanted to do it on anything other than an Image view, you can write a manual animation module by creating a runnable that loops through and sets the background drawable to be what ever frame is.

```java
final AnimationDrawable loader = new AnimationDrawable();		
loader.addFrame(getResources().getDrawable(R.drawable.image_loading_1), 50);
loader.addFrame(getResources().getDrawable(R.drawable.image_loading_2), 50);
loader.addFrame(getResources().getDrawable(R.drawable.image_loading_3), 50);
loader.addFrame(getResources().getDrawable(R.drawable.image_loading_4), 50);
loader.addFrame(getResources().getDrawable(R.drawable.image_loading_5), 50);
loader.addFrame(getResources().getDrawable(R.drawable.image_loading_6), 50);
loader.addFrame(getResources().getDrawable(R.drawable.image_loading_7), 50);
loader.addFrame(getResources().getDrawable(R.drawable.image_loading_8), 50);	

setImageResource(R.drawable.image_loading_1);						

final Handler h = new Handler();
final Runnable r = new Runnable()
{
	int index = 0;
	public void run()
	{
		index = index > 7 ? 0 : index;
		setImageDrawable(loader.getFrame(index++));
		h.postDelayed(this, 100);
	}
};
h.postDelayed(r, 100);
```