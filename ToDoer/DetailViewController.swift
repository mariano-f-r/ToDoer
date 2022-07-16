//
//  DetailViewController.swift
//  ToDoer
//
//  Created by DPI Student 12 on 7/12/22.
//

import UIKit

class DetailViewController: UIViewController {
    var task: Task!
    var taskIndex: Int!
    @IBOutlet weak var detailViewTitle: UINavigationItem!
    @IBOutlet weak var taskDescriptionLabel: UILabel!
    @IBOutlet weak var taskCompletionButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(task.id)
        print(task.description)
        // Do any additional setup after loading the view.
        detailViewTitle.title = task.title
        taskDescriptionLabel.text = task.description
        
        if task.completed == true {
            taskCompletionButton.isEnabled = false
            taskCompletionButton.isHidden = true
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        let destination = segue.destination as! TodolistTableViewController
        if let button = sender as? UIButton {
            if button.titleLabel?.text == "Delete" {
                destination.deletingTask = true
            }
        }
        destination.modifiedTaskIndex = taskIndex
    }

}
