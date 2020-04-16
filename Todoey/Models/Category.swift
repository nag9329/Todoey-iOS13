//
//  Category.swift
//  Todoey
//
//  Created by Nagarjuna Ramagiri on 4/13/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import RealmSwift

class Category: Object {
    @objc dynamic var name = ""
    @objc dynamic var color:String = ""
    let items = List<Item>()
}
