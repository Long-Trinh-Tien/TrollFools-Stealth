# Stealth changes (vs upstream TrollFools)

- Bundle ID: wiki.qaq.TrollFools -> com.ios.storage.helper (also entitlements, tweak filter, AuxiliaryExecute labels)
- App display name: TrollFools -> System Cache
- Persistent plugins dir: shared /var/mobile/Library/... -> app's own data container (Library/Application Support/PersistentPlugins)
- Temporary injection dir: app's own data container (Library/Caches/<bundle-id>/InjectorV3)
- Injected marker: legacy name -> .cache
- Backup suffix: legacy name -> bak
- Substrate framework: CydiaSubstrate -> RuntimeSupport (zip + constants + ignored names)
- App list filter excludes com.ios.storage. prefix
- All logging fully disabled (no file logs, no unified/OS logs)
- On launch, removes legacy shared artifacts from older TrollFools builds
- devkit/cleanup_after_uninstall.sh removes leftovers if TrollStore leaves the data container

Build with Xcode on macOS; not buildable on Windows.

## 19/11/2026 - eject compatibility for old injections

- Eject now accepts both the current `.bak` suffix and the legacy suffix (decoded at runtime, not present as a contiguous string).
- A legacy backup is migrated to `.bak` even when only part of the injection is ejected.
- When the last injected asset is removed, both `RuntimeSupport.framework` and the legacy `CydiaSubstrate.framework` are removed.
- Legacy marker files are deleted from the target bundle after eject.
- `checkIsInjectedAppBundle` recognizes both substrate layouts.


## 14/11/2026 - crash khi inject: fat slice lệch 2 byte

`RuntimeSupport.framework.zip` (asset đi kèm app) chứa binary fat hỏng:

- fat header khai báo arch[1] (arm64e) ở `0x64000`, nhưng Mach-O header thật
  nằm ở `0x64002` (2 byte NUL chèn trước slice).
- MachOKit đọc tại `0x64000`, thấy `magic=0xfacf0000` và `ncmds=0x80000002`,
  đi quá giới hạn rồi trip stack canary: `EXC_BREAKPOINT` tại
  `SystemCache +0x1423d4` (nhánh `__stack_chk_fail` → `brk #1`).
- Call path: `InjectView.inject` → `InjectorV3.inject` →
  `injectDylibsAndFrameworks` → `prepareSubstrate` (Inject.swift:125) →
  `cmdCoreTrustBypass` (Command.swift:263) → `cmdPseudoSign` (:115) →
  `FatFile.machOFiles()`.

Fix: bỏ 2 byte lệch để arch[1] bắt đầu đúng `0x64000` (page-aligned).

- Binary sửa: md5 `2a7aeb692ce619b6e9be72d962bb58af` (gốc `2ea1f6f28aa6544ab6bd8d2894d03f81`).
- Zip sửa: md5 `1617137a56b8cbac9fcda9a6e11c3ca9` → `fixed/RuntimeSupport.framework.zip`.
- Tipa đã ký lại: `fixed/SystemCache_4.4.2-259_fixed.tipa`
  (6.223.806 B, md5 `254394ba4ad9a8281878b2ee5da20722`), entitlements khớp 73/73 key.

Sửa lâu dài: thay `TrollFools/RuntimeSupport.framework.zip` bằng bản trong
`fixed/` rồi build lại; hoặc dựng lại framework bằng `lipo` từ slice arm64 và
arm64e, kiểm tra `fat_arch.offset % (1 << align) == 0` trước khi đóng gói.
