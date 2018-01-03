I've had this problem crop up a lot for "ZTE" devices where it would try to open a database stored in the databases folder "data/data/packagename/databases" and would crash because it 'attempt to write a readonly database" and it turns it its due to a bug in the device's OS where it opens the database, tries to write to it and fails. Even if you use SQLiteDatabase.OPEN_READONLY. 

To fix this we literally only have to open the database as READWRITE instead which allows the device to do what ever without failing.

Annoying as it seems, it fixes the issue.

[Source: http://code.google.com/p/android/issues/detail?id=20341](http://code.google.com/p/android/issues/detail?id=20341)