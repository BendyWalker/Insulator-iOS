import UIKit
import HealthKit

class VariablesTableViewController: UITableViewController {
    
    let healthManager = HealthManager()
    let preferencesManager = PreferencesManager.sharedInstance
    
    @IBOutlet weak var currentBloodGlucoseLevelTextField: UITextField!
    @IBOutlet weak var carbohydratesInMealTextField: UITextField!
    @IBOutlet weak var correctiveDoseLabel: UILabel!
    @IBOutlet weak var carbohydrateDoseLabel: UILabel!
    @IBOutlet weak var suggestedDoseLabel: UILabel!
    
    @IBAction func openSettings(sender: AnyObject) {
        var settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString, relativeToURL: nil)
        UIApplication.sharedApplication().openURL(settingsUrl!)
    }
    
    @IBAction func clearFields(sender: AnyObject) {
        currentBloodGlucoseLevelTextField.text = ""
        carbohydratesInMealTextField.text = ""
        suggestedDoseLabel.text = "0.0"
        carbohydrateDoseLabel.text = "0.0"
        correctiveDoseLabel.text = "0.0"
        
        self.view.endEditing(true)
    }
    
    @IBAction func isHealthKitAuthorized(sender: UIButton) {
        healthManager.authoriseHealthKit { (authorized, error) -> Void in
            if authorized {
                println("HealthKit authorization received.")
                self.getDataFromHealthKit()
            } else {
                println("HealthKit authorization denied!")
                if error != nil {
                    println("\(error)")
                }
            }
        }
    }
    
    func getDataFromHealthKit() {
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)
        
        healthManager.readMostRecentSample(sampleType, completion: { (mostRecentBloodGlucose, error) -> Void in
            if (error != nil) {
                println("Error reading blood glucose from HealthKit Store: \(error.localizedDescription)")
                return
            }
            
            let bloodGlucose: HKQuantitySample? = mostRecentBloodGlucose as? HKQuantitySample
            if let millgramsPerDeciliterOfBloodGlucose = bloodGlucose?.quantity.doubleValueForUnit(HKUnit(fromString: "mg/dL")) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    let bloodGlucoseUnit = self.preferencesManager.bloodGlucoseUnit
                    
                    // Maybe move this logic into the BloodGlucoseUnit type
                    // Would be nice to just call bloodGlucoseUnit.calculateFinaLevel(quantity)
                    let finalBloodGlucose: Double = {
                        switch bloodGlucoseUnit {
                        case .mmol: return Double(round((millgramsPerDeciliterOfBloodGlucose / 18) * 10) / 10)
                        case .mgdl: return Double(round(millgramsPerDeciliterOfBloodGlucose * 10) / 10)
                        }
                        }()
                    
                    self.currentBloodGlucoseLevelTextField.text = "\(finalBloodGlucose)"
                });
            }
            else {
                // No blood glucose quanity, so show not text
                self.currentBloodGlucoseLevelTextField.text = ""
            }
            
            self.attemptDoseCalculation()
        });
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateBloodGlucoseUnitPlaceholder()
        
        currentBloodGlucoseLevelTextField.addTarget(self, action: "attemptDoseCalculation", forControlEvents: UIControlEvents.EditingChanged)
        carbohydratesInMealTextField.addTarget(self, action: "attemptDoseCalculation", forControlEvents: UIControlEvents.EditingChanged)
        
        self.navigationController?.toolbarHidden = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateBloodGlucoseUnitPlaceholder", name: PreferencesDidChangeNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: PreferencesDidChangeNotification, object: nil)
    }
    
    func attemptDoseCalculation() {
        if let currentBloodGlucoseLevelText = currentBloodGlucoseLevelTextField.text {
            if let carbohydratesInMealText = carbohydratesInMealTextField.text {
                let bloodGlucoseLevel = (currentBloodGlucoseLevelText as NSString).doubleValue
                let carbohydrates = (carbohydratesInMealText as NSString).doubleValue
                
                calculateDose(currentBloodGlucoseLevel: bloodGlucoseLevel, carbohydratesInMeal: carbohydrates)
            }
        }
    }
    
    func calculateDose(#currentBloodGlucoseLevel: Double, carbohydratesInMeal: Double) {
        
        let calculator = Calculator(
            carbohydrateFactor: self.preferencesManager.carbohydrateFactor,
            correctiveFactor: self.preferencesManager.correctiveFactor,
            desiredBloodGlucoseLevel: self.preferencesManager.desiredBloodGlucose,
            currentBloodGlucoseLevel: currentBloodGlucoseLevel,
            carbohydratesInMeal: carbohydratesInMeal,
            bloodGlucoseUnit: self.preferencesManager.bloodGlucoseUnit)
        
        let suggestedDose = String(format: "%.1f", calculator.getSuggestedDose())
        let carbohydrateDose = String(format: "%.1f", calculator.getCarbohydrateDose())
        let correctiveDose = String(format: "%.1f", calculator.getCorrectiveDose())
        
        suggestedDoseLabel.text = suggestedDose
        carbohydrateDoseLabel.text = carbohydrateDose
        correctiveDoseLabel.text = correctiveDose
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
    func updateBloodGlucoseUnitPlaceholder() {
        let bloodGlucoseUnit = self.preferencesManager.bloodGlucoseUnit
        
        // TODO: Could you not just use .rawValue here?
        currentBloodGlucoseLevelTextField.placeholder = {
            switch bloodGlucoseUnit {
            case .mmol: return "mmol/L"
            case .mgdl: return "mg/dL"
            }
            }()
    }
}