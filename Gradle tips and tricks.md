Gradle is a pretty good tool, especially now that its pretty much mandatory. But it seems like there's a lot of hidden features/lack of documentation, especially when it comes to things like white labelling an app or executing external scripts, even the syntax can be quite confusing if you've never used Groovy before.

Here is a list of really cool tips and tricks I've picked up over the last few years of using Android Studio and Gradle.

## Tip #1 - Using Console for input values

It's really bad to have hard coded passwords/keystore paths in your code, especially if you're working on an open source piece of code, so one thing I do to get around this is to use environment variables and Console input.

### Using the console

Simply define a console variable at the top of your build gradle 

```java
def console = System.console();
```

and now you can call `console.readLine("Enter your password: ").trim()` to read input via the command line.

The downside to this is that console *can* be null, especially if you're launching from Android Studio, so make sure you do your null checks.

### Using Environment variables

If you dont want to type in your password each time, you can always use environment variables (stored in your bash_profile file)

Simple call `System.getenv("PASSWORD")` to access system environment variables. Make sure to `source ~/.bash_profile` after editing it so your variables are properly refreshed into system

## Tip #2 - Flag variables

There are a lot of projects I work on that are white label (meaning the same code base but built with different build variables for different clients), I used to manage this by having a separate flavour of the app for each client, but as client base grew, this became more and more unmanageable, so instead I use flags when calling `./gradlew assembleRelease` to define variables for the build.

You can define a closure at the top of your build gradle like so

```java
def getAppId = { ->
	def id = project.hasProperty('appId') ? appId.toString() : null

	if (id == null)
	{
		// default app id
		id = "1"
	}

	println "App id is set to $id"

	return id
}
```

This will look for the `-P` flag "appId" when running the assemble command. You can access this simply by calling `getAppId()` anywhere in your build gradle (example `./gradlew assembleRelease -PappId=1`.

## Tip #3 - Build Config fields

You may want to dynamically set variables for a particular flavour of your app (for example a boolean for if the app is free or paid) and it's quite simple.

In your flavour block add the line

```java
buildConfigField "String", "APP_ID", "\"123abc\""
```

As you can see the first parameter is the type, the second is the variable name, and the third is the value. Make sure you wrap Strings in escaped quotes else it will put the text in as-is and will generate a compile error.

You can now access this variable by calling `BuildConfig.APP_ID` from anywhere in your code.

## Tip #4 - Res config fields

Similar to build config, you can define variables to be generated for res values in the same way, very useful if you need to dynamically change variables that are only loaded from XML resources such as Google Analytics.

In your flavour block (or defaultConfig) add the line

```java
resValue "string", "ga_trackingId", "test"
```

As you can see the first parameter is the type, the second is the variable name, and the third is the value.

## Tip #5 - Manifest merger

Now this is a cool little piece of functionality that is well hidden in the documentation. This basically allows you to inject variables into your manifest, and is actually used behind the scenes for `applicationId`.

This is particularly useful for resources that are only loaded via the AndroidManifest.xml file such as google maps API key, or app name

in your flavour block (or default config) add the line

```java
manifestPlaceholders = [
	MAPS_TOKEN : "not_a_maps_token",
	APP_NAME : "my app",
]
```

`manifestPlaceholders` is a reserved array name that accepts a key value pairing (separated by colon). You can access these variables in your manifest by calling `${MAPS_TOKEN}` for example 

```xml
<meta-data
	android:name="com.google.android.maps.v2.API_KEY"
	android:value="${MAPS_TOKEN}"
/>
```

## Tip #6 - Check for release call

Sometimes you only want to do the above when you're actually making a release build and not during debug (adding a call to load signing key file will be called every time you run the app), this can be incredibly annoying and prevent you from actually running debug code, one way I've found to circumvent this is to add a check to ensure that `release` isn't being called

```java
def isRelease()
{
	for (String taskName : project.getGradle().startParameter.taskNames)
	{
		if (taskName.toLowerCase().contains("release"))
		{
			return true
		}
	}

	return false
}
```

This is a simple method that loops through the tasks being called to check if the keyword `release` is present, if not then its safe to assume that its a debug development build being run from the IDE.

Here's an example of it being used

```java
signingConfigs {
	main {
		if (isRelease())
		{
			storeFile getKeystoreFile()
			storePassword getKeystorePassword()
			keyAlias = getKeyAlias()
			keyPassword = getKeyPassword()
		}
	}
}
```

Without the `isRelease` call, the store methods will be called which in turn will prompt for input, even though I'm not making a release build. Note: you shouldn't need to use this unless you have the same multi-flavour setup I used to have.
