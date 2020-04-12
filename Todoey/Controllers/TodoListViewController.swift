//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class TodoListViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var items:[Item] = []
    let context = (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
    var selectedCategory:Category? {
        didSet {
            loadItems()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController.init(title: "Add a new Todoey Item", message: nil, preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            textField = alertTextField
        }
        alert.addAction(UIAlertAction.init(title: "Add", style: .default, handler: { (action) in
            if let text = textField.text {
                let item = Item(context: self.context)
                item.title = text
                item.done = false
                item.parentCategory = self.selectedCategory
                self.items.append(item)
                self.saveItems()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell")!
        cell.textLabel?.text = items[indexPath.row].title
        cell.accessoryType = items[indexPath.row].done ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items[indexPath.row].done = !items[indexPath.row].done
        saveItems()
    }

}

//MARK: - Items retrieve and save

extension TodoListViewController {
    
    func loadItems(with request:NSFetchRequest<Item> = Item.fetchRequest(), predicate:NSPredicate? = nil) {
        do {
            let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
            if let additionalPredicate = predicate {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
            } else {
                request.predicate = categoryPredicate
            }
            items = try context.fetch(request)
        } catch {
            print("Retrieving fetching items \(error)")
        }
         tableView.reloadData()
    }
    
    func saveItems() {
        do {
          try context.save()
        } catch {
            print("Error saving items \(error)")
        }
        tableView.reloadData()
    }
    
}

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
           let predicate = NSPredicate(format: "title CONTAINS[cd] %@", text)
            loadItems(predicate: predicate)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.count != 0 else {
            loadItems()
            return
        }
    }
    
}
