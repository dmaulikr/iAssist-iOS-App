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

import UIKit

class AddWorkoutTableViewController: UITableViewController {
  
  
  
  @IBOutlet var dateCell:DatePickerCell!
  @IBOutlet var startTimeCell:DatePickerCell!
  
  @IBOutlet var durationTimeCell:NumberCell!
  @IBOutlet var caloriesCell:NumberCell!
  @IBOutlet var distanceCell:NumberCell!
  
  
  let kSecondsInMinute=60.0
  let kDefaultWorkoutDuration:NSTimeInterval=(1.0*60.0*60.0) // One hour by default
  let lengthFormatter = NSLengthFormatter()
  var distanceUnit = DistanceUnit.Miles
  
  func datetimeWithDate(date:NSDate , time:NSDate) -> NSDate? {
    
    let currentCalendar = NSCalendar.currentCalendar()
    let dateComponents = currentCalendar.components(.DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit, fromDate: date)
    let hourComponents = currentCalendar.components(.HourCalendarUnit | .MinuteCalendarUnit, fromDate: time)
    
    let dateWithTime = currentCalendar.dateByAddingComponents(hourComponents, toDate:currentCalendar.dateFromComponents(dateComponents)!, options:NSCalendarOptions(0))
    
    return dateWithTime;
    
  }
  
  
  var startDate:NSDate? {
    get {
      
      return datetimeWithDate(dateCell.date, time: startTimeCell.date )
    }
  }
  
  var endDate:NSDate? {
    get {
      let endDate = startDate?.dateByAddingTimeInterval(durationInMinutes*kSecondsInMinute)
      return endDate
    }
  }
  
  var distance:Double {
    get {
      return distanceCell.doubleValue
    }
  }
  
  
  var durationInMinutes:Double {
    get {
      return durationTimeCell.doubleValue
    }
  }
  
  var energyBurned:Double? {
    return caloriesCell.doubleValue
    
  }
  
  func updateOKButtonStatus() {
    
    self.navigationItem.rightBarButtonItem?.enabled = ( distanceCell.doubleValue > 0 && caloriesCell.doubleValue > 0 && distanceCell.doubleValue > 0);
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dateCell.inputMode = .Date
    startTimeCell.inputMode = .Time
    
    
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    let endDate = NSDate()
    let startDate = endDate.dateByAddingTimeInterval(-kDefaultWorkoutDuration)
    
    dateCell.date = startDate;
    startTimeCell.date = startDate
    
    let formatter = NSLengthFormatter()
    formatter.unitStyle = .Long
    let unit = distanceUnit == DistanceUnit.Kilometers ? NSLengthFormatterUnit.Kilometer : NSLengthFormatterUnit.Mile
    let unitString = formatter.unitStringFromValue(2.0, unit: unit)
    distanceCell.textLabel?.text = "Distance (" + unitString.capitalizedString + ")"
    
    self.navigationItem.rightBarButtonItem?.enabled  = false
    
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  
  @IBAction func textFieldValueChanged(sender:AnyObject ) {
    updateOKButtonStatus()
  }
  
  
  
}

