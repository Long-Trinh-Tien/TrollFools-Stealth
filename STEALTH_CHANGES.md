# Stealth changes (vs upstream TrollFools)

- Bundle ID: wiki.qaq.TrollFools -> com.ios.storage.helper (also entitlements, tweak filter, AuxiliaryExecute labels)
- App display name: TrollFools -> System Cache
- Persistent plugins dir: shared /var/mobile/Library/... -> app's own data container (Library/Application Support/PersistentPlugins)
- Temporary injection dir: app's own data container (Library/Caches/<bundle-id>/InjectorV3)
- Injected marker: .troll-fools -> .cache
- Backup suffix: troll-fools.bak -> bak
- Substrate framework: CydiaSubstrate -> RuntimeSupport (zip + constants + ignored names)
- App list filter excludes com.ios.storage. prefix
- All logging fully disabled (no file logs, no unified/OS logs)

Build with Xcode on macOS; not buildable on Windows.