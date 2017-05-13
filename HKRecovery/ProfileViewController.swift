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
import HealthKit

class ProfileViewController: UITableViewController {
  
  let UpdateProfileInfoSection = 2
  let SaveBMISection = 3
  let kUnknownString   = "Unknown"

  
  @IBOutlet var ageLabel:UILabel!
  @IBOutlet var bloodTypeLabel:UILabel!
  @IBOutlet var biologicalSexLabel:UILabel!
  @IBOutlet var weightLabel:UILabel!
  @IBOutlet var heightLabel:UILabel!
  @IBOutlet var bmiLabel:UILabel!
    @IBOutlet weak var activeCaloriesLabel: UILabel!
    @IBOutlet weak var caffeineLabel: UILabel!
    @IBOutlet weak var carbohydrateLabel: UILabel!
    @IBOutlet weak var calciumLabel: UILabel!
    @IBOutlet weak var fiberLabel: UILabel!
    @IBOutlet weak var iodineLabel: UILabel!
    @IBOutlet weak var totalfatLabel: UILabel!
    @IBOutlet weak var sugarLabel: UILabel!
    @IBOutlet weak var restingCaloriesLabel: UILabel!
    @IBOutlet weak var cyclingDistanceLabel: UILabel!
    @IBOutlet weak var flightsClimbedLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var walkRunLabel: UILabel!
    @IBOutlet weak var bodyFatPercentLabel: UILabel!

    @IBAction func uploadToAzure(sender: UIButton) {
        let client = MSClient(applicationURLString: "", applicationKey: "")
        let item = ["Caffeine":self.caffeineString,"Calcium":self.calciumString,"Carbohydrates":self.carbohyrateString,"Iodine":self.iodineString,"Sugar":self.sugarString,"Fiber":self.fiberString,"TotalFat":self.totalFatString,"ActiveCalories":self.activeCaloriesString,"RestingCalories":self.restingCaloriesString,"CyclingDistance":self.cyclingString,"FlightsClimbed":self.flightsClimbedString,"Steps":self.stepsString,"WalkRunDistance":self.walkRunString,"FatPercent":self.fatPercentString,"Bmi":self.bmiString]
        
        let itemTable = client.tableWithName("HData")
        itemTable.insert(item) {
            (insertedItem, error) in
            if (error != nil) {
                println("Error" + error.description)
            } else {
                println("Items Inserted Successfully!")
                var alertView:UIAlertView = UIAlertView()
                alertView.title = "Microsoft Azure"
                alertView.message = "Upload of data (imperial Units) complete! "
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
                
            }
        }
    }
    
    
  var healthManager:HealthManager?
  var bmi:Double?

  var height, weight, fatPercent:HKQuantitySample?
  var activeCalories, restingCalories, cycleDistance, flightsClimbed, stepCount, walkRunDistance, bodyFatPercent, caffeine, calcium, carbohydrates, cholestrol, fiber, iodine, totalFat, sugar, heartRate:HKQuantitySample?
var caffeineString = ""
  var activeCaloriesString = ""
    var restingCaloriesString = ""
    var bmiString = ""
    var carbohyrateString = ""
  var calciumString = ""
  var fiberString = ""
   var iodineString = ""
     var totalFatString = ""
     var sugarString = ""
       var cyclingString = ""
         var walkRunString = ""
           var flightsClimbedString = ""
           var stepsString = ""
             var heartrateString = ""
             var fatPercentString = ""

  func updateHealthInfo() {
    
    updateProfileInfo();
    updateWeight();
    updateHeight();
    updateActiveCalories();
    updateRestingCalories();
    updateCaffeine();
    updateCarbohydrates();
    updateCalcium();
    updateFiber();
    updateIodine();
    updateSugar();
    updateTotalFat();
    updateCyclingDistance();
    updateWalkRunDistance();
    updateFlightsClimbed();
    updateSteps();
    updateFatPercent();
   
    
  }
  
