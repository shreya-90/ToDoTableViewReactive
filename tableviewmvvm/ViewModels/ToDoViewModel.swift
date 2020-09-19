//
//  ToDoViewModel.swift
//  tableviewmvvm
//
//  Created by Shreya Pallan on 15/09/20.
//  Copyright © 2020 Shreya Pallan. All rights reserved.
//

import Foundation

//MARK: - Menu Items View Model
protocol TodoMenuItemViewPresentable {
    var title : String? { get set }
    var backcolor : String? { get }
    
   
}

protocol ToDoMenuItemViewDelegate {
     func onMenuItemSelected() -> ()
}

//MARK: - Menu Items View Model Base Class
class TodoMenuItemViewModel : TodoMenuItemViewPresentable , ToDoMenuItemViewDelegate{
    var title : String?
    var backcolor : String?
    
    weak var parent: TodoItemViewDelegate?
     
    init(parentViewModel : TodoItemViewDelegate) {
        self.parent = parentViewModel
    }
    
    func onMenuItemSelected() {
        //Base class does not need implementation
    }
    
}

class RemoveMenuItemViewModel : TodoMenuItemViewModel {
    
    override func onMenuItemSelected() {
        //Base class does not need implementation
         print("Remove menu item delegate fn ")
        parent?.onRemoveSelected()
    }
}

class DoneMenuItemViewModel : TodoMenuItemViewModel {
    
    override func onMenuItemSelected() {
        //Base class does not need implementation
        print("Done menu item delegate fn ")
        parent?.onDoneSelected()
    }
}



//MARK: - tableview Cell View Model
protocol TodoItemViewDelegate:class {
    func onItemSelected() -> Void   //Implementation of didSelectRow
    func onRemoveSelected() -> Void
    func onDoneSelected() -> Void
}

protocol ToDoItemPresentable{
    var id : String? { get }
    var textValue : String? { get }
    var isDone : Bool? { get set }
    var menuItems : [TodoMenuItemViewPresentable]? { get }
}

class ToDoItemViewModel : ToDoItemPresentable {

    var id: String? = "0"
    var textValue: String?
    var isDone : Bool? = false
    var menuItems : [TodoMenuItemViewPresentable]? = []
    weak var parentViewModel : ToDoViewDelegate?
    
    init(id:String?,textValue:String?,parent:ToDoViewDelegate?) {
        self.id = id
        self.textValue = textValue
        self.parentViewModel = parent
         
        
        let removeMenuItem = RemoveMenuItemViewModel(parentViewModel: self)
        removeMenuItem.title = "Remove"
        removeMenuItem.backcolor = "ff0000"
        
        let doneMenuItem = DoneMenuItemViewModel(parentViewModel: self)
        doneMenuItem.title = isDone! ? "Undone" : "Done"
        doneMenuItem.backcolor = "008000"
        
        self.menuItems?.append(contentsOf: [removeMenuItem,doneMenuItem])
    }
}


extension ToDoItemViewModel : TodoItemViewDelegate {
    func onRemoveSelected() {
        parentViewModel?.onItemDeleted(id:  id!)
    }
    
    func onDoneSelected() {
        parentViewModel?.onItemDone(id: id!)
    }
    
    func onItemSelected() {
        print("did selct row called for item with id \(id)")
    }
    
}

//MARK: - tableview View Model
protocol ToDoViewPresentable {
    var newToDoItem : String? { get }
}

class TodoViewModel:ToDoViewPresentable {
    
    weak var view : ToDoView?
    var newToDoItem : String?
    var items : [ToDoItemPresentable] = []
    
    init(view:ToDoView) {
        
        self.view = view
        let item1 = ToDoItemViewModel(id: "1", textValue: "Washing Clothes", parent: self)
        let item2 = ToDoItemViewModel(id: "2", textValue: "Buy Groceries", parent: self)
        let item3 = ToDoItemViewModel(id: "3", textValue: "Wash Car", parent: self)

        items.append(contentsOf : [item1,item2,item3])
    }
    
}

protocol ToDoViewDelegate : class {
    func onToDoItemAdded() -> ()
    func onItemDeleted(id:String) -> Void
     func onItemDone(id:String) -> Void
}


extension TodoViewModel : ToDoViewDelegate {
    
    func onToDoItemAdded() {
        
        guard let newToDoItem = newToDoItem else {
            return
        }
        let newid = self.items.count + 1
        
        let item = ToDoItemViewModel(id: "\(newid)", textValue: newToDoItem, parent: self)
        self.items.append(item)
        self.view?.reloadWithNewItem()
        print("New value received in delegate - \(newToDoItem)")
        
    }
    
    func onItemDeleted(id: String) {
        
        guard let index = self.items.index(where : { $0.id! == id }) else {
            print("index not found")
            return
        }
        
        self.items.remove(at: index)
//        self.view?.reloadWithNewItem()
        self.view?.removeTodoItem(at: index)
    }
    
    func onItemDone(id: String) {
        print("done called with id \(id)")
        
        guard let index = self.items.index(where : { $0.id! == id }) else {
            print("index not found")
            return
        }
        
        var toDoItem = self.items[index]
        toDoItem.isDone = !(toDoItem.isDone!)
    
       if var    doneMenuItem = toDoItem.menuItems?.filter({ (todoMenuItem) -> Bool in
            todoMenuItem is DoneMenuItemViewModel
        }).first {
        doneMenuItem.title = toDoItem.isDone! ? "Undone" : "Done"
        }
        view?.updateToDoDone(at: index)
        
        self.items.sort { (item1, item2) -> Bool in
            
            if !(item1.isDone!) && !(item2.isDone!) {
                 return item1.id! < item2.id!
            }
            if (item1.isDone!) && (item2.isDone!) {
                 return item1.id! < item2.id!
            }
            return !(item1.isDone!) && item2.isDone!   // not done items appear before done items
        }
        
        self.view?.reloadItems()
    }
}
