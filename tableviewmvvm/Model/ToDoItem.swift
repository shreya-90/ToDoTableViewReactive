//
//  ToDoItem.swift
//  tableviewmvvm
//
//  Created by Shreya Pallan on 21/09/20.
//  Copyright © 2020 Shreya Pallan. All rights reserved.
//

//Using codable model objects to sync woth Firestore

struct ToDoItem : Codable {
    
    let id : String
    let title : String
    let completed : Bool
    
    enum CodingKeys : String, CodingKey{
        case id
        case title  = "name"
        case completed
    }
   
    
}

