Having to draw shapes on a `MapView` is quite a common thing to do, it's extremely simple, but not obvious to do.

Firstly we need to create our custom drawing class that overrides `Overlay`. When we subclass `Overlay` we have the ability to override the draw method which we will use to draw our shapes.

```java
public class CircleOverlay extends Overlay
{
	private double mLat, mLng;
	private float mRadius = 0.0;
	public CircleOverlay(double lat double lng, float radius)
	{
		mLat = lat;
		mLng = lng;
		mRadius = radius;
	}
	
	@Override public void draw(Canvas canvas, MapView map, boolean shadow)
	{
		Paint p = new Paint();
		p.setColor(0xffff0000);
		
		// we need to map the lat and lng to pixels on the canvas
		GeoPoint point = new GeoPoint((int)(lat * 1E6), (int)(lng * 1E6));
		Point mapCenter = new Point();
		map.getProjection().toPixels(point, mapCenter);
		
		// map the radius to pixels on the canvas
		float circleRadius = map.getProjection().metersToEquatorPixels(mRadius);
		
		// now we can draw the circle
		canvas.drawCircle(mapCenter.x, mapCenter.y, circleRadius, p);
	}
}
```

And that's it. If we want to be efficient and only draw the circle if the point is in view we can use `canvas.getClipBounds.contains()`

```java
if (circleRadius < 5 || !canvas.getClipBounds().contains(new Rect(mapCenter.x, mapCenter.y, mapCenter.x, mapCenter.y))) return;
```

Although this will only work for the center of the circle.

Now we just add it as an overlay in the map

```java
mMapView.getOverlays().add(new CircleOverlay(0, 0, 1500.0));
```