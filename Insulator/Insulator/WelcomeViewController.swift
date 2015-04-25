import UIKit

class WelcomeViewController: UIViewController {
    let preferencesManager = PreferencesManager.sharedInstance
    
    
    @IBOutlet weak var carbohydrateFactorTextField: UITextField!
    @IBOutlet weak var correctiveFactorTextField: UITextField!
    @IBOutlet weak var desiredBloodGlucoseTextField: UITextField!
    
    
    @IBAction func bloodGlucoseUnitSegmentedControlValueChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: preferencesManager.bloodGlucoseUnit = .mmol
        case 1: preferencesManager.bloodGlucoseUnit = .mgdl
        default: preferencesManager.bloodGlucoseUnit = BloodGlucoseUnit.defaultUnit()
        }
        
        preferencesManager.outputToLog()
    }
    
    @IBAction func allowFloatingPointCarbohydratesSwitchValueChanged(sender: UISwitch) {
        preferencesManager.allowFloatingPointCarbohydrates = sender.enabled
        preferencesManager.outputToLog()
    }
    
    @IBAction func displayHealthDataAuthorisation(sender: UIButton) {
    }
    
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
        
        preferencesManager.outputToLog()
    }
    
    @IBAction func closeWelcomeWizard(sender: UIButton) {
        if let build = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String {
            preferencesManager.buildNumber = build
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        preferencesManager.bloodGlucoseUnit = BloodGlucoseUnit.defaultUnit()
        preferencesManager.allowFloatingPointCarbohydrates = false
    }
}