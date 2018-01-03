This one took me a while to figgure out.

To make a SurfaceView transparent so you can draw lovely overlays on top of your app layout, you need to set the ZOrderOnTop to true and the format to transparent using

```java
setZOrderOnTop(true);
getHolder().setFormat(PixelFormat.TRANSPARENT);
```

Now the view will be transparent.

Sources:
http://stackoverflow.com/questions/5391089/how-to-make-surfaceview-transparent