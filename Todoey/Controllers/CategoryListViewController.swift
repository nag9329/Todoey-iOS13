//
//  CategoryListViewController.swift
//  Todoey
//
//  Created by Nagarjuna Ramagiri on 4/11/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryListViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
    var categories:[Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
    }

     //MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        destinationVC.selectedCategory = categories[tableView.indexPathForSelectedRow!.row]
    }
    
    @IBAction func addCategoryPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController.init(title: "Add a new Category", message: nil, preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            textField = alertTextField
        }
        alert.addAction(UIAlertAction.init(title: "Add", style: .default, handler: { (action) in
            if let text = textField.text {
                let category = Category(context: self.context)
                category.name = text
                self.categories.append(category)
                self.saveCategories()
            }
        }))
        present(alert, animated: true, completion: nil)
    }

}

//MARK: - Categories retrieve and save

extension CategoryListViewController {
    
    func loadCategories() {
        let request:NSFetchRequest<Category> = Category.fetchRequest()
        do {
            categories = try context.fetch(request)
        } catch {
            print("Retrieving fetching categories \(error)")
        }
    }
    
    func saveCategories() {
        do {
          try context.save()
        } catch {
            print("Error saving categories \(error)")
        }
        tableView.reloadData()
    }
    
}

// MARK: - Table view data source

extension CategoryListViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
}

//MARK: - Table view delegate methods

extension CategoryListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "TodoVC", sender: self)
    }
}
    
