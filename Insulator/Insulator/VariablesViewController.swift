import UIKit
import HealthKit

class VariablesTableViewController: UITableViewController {
    
    let healthManager = HealthManager()
    let preferencesManager = PreferencesManager(store: PreferencesStore())
    
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
            
            self.calculateDose()
        });
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateBloodGlucoseUnitPlaceholder()
        
        currentBloodGlucoseLevelTextField.addTarget(self, action: "calculateDoseOnTextChange:", forControlEvents: UIControlEvents.EditingChanged)
        carbohydratesInMealTextField.addTarget(self, action: "calculateDoseOnTextChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        self.navigationController?.toolbarHidden = false
    }
    
    func calculateDoseOnTextChange(sender: UITextField) {
        calculateDose()
    }
    
    func calculateDose() {
        var currentBloodGlucoseLevel = (currentBloodGlucoseLevelTextField.text! as NSString).doubleValue
        var carbohydratesInMeal = (carbohydratesInMealTextField.text! as NSString).doubleValue
        
        let calculator = Calculator(carbohydrateFactor: 1, correctiveFactor: 2, desiredBloodGlucoseLevel: 3, currentBloodGlucoseLevel: 4, carbohydratesInMeal: 5, bloodGlucoseUnit: .mmol, isHalfUnitsEnabled: true)
        
        
        let suggestedDose: String = "\(calculator.getSuggestedDose(true))"
        let carbohydrateDose: String = "\(calculator.getCarbohydrateDose(true))"
        let correctiveDose: String = "\(calculator.getCorrectiveDose(true))"
        
        suggestedDoseLabel.text = suggestedDose
        carbohydrateDoseLabel.text = carbohydrateDose
        correctiveDoseLabel.text = correctiveDose
    }
    
    override func viewWillAppear(animated: Bool) {
        // TODO: Listen for notification for when preferences change
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "defaultsDidChange:", name: NSUserDefaultsDidChangeNotification, object: nil)
        
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func defaultsDidChange(notification: NSNotification) {
        updateBloodGlucoseUnitPlaceholder()
    }
    
    func updateBloodGlucoseUnitPlaceholder() {
        let bloodGlucoseUnit = self.preferencesManager.bloodGlucoseUnit
        
        currentBloodGlucoseLevelTextField.placeholder = {
            switch bloodGlucoseUnit {
            case .mmol: return "mmol/L"
            case .mgdl: return "mg/dL"
            }
            }()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

