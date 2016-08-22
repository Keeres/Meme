//
//  CollectionViewController.swift
//  Meme 2.0
//
//  Created by Steven Chen on 3/31/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CollectionViewController:UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITabBarControllerDelegate, CreateMemeViewControllerDelegate {
   
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var memes = [Meme]()
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    // Define Delegate Method
    func createMemeViewControllerResponse(memes: [Meme]) {
        self.memes = memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        tabBarController!.delegate = self

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CollectionViewController.loadList(_:)),name:"load", object: nil)
        
        //flow layout
        let space: CGFloat = 3.0
        let dimension = (self.view.frame.size.width - (2*space))/3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
        
        memes = fetchAllMemes()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.toolbarHidden = true
    }
    
    func loadList(notification: NSNotification){
        //load data here
        self.collectionView.reloadData()
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
    
    //MARK: CollectionView Delegate
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("memeCollectionCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        let meme = self.memes[indexPath.row]
        
        // Set the image
        cell.memeCellImageView?.image = meme.originalImage as? UIImage
        
        cell.topLabel.textColor = UIColor.whiteColor()
        cell.topLabel.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: 20)
           cell.topLabel?.text = meme.topText
        cell.topLabel.attributedText = NSAttributedString(string: cell.topLabel.text! , attributes: [NSStrokeColorAttributeName:UIColor.blackColor(), NSStrokeWidthAttributeName : -5.0])
        
        cell.bottomLabel.textColor = UIColor.whiteColor()
        cell.bottomLabel.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: 20)
        cell.bottomLabel?.text = meme.bottomText
        cell.bottomLabel.attributedText = NSAttributedString(string: cell.bottomLabel.text! , attributes: [NSStrokeColorAttributeName:UIColor.blackColor(), NSStrokeWidthAttributeName : -5.0])

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let memeController = storyboard!.instantiateViewControllerWithIdentifier("memeView") as! MemeViewController
        
        memeController.meme = memes[indexPath.row]
        self.navigationController?.pushViewController(memeController, animated: true)

    }
    
    // MARK: Tab Bar Controller Delgate Functions
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        let nav = tabBarController.viewControllers![1] as! UINavigationController
        let controller = nav.childViewControllers[0] as! TableViewController
        
        controller.memes = self.memes
    }
    
    
    //MARK: Buttons
    @IBAction func addMemeButton(sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("createMeme") as! CreateMemeViewController
        controller.memes = self.memes
        controller.delegate = self

        self.navigationController?.pushViewController(controller, animated: true)
    }
}