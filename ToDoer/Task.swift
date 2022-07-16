//
//  task.swift
//  ToDoer
//
//  Created by DPI Student 12 on 7/12/22.
//

import Foundation

struct Task {
    var id: String = UUID().uuidString
    var title: String
    var date: Date
    var description: String
    var completed: Bool = false
}
