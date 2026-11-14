//
//  TrollFoolsApp.swift
//  TrollFools
//
//  Created by Lessica on 2024/7/19.
//

import SwiftUI

@main
struct TrollFoolsApp: SwiftUI.App {

    @AppStorage("isDisclaimerHiddenV2")
    var isDisclaimerHidden: Bool = false

    @Environment(\.scenePhase) private var scenePhase

    init() {
        try? FileManager.default.removeItem(at: InjectorV3.temporaryRoot)
        InjectorV3.cleanupLegacySharedArtifacts()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isDisclaimerHidden {
                    AppListView()
                        .environmentObject(AppListModel())
                        .transition(.opacity)
                } else {
                    DisclaimerView(isDisclaimerHidden: $isDisclaimerHidden)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: isDisclaimerHidden)
            .onChange(of: scenePhase) { phase in
                // A previous build (or a sysdiagnose restore) may have put files
                // back while we were running; re-check every time we come back.
                if phase == .active {
                    InjectorV3.cleanupLegacySharedArtifacts()
                }
            }
        }
    }
}
