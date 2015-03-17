import UIKit

class VariablesTableViewController: UITableViewController {
    
    let healthManager = HealthManager()
        
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
    
    @IBAction func authorizeHealthKit(sender: AnyObject) {
        healthManager.authoriseHealthKit { (authorized, error) -> Void in
            if authorized {
                println("HealthKit authorization received.")
            } else {
                println("HealthKit authorization denied!")
                if error != nil {
                    println("\(error)")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateBloodGlucoseUnitPlaceholder()
        
        currentBloodGlucoseLevelTextField.addTarget(self, action: "calculateDose:", forControlEvents: UIControlEvents.EditingChanged)
        carbohydratesInMealTextField.addTarget(self, action: "calculateDose:", forControlEvents: UIControlEvents.EditingChanged)
        
        self.navigationController?.toolbarHidden = false
    }
    
    func calculateDose(sender: UITextField) {
        let currentBloodGlucoseLevel = (currentBloodGlucoseLevelTextField.text as NSString).doubleValue
        let carbohydratesInMeal = (carbohydratesInMealTextField.text as NSString).doubleValue
        
        let calculator = Calculator(currentBloodGlucoseLevel: currentBloodGlucoseLevel, carbohydratesInMeal: carbohydratesInMeal)
        let suggestedDose: String = "\(calculator.getSuggestedDose(true))"
        let carbohydrateDose: String = "\(calculator.getCarbohydrateDose(true))"
        let correctiveDose: String = "\(calculator.getCorrectiveDose(true))"
        
        suggestedDoseLabel.text = suggestedDose
        carbohydrateDoseLabel.text = carbohydrateDose
        correctiveDoseLabel.text = correctiveDose
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "defaultsDidChange:", name: NSUserDefaultsDidChangeNotification, object: nil)
        
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func defaultsDidChange(notification: NSNotification) {
        updateBloodGlucoseUnitPlaceholder()
    }
    
    func updateBloodGlucoseUnitPlaceholder() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let bloodGlucoseUnit = userDefaults.valueForKey("blood_glucose_units_preference") as String
        let isMmolSelected = bloodGlucoseUnit.isEqual("mmol")
        
        var placeholder : String
        
        if isMmolSelected {
            placeholder = "mmol/L"
        } else {
            placeholder = "mg/dL"
        }
        
        currentBloodGlucoseLevelTextField.placeholder = placeholder
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

