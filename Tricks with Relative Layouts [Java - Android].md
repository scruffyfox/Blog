There's some pretty neat stuff you can do with Relative Layouts which are really useful, but not obvious.

You may have seen in apps a chevron (>) or something on the right side of a text view or container and you think, how do they make the container 100% width, but still leave enough space on the right for the chevron?

Here is a neat ASCII diagram of what I mean

```
╔═════════════════════════════╗
║ ╔══════════════════╗ ╔════╗ ║
║ ║   FILLED WIDTH   ║ ║    ║ ║
║ ╚══════════════════╝ ╚════╝ ║
╚═════════════════════════════╝
```

The way they do it is actually really simple. What we do is, we make the right view first in the relative layout, and the filler second. The filler being the view that will use the rest of the available space on the container.

```xml
<RelativeLayout 
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
>
	<ImageView
		android:layout_width="50dp"
		android:layout_height="50dp"
		android:id="@+id/right_view"
		android:layout_alignParentRight="true"
	/>

	<TextView
		android:layout_width="match_parent"
		android:layout_height="match_parent"
		android:layout_toLeftOf="@id/right_view"
	/>
</RelativeLayout>
```

Here we define the imageview first so we reserve the space needed, we tell the Relative Layout to align that view to the right of the container.

Next we create the text view with `match_parent` width to fill the rest of the space and because its defined after ImageView, naturally it won't be in the right place, so we just tell it to go back to the left of the image.

This works with any direction (left/right/top/bottom)