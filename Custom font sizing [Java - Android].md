I've had to do this on a few projects where the standard accessibility options on Android just isnt enough, it's always nice to have that extra option to increase the app's font size in certain places.

The old way I had done it in the past was to have (in ListView) a tag set for each text view I wanted to be resizable with the current font scale, and if it had changed, reset the font size based on the scale and original font size (which was also stored in a tag).

This worked fine, but I noticed that it caused the list to be quite jerky, so I decided to re-write the system to use custom views.

Firstly, I created a new custom view which extends `TextView`

```java
package in.lib.view;

import in.lib.manager.SettingsManager;
import in.rob.client.R;
import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.widget.TextView;

public class ResizableTextView extends TextView
{
	private float originalTextSize = 0f;
	private float textSizeAdjustment = 1.0f;

	public ResizableTextView(Context context)
	{
		super(context);
	}

	public ResizableTextView(Context context, AttributeSet attrs)
	{
		this(context, attrs, 0);
	}

	public ResizableTextView(Context context, AttributeSet attrs, int defStyle)
	{
		super(context, attrs, defStyle);

		TypedArray values = context.obtainStyledAttributes(attrs, R.styleable.ResizableTextView, defStyle, 0);
		originalTextSize = values.getDimension(R.styleable.ResizableTextView_textSize, 14.0f);
		values.recycle();

		refresh();
	}

	public void refresh()
	{
		textSizeAdjustment = SettingsManager.getFontSize();
		setAdjustment(textSizeAdjustment);
	}

	/**
	 * Sets the original text size of the view.
	 *
	 * @param original
	 *            The new original text size to be used on future adjustments
	 */
	public void setOriginalTextSize(float original)
	{
		setTextSize(original);
	}

	/**
	 * Sets the adjustment of the text view font size
	 *
	 * @param percent
	 *            The percentage increase of the original font size declared
	 *            from `app:textSize` or {@link setOriginalTextSize}
	 */
	public void setAdjustment(float percent)
	{
		textSizeAdjustment = percent;
		setTextSize(TypedValue.COMPLEX_UNIT_PX, originalTextSize * textSizeAdjustment);
	}
```

Note that `SettingsManager.getFontSize()` is a static singleton call to get the setting set by the user which is a % increase of the original font size in the form of a float (1.0 being 100%)

Next we need to add the attributes for the new view in `attrs.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
	<declare-styleable name="ResizableTextView">
		<attr name="textSize" format="dimension"/>
	</declare-styleable>
<resources>
```

Example usage:

```xml
<in.lib.view.ResizableTextView
	android:id="@+id/sub_title"
	android:layout_width="wrap_content"
	android:layout_height="wrap_content"
	android:fontFamily="sans-serif"
	app:textSize="12sp"
/>
```

Note: Make sure to include the `xmlns:app` namespace in the head of your layout (see [here for more](customxmlnamespacefornestedlibrariesxml-android.md))

So now you can use this view where you want and when it's created, it'll set its size correctly based on the setting set for `textSizeAdjustment`

### Refreshing views after changing the setting

One thing I had to do was to refresh the views after the setting was changed, and for `ListView`s, its very difficult because of the way the scrap view and recycling works.

One way to get around this is to take advantage of the `reclaimViews` method in the list view.

```java
public void refreshFontSizes()
{
	List<View> views = new ArrayList<View>();
	getListView().reclaimViews(views);

	if (views != null && views.size() > 0)
	{
		for (View v : views)
		{
			List<View> children = ViewUtils.getAllChildrenByInstance((ViewGroup)v, ResizableTextView.class);

			if (children != null && children.size() > 0)
			{
				for (View c : children)
				{
					((ResizableTextView)c).refresh();
				}
			}
		}
	}
}
```

You can then call this method to recursivly loop through the views on screen and refresh the sizes. We dont need to worry about new views because they will use the setting which has been updated.

Here's the code for `getAllChildrenByInstance` method:

```java
 /**
 * Gets all views of a parent that match an instance (recursive)
 * @param parent The parent view
 * @param instance The instance to check
 * @return An array of views
 */
public static ArrayList<View> getAllChildrenByInstance(ViewGroup parent, Class instance)
{
	ArrayList<View> views = new ArrayList<View>();
	int childCount = parent.getChildCount();

	for (int childIndex = 0; childIndex < childCount; childIndex++)
	{
		View child = parent.getChildAt(childIndex);

		if (child instanceof ViewGroup)
		{
			views.addAll(getAllChildrenByInstance((ViewGroup)child, instance));
		}
		else
		{
			if (instance.isInstance(child))
			{
				views.add(child);
			}
		}
	}

	return views;
}
```

Note that this will only do it for the list view views, other views such as headers/footers and non list-view based views will have to be manually refreshed, but you should be able to recursivly search the view tree using the above method to do this.