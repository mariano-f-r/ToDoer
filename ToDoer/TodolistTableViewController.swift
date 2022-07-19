//
//  TodolistTableViewController.swift
//  ToDoer
//
//  Created by DPI Student 12 on 7/11/22.
//

import UIKit
import SQLite

/// This class is responsible for the main database handling, as well as listing all the tasks
class TodolistTableViewController: UITableViewController {
    var todoTasks = [Task]()
    var modifiedTaskIndex: Int?
    var deletingTask: Bool?
    
    func dateParser() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "firstLaunch")
        
        if launchedBefore == true {
            print("Launched Before")
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!
            do {
                let taskDB = try Connection("\(path)/db.sqlite3")
                let tasks = Table("Tasks")
                let formatter = dateParser()
                let taskTitle = Expression<String>("title")
                let date = Expression<String>("date")
                let description = Expression<String>("description")
                let completed = Expression<Bool>("completed")
                let uuid = Expression<String>("uuid")
                for task in try taskDB.prepare(tasks.filter(completed == false)) {
                    let taskDate = formatter.date(from: task[date])
                    print("ID: \(task[uuid]), Title: \(task[taskTitle]), Date: \(String(describing: taskDate)), Description: \(task[description]), Completed: \(task[completed])")
                    let storedTask = Task(id: task[uuid] ,title: task[taskTitle], date: taskDate!, description: task[description], completed: false )
                    todoTasks.append(storedTask)
                }
                for task in try taskDB.prepare(tasks.filter(completed == true)) {
                    let taskDate = formatter.date(from: task[date])
                    print("ID: \(task[uuid]), Title: \(task[taskTitle]), Date: \(String(describing: taskDate)), Description: \(task[description]), Completed: \(task[completed])")
                    let storedCompletedTask = Task(id: task[uuid], title: task[taskTitle], date: taskDate!, description: task[description], completed: true)
                    todoTasks.append(storedCompletedTask)
                    
                }
                
            } catch {
                print(error)
            }
            print(todoTasks)
        } else {
            print("First Launch")
            UserDefaults.standard.setValue(true, forKey: "firstLaunch")
            do {
                let path = NSSearchPathForDirectoriesInDomains(
                    .documentDirectory, .userDomainMask, true
                ).first!
                
                let taskDB = try Connection("\(path)/db.sqlite3")
                let tasks = Table("Tasks")
                let taskTitle = Expression<String>("title")
                let date = Expression<String>("date")
                let description = Expression<String>("description")
                let completed = Expression<Bool>("completed")
                let uuid = Expression<String>("uuid")

                try taskDB.run(tasks.create { t in
                    t.column(uuid)
                    t.column(taskTitle)
                    t.column(date)
                    t.column(description)
                    t.column(completed, defaultValue: false)
                })
            } catch  {
                print(error)
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return todoTasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)

        // Configure the cell...
        
        let formatter = dateParser()

        cell.textLabel?.text = todoTasks[indexPath.row].title
        let cellDueDate = todoTasks[indexPath.row].date
        let dateString = formatter.string(from: cellDueDate)
        cell.detailTextLabel?.text = "Due on \(dateString)"
        if todoTasks[indexPath.row].completed == true {
            cell.textLabel?.isEnabled = false
            cell.detailTextLabel?.isEnabled = false
        }
        
        return cell
    }
    
    @IBAction func unwindToTaskList(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        
        let taskDB = try! Connection("\(path)/db.sqlite3")
        let tasks = Table("Tasks")
        let taskTitle = Expression<String>("title")
        let date = Expression<String>("date")
        let description = Expression<String>("description")
        let completed = Expression<Bool>("completed")
        let uuid = Expression<String>("uuid")

        
        let formatter = dateParser()
        let dueDate = formatter.string(from: todoTasks[modifiedTaskIndex!].date)
        
        if sourceViewController is DetailViewController {
            if deletingTask == true {
                let dbTaskToDelete = tasks.filter(uuid == todoTasks[modifiedTaskIndex!].id)
                do {
                    try taskDB.run(dbTaskToDelete.delete())
                } catch  {
                    print(error)
                }
                todoTasks.remove(at: modifiedTaskIndex!)
                modifiedTaskIndex = nil
                deletingTask = nil
            } else {
                if let modifiedTaskIndex = modifiedTaskIndex {
                    let dbTaskToComplete = tasks.filter(uuid == todoTasks[modifiedTaskIndex].id)
                    do {
                        try taskDB.run(dbTaskToComplete.update(completed <- true))
                    } catch  {
                        print(error)
                    }
                    todoTasks[modifiedTaskIndex].completed = true
                    let modifiedTask = todoTasks[modifiedTaskIndex]
                    todoTasks.remove(at: modifiedTaskIndex)
                    todoTasks.append(modifiedTask)
                    self.modifiedTaskIndex = nil
                    self.deletingTask = nil
                }
            }
            
        } else {
            let newTask = todoTasks[modifiedTaskIndex!]
            print(newTask.description)
            do {
            try taskDB.run(tasks.insert(uuid <- newTask.id ,taskTitle <- newTask.title, date <- dueDate, description <- newTask.description ,completed <- newTask.completed))
            } catch {
                print(error)
            }
            self.modifiedTaskIndex = nil
            self.deletingTask = nil
        }
        tableView.reloadData()
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
                
        if segue.identifier == "addView" {
            return
        } else if segue.identifier == "detailView" {
            let destination = segue.destination as! DetailViewController
            let index = tableView.indexPathForSelectedRow!
            destination.task = todoTasks[index.row]
            destination.taskIndex = index.row
        }
    }
    
    

}
