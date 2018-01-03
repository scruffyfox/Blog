Lombok is a fantastic Java library I found over the weekend when I got fed up of having to write getters/setters every time I added a new variable to my object models. (Yes I know Eclipse can do it automatically, but there is still a level of abstraction and maintainence when you change things).

Essentially what it does is 'automatically' creates getters and setters using annotations.

Although it doesnt *actually* create phsyical code, it works by generating the javadoc for it at compile time so Eclipse thinks a method exsits when it doesnt, and then when you compile your app, it inserts the right byte code to handle it.

Changes this:

```java
public class User
{
	private String username;
	private String userId;
	
	public void setUsername(String uname)
	{
		username = uname;
	}
	
	public String getUsername()
	{
		return username;
	}
	
	public void setId(String id)
	{
		userId = id;
	}
	
	public String getId()
	{
		return userId;
	}
}
```

Into this:

```java
public class User
{
	@Getter @Setter private String username;
	@Getter @Setter private String userId;
}
```

And if you have models with tens of properties, you can imagine how much time/code you are saving.

To install it, head over to [http://projectlombok.org/](http://projectlombok.org/) and download the jar.

Execute the jar and it'll prompt you to select your Eclipse installation, so browse for Eclipse.exe (or Eclipse.app if you're on mac) and hit ok. It'll install a library and edit your Eclipse.ini file.

Next open up command line and execute `java -jar lombok.jar publicApi` This will create `lombok-api.jar`.

Include this jar in your android projects and voila, you can now use the annotations.

The only downside to this is, you can't prefix your members else the getters/setters end up like `getMuserName() and setMuserName()` The way I got around this was to use normal names, and in code always refer to them using `this.` or you could just use the getter/setter.

Note: With `boolean`s, the getters change from `get` to `is`, but if you use the class `Boolean` (capital B), it'll fallback to using `get` (so make sure you name your boolean's right!)