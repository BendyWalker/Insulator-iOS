import UIKit

class WelcomeViewController: UIViewController {
    let preferencesManager = PreferencesManager.sharedInstance
    let healthManager = HealthManager()
    
    
    @IBAction func authoriseHealthKit(sender: UIButton) {
        self.healthManager.authoriseHealthKit { (authorized, error) -> Void in
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
    
    @IBAction func bloodGlucoseUnitSegmentedControlValueChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: preferencesManager.bloodGlucoseUnit = .mmol
        case 1: preferencesManager.bloodGlucoseUnit = .mgdl
        default: preferencesManager.bloodGlucoseUnit = BloodGlucoseUnit.defaultUnit()
        }
    }
    
    @IBAction func allowFloatingPointCarbohydratesSwitchValueChanged(sender: UISwitch) {
        preferencesManager.allowFloatingPointCarbohydrates = sender.on
    }
    
    @IBAction func closeModal(sender: UIBarButtonItem) {
        if let build = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String {
            preferencesManager.buildNumber = build
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

class ConstantsWelcomeViewController: UIViewController {
    let preferencesManager = PreferencesManager.sharedInstance
    
    
    @IBOutlet weak var carbohydrateFactorTextField: UITextField!
    @IBOutlet weak var correctiveFactorTextField: UITextField!
    @IBOutlet weak var desiredBloodGlucoseTextField: UITextField!
    
    
    @IBAction func saveValuesToPreferenceManager(sender: UITextField) {
        if let carbohydrateFactorText = carbohydrateFactorTextField.text {
            let carbohydrateFactor = (carbohydrateFactorText as NSString).doubleValue
            preferencesManager.carbohydrateFactor = carbohydrateFactor
        }
        
        if let correctiveFactorText = correctiveFactorTextField.text {
            let correctiveFactor = (correctiveFactorText as NSString).doubleValue
            preferencesManager.correctiveFactor = correctiveFactor
        }
        
        if let desiredBloodGlucoseText = desiredBloodGlucoseTextField.text {
            let desiredBloodGlucose = (desiredBloodGlucoseText as NSString).doubleValue
            preferencesManager.desiredBloodGlucose = desiredBloodGlucose
        }
    }
    
    
    override func viewDidLoad() {
        carbohydrateFactorTextField.addTarget(self, action: "addDecimal", forControlEvents: UIControlEvents.EditingChanged)
        correctiveFactorTextField.addTarget(self, action: "addDecimal", forControlEvents: UIControlEvents.EditingChanged)
        desiredBloodGlucoseTextField.addTarget(self, action: "addDecimal", forControlEvents: UIControlEvents.EditingChanged)
        
        let placeholder = preferencesManager.bloodGlucoseUnit.rawValue
        correctiveFactorTextField.placeholder = placeholder
        desiredBloodGlucoseTextField.placeholder = placeholder
    }
    
    
    func addDecimal() {
        carbohydrateFactorTextField.text = addDecimalPlace(carbohydrateFactorTextField.text)
        
        if preferencesManager.bloodGlucoseUnit == .mmol {
            correctiveFactorTextField.text = addDecimalPlace(correctiveFactorTextField.text)
            desiredBloodGlucoseTextField.text = addDecimalPlace(desiredBloodGlucoseTextField.text)
        }
    }
}