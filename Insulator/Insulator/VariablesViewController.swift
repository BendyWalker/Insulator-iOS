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
        super.viewDidLoad()
        
        currentBloodGlucoseLevelTextField.addTarget(self, action: "attemptDoseCalculation", forControlEvents: UIControlEvents.EditingChanged)
        currentBloodGlucoseLevelTextField.addTarget(self, action: "toggleRightBarButtonItem", forControlEvents: UIControlEvents.EditingDidBegin)
        currentBloodGlucoseLevelTextField.addTarget(self, action: "toggleRightBarButtonItem", forControlEvents: UIControlEvents.EditingDidEnd)
        carbohydratesInMealTextField.addTarget(self, action: "attemptDoseCalculation", forControlEvents: UIControlEvents.EditingChanged)
        carbohydratesInMealTextField.addTarget(self, action: "toggleRightBarButtonItem", forControlEvents: UIControlEvents.EditingDidBegin)
        carbohydratesInMealTextField.addTarget(self, action: "toggleRightBarButtonItem", forControlEvents: UIControlEvents.EditingDidEnd)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUi", name: PreferencesDidChangeNotification, object: nil)
        
        updateUi()
        
        if let build = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String {
            if preferencesManager.buildNumber != build {
                self.performSegueWithIdentifier("welcome", sender: AnyObject?())
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
                checkHealthKitAuthorisation()
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
        currentBloodGlucoseLevelTextField.placeholder = preferencesManager.bloodGlucoseUnit.rawValue
    }
    
    func clearFields() {
        currentBloodGlucoseLevelTextField.text = ""
        carbohydratesInMealTextField.text = ""
        suggestedDoseLabel.text = "0.0"
        carbohydrateDoseLabel.text = "0.0"
        correctiveDoseLabel.text = "0.0"
        
        self.view.endEditing(true)
    }
    
    func checkHealthKitAuthorisation() {
        self.healthManager.authoriseHealthKit { (authorized, error) -> Void in
            if authorized {
                println("HealthKit authorization received.")
                self.updateCurrentBloodGlucoseTextFieldFromHealthKit()
            } else {
                println("HealthKit authorization denied!")
                if error != nil {
                    println("\(error)")
                }
            }
        }
    }
    
    func updateCurrentBloodGlucoseTextFieldFromHealthKit() {
        healthManager.queryBloodGlucose() { bloodGlucose in
            if bloodGlucose != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.currentBloodGlucoseLevelTextField.text = "\(bloodGlucose!)"
                    self.attemptDoseCalculation()
                });
            } else {
                let alertView = UIAlertController(title: "No Data Found", message: "Insulator cannot find any Blood Glucose data in Health. This may be because you have denied access to Health data. To allow access, please open Health and change your settings.", preferredStyle: UIAlertControllerStyle.Alert)
                let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alertView.addAction(okButton)
                self.presentViewController(alertView, animated: true, completion: nil)
            }
        }
    }
    
    func attemptDoseCalculation() {
        if let currentBloodGlucoseLevelText = currentBloodGlucoseLevelTextField.text {
            if let carbohydratesInMealText = carbohydratesInMealTextField.text {
                let bloodGlucoseLevel = (currentBloodGlucoseLevelText as NSString).doubleValue
                let carbohydrates = (carbohydratesInMealText as NSString).doubleValue
                
                if preferencesManager.bloodGlucoseUnit == .mmol {
                currentBloodGlucoseLevelTextField.text = addDecimalPlace(currentBloodGlucoseLevelTextField.text)
                }
                
                if preferencesManager.allowFloatingPointCarbohydrates {
                    carbohydratesInMealTextField.text = addDecimalPlace(carbohydratesInMealTextField.text)
                }
                
                calculateDose(currentBloodGlucoseLevel: bloodGlucoseLevel, carbohydratesInMeal: carbohydrates)
            }
        }
    }
    
    func calculateDose(#currentBloodGlucoseLevel: Double, carbohydratesInMeal: Double) {
        
        let calculator = Calculator(bloodGlucoseUnit: preferencesManager.bloodGlucoseUnit, carbohydrateFactor: preferencesManager.carbohydrateFactor, correctiveFactor: preferencesManager.correctiveFactor, desiredBloodGlucoseLevel: preferencesManager.desiredBloodGlucose, currentBloodGlucoseLevel: currentBloodGlucoseLevel, carbohydratesInMeal: carbohydratesInMeal)
        
        suggestedDoseLabel.text = "\(calculator.getSuggestedDose())"
        carbohydrateDoseLabel.text = "\(calculator.getCarbohydrateDose())"
        correctiveDoseLabel.text = "\(calculator.getCorrectiveDose())"
    }
    
    func addDecimalPlace(string: String) -> String {
        let point: Character = "."
        let zero: Character = "0"
        
        var index = 0
        var indexToRemove = 0
        var editedString = ""
        
        for character in string {
            if index == 0 {
                if character == zero {
                } else {
                editedString.append(character)
                }
            } else if index > 0 {
                if character == point {
                } else {
                    editedString.append(character)
                }
            }
            index++
        }
        
        let length = count(editedString)
        index = 0
        var newString = ""
        
        for character in editedString {
            if length == 1 {
                newString += "0.\(character)"
            } else {
                if index == length - 1 {
                    newString.append(point)
                }
                newString.append(character)
            }
            
            index++
        }
        println(index)
        return newString
    }
}