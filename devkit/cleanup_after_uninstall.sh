#!/bin/sh
# Run as root on the device after uninstalling TrollFools/SystemCache.
# Removes shared leftovers from old builds and the app data container if TrollStore left it.

set -u

rm -rf /var/mobile/Library/TrollFools
rm -rf /var/mobile/Library/Caches/wiki.qaq.TrollFools
rm -rf /var/mobile/Library/Caches/com.ios.storage.helper
rm -rf /var/mobile/Library/Caches/PersistentPlugins
rm -f  /var/mobile/Library/Preferences/wiki.qaq.TrollFools.plist
rm -f  /var/mobile/Library/Preferences/com.ios.storage.helper.plist
rm -rf "/var/mobile/Library/Saved Application State/wiki.qaq.TrollFools.savedState"
rm -rf "/var/mobile/Library/Saved Application State/com.ios.storage.helper.savedState"

for d in /var/mobile/Containers/Data/Application/*; do
  [ -f "$d/.com.apple.mobile_container_manager.metadata.plist" ] || continue
  if plutil -p "$d/.com.apple.mobile_container_manager.metadata.plist" 2>/dev/null | grep -qE 'wiki\.qaq\.TrollFools|com\.ios\.storage\.helper'; then
    rm -rf "$d"
  fi
done

echo "cleanup done"
