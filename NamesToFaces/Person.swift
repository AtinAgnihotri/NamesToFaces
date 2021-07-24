//
//  Person.swift
//  NamesToFaces
//
//  Created by Atin Agnihotri on 23/07/21.
//

import UIKit

class Person: NSObject, NSCoding {
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(image, forKey: "image")
    }
    
    required init?(coder: NSCoder) {
        name = coder.decodeObject(forKey: "name") as? String ?? "Unknown Name"
        image = coder.decodeObject(forKey: "image") as? String ?? ""
    }
    
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
