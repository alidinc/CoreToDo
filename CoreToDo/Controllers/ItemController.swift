//
//  ItemController.swift
//  CoreToDo
//
//  Created by Ali Dinç on 15/08/2021.
//
import UIKit
import CoreData

class ItemController {
    
    // MARK: - Properties
    static let shared = ItemController()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items = [Item]()
    
    // MARK: - CRUD
    func save() {
        do {
            try context.save()
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
    }
    
    func updateItem(item: Item, newTitle: String) {
        item.title = newTitle
        self.save()
    }
    
    func fetchItems() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        do {
            items = try context.fetch(request)
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
    }
    
    func deleteItem(item: Item) {
        guard let index = items.firstIndex(of: item) else { return }
        items.remove(at: index)
        context.delete(item)
        self.save()
    }
}
