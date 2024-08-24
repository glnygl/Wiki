# Places
- Fetch locations (async/await)
- List locations
- Create url with location and scheme 
- Redirect to Wikipedia App when tab a location (or type a new custom location)
- Localize hard coded strings
- UnitTests
- Accessibility

# Wikipedia
- Fetch redirectURl in SceneDelegate
- Get queryItems from Url
- Redirect location with openURLWithRegion func 

📌 If app is terminated we should resume the app to loadUI. After resume app redirect selected location. If app status is in background or active no need to resume. 

 > In openURLWithRegions func: 

```
Get query items and call showPlaces func 
Select places tab
Pop navigation controllers,
Dismis other controllers (in case user select filter, share then redirect)
Set viewMode to map (in case select another viewMode)
Cancel search (in case user typed a location text)
Set new location
```
📌 If mapView not loaded (user didn't select places tab yet, I checked mapView status in setLocation func set redirectLocation and then modified zoomAndPanMapView func according to new location

Normally, we can redirect a link with openURL func using user activity. To process this activity we should have spesific articleURL for each location as wmf_linkURL. But we dont have a articleURL so I coded a new func. 

E.g. : WMFArticleURL=https://en.wikipedia.org/wiki/Union_Square,_San_Francisco?wprov=sfti1
