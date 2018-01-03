This is a really cool way to have a singleton class in your application which any activity can have access to. This is particually useful for if you have a single class that needs to be accessed by every sub activity.

Firstly you create a new class and extend Application in it. Here you can put all of the members you want to be golbally accessed.

Next, in your AndroidManifest.xml file, add the application name to your application tag. For example:

```xml
<application
	android:icon="@drawable/icon"
	android:label="@string/app_name"
	android:theme="@style/no_frame"
	android:name=".MyApplicationClassName"
>
```

Then in your child activities you can access it via the getApplication method.

An example of this is if you wanted say a string with a secret password that every activity needs access to. We create our application class.

```java
import android.app.Application;

public class MyApplication extends Application
{
	public String mySecretPassword = "HelloWorld";
}
```

Now in our child classes we access it

```java
((MyApplication)getApplication()).mySecretPassword;
```

Thanks to [Dark-Side](https://plus.google.com/103712551745434839608) for pointing this useful feature out to me.

[Link to the Application Documentation](http://developer.android.com/reference/android/app/Application.html)