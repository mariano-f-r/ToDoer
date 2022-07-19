//
//  AddViewController.swift
//  ToDoer
//
//  Created by DPI Student 12 on 7/12/22.
//

import UIKit

/// This class is responsible for handling the input of user data, the sanitisation of user data
class AddViewController: UIViewController {
    var titleCompleted = false
    var dateCompleted = false
    var descriptionCompleted = false
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var taskDueDatePicker: UIDatePicker!
    @IBOutlet weak var taskDescriptionTextField: UITextField!
    @IBOutlet weak var taskDoneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskDoneButton.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    func checkFields() {
        if taskTitleTextField.text != "" {
            titleCompleted = true
        } else {
            titleCompleted = false
        }
        if Date().distance(to: taskDueDatePicker.date).isLessThanOrEqualTo(0) {
            dateCompleted = false
        } else {
            dateCompleted = true
        }
        if taskDescriptionTextField.text != "" {
            descriptionCompleted = true
            
        } else {
            descriptionCompleted = false
        }
        if titleCompleted && dateCompleted && descriptionCompleted {
            taskDoneButton.isEnabled = true
        } else {
            taskDoneButton.isEnabled = false
        }
    }
    
    @IBAction func onCancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func onTaskTitleEdited() {
        checkFields()
    }
    
    @IBAction func onDueDatePickerChanged() {
        checkFields()
    }


    @IBAction func onTaskDescriptionEdited() {
        checkFields()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        
        let newTask = Task(title: taskTitleTextField.text!, date: taskDueDatePicker.date, description: taskDescriptionTextField.text!)
        
        let homeVC = segue.destination as! TodolistTableViewController
        
        var counter = 0
        for task in homeVC.todoTasks {
            if task.completed == true {
                break
            }
            counter += 1
        }
        
        homeVC.modifiedTaskIndex = counter
        homeVC.todoTasks.insert(newTask, at: counter)
    }
}
