List views are a massive ball ache to get working properly and efficiently. I’ve spent my fair share of time trying to find the most efficient and best way to render out data into a list view, and here’s the bast way I found.

List Views are a weird type of view, they contain cells (obviously) for the data, but when you scroll, these cells get re-used in the view to save up on that low amount of heap-space your app gets allocated and if don’t handle this properly, you could get duplicate views by mistake.

Firstly when you create a list view layout you need to create a list view (duh). But this isn’t as straight forward. For example you have to use the id "@android:id/list".

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout
	xmlns:android="http://schemas.android.com/apk/res/android"
 	android:orientation="vertical"
	android:layout_width="fill_parent"
	android:layout_height="fill_parent"
	android:background="#D6CABE"
>
    <ListView
    	android:background="#D6CABE"
    	android:id="@android:id/list"
    	android:layout_width="fill_parent"
    	android:layout_height="fill_parent"
    	android:dividerHeight="0px"
    	android:divider="@null"
    	android:fadingEdge="none"
    	android:headerDividersEnabled="false"
    />

</LinearLayout>
```

Here is an example XML layout for a list view.

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout
	xmlns:android="http://schemas.android.com/apk/res/android"
	android:layout_width="fill_parent"
	android:layout_height="wrap_content"
	android:background="@drawable/listitem_drawable"
	android:orientation="horizontal"
>
	<FrameLayout
		android:layout_width="fill_parent"
		android:layout_height="wrap_content"
	>
		<LinearLayout
			android:layout_width="fill_parent"
			android:layout_height="wrap_content"
			android:orientation="horizontal"
			android:padding="10dp"
		>
		    <ImageView
		   		android:layout_width="wrap_content"
		   		android:layout_height="wrap_content"
		   		android:id="@+id/avatar"
		   	/>

		   	<LinearLayout
		   		android:layout_width="wrap_content"
		   		android:layout_height="wrap_content"
		   		android:orientation="vertical"
		   		android:paddingLeft="10dp"
		   		android:layout_marginTop="-5dp"
		   	>
		   		<TextView
		   			android:layout_width="wrap_content"
		   			android:layout_height="wrap_content"
		   			android:id="@+id/title"
		   			style="@style/listitem_title"
		   		/>
		   		<TextView
		   			android:layout_width="wrap_content"
		   			android:layout_height="wrap_content"
		   			android:id="@+id/link"
		   			android:singleLine="false"
		   			android:layout_marginTop="5dp"
		   			style="@style/listitem_link"

		   		/>
		   	</LinearLayout>
		</LinearLayout>
	</FrameLayout>
</LinearLayout>
```

Here is the list item XML. This is the view we will inflate for each row in the list view.
That’s the easy bit. Now the hard bit.
The hardest bit is inflating the view with the data you want. Firstly you extend ListActivity instead of Activity

```java
package your_package_name;

import android.app.ListActivity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class myListView extends ListActivity
{
	public DataMap[] dataObjects;
	protected LayoutInflater mLayoutInflater;
	protected Context mContext = this;

	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);

		setContentView(R.layout.home_list_view);

		mLayoutInflater = (LayoutInflater)getSystemService(Context.LAYOUT_INFLATER_SERVICE);

		dataObjects = new DataMap[]
		{
			new DataMap("Callum Taylor", 20),
			new DataMap("Phillip Caudell", 15),
			new DataMap("Callum Taylor", 1),
			new DataMap("Phillip Caudell", 20),
			new DataMap("Callum Taylor", 56),
			new DataMap("Phillip Caudell", 99999999)
		};

		setListAdapter(new ListViewAdapter(this, R.layout.home_list_view_list_item, dataObjects));
	}

	final class ListViewAdapter extends ArrayAdapter<DataMap>
	{
		private int layoutResource;
		public ListViewAdapter(Context context, int resource, DataMap[] objects)
		{
			super(context, resource, objects);
			layoutResource = resource;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent)
		{
			if (convertView == null)
			{
				convertView = mLayoutInflater.inflate(layoutResource, null, false);
			}

			DataMap data = dataObjects[position];

			TextView t = (TextView)convertView.findViewById(R.id.title);
			t.setText("" + data.contactName);

			TextView link = (TextView)convertView.findViewById(R.id.link);
			link.setText(data.followerCount + " followers");

			ImageView avatar = (ImageView)convertView.findViewById(R.id.avatar);
			avatar.setBackgroundResource(R.drawable.user_avatar);

			return convertView;
		}
	}

	final class DataMap
	{
		public String contactName = "";
		public int followerCount;

		public DataMap(String contactName, int followerCount)
		{
			this.contactName = contactName;
			this.followerCount = followerCount;
		}
	}
}
```

Basically all that’s going on here is that we create a class (DataMap) as a holder for our data, that way we can reference it properly in our array adapter. We create an array of the data we want to be displayed and pass it to our array adapter. This is where the processing starts.
We override the ArrayAdapter class so we can pass our custom data map to it. Inside this we override the "getView" function which allows us to inflate our custom XML view and put in our data. Here we have to check if “convertView” is null. If it is, that means its a new view, if not, then that means its a reused view.
If its null, we need to create a view by inflating our XML layout.
Now after we’ve done that we get our DataMap value from the "(DataMap)getPosition(int)" or if we declare it as public (in this case we have) we can reference it directly, and we find our views within convertView, and assign the data to it. Then we return convert view from the method.
That’s essentially it! Not that hard really.

