//
//  TableViewController.swift
//  Meme 2.0
//
//  Created by Steven Chen on 3/31/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate, NSFetchedResultsControllerDelegate, MemeEditorViewControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    var memes = [Meme]()

    // Define Delegate Method
    func memeEditorViewControllerResponse(memes: [Meme]) {
        self.memes = memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tabBarController!.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TableViewController.loadList(_:)),name:"load", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
      self.navigationController?.toolbarHidden = true
        tableView.reloadData()

    }
    
    func loadList(notification: NSNotification){
        //load data here
        tableView.reloadData()
    }
    
    // MARK: Table Delgate Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        let rows = memes.count
        
        return rows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("memeCell")! as UITableViewCell
        let meme = memes[indexPath.row]
        
        cell.imageView?.image = meme.memeImage as? UIImage
        cell.textLabel?.text = meme.topText! + "..." + meme.bottomText!
        cell.textLabel?.textAlignment = .Right
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let memeController = storyboard!.instantiateViewControllerWithIdentifier("memeView") as! MemeViewController
    
        memeController.meme = memes[indexPath.row]
        self.navigationController?.pushViewController(memeController, animated: true)
    }
    
     func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if (self.tableView.editing) {
            return UITableViewCellEditingStyle.Delete;
        }
        
        return UITableViewCellEditingStyle.None;
    }
    
     func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let event = memes[indexPath.row]
            
            memes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            sharedContext.deleteObject(event)
            
            do {
                try self.sharedContext.save()
            } catch _ {}
            
            
        } 
    }

    
    // MARK: Tab Bar Controller Delgate Functions
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        let nav = tabBarController.viewControllers![0] as! UINavigationController
        let controller = nav.childViewControllers[0] as! CollectionViewController

        controller.memes = self.memes
    }
    
    // Button
    @IBAction func addMemeButton(sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditor") as! MemeEditorViewController
        controller.memes = self.memes
        controller.delegate = self
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func editButton(sender: AnyObject) {
        self.tableView.setEditing(true, animated: true)
    }
}