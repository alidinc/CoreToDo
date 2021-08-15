//
//  ViewController.swift
//  CoreToDo
//
//  Created by Ali Dinç on 15/08/2021.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    // MARK: - Properties
    var textField = UITextField()
    var filteredItems = [Item]()
    let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    var refresh = UIRefreshControl()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ItemController.shared.fetchItems()
        updateViews()
        searchBarSetup()
        refreshSetup()
    }

    // MARK: - Actions
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new todo item", message: "", preferredStyle: .alert)
        alert.addTextField { alertTextfield in
            alertTextfield.placeholder = "Create new item"
        }
        let action = UIAlertAction(title: "Add item", style: .default) { action in
            let newItem = Item(context: ItemController.shared.context)
            guard let text = alert.textFields![0].text else { return }
            newItem.title = text
            ItemController.shared.items.append(newItem)
            ItemController.shared.save()
            self.tableView.reloadData()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    func presentAC(with title: String, message: String, textfieldPlaceholder: String, for action: UIAlertAction) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { alertTextfield in
            alertTextfield.placeholder = textfieldPlaceholder
            self.textField = alertTextfield
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func searchBarSetup() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search your notes"
        searchController.searchBar.returnKeyType = .go
        searchController.searchBar.barStyle = .black
        searchController.searchBar.searchTextField.backgroundColor = .label
        searchController.searchBar.autocapitalizationType = .sentences
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func filterContentForSearchBar(searchText: String) {
        if searchText.count > 0 {
            filteredItems = ItemController.shared.items.filter { ($0.title?.contains(searchText))!}
        }
        self.tableView.reloadData()
    }
    
    func refreshSetup() {
        refresh.attributedTitle = NSAttributedString(string: "Pull down to refresh your notes.")
        refresh.addTarget(self, action: #selector(updateViews), for: .valueChanged)
        tableView.addSubview(refresh)
    }
    
    @objc func updateViews() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refresh.endRefreshing()
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ToDoListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredItems.count : ItemController.shared.items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoItemCell", for: indexPath)
        let item = isFiltering ? filteredItems[indexPath.row] : ItemController.shared.items[indexPath.row]
        cell.textLabel?.text = item.title
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentAC(with: "Would you like to update me?", message: "", textfieldPlaceholder: "Type here...", for: UIAlertAction(title: "Update me", style: .default, handler: { action in
            let itemToUpdate = self.isFiltering ? self.filteredItems[indexPath.row] : ItemController.shared.items[indexPath.row]
            ItemController.shared.updateItem(item: itemToUpdate, newTitle: self.textField.text ?? "")
            self.tableView.reloadData()
        }))
        ItemController.shared.save()
        self.tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete =  isFiltering ? filteredItems[indexPath.row] : ItemController.shared.items[indexPath.row]
            ItemController.shared.deleteItem(item: itemToDelete)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height / 8
    }
}

extension ToDoListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchBar(searchText: searchBar.text!)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.tableView.reloadData()
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}
