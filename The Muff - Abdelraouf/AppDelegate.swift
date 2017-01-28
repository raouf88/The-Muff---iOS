//
//  AppDelegate.swift
//  hold the images cache and favorite list for easy access throught the application
//
//  Created by Raouf on 27/01/2017.
//  Copyright © 2017 Raouf Maz. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    /** application's cache for images*/
    let imagesCache = NSCache<AnyObject, UIImage>()
    /** application's favorite list*/
    let favorites = Favorites()

}

