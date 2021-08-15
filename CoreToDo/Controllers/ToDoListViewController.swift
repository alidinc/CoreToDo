//
//  ViewController.swift
//  CoreToDo
//
//  Created by Ali Dinç on 15/08/2021.
//

import UIKit

class ToDoListViewController: UITableViewController {

    // MARK: - Properties
    var items = [Item]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    
    // MARK: - Actions
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new todo item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { action in
            let newItem = Item()
            newItem.title = textField.text!
            self.items.append(newItem)
            
            self.save()
        
            self.tableView.reloadData()
        }
        alert.addTextField { alertTextfield in
            alertTextfield.placeholder = "Create new item"
            textField = alertTextfield
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Persistence
    
    func save() {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(self.items)
            try data.write(to: self.dataFilePath!)
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
    }
    
    func load() {
        let decoder = PropertyListDecoder()
        
        do {
            guard let data = try? Data(contentsOf: dataFilePath!) else { return }
            items = try decoder.decode([Item].self, from: data)
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
    }
}

// MARK: - UITableViewDataSource
extension ToDoListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoItemCell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done == true ? .checkmark : .none
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        items[indexPath.row].done.toggle()
        save()
        self.tableView.reloadData()
    }
}
