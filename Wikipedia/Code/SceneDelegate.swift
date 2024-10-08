import UIKit
import BackgroundTasks
import CocoaLumberjackSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
#if TEST
// Avoids loading needless dependencies during unit tests
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
    }
    
#else

    var window: UIWindow?
    private var appNeedsResume = true

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        guard let appViewController else { return }
        
        if let firstURL = connectionOptions.urlContexts.first?.url {
            
            if firstURL.absoluteString.contains("glny") {
                openURLWithRegion(firstURL: firstURL, appResume: true)
            } else {
               openURL(firstURL: firstURL)
            }
        }
        
        UNUserNotificationCenter.current().delegate = appViewController
        appViewController.launchApp(in: window, waitToResumeApp: appNeedsResume)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {

    }

    func sceneDidBecomeActive(_ scene: UIScene) {

        resumeAppIfNecessary()
    }

    func sceneWillResignActive(_ scene: UIScene) {

        UserDefaults.standard.wmf_setAppResignActiveDate(Date())
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        appDelegate?.cancelPendingBackgroundTasks()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {

        appDelegate?.updateDynamicIconShortcutItems()
        appDelegate?.scheduleBackgroundAppRefreshTask()
        appDelegate?.scheduleDatabaseHousekeeperTask()
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        appViewController?.processShortcutItem(shortcutItem, completion: completionHandler)
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let appViewController else {
            return
        }
        
        appViewController.showSplashView()
        var userInfo = userActivity.userInfo
        userInfo?[WMFRoutingUserInfoKeys.source] = WMFRoutingUserInfoSourceValue.deepLinkRawValue
        userActivity.userInfo = userInfo
        
        _ = appViewController.processUserActivity(userActivity, animated: false) { [weak self] in
            
            guard let self else {
                return
            }
            
            if appNeedsResume {
                resumeAppIfNecessary()
            } else {
                appViewController.hideSplashView()
            }
        }
    }
    
    func scene(_ scene: UIScene, didFailToContinueUserActivityWithType userActivityType: String, error: any Error) {
        DDLogDebug("didFailToContinueUserActivityWithType: \(userActivityType) error: \(error)")
    }
    
    func scene(_ scene: UIScene, didUpdate userActivity: NSUserActivity) {
        DDLogDebug("didUpdateUserActivity: \(userActivity)")
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        guard let firstURL = URLContexts.first?.url else { return }
        
        // MARK: Workaround we need articleURL for redirect with openURL func
        
        if firstURL.absoluteString.contains("glny") {
            openURLWithRegion(firstURL: firstURL, appResume: false)
        } else {
            openURL(firstURL: firstURL)
        }
    }
    
    private func openURLWithRegion(firstURL: URL, appResume: Bool) {
        guard let appViewController else { return }
        let urlComponents = URLComponents(url: firstURL, resolvingAgainstBaseURL: false)
        let queryItems = urlComponents?.queryItems
        let name = queryItems?.first(where: { $0.name == "name" })?.value ?? ""
        let lat = queryItems?.first(where: { $0.name == "lat" })?.value ?? ""
        let long = queryItems?.first(where: { $0.name == "long" })?.value ?? ""
        appViewController.showPlaces(RedirectLocation(name: name, lat: lat, long: long), appResume: appResume)
        return
    }
    
    
    private func openURL(firstURL: URL) {
        guard let appViewController else { return }
        
        guard let activity = NSUserActivity.wmf_activity(forWikipediaScheme: firstURL) ?? NSUserActivity.wmf_activity(for: firstURL) else {
            resumeAppIfNecessary()
            return
        }
        
        appViewController.showSplashView()
        _ = appViewController.processUserActivity(activity, animated: false) { [weak self] in
            
            guard let self else { return }
            
            if appNeedsResume {
                resumeAppIfNecessary()
            } else {
                appViewController.hideSplashView()
            }
        }
    }

    // MARK: Private
    
    private var appDelegate: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    private var appViewController: WMFAppViewController? {
        return appDelegate?.appViewController
    }
    
    private func resumeAppIfNecessary() {
        if appNeedsResume {
            appViewController?.hideSplashScreenAndResumeApp()
            appNeedsResume = false
        }
    }
    
#endif
}
