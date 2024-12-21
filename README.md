# flutter_offline_mapbox

A Flutter app for training. The app is a simple maps app that allows you to add points at random places on the map, and comments to them.
The access to the map is provided by Mapbox with ability to download persistent data and styles locally.
Other maps' metadata / comments / points / users were stored at SQLite database. Passwords for users were stored in SQLite storage but hashed with salt using Crypt.


### Technologies:
- Flutter
- SQFLite for managing all of the vertical data
- Mapbox Maps Flutter SDK
- Custom extended cubits + rxdart streams
- Crypt for password hashing
- GoRouter for navigation
- Injectable, GetIt, Equatable


### Prerequisites:
Create a .env file at the root with public and secret Mapbox access tokens. Public is for Flutter's work, secret is for buggy Android SDK. Buggy, because it should work without a secret token accordingly to the docs, but due to Android SDK implementation, it doesn't.
Also, Android SDK requires you to enable DOWNLOAD:READ rights for the secret token.

`./.env` file should look like this. The ORG_GRADLE_PROJECT_ prefix is for gradle.properties, so it could be read from environment.
```
MAPBOX_ACCESS_TOKEN=pk.eyJ1IjoibX.....
ORG_GRADLE_PROJECT_SDK_REGISTRY_TOKEN=sk.eyJ1IjoibX.....
```


### Journey through the UI:

- Sign In/Sign Up page
![Screenshot 2024-12-21 at 06.43.12.png](..%2F..%2FDesktop%2FScreenshot%202024-12-21%20at%2006.43.12.png)

- Main page with quick access to the features
![Screenshot 2024-12-21 at 06.43.53.png](..%2F..%2FDesktop%2FScreenshot%202024-12-21%20at%2006.43.53.png)

- Ability to add a point at a random place on the map
![Screenshot 2024-12-21 at 06.44.22.png](..%2F..%2FDesktop%2FScreenshot%202024-12-21%20at%2006.44.22.png)

- Recent Points page with ability to filter by My/All points + ability to delete only YOUR points
![Screenshot 2024-12-21 at 06.46.27.png](..%2F..%2FDesktop%2FScreenshot%202024-12-21%20at%2006.46.27.png)

- Quick access to the Point details directly from the Recent Points page
![Screenshot 2024-12-21 at 06.46.48.png](..%2F..%2FDesktop%2FScreenshot%202024-12-21%20at%2006.46.48.png)
