This cropped up for me in the American Red Cross Disaster series apps where I have a global common library project which references my X-Library which essentially means theres 2 levels library projects. The normal way of declaring a library namespace doesn't work with this. Instead you need to use `res-auto` instead of the package id.

For example:

```xml
xmlns:android="http://schemas.android.com/apk/res/android"
xmlns:x="http://schemas.android.com/apk/res-auto"
```