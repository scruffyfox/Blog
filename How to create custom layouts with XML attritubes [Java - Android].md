This is a short tutorial on how to create a custom layout (in this case an AbsoluteLayout) with your own custom layout attributes that apply to direct children (I.E. layout_x, layout_y).

Firstly we create the AbsoluteLayout class. I pretty much copied and pasted the source code from the android source files for convenience.

```java
package x.ui;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RemoteViews.RemoteView;

/**
 * A layout that lets you specify exact locations (x/y coordinates) of its
 * children. Absolute layouts are less flexible and harder to maintain than
 * other types of layouts without absolute positioning.
 *
 * Re-added to library because I needed to use it without risk of older systems
 * not supporting it.
 */
public class XUIAbsoluteLayout extends ViewGroup
{
	private int mPaddingLeft, mPaddingRight, mPaddingTop, mPaddingBottom;

	public XUIAbsoluteLayout(Context context)
	{
		super(context);
	}

	public XUIAbsoluteLayout(Context context, AttributeSet attrs)
	{
		super(context, attrs);
	}

	public XUIAbsoluteLayout(Context context, AttributeSet attrs, int defStyle)
	{
		super(context, attrs, defStyle);
	}

	@Override protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec)
	{
		int count = getChildCount();

		int maxHeight = 0;
		int maxWidth = 0;

		// Find out how big everyone wants to be
		measureChildren(widthMeasureSpec, heightMeasureSpec);

		// Find rightmost and bottom-most child
		for (int childIndex = 0; childIndex < count; childIndex++)
		{
			View child = getChildAt(childIndex);
			if (child.getVisibility() != GONE)
			{
				int childRight;
				int childBottom;

				XUIAbsoluteLayout.LayoutParams lp = (XUIAbsoluteLayout.LayoutParams)child.getLayoutParams();

				childRight = lp.x + child.getMeasuredWidth();
				childBottom = lp.y + child.getMeasuredHeight();

				maxWidth = Math.max(maxWidth, childRight);
				maxHeight = Math.max(maxHeight, childBottom);
			}
		}

		// Account for padding too
		maxWidth += mPaddingLeft + mPaddingRight;
		maxHeight += mPaddingTop + mPaddingBottom;

		// Check against minimum height and width
		maxHeight = Math.max(maxHeight, getSuggestedMinimumHeight());
		maxWidth = Math.max(maxWidth, getSuggestedMinimumWidth());

		setMeasuredDimension(resolveSize(maxWidth, widthMeasureSpec), resolveSize(maxHeight, heightMeasureSpec));
	}

	/**
	 * Returns a set of layout parameters with a width of
	 * {@link android.view.ViewGroup.LayoutParams#WRAP_CONTENT}, a height of
	 * {@link android.view.ViewGroup.LayoutParams#WRAP_CONTENT} and with the
	 * coordinates (0, 0).
	 */
	@Override protected ViewGroup.LayoutParams generateDefaultLayoutParams()
	{
		return new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT, 0, 0);
	}

	@Override protected void onLayout(boolean changed, int l, int t, int r, int b)
	{
		int count = getChildCount();

		for (int childIndex = 0; childIndex < count; childIndex++)
		{
			View child = getChildAt(childIndex);
			if (child.getVisibility() != GONE)
			{
				XUIAbsoluteLayout.LayoutParams lp = (XUIAbsoluteLayout.LayoutParams)child.getLayoutParams();

				int childLeft = mPaddingLeft + lp.x;
				int childTop = mPaddingTop + lp.y;
				child.layout(childLeft, childTop, childLeft + child.getMeasuredWidth(), childTop + child.getMeasuredHeight());
			}
		}
	}

	@Override public ViewGroup.LayoutParams generateLayoutParams(AttributeSet attrs)
	{
		return new XUIAbsoluteLayout.LayoutParams(getContext(), attrs);
	}

	// Override to allow type-checking of LayoutParams.
	@Override protected boolean checkLayoutParams(ViewGroup.LayoutParams p)
	{
		return p instanceof XUIAbsoluteLayout.LayoutParams;
	}

	@Override protected ViewGroup.LayoutParams generateLayoutParams(ViewGroup.LayoutParams p)
	{
		return new LayoutParams(p);
	}

	/**
	 * Per-child layout information associated with AbsoluteLayout. See
	 * {@link android.R.styleable#AbsoluteLayout_Layout Absolute Layout
	 * Attributes} for a list of all child view attributes that this class
	 * supports.
	 */
	public static class LayoutParams extends ViewGroup.LayoutParams
	{
		/**
		 * The horizontal, or X, location of the child within the view group.
		 */
		public int x;

		/**
		 * The vertical, or Y, location of the child within the view group.
		 */
		public int y;

		/**
		 * Creates a new set of layout parameters with the specified width,
		 * height and location.
		 *
		 * @param width The width, either {@link #MATCH_PARENT}, {@link #WRAP_CONTENT} or a fixed size in pixels
		 * @param height The height, either {@link #MATCH_PARENT}, {@link #WRAP_CONTENT} or a fixed size in pixels
		 * @param x The X location of the child
		 * @param y The Y location of the child
		 */
		public LayoutParams(int width, int height, int x, int y)
		{
			super(width, height);
			this.x = x;
			this.y = y;
		}

		/**
		 * Creates a new set of layout parameters. The values are extracted from
		 * the supplied attributes set and context. The XML attributes mapped to
		 * this set of layout parameters are:
		 * <ul>
		 * <li><code>layout_x</code>: the X location of the child</li>
		 * <li><code>layout_y</code>: the Y location of the child</li>
		 * <li>All the XML attributes from
		 * {@link android.view.ViewGroup.LayoutParams}</li>
		 * </ul>
		 *
		 * @param c The application environment
		 * @param attrs The set of attributes fom which to extract the layout  parameters values
		 */
		public LayoutParams(Context c, AttributeSet attrs)
		{
			super(c, attrs);
			TypedArray a = c.obtainStyledAttributes(attrs, R.styleable.XUIAbsoluteLayout_Layout);
            x = a.getDimensionPixelOffset(R.styleable.XUIAbsoluteLayout_Layout_layout_x, 0);
            y = a.getDimensionPixelOffset(R.styleable.XUIAbsoluteLayout_Layout_layout_y, 0);
            a.recycle();
		}

		/**
		 * {@inheritDoc}
		 */
		public LayoutParams(ViewGroup.LayoutParams source)
		{
			super(source);
		}
	}
}
```

