import UIKit

class WelcomeViewController: UIViewController {
    let preferencesManager = PreferencesManager.sharedInstance
    let healthManager = HealthManager()
    
    
    @IBAction func authoriseHealthKit(sender: UIButton) {
        self.healthManager.authoriseHealthKit { (authorized, error) -> Void in
            if authorized {
                print("HealthKit authorization received.")
            } else {
                print("HealthKit authorization denied!")
                if error != nil {
                    print("\(error)")
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
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBAction func saveValuesToPreferenceManager(sender: UITextField) {
        if let carbohydrateFactorText = carbohydrateFactorTextField.text {
            let carbohydrateFactor = carbohydrateFactorText.doubleValue
            preferencesManager.carbohydrateFactor = carbohydrateFactor
        }
        
        if let correctiveFactorText = correctiveFactorTextField.text {
            let correctiveFactor = correctiveFactorText.doubleValue
            preferencesManager.correctiveFactor = correctiveFactor
        }
        
        if let desiredBloodGlucoseText = desiredBloodGlucoseTextField.text {
            let desiredBloodGlucose = desiredBloodGlucoseText.doubleValue
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
    }
    
    
    func keyboardWasShown(notification: NSNotification) {
        let info: NSDictionary = notification.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var rect = self.view.frame
        rect.size.height = (rect.size.height - keyboardSize.height)
        
        if !CGRectContainsPoint(rect, desiredBloodGlucoseTextField.frame.origin) {
            self.scrollView.scrollRectToVisible(desiredBloodGlucoseTextField.frame, animated: true)
        }
    }
    
    func addDecimal() {
        if let carbohydrateFactorText = carbohydrateFactorTextField.text {
            carbohydrateFactorTextField.text = addDecimalPlace(carbohydrateFactorText)
        }
        
        if preferencesManager.bloodGlucoseUnit == .mmol {
            if let correctiveFactorText = correctiveFactorTextField.text, desiredBloodGlucoseText = desiredBloodGlucoseTextField.text {
                correctiveFactorTextField.text = addDecimalPlace(correctiveFactorText)
                desiredBloodGlucoseTextField.text = addDecimalPlace(desiredBloodGlucoseText)
            }
        }
    }
}