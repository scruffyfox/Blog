It's been 8 months since I stopped development on Robin (you can read about it [here](https://github.com/scruffyfox/Robin-Blog/blob/master/public/posts/End%20of%20an%20Era.md)). I have always wanted to open source the app code, but due to bad git practices, couldn't simply push to GitHub, so instead had to strip out certain parts of the source (passwords/api keys etc) in order to do so. I also wanted to wait a few months before doing so to make sure that there was no chance that I would want to continue development on the app.

The project was super fun to work on and I learned so much, it was such a shame that it didn't work out, but maybe someone will get some good use, or even learn a thing or two, from the codebase.

Some notable mentions in the source code that I'm particularly proud of

1. [Spannable texts](https://github.com/scruffyfox/Robin-Client/tree/master/v2%20client/Robin/src/main/java/in/lib/view/spannable). This was SUPER hard to get right, it basically allows mentions, hashtags, markdown links, etc to be clickable independently in a `TextView`
2. [Code utils](https://github.com/scruffyfox/Robin-Client/blob/master/v2%20client/Robin/src/main/java/in/lib/utils/CodeUtils.java). This was used for the 'custom display name' feature in settings that basically allowed you to customise, to a code level, how usernames are displayed in your feed. This can easily be expanded for dates, post text, etc.
3. [Text Entities](https://github.com/scruffyfox/Robin-Client/tree/master/v2%20client/Robin/src/main/java/in/data/entity). Used for processing mentions, hashtags, and 'post emphasis' allowing text like `**hello**` to be translated into **hello**
4. [The whole adapter system](https://github.com/scruffyfox/Robin-Client/tree/master/v2%20client/Robin/src/main/java/in/controller/adapter). Due to the awesomeness of the App.net API, all the streams were very similar and allowed me to create a single generic adapter which *every* section in the app can use. It also uses a `delegate` style adapter system, outlined in [this blog post](http://antoine-merle.com/blog/2013/06/11/making-a-multiple-view-type-adapter-with-annotations/)
5. [The theming](https://github.com/scruffyfox/Robin-Client/blob/master/v2%20client/Robin/src/main/res/values/themes.xml). Theming is difficult in Android. I made it nice in Robin.

# Links

### Robin blog

Blog rails app for robinapp.net - https://github.com/scruffyfox/Robin-Blog

### Robin client

Android client for app.net called Robin — https://github.com/scruffyfox/Robin-Client

### Robin translation parser

Simple TSV to Strings.xml resource parser - https://github.com/scruffyfox/Robin-TranslationParser

### Robin notification API

Rails API for the app to store notification data into a database for the notification worker - https://github.com/scruffyfox/Robin-NotificationAPI

### Robin notification server

Simple applet that runs on UNIX based servers that uses App.net streaming API and sends push notifications to GCM - https://github.com/scruffyfox/Robin-NotificationWorker

# Footnotes

All projects are GPG signed with my key `60E6 C1E5 939A 8BAD`

It was great working on this project, and so many thanks to all the people that helped along the way, (noteably [Romain Piel](http://romainpiel.com/) and [Damian Gribben](https://twitter.com/simpleline)), those in the beta, giving feedback, sending me beer money (I really did need it at the time to get me through the day), and those who bought the app!

This does mean, however, that the notification server **will** be shutdown, sorry, no more notifications!