Over the weekend, I decided to re-write the notification system to ensure its scalability and efficiency. I decided to do it using proper Rails conventions and models rather than the hack job I had done previously.

Before, the database consisted of one table `users` for all the devices and users. This was fine for single users/devices but then we wanted to scale for mulitple devices per user, and now we want to scale even more and have multiple users per device.

`users`

`Device ID`	| `User ID`	| `Push ID`	| `Access Token`	| `Last mention ID`	| `Disabled`	| `Follow only`

This is a really messy way of doing it, and isnt in any way relation.

Now I use 2 tables, one for users, and one for devices.

`users`

`ID`	| `Access Token`	| `Last mention ID`

`devices`

`ID`	| `User ID`	| `Push ID`	| `Enabled`

### API

The API uses the Rails framework, mainly because I like Rails, and needed a new project to work on, also it's extremely nice when it comes to MVC.

The way notifications works is, 

1. Devices use the API to register their push IDs and user IDs
2. The server hosing the API runs a CRON task every 60 seconds to execute a RAKE task
3. The rake task loads all users with valid devices (count > 0 && enabled = true)
4. The rake initiates a new Iron.io worker for every 200 users
5. The user worker checks the user's last mention, if there's a new mention, it sends a notification

The worker also catches any invalidations such as the user uninstalls the app or the notification failed by deleting the row from the database.

The guys over at [Iron.io](http://iron.io) were extremely helpful in setting it up and working out costings. We currently have 180 users which means 180 tasks get executed every minute. Each task takes betweek 0-2seconds each to run which equates to roughly 180 seconds of computation time per minute (their servers handle load balance so it's perfect for scaling). Per month, that will cost around $100. I have recently changed the script slightly to run batches of 200 users per task instead of one per user. I ran a test with 1327 rows which took 52 seconds of computation time (7 workers for 200 users) compared to (scaled up) 1327 seconds (1327 workers for 1327 users). $31/mo compared to (scaled) $807/mo is a massive saving on costs and usage, but a shame I had to break the nice abstraction of 1 user 1 task (highly disadvised anyway).

### Iron.io

You can sign up for 15 free hours of computing time (5hr free a mo + 10 free hours for completing the tutorial) over at [http://iron.io](http://iron.io), its free and doesnt require any payments. It's a great service because you only pay for the time you use in terms of processing which works perfectly, and also forces you to optimise your scripts above and beyond (like they say, time is money)

The whole project is free to use/distribute and open source over at [GitHub](https://github.com/scruffyfox/robin-notifications)

### Aditional notes

This is my third(?) Rails application, i've tried my best. Any optimisations/changes you want to add to make it better, feel free to send a pull request

### Related Links

1. [Iron.io](http://iron.io)
2. [Building a Platform API on Rails](http://blog.gomiso.com/2011/06/27/building-a-platform-api-on-rails/)
3. [Robin Notifications](https://github.com/scruffyfox/robin-notifications)
4. [Robin App for App.net](http://getrob.in)


### Edits

**Edit 1**: As pointed out, the cost of these tasks are $100, not $3 a month. Because of this, I am currently looking into changing the way the tasks are created to have a distributed set of workers executing a list of users in a thread rather than a single task for each user (as discourraged by Iron.io anyway) which should cut costs down considerably.

The reason it's more expensive is because its currently using 1 second of computation time * 180 users (3 minutes of processing every minute). The new way could be as little as 0-5 seconds per minute. Will update when tested and committed.

**Edit 2**: Updated article for new task pattern and threadding