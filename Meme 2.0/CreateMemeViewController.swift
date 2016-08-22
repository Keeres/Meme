//
//  CreateMemeViewController.swift
//  Meme 2.0
//
//  Created by Steven Chen on 3/30/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import UIKit
import CoreData

protocol CreateMemeViewControllerDelegate{
    func createMemeViewControllerResponse(memes: [Meme])
}

class CreateMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!

    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    let imagePicker = UIImagePickerController()
    var topTextView: UITextView!
    var bottomTextView: UITextView!
    var memes = [Meme]()
    var delegate: CreateMemeViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        self.navigationController?.toolbarHidden = false

        initializeTextView()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Initialize TextView
    func initializeTextView(){
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        topTextView = UITextView(frame: CGRectMake(100, 100, screenSize.width*0.8, 100))
        topTextView.delegate = self
        defaultTextProperties(topTextView)
        topTextView.text = "TOP"
        topTextView.hidden = true
        self.view.addSubview(topTextView)
        
        bottomTextView = UITextView(frame: CGRectMake(100, 100, screenSize.width*0.8, 75))
        bottomTextView.delegate = self
        defaultTextProperties(bottomTextView)
        bottomTextView.text = "BOTTOM"
        bottomTextView.hidden = true
        self.view.addSubview(bottomTextView)
    }
    
    func textViewGuard(textView:UITextView){
        
    }
    
    func defaultTextProperties(textView:UITextView){
        let memeAttributeString = NSAttributedString(string: " ", attributes:[NSStrokeColorAttributeName : UIColor.blackColor(),NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 35.0)!,            NSStrokeWidthAttributeName : -5.0])
        textView.attributedText = memeAttributeString
        textView.textAlignment = NSTextAlignment.Center
        textView.textColor = UIColor.lightGrayColor()
        textView.textContainer.maximumNumberOfLines = 2;
        textView.backgroundColor = nil
        textView.hidden = false
        portraitTextViewOrientation()
        textView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth, .FlexibleBottomMargin, .FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin]
        }


    func portraitTextViewOrientation(){
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        guard let topTextView = topTextView else{
            print("topTextView not initialized")
            return
        }
        guard let bottomTextView = bottomTextView else{
            print("topTextView not initialized")
            return
        }
        topTextView.center.x = screenSize.width/2
        topTextView.center.y = screenSize.height*0.2
        
        bottomTextView.center.x = screenSize.width/2
        bottomTextView.center.y = screenSize.height*0.85
    }
    
    func landscapeTextViewOrientation(){
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        guard let topTextView = topTextView else{
            print("topTextView not initialized")
            return
        }
        guard let bottomTextView = bottomTextView else{
            print("topTextView not initialized")
            return
        }
        
        topTextView.center.x = screenSize.width/2
        topTextView.center.y = screenSize.height*0.2
        
        bottomTextView.center.x = screenSize.width/2
        bottomTextView.center.y = screenSize.height*0.8
    }
    
    // MARK: Orientation
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        switch UIDevice.currentDevice().orientation{
        case .Portrait:
            portraitTextViewOrientation()
        case .PortraitUpsideDown:
            portraitTextViewOrientation()
        case .LandscapeLeft:
            landscapeTextViewOrientation()
        case .LandscapeRight:
            landscapeTextViewOrientation()
        default:
            portraitTextViewOrientation()
        }
    }

    // MARK: Generate MEME
    func generateMemedImage() -> UIImage
    {
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.toolbarHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.toolbarHidden = false
        
        return memedImage
    }
    
    // MARK: Buttons
    
    @IBAction func actionButton(sender: AnyObject) {
        let memeImage = generateMemedImage()
        let actionController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        self.presentViewController(actionController, animated: true, completion: {
            //Create the meme
            let meme = Meme(topText: self.topTextView.text, bottomText: self.bottomTextView.text, image: self.memeImageView.image!, memedImage: memeImage, context: self.sharedContext)
            
            self.memes.append(meme)
            
            NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)

            do {
                try self.sharedContext.save()
            } catch {
                print("save to core data failed")
            }
           // let object = UIApplication.sharedApplication().delegate
            //let appDelegate = object as! AppDelegate
           // appDelegate.memes.append(meme)
        })
    }

    @IBAction func albumButton(sender: AnyObject) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)

    }
    
    @IBAction func cameraButton(sender: AnyObject) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
        
        self.delegate?.createMemeViewControllerResponse(memes)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
   
    // MARK: ImagePicker Delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        memeImageView.image = image
        memeImageView.contentMode = .ScaleAspectFill    
        topTextView.hidden = false
        bottomTextView.hidden = false
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: TextView Delegate
    func textViewDidBeginEditing(textView: UITextView) {
        if textView == topTextView{
            topTextView.text = nil
            topTextView.textColor = UIColor.whiteColor()
        }
        if textView == bottomTextView{
            bottomTextView.text = nil
            bottomTextView.textColor = UIColor.whiteColor()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            // Return FALSE so that the final '\n' character doesn't get added
            return false;
        }
        let currentCharacterCount = textView.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + text.characters.count - range.length
        return newLength <= 40
      
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView == topTextView && topTextView.text.isEmpty{
            textView.text = "TOP"
            textView.textColor = UIColor.lightGrayColor()
        }
        if textView == bottomTextView && bottomTextView.text.isEmpty{
            textView.text = "Bottom"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    // MARK: Navigation
    // view controller is signing up to be notified when keyboard will apper
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CreateMemeViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CreateMemeViewController.keyboardWillShow(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // view controller unsubscribes notification when keyboard will disapper
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    // show and shift keyboard when notification is recieved
    func keyboardWillShow(notification: NSNotification) {  //notification annouce information across class
        if bottomTextView.isFirstResponder(){
            print("before")
            print(view.frame.origin.y)

            view.frame.origin.y -= getKeyboardHeight(notification) //origin is top of the view
            print("after")
            print(view.frame.origin.y)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {  //notification annouce information across class
        if bottomTextView.isFirstResponder(){
            view.frame.origin.y += getKeyboardHeight(notification) //origin is top of the view
            print("end")
            print(view.frame.origin.y)

        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        //notification carries information inside userInfo dictionary
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        print(keyboardSize.CGRectValue().height)
        return keyboardSize.CGRectValue().height
    }
    
    
}

