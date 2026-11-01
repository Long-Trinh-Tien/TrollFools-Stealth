//
//  Constants.swift
//  TrollFools
//
//  Created by 82Flex on 3/8/25.
//

import Foundation

enum Constants {
    private static let gInfoPlist: [AnyHashable: Any] = {
        var values = [
            "FeedbackMailTo": "mailto:support@example.com",
            "InviteLinkDiscord": "https://www.apple.com",
            "GitHubReleasePage": "https://www.apple.com",
            "GitHubReleaseEndpointForUpgradeCheck": "https://www.apple.com",
        ]
        return values
    }()

    private static func infoValue<T>(forKey key: String) -> T {
        guard let value = gInfoPlist[key] as? T
        else { fatalError("Malformed application manifest") }
        return value
    }

    static let gFeedbackMailToURL: URL = .init(string: infoValue(forKey: "FeedbackMailTo"))!
    static let gInviteLinkDiscordURL: URL = .init(string: infoValue(forKey: "InviteLinkDiscord"))!

    static let gReleaseNotesURL: URL = .init(string: infoValue(forKey: "GitHubReleasePage"))!
    static let gUpdateCheckEndpoint: URL = .init(string: infoValue(forKey: "GitHubReleaseEndpointForUpgradeCheck"))!

    static let gAppName = (Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String) ?? "System Cache"
    static let gAppVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
    static let gAppBuildVersion = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "1"
    static let gAppIdentifier = Bundle.main.bundleIdentifier ?? "com.ios.storage.helper"
    static let gErrorDomain = "\(gAppIdentifier).error"

    // Always keep TrollFools-owned data inside its own app container so no
    // shared/system-wide directory is created for other apps to inspect.
    static let gAppDataContainerURL: URL = {
        if let url = LSApplicationProxy(forIdentifier: gAppIdentifier)?.dataContainerURL() {
            return url
        }
        if let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return docs
        }
        return FileManager.default.temporaryDirectory
    }()

    static let updateManagerCheckInterval: TimeInterval = 7200 // 2 hours
    static let updateManagerRetryInterval: TimeInterval = 90 // 90 seconds
    static let updateManagerAlertDelayDuration: TimeInterval = 60 * 60 * 24 * 7 // 1 week
    static let trollStoreIdentifier = "com.opa334.TrollStore"
    static let trollStoreInstallURLScheme = "apple-magnifier://install?url="
}
