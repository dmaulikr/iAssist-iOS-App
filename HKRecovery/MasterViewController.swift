/*
 Copyright 2015 Manoj
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

import UIKit


class MasterViewController: UITableViewController {
  
  let kAuthorizeHealthKitSection = 2
  let kProfileSegueIdentifier = "profileSegue"
  let kWorkoutSegueIdentifier = "workoutsSeque"
  
  let healthManager:HealthManager = HealthManager()
  var table : MSTable?
  
  func authorizeHealthKit()
  {
    healthManager.authorizeHealthKit { (authorized,  error) -> Void in
      if authorized {
        println("HealthKit authorization Received!!!")
      }
      else
      {
        println("HealthKit authorization Failed!!!")
        if error != nil {
          println("\(error)")
        }
      }
    }
  }
  
  
  // MARK: - Segues
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier ==  kProfileSegueIdentifier {
      
      let profileViewController = segue.destinationViewController as ProfileViewController
      profileViewController.healthManager = healthManager
      
    }
    else if segue.identifier == kWorkoutSegueIdentifier {
      let workoutViewController = segue.destinationViewController.topViewController as WorkoutsTableViewController
      workoutViewController.healthManager = healthManager;
    }
  }
  
  // MARK: - TableView Delegate
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    switch (indexPath.section, indexPath.row)
    {
    case (kAuthorizeHealthKitSection,0):
      authorizeHealthKit()
    default:
      break
    }
    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    let client = MSClient(applicationURLString: "", applicationKey: "")
    var db12 = "This"
    
    let item = ["text":"Awesome item","text1":"Text 3 inserted","text4":db12]
    let itemTable = client.tableWithName("Item")
    itemTable.insert(item) {
      (insertedItem, error) in
      if (error != nil) {
        println("Error" + error.description)
      } else {
        println("Item Inserted")
        
      }
    }
    
  }
  
  
}
