In this tutorial i’ll show you how to create a simple control that will take an the child views give the background a wood texture.

The way i’m going to do is it so show you how to
1. inflate a custom view ‘template’ to use
2. take existing views from the control in XML and put them into our new control layout
3. use custom XML attributes to control the amount of wood we show

The general flow of the custom view goes:
1. Constructor
2: onFinishedInflate
3. onAttachedToWindow
4. onMeasure
5. onLayout
6. onDetatchedFromWindow (when the view is no longer visible)

Firstly we need to create our control’s source code. Create a new file and call it ‘WoodenBoardView.java’

Next we need to create the code for it. Because it’s going to hold children, we want to extend a ViewGroup. Depending on how we want to layout the children by default we can change it, but because we’re going to put them into another view, we dont need any special layouts.

Next we add the methods we will need. We’ll need 2 constructors. The top one is for when we create the view in code, and the second one is for when the view is constructed by Android’s XML parser. The finishedInflate method we will use to process the views that are added to the control in the XML layout.

```java
package com.cube.obj;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;

public class WoodenBoardView extends FrameLayout
{
	private Context mContext;
	private LayoutInflater mLayoutInflater;
	private View mLayoutView;
	private int mBoardHeight;

	public WoodenBoardView(Context context)
	{
		super(context);

		mContext = context;
	}

	public WoodenBoardView(Context context, AttributeSet attrs)
	{
		super(context, attrs);
		mContext = context;
	}		

	@Override protected void onFinishInflate()
	{
		super.onFinishInflate();
	}
}
```

Now we have the base class set up, we want to create our template in XML. Create a new layout and call it wooden_board.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:duplicateParentState="true"
>
	<LinearLayout
		android:layout_width="match_parent"
		android:layout_height="wrap_content"
		android:id="@+id/board_bg"
		android:orientation="vertical"
		android:paddingLeft="1dp"
		android:duplicateParentState="true"
	/>

	<FrameLayout
	 	android:layout_width="match_parent"
	 	android:layout_height="match_parent"
	 	android:id="@+id/content"
	 	android:duplicateParentState="true"
	 	android:layout_gravity="center"
	/>
</FrameLayout>
```

Here we have 2 main containers, one for the board background (the LinearLayout) and one for the content (FrameLayout)

Now we need to add this to our java class.

In the first constructor we want to inflate the view directly to the parent. We can do this because we dont need to worry about any children being in the view.

```java
mLayoutInflater = (LayoutInflater)mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
mLayoutView = mLayoutInflater.inflate(R.layout.wooden_board, this);
```

For the other constructor however, because the view may have children already in it, if we set the parent to ‘this’ it will error saying that the view already has children in it, so we set it to null.

```java
mContext = context;
mLayoutInflater = (LayoutInflater)mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

mLayoutView = mLayoutInflater.inflate(R.layout.wooden_board, null);
```

Now in the onFinishedInflate method, we want to handle any children that may already be in the view. So first we need to loop through and get each child and store it in an array and remove them from the view

```java
View[] nativeViews = new View[getChildCount()];
for (int index = 0; index < nativeViews.length; index++)
{
	nativeViews[index] = getChildAt(index);
}

removeAllViews();
```

Next we want to add our inflated view and add the children into our container (@+id/content)

```java
this.addView(mLayoutView);

FrameLayout container = (FrameLayout)mLayoutView.findViewById(R.id.container);
for (int index = 0; index < nativeViews.length; index++)
{
	container.addView(nativeViews[index]);
}
```

Then we want to relayout the view and invalidate it

```java
mLayoutView.requestLayout();
invalidate();
```

Now we want to create an attribute to control how many boards to draw in the background (if you want a more in-depth tutorial on custom attributes, look at this article, for now I will asume you know about them)

So we want to add a new attribute called “boardHeight”

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
	<!-- VIEW VALUES -->
	<declare-styleable name="WoodenBoardView">
		<attr name="boardHeight" format="integer"/>
	</declare-styleable>
</resources>
```

Now, in our main source we need to get this attribute. In the second constructor add the following code

```java
TypedArray attributes = context.obtainStyledAttributes(attrs, R.styleable.WoodenBoardView);
mBoardHeight = attributes.getInt(R.styleable.WoodenBoardView_boardHeight, 1);
```

We also want to be kind to the people who prefer to use code to layout their views, so add getters and setters for that variable

```java
public void setBoardHeight(int boardHeight)
{
	mBoardHeight = boardHeight;
	updateBoardHeight();
}

public int getBoardHeight()
{
	return mBoardHeight;
}
```

Now we create our updateBoardHeight method to create the views

```java
private void updateBoardHeight()
{
	LinearLayout boardBgContainer = (LinearLayout)findViewById(R.id.board_bg);
	boardBgContainer.removeAllViewsInLayout();

	for (int index = 0; index < mBoardHeight; index++)
	{
		ImageView board = new ImageView(mContext);
		board.setLayoutParams(new LinearLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT));
		board.setBackgroundResource(R.drawable.wood_bg);

		boardBgContainer.addView(board);
	}		

	requestLayout();
}
```

Now finally we add that method call in our onFinishedInflate method

```java
@Override protected void onFinishInflate()
{
	super.onFinishInflate();

	View[] nativeViews = new View[getChildCount()];
	for (int index = 0; index < nativeViews.length; index++)
	{
		nativeViews[index] = getChildAt(index);
	}

	removeAllViews();
	this.addView(mLayoutView);

	FrameLayout container = (FrameLayout)mLayoutView.findViewById(R.id.container);
	for (int index = 0; index < nativeViews.length; index++)
	{
		container.addView(nativeViews[index]);
	}

	mLayoutView.requestLayout();
	invalidate();

	updateBoardHeight();
}
```

And that’s it! Now we can create the view in xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<com.cube.lib.WoodenBoardView
	xmlns:android="http://schemas.android.com/apk/res/android"
	xmlns:x="http://schemas.android.com/apk/res/com.cube.rbf"
	android:layout_width="match_parent"
	android:layout_height="wrap_content"
	x:boardHeight="1"
>
	<TextView
		android:layout_width="match_parent"
    		android:layout_height="wrap_content"
	    	android:textSize="15dp"
	    	android:text="Bournemouth Pier"
	    	android:textStyle="bold"
	    	android:textColor="@color/black"
	    	android:id="@+id/beach_title"
	/>
</com.cube.lib.WoodenBoardView>
```

Or in code

```java
WoodenBoardView board = new WoodenBoardView(context);
board.setBoardHeight(3);
board.addChildView(new TextView(context));
```

And that’s it!

Any problems with the tutorial email me at callum@callumtaylor.net