  func updateProfileInfo()
  {
    let profile = healthManager?.readProfile()
    
    ageLabel.text = profile?.age == nil ? kUnknownString : String(profile!.age!)
    biologicalSexLabel.text = biologicalSexLiteral(profile?.biologicalsex?.biologicalSex)
    bloodTypeLabel.text = bloodTypeLiteral(profile?.bloodtype?.bloodType)
  }
  
  
  func updateHeight()
  {
    // 1. Construct an HKSampleType for Height
    let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
    
    // 2. Call the method to read the most recent Height sample
    self.healthManager?.readMostRecentSample(sampleType, completion: { (mostRecentHeight, error) -> Void in
      
      if( error != nil )
      {
        println("Error reading height from HealthKit Store: \(error.localizedDescription)")
        return;
      }
      
      var heightLocalizedString = self.kUnknownString;
      self.height = mostRecentHeight as? HKQuantitySample;
      // 3. Format the height to display it on the screen
      if let meters = self.height?.quantity.doubleValueForUnit(HKUnit.meterUnit()) {
        let heightFormatter = NSLengthFormatter()
        heightFormatter.forPersonHeightUse = true;
        heightLocalizedString = heightFormatter.stringFromMeters(meters);
      }
      
      
      // 4. Update UI. HealthKit use an internal queue. We make sure that we interact with the UI in the main thread
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.heightLabel.text = heightLocalizedString
        self.updateBMI()
      });
    })
  }
  
  func updateWeight()
  {
    // 1. Construct an HKSampleType for weight
    let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
    
    // 2. Call the method to read the most recent weight sample
    self.healthManager?.readMostRecentSample(sampleType, completion: { (mostRecentWeight, error) -> Void in
      
      if( error != nil )
      {
        println("Error reading weight from HealthKit Store: \(error.localizedDescription)")
        return;
      }
      
      var weightLocalizedString = self.kUnknownString;
      // 3. Format the weight to display it on the screen
      self.weight = mostRecentWeight as? HKQuantitySample;
      if let kilograms = self.weight?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo)) {
        let weightFormatter = NSMassFormatter()
        weightFormatter.forPersonMassUse = true;
        weightLocalizedString = weightFormatter.stringFromKilograms(kilograms)
      }
      
      // 4. Update UI in the main thread
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.weightLabel.text = weightLocalizedString
        self.updateBMI()
        
      });
    });
  }
  
  func updateBMI()
  {
    if weight != nil && height != nil {
      // 1. Get the weight and height values from the samples read from HealthKit
      let weightInKilograms = weight!.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo))
      let heightInMeters = height!.quantity.doubleValueForUnit(HKUnit.meterUnit())
      // 2. Call the method to calculate the BMI
      bmi  = calculateBMIWithWeightInKilograms(weightInKilograms, heightInMeters: heightInMeters)
    }
    // 3. Show the calculated BMI
    var bmiString = kUnknownString
    if bmi != nil {
      self.bmiString = NSString(format: "%.02f", bmi!)
      bmiLabel.text =  self.bmiString
      
    }
  }
  
  func saveBMI() {
    
    // Save BMI value with current BMI value
    if bmi != nil {
      healthManager?.saveBMISample(bmi!, date: NSDate())
    }
    else {
      println("There is no BMI data to save")
    }
  }
  // MARK: - utility methods
  func calculateBMIWithWeightInKilograms(weightInKilograms:Double, heightInMeters:Double) -> Double?
  {
    if heightInMeters == 0 {
      return nil;
    }
    return (weightInKilograms/(heightInMeters*heightInMeters));
  }
  
  
  func biologicalSexLiteral(biologicalSex:HKBiologicalSex?)->String
  {
    var biologicalSexText = kUnknownString;
    
    if  biologicalSex != nil {
      
      switch( biologicalSex! )
      {
      case .Female:
        biologicalSexText = "Female"
      case .Male:
        biologicalSexText = "Male"
      default:
        break;
      }
      
    }
    return biologicalSexText;
  }
  
  func bloodTypeLiteral(bloodType:HKBloodType?)->String
  {
    
    var bloodTypeText = kUnknownString;
    
    if bloodType != nil {
      
      switch( bloodType! ) {
      case .APositive:
        bloodTypeText = "A+"
      case .ANegative:
        bloodTypeText = "A-"
      case .BPositive:
        bloodTypeText = "B+"
      case .BNegative:
        bloodTypeText = "B-"
      case .ABPositive:
        bloodTypeText = "AB+"
      case .ABNegative:
        bloodTypeText = "AB-"
      case .OPositive:
        bloodTypeText = "O+"
      case .ONegative:
        bloodTypeText = "O-"
      default:
        break;
      }
      
    }
    return bloodTypeText;
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath , animated: true)
    
    switch (indexPath.section, indexPath.row)
    {
    case (UpdateProfileInfoSection,0):
      updateHealthInfo()
    case (SaveBMISection,0):
      saveBMI()
    default:
      break;
    }
    
    
  }
    // inserted code here
    
    func updateActiveCalories()
    {
        // 1. Construct an HKSampleType for active calories
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)
        
        // 2. Call the method
        self.healthManager?.readMostRecentSample(sampleType, completion: { (mostRecentActiveCalories, error) -> Void in
            
            if( error != nil )
            {
                println("Error reading active calories from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            
            var activeCaloriesLocalizedString = self.kUnknownString;
            // 3. Format the calories to display it on the screen
            self.activeCalories = mostRecentActiveCalories as? HKQuantitySample;
            if let calories = self.activeCalories?.quantity.doubleValueForUnit(HKUnit.calorieUnit()) {
                let calorieFormatter = NSEnergyFormatter()
              
                activeCaloriesLocalizedString = calorieFormatter.stringForObjectValue(calories)!
            }
            // 4. Update UI in the main thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.activeCaloriesString = activeCaloriesLocalizedString
              self.activeCaloriesLabel.text = self.activeCaloriesString
                
                
            });
        });
    }
  func updateRestingCalories()
  {
    // 1. Construct an HKSampleType for active calories
    let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBasalEnergyBurned)
    
    // 2. Call the method
    self.healthManager?.readMostRecentSample(sampleType, completion: { (mostRecentRestingCalories, error) -> Void in
      
      if( error != nil )
      {
        println("Error reading resting calories from HealthKit Store: \(error.localizedDescription)")
        return;
      }
      
      var restingCaloriesLocalizedString = self.kUnknownString;
      // 3. Format the calories to display it on the screen
      self.restingCalories = mostRecentRestingCalories as? HKQuantitySample;
      if let calories = self.restingCalories?.quantity.doubleValueForUnit(HKUnit.calorieUnit()) {
        let calorieFormatter = NSEnergyFormatter()
        
        restingCaloriesLocalizedString = calorieFormatter.stringForObjectValue(calories)!
      }
      // 4. Update UI in the main thread
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
         self.restingCaloriesString = restingCaloriesLocalizedString
        self.restingCaloriesLabel.text = self.restingCaloriesString
        
      });
    });
  }
  func updateCaffeine()
  {
    // 1. Construct an HKSampleType for weight
    let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCaffeine)
    
    // 2. Call the method to read the most recent weight sample
    self.healthManager?.readMostRecentSample(sampleType, completion: { (mostRecentCaffeine, error) -> Void in
      
      if( error != nil )
      {
        println("Error reading caffeine from HealthKit Store: \(error.localizedDescription)")
        return;
      }
      
      var caffeineLocalizedString = self.kUnknownString;
      // 3. Format the weight to display it on the screen
      self.caffeine = mostRecentCaffeine as? HKQuantitySample;
      if let milligrams = self.caffeine?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix( .Milli)) {
        let caffeineFormatter = NSMassFormatter()
        
        caffeineLocalizedString = caffeineFormatter.stringForObjectValue(milligrams)!
      }
      
      // 4. Update UI in the main thread
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.caffeineString = caffeineLocalizedString
        self.caffeineLabel.text = self.caffeineString
        
      });
    });

  }
  func updateCarbohydrates()
  {
    // 1. Construct an HKSampleType for weight
    let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCarbohydrates)
    
    // 2. Call the method to read the most recent weight sample
    self.healthManager?.readMostRecentSample(sampleType, completion: { (mostRecentCarbohydrates, error) -> Void in
      
      if( error != nil )
      {
        println("Error reading carbohydrates from HealthKit Store: \(error.localizedDescription)")
        return;
      }
      
      var carbohydrateLocalizedString = self.kUnknownString;
      // 3. Format the weight to display it on the screen
      self.carbohydrates = mostRecentCarbohydrates as? HKQuantitySample;
      if let grams = self.carbohydrates?.quantity.doubleValueForUnit(HKUnit.gramUnit()) {
        let carbohydrateFormatter = NSMassFormatter()
        
        carbohydrateLocalizedString = carbohydrateFormatter.stringForObjectValue(grams)!
      }
      
      // 4. Update UI in the main thread
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.carbohyrateString = carbohydrateLocalizedString
        self.carbohydrateLabel.text = self.carbohyrateString
        
      });
    });
    
    
  }

  func updateCalcium()
  {
    // 1. Construct an HKSampleType for weight
    let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCalcium)
    
    // 2. Call the method to read the most recent weight sample
    self.healthManager?.readMostRecentSample(sampleType, completion: { (mostRecentCaffeine, error) -> Void in
      
      if( error != nil )
      {
        println("Error reading calcium from HealthKit Store: \(error.localizedDescription)")
        return;
      }
      
      var caffeineLocalizedString = self.kUnknownString;
      // 3. Format the weight to display it on the screen
      self.calcium = mostRecentCaffeine as? HKQuantitySample;
      if let milligrams = self.calcium?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix( .Milli)) {
        let caffeineFormatter = NSMassFormatter()
        
        caffeineLocalizedString = caffeineFormatter.stringForObjectValue(milligrams)!
      }
      
      // 4. Update UI in the main thread
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.calciumString = caffeineLocalizedString
        self.calciumLabel.text = self.calciumString
        
      });
    });
    
  }
  func updateFiber()
  {
    // 1. Construct an HKSampleType for weight
    let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryFiber)
    
    // 2. Call the method to read the most recent weight sample
    self.healthManager?.readMostRecentSample(sampleType, completion: { (mostRecentCarbohydrates, error) -> Void in
      
      if( error != nil )
      {
        println("Error reading fiber from HealthKit Store: \(error.localizedDescription)")
        return;
      }
      
      var carbohydrateLocalizedString = self.kUnknownString;
      // 3. Format the weight to display it on the screen
      self.fiber = mostRecentCarbohydrates as? HKQuantitySample;
      if let grams = self.fiber?.quantity.doubleValueForUnit(HKUnit.gramUnit()) {
        let carbohydrateFormatter = NSMassFormatter()
        
        carbohydrateLocalizedString = carbohydrateFormatter.stringForObjectValue(grams)!
      }
      
      // 4. Update UI in the main thread
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.fiberString = carbohydrateLocalizedString
        self.fiberLabel.text = self.fiberString
        
      });
    });
    
    
  }
  func updateIodine()
  {
    // 1. Construct an HKSampleType for weight
    let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryIodine)
    
    // 2. Call the method to read the most recent weight sample
    self.healthManager?.readMostRecentSample(sampleType, completion: { (mostRecentCaffeine, error) -> Void in
      
      if( error != nil )
      {
        println("Error reading iodine from HealthKit Store: \(error.localizedDescription)")
        return;
      }
      
      var caffeineLocalizedString = self.kUnknownString;
      // 3. Format the weight to display it on the screen
      self.iodine = mostRecentCaffeine as? HKQuantitySample;
      if let milligrams = self.iodine?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix( .Micro)) {
        let caffeineFormatter = NSMassFormatter()
        
        caffeineLocalizedString = caffeineFormatter.stringForObjectValue(milligrams)!
      }
      
      // 4. Update UI in the main thread
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.iodineString = caffeineLocalizedString
        self.iodineLabel.text = self.iodineString
        
      });
    });
    
  }
  func updateTotalFat()
  {
    // 1. Construct an HKSampleType for weight
    let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryFatTotal)
    
    // 2. Call the method to read the most recent weight sample
    self.healthManager?.readMostRecentSample(sampleType, completion: { (mostRecentCarbohydrates, error) -> Void in
      
      if( error != nil )
      {
        println("Error reading total fat from HealthKit Store: \(error.localizedDescription)")
        return;
      }
      
      var carbohydrateLocalizedString = self.kUnknownString;
      // 3. Format the weight to display it on the screen
      self.totalFat = mostRecentCarbohydrates as? HKQuantitySample;
      if let grams = self.totalFat?.quantity.doubleValueForUnit(HKUnit.gramUnit()) {
        let carbohydrateFormatter = NSMassFormatter()
        
        carbohydrateLocalizedString = carbohydrateFormatter.stringForObjectValue(grams)!
      }
      
      // 4. Update UI in the main thread
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.totalFatString = carbohydrateLocalizedString
        self.totalfatLabel.text = self.totalFatString
        
      });
    });
    
    
  }
  
  func updateSugar()
  {
    // 1. Construct an HKSampleType for weight
    let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietarySugar)
    
    // 2. Call the method to read the most recent weight sample
    self.healthManager?.readMostRecentSample(sampleType, completion: { (mostRecentCarbohydrates, error) -> Void in
      
      if( error != nil )
      {
        println("Error reading sugar from HealthKit Store: \(error.localizedDescription)")
        return;
      }
      
      var carbohydrateLocalizedString = self.kUnknownString;
      // 3. Format the weight to display it on the screen
      self.sugar = mostRecentCarbohydrates as? HKQuantitySample;
      if let grams = self.sugar?.quantity.doubleValueForUnit(HKUnit.gramUnit()) {
        let carbohydrateFormatter = NSMassFormatter()
        
        carbohydrateLocalizedString = carbohydrateFormatter.stringForObjectValue(grams)!
      }
      
      // 4. Update UI in the main thread
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.sugarString = carbohydrateLocalizedString
        self.sugarLabel.text = self.sugarString
        
      });
    });
    
    
  }
  func updateCyclingDistance()
  {
    // 1. Construct an HKSampleType for Height
    let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceCycling)
    
    // 2. Call the method to read the most recent Height sample
    self.healthManager?.readMostRecentSample(sampleType, completion: { (mostRecentHeight, error) -> Void in
      
      if( error != nil )
      {
        println("Error reading cycling distance from HealthKit Store: \(error.localizedDescription)")
        return;
      }
      
      var heightLocalizedString = self.kUnknownString;
      self.cycleDistance = mostRecentHeight as? HKQuantitySample;
      // 3. Format the height to display it on the screen
      if let meters = self.cycleDistance?.quantity.doubleValueForUnit(HKUnit.meterUnitWithMetricPrefix( .Kilo)) {
        let heightFormatter = NSLengthFormatter()
       
        heightLocalizedString = heightFormatter.stringFromMeters(meters);
      }
      
      
      // 4. Update UI. HealthKit use an internal queue. We make sure that we interact with the UI in the main thread
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.cyclingString = heightLocalizedString
        self.cyclingDistanceLabel.text = self.cyclingString
      });
    })
  }
  func updateWalkRunDistance()
  {
    // 1. Construct an HKSampleType for Height
    let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
    
    // 2. Call the method to read the most recent Height sample
    self.healthManager?.readMostRecentSample(sampleType, completion: { (mostRecentHeight, error) -> Void in
      
      if( error != nil )
      {
        println("Error reading walk and run distance from HealthKit Store: \(error.localizedDescription)")
        return;
      }
      
      var heightLocalizedString = self.kUnknownString;
      self.walkRunDistance = mostRecentHeight as? HKQuantitySample;
      // 3. Format the height to display it on the screen
      if let meters = self.walkRunDistance?.quantity.doubleValueForUnit(HKUnit.meterUnitWithMetricPrefix( .Kilo)) {
        let heightFormatter = NSLengthFormatter()
        
        heightLocalizedString = heightFormatter.stringFromMeters(meters);
      }
      
      
      // 4. Update UI. HealthKit use an internal queue. We make sure that we interact with the UI in the main thread
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.walkRunString = heightLocalizedString
        self.walkRunLabel.text = self.walkRunString
      });
    })
  }
  func updateFlightsClimbed()
  {
    // 1. Construct an HKSampleType for Height
    let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)
    
    // 2. Call the method to read the most recent Height sample
    self.healthManager?.readMostRecentSample(sampleType, completion: { (mostRecentHeight, error) -> Void in
      
      if( error != nil )
      {
        println("Error reading flights climbed from HealthKit Store: \(error.localizedDescription)")
        return;
      }
      
      var heightLocalizedString = self.kUnknownString;
      self.flightsClimbed = mostRecentHeight as? HKQuantitySample;
      // 3. Format the height to display it on the screen
      if let meters = self.flightsClimbed?.quantity.doubleValueForUnit(HKUnit.countUnit()) {
        let heightFormatter = NSLengthFormatter()
        
        heightLocalizedString = heightFormatter.stringForObjectValue(meters)!
      }
      
      
      // 4. Update UI. HealthKit use an internal queue. We make sure that we interact with the UI in the main thread
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.flightsClimbedString = heightLocalizedString
        self.flightsClimbedLabel.text = self.flightsClimbedString
      });
    })
  }
  func updateSteps()
  {
    // 1. Construct an HKSampleType for Height
    let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
    
    // 2. Call the method to read the most recent Height sample
    self.healthManager?.readMostRecentSample(sampleType, completion: { (mostRecentHeight, error) -> Void in
      
      if( error != nil )
      {
        println("Error reading steps from HealthKit Store: \(error.localizedDescription)")
        return;
      }
      
      var heightLocalizedString = self.kUnknownString;
      self.stepCount = mostRecentHeight as? HKQuantitySample;
      // 3. Format the height to display it on the screen
      if let meters = self.stepCount?.quantity.doubleValueForUnit(HKUnit.countUnit()) {
        let heightFormatter = NSLengthFormatter()
        
        heightLocalizedString = heightFormatter.stringForObjectValue(meters)!
      }
      
      
      // 4. Update UI. HealthKit use an internal queue. We make sure that we interact with the UI in the main thread
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.stepsString = heightLocalizedString
        self.stepsLabel.text = self.stepsString
      });
    })
  }
  
  func updateFatPercent()
  {
    // 1. Construct an HKSampleType for Height
    let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyFatPercentage)
    
    // 2. Call the method to read the most recent Height sample
    self.healthManager?.readMostRecentSample(sampleType, completion: { (mostRecentHeight, error) -> Void in
      
      if( error != nil )
      {
        println("Error reading fat percent from HealthKit Store: \(error.localizedDescription)")
        return;
      }
      
      var heightLocalizedString = self.kUnknownString;
      self.fatPercent = mostRecentHeight as? HKQuantitySample;
      // 3. Format the height to display it on the screen
      if let meters = self.fatPercent?.quantity.doubleValueForUnit(HKUnit.percentUnit()) {
        let heightFormatter = NSMassFormatter();
        
        heightLocalizedString = heightFormatter.stringForObjectValue(meters)!
      }
      
      
      // 4. Update UI. HealthKit use an internal queue. We make sure that we interact with the UI in the main thread
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.fatPercentString = heightLocalizedString
        self.bodyFatPercentLabel.text = self.fatPercentString
      });
    })
  }

  
  
}