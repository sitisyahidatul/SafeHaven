# SafeHaven - Disaster Shelter Locator (SDG 11)

Flutter (Material 3) front-end prototype for Practical 1.
Device feature: **location** (geolocator). Data is hard-coded sample data; the database comes in Practical 2.

## Run it

```bash
flutter create disaster_shelter_locator      # creates android/ ios/ web/ etc.
# copy this project's lib/, assets/ and pubspec.yaml over the new project
cd disaster_shelter_locator
flutter pub get
flutter run                                  # or: flutter run -d chrome
```

## Demo accounts (any password with 6+ characters)

| Role | Email | Can do |
|---|---|---|
| User | `user@shelter.com` | Find and view shelters |
| Volunteer | `volunteer@shelter.com` | Add shelters, and edit only the shelters they added (the 6 sample shelters belong to this account) |

An unknown email logs in as a **User**.

To register as a **Volunteer**, choose "Volunteer" on the Register screen and enter a valid
**Volunteer ID code**. Sample codes: `SH-ADM-2026` or `SH-ADM-2027`.
(Practical 1: codes are written in the app. Practical 2: they move into the database.)

## Location permissions (required, otherwise GPS will always fail)

**Android** - `android/app/src/main/AndroidManifest.xml`, inside `<manifest>` and above `<application>`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

**iOS** - `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We use your location to show the nearest disaster shelters.</string>
```

**Get directions** opens Google Maps (url_launcher). On Android 11+ add this inside `<manifest>` of AndroidManifest.xml if the map does not open:

```xml
<queries>
  <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>
</queries>
```

**Emulator tip:** Android emulator > "..." > Location, set a point, then press the refresh icon in the app.
If permission is denied or GPS is off, the app falls back to central Kuala Lumpur.

## Screens
1. Onboarding (3 pages)  2. Login  3. Register (User / Volunteer + volunteer ID code)
4. Dashboard (BottomNavigationBar: Home, Shelters, Profile)  5. Shelter list (main feature)
6. Shelter details (Get directions opens Google Maps)  7. Add / Edit shelter form (Admin only)

**Profile tab:** Edit profile and Change password (show a "coming in a later practical" message),
Emergency numbers (User) or Shelters added (Volunteer), About SafeHaven (includes SDG 11), Log out.

**Volunteer extras:** Add shelter button, "My shelters" filter, quick edit icon on their own shelters.

## Folder layout
```
lib/main.dart                      app + routes
lib/theme/app_theme.dart           the ONE ThemeData (navy + red) + card decoration
lib/models/shelter.dart            model + sample data
lib/services/shelter_store.dart    location logic + in-memory shelter data
lib/services/session.dart          logged-in user, roles, admin ID codes, edit rule
lib/widgets/                       shelter card + type icons, logo, bottom wave
lib/screens/*.dart                 the screens
assets/images/                     logo and onboarding illustrations
```

Sample shelter names and coordinates are illustrative only.
