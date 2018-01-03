If you're a heavy Android developer (or have used AsyncTasks and Dialogs before) then you'll know the pains of trying to make AsyncTasks and Dialogs work properly when the user changes orientation in an Activity/Fragment.

I've had this issue for quite some time and I (think) i've come up with an elegant solution based on a few different suggestions.

**Note: This is not *perfect* and probably could be optimised, but it does work**

You can find the sources on GitHub [here](https://github.com/scruffyfox/AsyncAttachmentTest)


## The problem

The problem with AsyncTask is not necessarily the task, because it runs in the background asynchronously to the activity, the problem is when you want to update the UI, maybe you've got an AsyncTask for an [AsyncHttpClient](https://github.com/scruffyfox/AsyncHttpClient) and want to update a list Adapter when the response finishes, and the user changes orientation. Because of the nature of Android, the Activity is destroyed and recreated which means the response will no longer have any reference to the activity to be able to update the UI anymore (this will be the same issue as with Fragments)

## The solution

The solution i've found is to keep an inner reference to the Activity/Fragment in the task and attach/detach it when the activity is created/destroyed (as seen in CommonsWare's solution [here](http://stackoverflow.com/questions/3821423/background-task-progress-dialog-orientation-change-is-there-any-100-working/3821998#3821998)) The issue with his solution is it doesn't really apply for Fragments and the retain instance methods are deprecated.

What I do is, I have a singleton helper class which keeps a static WeakReference to all of the tasks created. This is used to set/get the tasks when the Activity/Fragment is destroyed and recreated so you can re-attach the context.

```java
package net.callumtaylor.asynctest;

import java.lang.ref.WeakReference;
import java.util.WeakHashMap;

import android.app.Activity;

public class TaskHelper
{
	public final HashMap<String, WeakReference<Task>> tasks = new HashMap<String, WeakReference<Task>>();
	private static TaskHelper instance;

	public static TaskHelper getInstance()
	{
		if (instance == null)
		{
			synchronized (TaskHelper.class)
			{
				if (instance == null)
				{
					instance = new TaskHelper();
				}
			}
		}

		return instance;
	}

	/**
	 * Gets the task from the map of tasks
	 * @param key The key of the task
	 * @return The task, or null
	 */
	public Task getTask(String key)
	{
		return tasks.get(key) == null ? null : tasks.get(key).get();
	}

	/**
	 * Adds a new task to the map
	 * @param key The key
	 * @param response The task
	 */
	public void addTask(String key, Task response)
	{
		addTask(key, response, null);
	}

	/**
	 * Adds a new task to the map and attaches the activity to it
	 * @param key The key
	 * @param response The task
	 * @param o The activity
	 */
	public void addTask(String key, Task response, Activity o)
	{
		detach(key);
		tasks.put(key, new WeakReference<Task>(response));

		if (o != null)
		{
			attach(key, o);
		}
	}

	/**
	 * Removes and detaches the activty from a task
	 * @param key
	 */
	public void removeTask(String key)
	{
		detach(key);
		tasks.remove(key);
	}

	/**
	 * Detaches the activity from a task if it's still available
	 * @param key
	 */
	public void detach(String key)
	{
		if (tasks.containsKey(key) && tasks.get(key) != null && tasks.get(key).get() != null)
		{
			tasks.get(key).get().detach();
		}
	}

	/**
	 * Attaches an activity to a task if its available
	 * @param key The key
	 * @param o The activity
	 */
	public void attach(String key, Activity o)
	{
		Task handler = getTask(key);
		if (handler != null)
		{
			handler.attach(o);
		}
	}
}
```

I then create a reference in the task to this Activity/Fragment which I then use in the postExecute method to update any UI elements.

```java
package net.callumtaylor.asynctest;

import android.app.Activity;
import android.os.AsyncTask;

public class Task extends AsyncTask<Void, Integer, Void>
{
	private MainActivity activity;
	
	@Override protected Void doInBackground(Void... params)
	{
		return null;
	}

	@Override protected void onProgressUpdate(Integer... values)
	{
		super.onProgressUpdate(values);

		// update the progress
		progressDialog.setProgress(activity.getFragmentManager(), values[0]);
	}

	@Override protected void onPostExecute(Void result)
	{
		super.onPostExecute(result);

		if (activity != null)
		{
			// reference UI updates using activity
			activity.updateUI();
		}

		// IMPORTANT: remove the reference
		TaskHelper.getInstance().removeTask("task");
	}

	/**
	 * Attaches an activity to the task
	 * @param a The activity to attach
	 */
	public void attach(Activity a)
	{
		this.activity = (MainActivity)a;
	}

	/**
	 * Removes the activity from the task
	 */
	public void detach()
	{
		this.activity = null;
	}
}
```

In the Activity when the task is created, you create and set the task in the helper

```java
// start the task
Task t = new Task();
TaskHelper.getInstance().addTask("task", t, (Activity)this);
t.execute();
```

And in the `onDestory`, `onCreate` methods, you re-attach and detach the activity from the task

```java
@Override protected void onCreate(Bundle savedInstanceState)
{
	super.onCreate(savedInstanceState);
	
	// re-attach the activity if the task is still available
	TaskHelper.getInstance().attach("task", this);
}

@Override protected void onDestroy()
{
	super.onDestroy();

	// detach the activity so we dont leak
	TaskHelper.getInstance().detach("task");
}
```

## Progress dialog fragment

In the example repository, there is a custom dialog Fragment which is used as well. 

Instead of creating the progress dialog in the Activity, it is created in the task using the attached Activity

```java
private ProgressDialogFragment progressDialog;

@Override protected void onPreExecute()
{
	super.onPreExecute();

	// create the dialog and attach it to the fragment manager
	progressDialog = new ProgressDialogFragment.Builder()
		.setMessage("Working...")
		.build();
	progressDialog.show(activity.getFragmentManager(), "task_progress");
}
```

This is a fairly standard way of creating the dialog. The issue comes when updating the progress and ultimately dismissing the dialog.

You can't simply call `progressDialog.dismiss()` because when the orientation is changed, the underlining FragmentManager in the fragment dialog is now null as it was referenced to the old Activity which is now destroyed, instead we need to re-bind the dialog from the FragmentManager of the new Activity. You could do this in the `attach(Activity a)` method, but instead I created 2 new methods in the fragment dialog to handle it properly.

```java
/**
 * Sets the progress of the dialog, we need to make sure we get the right dialog reference here
 * which is why we obtain the dialog fragment manually from the fragment manager
 * @param manager
 * @param progress
 */
public void setProgress(FragmentManager manager, int progress)
{
	ProgressDialogFragment dialog = (ProgressDialogFragment)manager.findFragmentByTag(dialogTag);
	if (dialog != null)
	{
		((ProgressDialog)dialog.getDialog()).setProgress(progress);
	}
}

/**
 * Dismisses the dialog from the fragment manager. We need to make sure we get the right dialog reference
 * here which is why we obtain the dialog fragment manually from the fragment manager
 * @param manager
 */
public void dismiss(FragmentManager manager)
{
	ProgressDialogFragment dialog = (ProgressDialogFragment)manager.findFragmentByTag(dialogTag);
	if (dialog != null)
	{
		dialog.dismiss();
	}
}
```

Here you pass the FragmentManager from the Activity in the task, and you find it by the original tag which was set using the `show(FragmentManager manager, String tag)` method.
