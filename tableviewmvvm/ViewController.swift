//
//  ViewController.swift
//  tableviewmvvm
//
//  Created by Shreya Pallan on 15/09/20.
//  Copyright © 2020 Shreya Pallan. All rights reserved.
//

import UIKit

extension String {
   static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
protocol ToDoView : class {
    
    func reloadWithNewItem()
    func removeTodoItem(at index : Int) -> Void
    func updateToDoDone(at index : Int)
    func reloadItems()
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var newItemTextField: UITextField!
    
    let identifier = "todoItemCellIdentifier"
    
    var viewModel :  TodoViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let nib = UINib(nibName: "ToDoItemTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: self.identifier)
        
        viewModel = TodoViewModel(view: self)
    }

    @IBAction func onAddItem(_ sender: UIButton) {
        
        guard let newValue = self.newItemTextField.text, newValue != "" else {
            return
        }
        
        self.viewModel?.newToDoItem = newValue
        
        DispatchQueue.global(qos: .background).async {
           self.viewModel?.onToDoItemAdded()
        }
        
    }
    
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Datasource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ToDoItemTableViewCell
        
        let itemsViewModel = self.viewModel?.items[indexPath.row]
        cell?.configure(with: itemsViewModel!)
        return cell!
    }
    
    //MARK: - Delegate method for row selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemviewmodel = viewModel?.items[indexPath.row]
        (itemviewmodel as? TodoItemViewDelegate)?.onItemSelected()
    }
    
    //MARK: - Delegate method for swipe action on tableview cell
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let itemVMSelected = self.viewModel?.items[indexPath.row]
        var menuActions : [UIContextualAction] = []
         
        itemVMSelected?.menuItems?.map({ item in
            let menuAction = UIContextualAction(style: .normal, title: item.title) { (action, view, success : (Bool)->()) in
                
//                self.viewModel?.onItemDeleted(id: (itemVMSelected?.id!)!)
                if let delegate = item as? ToDoMenuItemViewDelegate {
                    
                    DispatchQueue.global(qos: .background).async {
                       delegate.onMenuItemSelected()
                    }
                     
                }
                
                success(true)
            }
            
            menuAction.backgroundColor = String.hexStringToUIColor(hex: item.backcolor!)
            menuActions.append(menuAction)
        })
        
        
        return UISwipeActionsConfiguration(actions: menuActions)
    }
    
    
}


extension ViewController : ToDoView {
    func updateToDoDone(at index : Int) {

        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }

    }
    
    func reloadItems(){
        
        DispatchQueue.main.async {   // COMMON CODE FOR INSERT AND DEETE ROW
            self.tableView.reloadData()
            self.newItemTextField.text = ""
        }
        
    }
    func reloadWithNewItem() {
        
//        DispatchQueue.main.async {   // COMMON CODE FOR INSERT AND DEETE ROW
//            self.tableView.reloadData()
//            self.newItemTextField.text = ""
//        }
        
        guard let items = viewModel?.items else {
            print("items not available")
            return
        }
        
        
        // SPECIFIC METHOD for inserting one row with animation
        
        /*
         1. If you are adding or removing for example only one cell, you should definitely use insertRow. reloadData will reload the whole tableview and instatiate all the cells all over again, latter one just adds one cell and doesn’t do any other updates. You can imagine how much more efficient the latter one is :)
         
         2. As Fjalmari mentiones reloadData reloads your entire table view meaning it will reset any changes you made on your cell like adding a checkmark. insertRow will just add cells to the indexPaths specified by you without altering the other cells.
         
         
         
         */
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: items.count-1, section: 0)], with: .automatic)
            self.tableView.endUpdates()
        }
        
 
    }
    
    func removeTodoItem(at index: Int) {
        
        DispatchQueue.main.async {
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        self.tableView.endUpdates()
        }
    }


}

