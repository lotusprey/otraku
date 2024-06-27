# Otraku
An unofficial AniList app.

<p align='center'>
<img src='https://user-images.githubusercontent.com/35681808/115051277-4fe46680-9ee5-11eb-9cf7-ac62529c4760.png' width='200'>
</p>

<p align='center'>
<a href='https://play.google.com/store/apps/details?id=com.otraku.app'>Google Play</a> • <a href='https://apt.izzysoft.de/fdroid/index/apk/com.otraku.app'>IzzyOnDroid (F-Droid)</a> • <a href='https://sites.google.com/view/otraku/privacy-policy'>Privacy Policy</a>
</p>
<p align='center'>
The iOS .ipa and the android .apk are bundled with each Github release.
</p>

<details><p align='center'>
<summary>Screenshots</summary>

<img width=18% src='https://github.com/lotusprey/otraku/assets/35681808/b6d04e69-e0ae-4b4d-b9bb-621b85b6f220'>
<img width=18% src='https://github.com/lotusprey/otraku/assets/35681808/62cf5d01-43cd-4aba-a292-1bf08e7500b6'>
<img width=18% src='https://github.com/lotusprey/otraku/assets/35681808/63e50f2e-30ca-4e36-8ed0-0d34048060b7'>
<img width=18% src='https://github.com/lotusprey/otraku/assets/35681808/692c6bf8-a5c0-41bf-8bc4-4ce16909550a'>
<img width=18% src='https://github.com/lotusprey/otraku/assets/35681808/a68aac0e-7f2a-4ae0-b0d5-d06d6f485f87'>
<img width=18% src='https://github.com/lotusprey/otraku/assets/35681808/40d47bfc-a0eb-43fa-be70-21aa8ae59122'>
<img width=18% src='https://github.com/lotusprey/otraku/assets/35681808/560d8261-a206-4403-87e3-2207bdbb1c23'>
<img width=18% src='https://github.com/lotusprey/otraku/assets/35681808/7fcfd048-80c2-472f-a833-548ea6b7fafe'>
<img width=18% src='https://github.com/lotusprey/otraku/assets/35681808/c8ab401e-1098-4e69-992b-1d6bc3513ddd'>
<img width=18% src='https://github.com/lotusprey/otraku/assets/35681808/5bcd8eff-2cd7-4f35-90a3-145156a83e2a'>

</p></details>
<details><summary>Building for android</summary>

1. Run `flutter build apk --split-per-abi`
2. Grab the apk release build file with your required ABI
</details>
<details><summary>Building for iOS</summary>

1. Run `flutter build ios --no-codesign`
2. Copy `./build/ios/iphoneos/Runner.app` into a `Payload` directory
3. Compress `Payload` and change extension to `.ipa`
</details>
