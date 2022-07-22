//
//  Person.swift
//  project10
//
//  Created by Madiapps on 21/07/2022.
//

import UIKit

class Person: NSObject, Codable {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
