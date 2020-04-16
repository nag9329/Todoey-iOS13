//
//  Item.swift
//  Todoey
//
//  Created by Nagarjuna Ramagiri on 4/13/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
