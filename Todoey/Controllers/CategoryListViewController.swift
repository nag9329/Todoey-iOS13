//
//  CategoryListViewController.swift
//  Todoey
//
//  Created by Nagarjuna Ramagiri on 4/11/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryListViewController: SwipeTableViewController {
    
    var categories:Results<Category>?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")
        }
        navBar.backgroundColor = UIColor(hexString: "#1D9BF6")
    }
    override func updateModel(at row: Int) {
        if let rowItem = categories?[row] {
            do {
                try realm.write {
                    realm.delete(rowItem)
                }
            } catch {
                print("Error deleting categories \(error)")
            }
        }
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        destinationVC.selectedCategory = categories?[tableView.indexPathForSelectedRow!.row]
    }
    
    @IBAction func addCategoryPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController.init(title: "Add a new Category", message: nil, preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            textField = alertTextField
        }
        alert.addAction(UIAlertAction.init(title: "Add", style: .default, handler: { (action) in
            if let text = textField.text {
                let category = Category()
                category.name = text
                category.color = UIColor.randomFlat().hexValue()
                do {
                    try self.realm.write {
                        self.realm.add(category)
                    }
                } catch {
                    print("Error saving categories \(error)")
                }
            }
            self.loadCategories()
        }))
        present(alert, animated: true, completion: nil)
    }
    
}

//MARK: - Categories retrieve and save

extension CategoryListViewController {
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
}

// MARK: - Table view data source

extension CategoryListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            let color = UIColor(hexString: category.color)!
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        return cell
    }
}

//MARK: - Table view delegate methods

extension CategoryListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "TodoVC", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

