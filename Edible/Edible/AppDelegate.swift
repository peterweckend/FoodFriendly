//
//  AppDelegate.swift

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        GMSServices.provideAPIKey("AIzaSyCJR1A6QVlIlSa8JxMFNfTXyqQw5brf-io")
        GMSPlacesClient.provideAPIKey("AIzaSyCJR1A6QVlIlSa8JxMFNfTXyqQw5brf-io")
        
        // This will send the user to the Featured tab if they are already signed in.
        // If the user is not signed in, they will go to the intro page.
        // The isInSignUp global variable is to prevent a user who just created an account from being
        // pushed to the Featured tab if they're still modifying their account information during the sign up process.
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil && !Globals.isInSignUp {
                
                self.window = UIWindow(frame: UIScreen.main.bounds)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "mainMenuView")
                
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            } else if !Globals.isInSignUp {
                self.window = UIWindow(frame: UIScreen.main.bounds)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "introPage")
                
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }
        }
        
        // To change Navigation Bar Background Color
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 1, green: 0.6588235294, blue: 0, alpha: 1)
        // To change Back button title & icon color
        UINavigationBar.appearance().tintColor = UIColor.white
        // To change Navigation Bar Title Color
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        // To change selected bar icon color
        UITabBar.appearance().tintColor = #colorLiteral(red: 1, green: 0.6588235294, blue: 0, alpha: 1)
        // To change bottom tab bar background color
        UITabBar.appearance().barTintColor = #colorLiteral(red: 1, green: 1, blue: 0.9411764706, alpha: 1)
        

        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

