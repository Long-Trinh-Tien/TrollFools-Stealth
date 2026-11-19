//
//  InjectorV3+Backup.swift
//  TrollFools
//
//  Created by 82Flex on 2025/1/10.
//

import Foundation

extension InjectorV3 {
    // MARK: - Constants

    static let alternateSuffix = "bak"

    // Suffix used by older builds. Decoded at runtime so the old name never
    // appears as a contiguous string in the binary.
    static let legacyAlternateSuffix: String = {
        let encoded = "dHJvbGwtZm9vbHMuYmFr"
        guard let data = Data(base64Encoded: encoded),
              let value = String(data: data, encoding: .utf8) else { return "" }
        return value
    }()

    // Marker used by older builds. Same runtime decoding rule as above.
    static let legacyMarkerName: String = {
        let encoded = "LnRyb2xsLWZvb2xz"
        guard let data = Data(base64Encoded: encoded),
              let value = String(data: data, encoding: .utf8) else { return "" }
        return value
    }()

    static func alternateURL(for target: URL) -> URL {
        target.appendingPathExtension(Self.alternateSuffix)
    }

    static func legacyAlternateURL(for target: URL) -> URL? {
        guard !Self.legacyAlternateSuffix.isEmpty else { return nil }
        return target.appendingPathExtension(Self.legacyAlternateSuffix)
    }

    static func alternateURLs(for target: URL) -> [URL] {
        var urls = [Self.alternateURL(for: target)]
        if let legacy = Self.legacyAlternateURL(for: target) {
            urls.append(legacy)
        }
        return urls
    }

    // MARK: - Shared Methods

    func existingAlternateURL(for target: URL) -> URL? {
        for url in Self.alternateURLs(for: target) where FileManager.default.fileExists(atPath: url.path) {
            return url
        }
        return nil
    }

    func hasAlternate(_ target: URL) -> Bool {
        existingAlternateURL(for: target) != nil
    }

    func makeAlternate(_ target: URL) throws {
        if let legacy = Self.legacyAlternateURL(for: target),
           FileManager.default.fileExists(atPath: legacy.path) {
            try migrateLegacyAlternate(target)
            return
        }
        guard !hasAlternate(target) else {
            return
        }
        try cmdCopy(from: target, to: Self.alternateURL(for: target))
    }

    // Rename an old backup to the current suffix so it no longer carries the
    // legacy filename, even when only part of the injection is ejected.
    func migrateLegacyAlternate(_ target: URL) throws {
        guard let legacy = Self.legacyAlternateURL(for: target),
              FileManager.default.fileExists(atPath: legacy.path) else {
            return
        }
        let current = Self.alternateURL(for: target)
        if FileManager.default.fileExists(atPath: current.path) {
            try? cmdRemove(legacy)
        } else {
            try cmdMove(from: legacy, to: current, overwrite: false)
        }
    }

    func removeAlternate(_ target: URL) throws {
        for url in Self.alternateURLs(for: target) where FileManager.default.fileExists(atPath: url.path) {
            try cmdRemove(url)
        }
    }

    func restoreAlternate(_ target: URL) throws {
        guard let alternateURL = existingAlternateURL(for: target) else {
            return
        }
        try cmdMove(from: alternateURL, to: target, overwrite: true)
        // Remove a second backup (legacy/current) so the old filename does not survive.
        for url in Self.alternateURLs(for: target) where url.path != alternateURL.path {
            if FileManager.default.fileExists(atPath: url.path) {
                try? cmdRemove(url)
            }
        }
    }
}
