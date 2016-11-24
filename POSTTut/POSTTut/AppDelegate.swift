//
//  AppDelegate.swift
//  POSTTut
//
//  Created by Jameson Quave on 8/29/14.
//  Copyright (c) 2014 JQ Software LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?


    func application(_ application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        
        // Correct url and username/password
        self.post(["username":"jameson", "password":"password"], url: "http://localhost:4567/login") { (succeeded: Bool, msg: String) -> () in
            let alert = UIAlertView(title: "Success!", message: msg, delegate: nil, cancelButtonTitle: "Okay.")
            if(succeeded) {
                alert.title = "Success!"
                alert.message = msg
            }
            else {
                alert.title = "Failed :("
                alert.message = msg
            }
            
            // Move to the UI thread
            DispatchQueue.main.async(execute: { () -> Void in
                // Show the alert
                alert.show()
            })
        }

        return true
    }
    
    func post(_ params : Dictionary<String, String>, url : String, postCompleted : @escaping (_ succeeded: Bool, _ msg: String) -> ()) {
        var request = NSMutableURLRequest(url: URL(string: "http://localhost:4567/login")!)
        var session = URLSession.shared
        request.httpMethod = "POST"
        
        var err: NSError?
        request.HTTPBody = JSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            println("Body: \(strData)")
            var err: NSError?
            var json = JSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            var msg = "No message"
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                println("Error could not parse JSON: '\(jsonStr)'")
                postCompleted(false, "Error")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    if let success = parseJSON["success"] as? Bool {
                        println("Succes: \(success)")
                        postCompleted(succeeded: success, msg: "Logged in.")
                    }
                    return
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    println("Error could not parse JSON: \(jsonStr)")
                    postCompleted(false, "Error")
                }
            }
        })
        
        task.resume()
    }

    func applicationWillResignActive(_ application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication!) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication!) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

