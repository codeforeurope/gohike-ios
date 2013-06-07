Scavenger App for Code for Europe Amsterdam ( iOS repo )


ScavengerApp (Go Take a Hike!) documentation
============================================


How to build
-------------
* Clone the repository
* Add a file called "secret" containing the secret API Key for the API (not disclosed on GitHub)
* Init and update the submodules with the command 
> git submodule update --init --recursive

That's it. Build and run.

The Tracker for this project is here: https://www.pivotaltracker.com/projects/820375


Important remarks
---------
* Please always use NSLocalizedString when using strings to localize interface (Buttons, labels, etc...).
* Content (description of locations, locations, etc) is (as of now) available in English and Dutch. Which means that the dictionary contains `description_en` and `description_nl` and the `[[AppState sharedInstance] language]` returns the language `nl` if locale of the device is NL or `en` in any other case. So when you call the dictionary Key please keep this in mind.


How the game is played (app flow)
-------
App flow can be viewed at this address: https://www.fluidui.com/editor/live/preview/p_Nl84l6Gh146LMRUMhRKQderUoS8TA5o8.1369861306606

When game starts, a "How to play" screen is displayed. When the user dismisses it, it can still bring it up using the "Help" button (to be implemented). 
The player can choose among a certain number of "PROFILES". Each profile represents a "mood or "theme" of the routes, for example "parks" or "shopping" or "architecture".
When a profile is selected, the player has to choose a ROUTE. A route is a list of WAYPOINTS, that need to be reached in fixed order in order to complete the route and get a REWARD. 
When selected "Go Hike" button, the app shows a compass with an arrow. When player is  close enough to a location, the app asks "Want to check in?". If players checks in, then the location is marked as "visited" and can proceed to the next one.



Content
-------
The app (game) content is stored into the content.json file, which is included in the [NSBundle mainBundle].
When app starts, the app checks if there is a content.json file in the Documents Directory folder. If that is the case, it means that this file has been downloaded after the bundled one, so it is loaded. 
If there is no content.json in the Documents directory, the one included in the bundle is loaded. 
The entire game (included pictures, that are stored in Base64 string encoding) is kept in memory in a NSDictionary.
The game is intended to support content updating via the api which is located at http://gohike.herokuapp.com/api.


Content updating
-------
When app starts, if an internet connection (via Wifi, to avoid the user incurring in extra data download for its data plan) is detected, the app calls the "ping" endpoint of the api (http://gohike.herokuapp.com/api/ping) with a POST request that has the Content-Type set to application/json and sends as parameters the `version` of the content. 
The version is the MD5 checksum of the content.json file, and is stored in the key "version". 
If the versions are different, means that on the server there is a newer one (we always consider the server to be more up to date) and we try to download it.

The content is updated calling the /content endpoint with a GET request without parameters (http://gohike.herokuapp.com/api/content).
The received JSON is saved to disk and stored in content.json, overwriting the previous one. Also, the game content is updated immediately so the player will see changes in real-time. 

As this could break if location IDs change, this has to be tested. 



App State
-------
The AppState is a singleton representing the current state of the application. 
It has few primitive properties (integers) to keep track of the game progress, an array of check-ins that represent the player advancing through the game and a NSDictionary that contains the entire game content.
When the -(void)save method is called, all AppState excluding the game content is saved to disk.
The state is restored at app start with the -(void)restore method.

Due to the fact that we do not store data structures in the AppState, when we need to know the current Route, or current Profile, or a list of checkins with info about them being visited or not,  there are some useful methods for this:

    - (NSDictionary*)activeProfile;
    - (NSDictionary*)activeRoute;
    - (NSDictionary*)activeWaypoint;
    
    - (NSArray*)checkinsForRoute:(int)routeId;
    - (NSDictionary*)routeWithId:(int)routeId;
    - (NSArray*)waypointsWithCheckinsForRoute:(int)routeId;



Players Check-ins
-------
The check-ins of the players are an NSArray stored in the AppState. They are uploaded to the server (no personal data is sent) 


Styling
-------
App has a flat, consistent and professional looking style. However, we don't have to forget that it's a game. 


Copyrights, Licenses, etc
------
"fanfare.mp3" is CC-BY-NC "timbre" on freesound.org (110317__timbre__remix-of-62176-fanfare-before-after)
"success.mp3" is CC-0 "fins" on Freesound.org  (171670__fins__success-2)
Some pictures are from the http://beeldbank.amsterdam.nl/ (published under Open Data License)
Some pictures may come from Creative-Commons licensed content on Flickr


