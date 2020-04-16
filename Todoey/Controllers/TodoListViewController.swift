//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var items:Results<Item>?
    var selectedCategory:Category? {
        didSet {
            loadItems()
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    let realm = try! Realm()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let color = selectedCategory?.color {
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")
            }
            if let navBarColour = UIColor(hexString: color) {
                navBar.backgroundColor = navBarColour
                searchBar.barTintColor = navBarColour
            }
        }
    }
    
    override func updateModel(at row: Int) {
        if let rowItem = items?[row] {
            do {
                try realm.write{
                    realm.delete(rowItem)
                }
            } catch {
                print("Error deleting items \(error)")
            }
        }
    }
        
    
    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController.init(title: "Add a new Todoey Item", message: nil, preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            textField = alertTextField
        }
        alert.addAction(UIAlertAction.init(title: "Add", style: .default, handler: { (action) in
            if let text = textField.text {
                do {
                    try self.realm.write {
                        let item = Item()
                        item.title = text
                        item.dateCreated = Date()
                        self.selectedCategory?.items.append(item)
                    }
                } catch {
                    print("Error saving items \(error)")
                }
            }
            self.loadItems()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title
            let color = UIColor(hexString: selectedCategory!.color)!.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(items!.count))!
            cell.tintColor = ContrastColorOf(color, returnFlat: true)
            cell.accessoryType = item.done ? .checkmark : .none
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do {
            try realm.write {
                let checked = items![indexPath.row].done
                items![indexPath.row].done = !checked
                tableView.reloadData()
            }
        } catch {
            print("Error updating item \(error)")
        }
    }

}

//MARK: - Items retrieve and save

extension TodoListViewController {
    
    func loadItems() {
        items = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
    }
}

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            items = items?.filter(NSPredicate(format: "title CONTAINS[cd] %@", text)).sorted(byKeyPath: "title", ascending: true)
            tableView.reloadData()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.count != 0 else {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            return
        }
    }

}
