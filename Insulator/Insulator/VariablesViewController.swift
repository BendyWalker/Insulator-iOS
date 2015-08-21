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
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!

    
    @IBAction func onRightBarButtonTouched(sender: AnyObject) {
        if carbohydratesInMealTextField.editing {
            carbohydratesInMealTextField.resignFirstResponder()
        } else if currentBloodGlucoseLevelTextField.editing {
            currentBloodGlucoseLevelTextField.resignFirstResponder()
        } else {
            clearFields()
        }
    }
    
    
    override func viewDidLoad() {        
        currentBloodGlucoseLevelTextField.addTarget(self, action: "attemptDoseCalculation", forControlEvents: UIControlEvents.EditingChanged)
        currentBloodGlucoseLevelTextField.addTarget(self, action: "toggleRightBarButtonItem", forControlEvents: UIControlEvents.EditingDidBegin)
        currentBloodGlucoseLevelTextField.addTarget(self, action: "toggleRightBarButtonItem", forControlEvents: UIControlEvents.EditingDidEnd)
        carbohydratesInMealTextField.addTarget(self, action: "attemptDoseCalculation", forControlEvents: UIControlEvents.EditingChanged)
        carbohydratesInMealTextField.addTarget(self, action: "toggleRightBarButtonItem", forControlEvents: UIControlEvents.EditingDidBegin)
        carbohydratesInMealTextField.addTarget(self, action: "toggleRightBarButtonItem", forControlEvents: UIControlEvents.EditingDidEnd)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUi", name: PreferencesDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUi", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        updateUi()
        
        if let build = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String {
            if preferencesManager.buildNumber != build {
                self.performSegueWithIdentifier("Welcome", sender: AnyObject?())
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.estimatedRowHeight = 100
        tableView.reloadData()
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.reloadData()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: PreferencesDidChangeNotification, object: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 1
        case 2: return 3
        default: return 0
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                currentBloodGlucoseLevelTextField.becomeFirstResponder()
                currentBloodGlucoseLevelTextField.selectAll(self)
            case 1:
                carbohydratesInMealTextField.becomeFirstResponder()
                carbohydratesInMealTextField.selectAll(self)
            default:
                return
            }
        case 1:
            switch indexPath.row {
            case 0:
                updateUi()
            default:
                return
            }
            tableView.reloadData()
        default:
            return
        }
    }
    
    
    func toggleRightBarButtonItem() {
        if currentBloodGlucoseLevelTextField.editing || carbohydratesInMealTextField.editing {
            rightBarButtonItem.style = UIBarButtonItemStyle.Done
            rightBarButtonItem.title = "Done"
        } else {
            rightBarButtonItem.style = UIBarButtonItemStyle.Plain
            rightBarButtonItem.title = "Clear"
        }
    }
    
    func updateUi() {
        let healthKitBloodGlucose = self.preferencesManager.healthKitBloodGlucose
        currentBloodGlucoseLevelTextField.placeholder = preferencesManager.bloodGlucoseUnit.rawValue
        
        if healthKitBloodGlucose != 0 {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.currentBloodGlucoseLevelTextField.text = "\(healthKitBloodGlucose)"
                self.attemptDoseCalculation()
            });
        }
    }
    
    func clearFields() {
        currentBloodGlucoseLevelTextField.text = ""
        carbohydratesInMealTextField.text = ""
        suggestedDoseLabel.text = "0.0"
        carbohydrateDoseLabel.text = "0.0"
        correctiveDoseLabel.text = "0.0"
        
        self.view.endEditing(true)
    }
    
    func attemptDoseCalculation() {
        if let currentBloodGlucoseLevelText = currentBloodGlucoseLevelTextField.text {
            if let carbohydratesInMealText = carbohydratesInMealTextField.text {
                var finalCurrentBloodGlucoseLevelText = currentBloodGlucoseLevelText
                var finalCarbohydratesInMealText = carbohydratesInMealText
                
                if preferencesManager.bloodGlucoseUnit == .mmol {
                    finalCurrentBloodGlucoseLevelText = addDecimalPlace(currentBloodGlucoseLevelText)
                    currentBloodGlucoseLevelTextField.text = finalCurrentBloodGlucoseLevelText
                }
                
                if preferencesManager.allowFloatingPointCarbohydrates {
                    finalCarbohydratesInMealText = addDecimalPlace(carbohydratesInMealText)
                    carbohydratesInMealTextField.text = finalCarbohydratesInMealText
                }
                
                let bloodGlucoseLevel = finalCurrentBloodGlucoseLevelText.doubleValue
                let carbohydrates = finalCarbohydratesInMealText.doubleValue
                calculateDose(currentBloodGlucoseLevel: bloodGlucoseLevel, carbohydratesInMeal: carbohydrates)
            }
        }
    }
    
    func calculateDose(currentBloodGlucoseLevel currentBloodGlucoseLevel: Double, carbohydratesInMeal: Double) {
        
        let calculator = Calculator(bloodGlucoseUnit: preferencesManager.bloodGlucoseUnit, carbohydrateFactor: preferencesManager.carbohydrateFactor, correctiveFactor: preferencesManager.correctiveFactor, desiredBloodGlucoseLevel: preferencesManager.desiredBloodGlucose, currentBloodGlucoseLevel: currentBloodGlucoseLevel, carbohydratesInMeal: carbohydratesInMeal)
        
        suggestedDoseLabel.text = "\(calculator.getSuggestedDose())"
        carbohydrateDoseLabel.text = "\(calculator.getCarbohydrateDose())"
        correctiveDoseLabel.text = "\(calculator.getCorrectiveDose())"
    }
}