The layout itself is pretty straight forward with how the view needs to layout it’s children and what ever, but the important part is the LayoutParams.

There is a static class within the source for the LayoutParams which contains the place holders for the X and Y values. This is the class that is used in code and in XML.

Inside this class the main method that handles the magic is the constructor

```java
public LayoutParams(Context c, AttributeSet attrs)
{
	super(c, attrs);
	TypedArray a = c.obtainStyledAttributes(attrs, R.styleable.XUIAbsoluteLayout_Layout);
	x = a.getDimensionPixelOffset(R.styleable.XUIAbsoluteLayout_Layout_layout_x, 0);
	y = a.getDimensionPixelOffset(R.styleable.XUIAbsoluteLayout_Layout_layout_y, 0);
	a.recycle();
}
```

Here we’re basically getting our custom values (layout_x, layout_y) from our attr list and assigning them to our values. These references MUST end in the name you want your custom attribute to be, for instance if you wanted layout_visibility you would use XUIAbsoluteLayout_Layout_layout_visibility.

Here is the XML for the attribute list:

```xml
<declare-styleable name="XUIAbsoluteLayout_Layout">
       <attr name="layout_x" format="dimension" />
       <attr name="layout_y" format="dimension" />
</declare-styleable>
```

And that’s all there is too it.