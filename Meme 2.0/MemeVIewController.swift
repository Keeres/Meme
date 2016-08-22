//
//  MemeVIewController.swift
//  Meme 2.0
//
//  Created by Steven Chen on 4/1/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import Foundation
import UIKit

class MemeViewController:UIViewController {
    
    @IBOutlet weak var memeImageView: UIImageView!
    var meme:Meme?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        memeImageView.image = meme?.memeImage as? UIImage
        memeImageView.contentMode = .ScaleAspectFit
    }
    
    @IBAction func shareButton(sender: AnyObject) {
        let memeImage = memeImageView.image
        let actionController = UIActivityViewController(activityItems: [memeImage!], applicationActivities: nil)
        self.presentViewController(actionController, animated: true, completion: nil)
    }
}