//
//  AppCoordinator.swift
//  Ads Example App
//

import UIKit
import RichieSDK

@MainActor
public class AppCoordinator {
    private let richieAdsController: RichieAdsController
    private let window: UIWindow

    public init(window: UIWindow) {
        self.window = window

        let rootViewController = RootViewController()
        self.window.rootViewController = rootViewController
        self.window.makeKeyAndVisible()

        // Initialize Richie early in your app’s lifecycle;
        // application:didFinishLaunchingWithOptions: is a good candidate.
        // Contact Richie to get your production app identifier before
        // submitting an app to the App Store.
        // Initialize with a backgroundDownloadManager if you want background downloads for ads.
        self.richieAdsController = RichieAdsController(appIdentifier: "richiedemo")

        rootViewController.dynamicAdsCallback = { [weak self] in
            guard let self else { return }
            let dynamicAdsVC = DynamicAdsViewController(richieAdsController: self.richieAdsController)
            dynamicAdsVC.modalPresentationStyle = .fullScreen
            self.window.rootViewController?.present(dynamicAdsVC, animated: true)
        }
    }
}
