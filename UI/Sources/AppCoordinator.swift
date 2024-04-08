//
//  AppCoordinator.swift
//  Ads Example App
//

import UIKit
import RichieSDK

@MainActor
public class AppCoordinator {
    private let window: UIWindow

    public init(window: UIWindow) {
        self.window = window

        let rootViewController = RootViewController()
        self.window.rootViewController = rootViewController
        self.window.makeKeyAndVisible()

        // Initialize Richie early in your app’s lifecycle;
        // application:didFinishLaunchingWithOptions: is a good candidate.
        // This example uses the shared singleton; you can also initialize `Richie`
        // and pass that around as an ordinary value.
        Richie.initializeShared(appIdentifier: Bundle.main.bundleIdentifier!)
        Task {
            let richieAdsController = try await Richie.shared.makeAds()

            rootViewController.dynamicAdsCallback = { [weak self] in
                guard let self else { return }
                let dynamicAdsVC = DynamicAdsViewController(richieAdsController: richieAdsController)
                dynamicAdsVC.modalPresentationStyle = .fullScreen
                self.window.rootViewController?.present(dynamicAdsVC, animated: true)
            }
        }
    }
}
