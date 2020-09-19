//
//  ToDoItemTableViewCell.swift
//  tableviewmvvm
//
//  Created by Shreya Pallan on 15/09/20.
//  Copyright © 2020 Shreya Pallan. All rights reserved.
//

import UIKit

class ToDoItemTableViewCell: UITableViewCell {

    @IBOutlet weak var txtIndex: UILabel!
    
    @IBOutlet weak var txtToDoItem: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with viewModel : ToDoItemPresentable)  {
        self.txtIndex.text = viewModel.id!
        
        let attributedString  = NSMutableAttributedString(string: viewModel.textValue!)
       
        
        if viewModel.isDone! {
            let range = NSMakeRange(0, attributedString.length)
            attributedString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.gray, range: range)
            attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: range)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: range)
             
        }
        self.txtToDoItem.attributedText = attributedString
        
    }
    
}
