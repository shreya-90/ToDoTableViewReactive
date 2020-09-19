//
//  ViewController.swift
//  tableviewmvvm
//
//  Created by Shreya Pallan on 15/09/20.
//  Copyright © 2020 Shreya Pallan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol ToDoView : class {
    
    //func reloadWithNewItem()
//    func removeTodoItem(at index : Int) -> Void
//    func updateToDoDone(at index : Int)
//    func reloadItems()
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var newItemTextField: UITextField!
    
    let identifier = "todoItemCellIdentifier"
    
    var viewModel :  TodoViewModel?
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let nib = UINib(nibName: "ToDoItemTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: self.identifier)
        
        viewModel = TodoViewModel()
        
        //Binding tableview with - gets rid of data source methods - numberofrowsinsection and cellforrowat. Disconnect datasource from view controller in stpryboard else it will crash.
            
        
        
        //Using RxSwift also gets rid of all the delegate methods caaled from ViewModel to Viewcontroller for updating the view. ( ToDoView protocol )
         
        self.viewModel?.items.asObservable().bind(to: tableView.rx.items(cellIdentifier: identifier, cellType: ToDoItemTableViewCell.self)) { index, item,cell in
            cell.configure(with: item)
        }.disposed(by: disposeBag)
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

extension ViewController : UITableViewDelegate {
    
    //MARK: - Datasource methods
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel?.items.value.count ?? 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ToDoItemTableViewCell
//
//        let itemsViewModel = self.viewModel?.items.value[indexPath.row]
//        cell?.configure(with: itemsViewModel!)
//        return cell!
//    }
    
    //MARK: - Delegate method for row selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemviewmodel = viewModel?.items.value[indexPath.row]
        (itemviewmodel as? TodoItemViewDelegate)?.onItemSelected()
    }
    
    //MARK: - Delegate method for swipe action on tableview cell
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let itemVMSelected = self.viewModel?.items.value[indexPath.row]
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



