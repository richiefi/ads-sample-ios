import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func applicationDidFinishLaunching(_: UIApplication) {
        let window = UIWindow()
        self.window = window
        self.appCoordinator = AppCoordinator(window: window)
    }
}
