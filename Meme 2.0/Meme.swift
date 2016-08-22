//
//  Meme.swift
//  Meme 2.0
//
//  Created by Steven Chen on 3/31/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Meme: NSManagedObject {
    
    @NSManaged var topText: String?
    @NSManaged var bottomText: String?
    @NSManaged var originalImage: NSObject?
    @NSManaged var memeImage: NSObject?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(topText:String, bottomText:String, image: UIImage, memedImage: UIImage, context:NSManagedObjectContext){
        if let entity =  NSEntityDescription.entityForName("Meme", inManagedObjectContext: context){
            super.init(entity: entity, insertIntoManagedObjectContext: context)
            
            self.topText = topText
            self.bottomText = bottomText
            self.originalImage = image
            self.memeImage = memedImage
            
        }else{
            fatalError("Unable to find Entity name!")
        }
       
    }
}
