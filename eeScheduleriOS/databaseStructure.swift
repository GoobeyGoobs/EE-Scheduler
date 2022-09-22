//
//  databaseStructure.swift
//  eeScheduleriOS
//
//

import Foundation
import UIKit

public struct studentInformation {
    var nameID: String?
    var tutorID: String?
    var imageURL: String?
    var emailID: String?
    
    init(nameID: String?, tutorID: String?, imageURL: String?, emailID: String?) {
        self.nameID = nameID
        self.tutorID = tutorID
        self.imageURL = imageURL
        self.emailID = emailID
    }
    
    init?(dictionary: [String : Any]) {
        
        let nameID = dictionary["nameID"] as! String
        let tutorID = dictionary["tutorID"] as! String
        let imageURL = dictionary["imageURL"] as! String
        let emailID = dictionary["emailID"] as! String
        self.init(nameID: nameID, tutorID: tutorID, imageURL: imageURL, emailID: emailID)
    }
    
}

