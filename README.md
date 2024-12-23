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
<img width="324" alt="Screenshot 2024-12-21 at 06 43 12" src="https://github.com/user-attachments/assets/7b09eec8-1d51-4d58-8896-e41fcc794e00" />

- Main page with quick access to the features
<img width="324" alt="Screenshot 2024-12-21 at 06 43 53" src="https://github.com/user-attachments/assets/ad489e10-2efa-4832-8542-1187b75f72d9" />

- Ability to add a point at a random place on the map
<img width="329" alt="Screenshot 2024-12-21 at 06 44 22" src="https://github.com/user-attachments/assets/132f901b-71cc-47ee-8141-b85b9b491303" />
<img width="326" alt="Screenshot 2024-12-21 at 06 45 07" src="https://github.com/user-attachments/assets/6ea78f55-d29a-4f78-bb70-ad8b90962ca0" />

- Recent Points page with ability to filter by My/All points + ability to delete only YOUR points
<img width="320" alt="Screenshot 2024-12-21 at 06 46 27" src="https://github.com/user-attachments/assets/85caccb3-9325-4d33-9594-6ecb4a32a86a" />

- Quick access to the Point details directly from the Recent Points page
<img width="323" alt="Screenshot 2024-12-21 at 06 46 48" src="https://github.com/user-attachments/assets/6e3b138a-c14f-4605-be2f-ae9946c91f21" />

- Ability to write/edit/delete your OWN comments per each point, and attach local images per each comment. Everything will be cached. (Attachment of images won't work on iOS simulator due to library bug regarding chip architecture most probably)
<img width="241" alt="Screenshot 2024-12-23 at 16 56 37" src="https://github.com/user-attachments/assets/9d9d7bb6-0fce-4695-8428-da76732702e0" />

