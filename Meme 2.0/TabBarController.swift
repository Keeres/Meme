//
//  TabBarController.swift
//  Meme 2.0
//
//  Created by Steven Chen on 5/20/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class TabBarController: UITabBarController, UITabBarControllerDelegate {

    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    var memes = [Meme]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        memes = fetchAllMemes()
    }
    
    func fetchAllMemes() -> [Meme] {
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Meme")
        //    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
        
        // Execute the Fetch Request
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Meme]
        } catch  let error as NSError {
            print("Error in fetchAllEvents(): \(error)")
            return [Meme]()
        }
    }

    
    // MARK: Tab Bar Controller Delgate Functions
/*    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
        let selectedIndex = tabBarController.selectedIndex
        
        if selectedIndex == 0 {
            let nva = tabBarController.viewControllers as! UINavigationController
            let controller = nav[0] as? CollectionViewController
            controller!.memes = self.memes
        }else if selectedIndex == 1 {
            let controller = tabBarController.viewControllers![1] as! TableViewController
            controller.memes = self.memes
        }
        
    }*/
}