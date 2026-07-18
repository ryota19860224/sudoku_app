# Google Play release steps (Flutter)

This project is almost ready for release. Follow these steps in order.

## 1) Set production app ID (required)
Edit `android/app/build.gradle.kts`:
- `namespace = "com.example.sudoku_app"`
- `applicationId = "com.example.sudoku_app"`

Replace both with your real package name, for example:
- `com.ryota19860224.sudokuapp`

Important:
- This value is permanent once the app is published.
- It must be globally unique on Google Play.

## 2) Set app version
Edit `pubspec.yaml` and update:
- `version: 0.1.0+1`

Example:
- `version: 1.0.0+1`

`1.0.0` is the user-facing version.
`+1` is versionCode and must increase every release.

## 3) Create upload keystore
From project root (`D:\work\sudoku_app`):

```powershell
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

## 4) Configure signing
1. Copy `android/key.properties.example` to `android/key.properties`
2. Fill real values.

Example:

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=../upload-keystore.jks
```

## 5) Build App Bundle (.aab)

```powershell
flutter clean
flutter pub get
flutter build appbundle --release
```

Output:
- `build/app/outputs/bundle/release/app-release.aab`

## 6) Prepare Play Console listing
In Google Play Console:
1. Create app
2. Set app details (name, description, category)
3. Upload app icon, feature graphic, screenshots
4. Add privacy policy URL
5. Complete Content rating
6. Complete Data safety form
7. Set target audience

## 7) Upload to internal testing first
1. Open `Release > Testing > Internal testing`
2. Create release
3. Upload `app-release.aab`
4. Add tester emails
5. Roll out

After confirming, promote to Production.

## 8) One-time Play App Signing note
Google Play will ask about app signing on first upload. Use recommended Play App Signing.
Keep your keystore and credentials safe and backed up.
