This is a short tutorial on how to use the Tab system in X Library.

I’ve never really used the standard Android tabbing system because its shit. So instead I created my own.

Firstly in the XML layout we need to define our Tab Host. This will be the container for the tabs of the view. We also need to create a place holder for the views in each tab.

```xml
<!-- Tab Host -->
<x.ui.XUITabHost
	android:layout_width="fill_parent"
	android:layout_height="46dp"
	android:background="@drawable/tabbar_drawable"
	x:targetContainer="@+id/content_view"
	android:id="@+id/tab_host"
/>	

<!-- Content View -->
<RelativeLayout
	android:layout_width="fill_parent"
	android:layout_height="fill_parent"
	android:id="@+id/content_view"
/>
```

Don’t forget to bind the namespace x in the top of your layout file. For example if your package name is com.cube.tsc, you would put

```xml
xmlns:x="http://schemas.android.com/apk/res/com.cube.tsc"
```

Now we have the necessary layout elements, in the code we need to add some tabs.

Firstly you need to extend your class with XUITabActivity. Next you need to setup the tabs by getting the tabhost and calling setup.

```java
//	Set up the tabs
XUITabHost tabHost = (XUITabHost)findViewById(R.id.tab_host);
tabHost.setup(getLocalActivityManager());
```

Now we add the tabs. You need to create an instance of XUITabParams for the settings of the tab. This includes things like tab text, the activity to load when the tab is clicked etc.

```java
XUITabParams tabParams = new XUITabParams();
tabParams.tabIcon.selected = (Bitmap)bg;
tabParams.tabIcon.deselected = (Bitmap)bg;
tabParams.layoutParams.width = tabWidth;
tabParams.iconLayoutParams.leftMargin = 0;
tabParams.layoutParams.leftMargin = 0;
tabParams.tabBackground.deselected = new BitmapDrawable(tabBackgrounds.deselected);
tabParams.tabBackground.selected = new BitmapDrawable(tabBackgrounds.selected);
tabParams.intent = new Intent(this, NewActivity.class);
tabParams.intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);

XUITab tab = new XUITab(this);
tabHost.addTab(tab, tabParams);
```