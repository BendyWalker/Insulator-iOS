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
    
    @IBAction func closeModal(sender: UIBarButtonItem) {
        if let build = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String {
            preferencesManager.buildNumber = build
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

class PreferencesWelcomeTableViewController: UITableViewController {
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
        
        updatePlaceholder()
    }
    
    @IBAction func allowFloatingPointCarbohydratesSwitchValueChanged(sender: UISwitch) {
        preferencesManager.allowFloatingPointCarbohydrates = sender.on
    }
    
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
        
        let bodyFontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
        let bodyMonospacedNumbersFontDescriptor = bodyFontDescriptor.fontDescriptorByAddingAttributes(
            [
                UIFontDescriptorFeatureSettingsAttribute: [
                    [
                        UIFontFeatureTypeIdentifierKey: kNumberSpacingType,
                        UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector
                    ]
                ]
            ])
        let bodyMonospacedNumbersFont = UIFont(descriptor: bodyMonospacedNumbersFontDescriptor, size: 0.0)

        
        carbohydrateFactorTextField.font = bodyMonospacedNumbersFont
        correctiveFactorTextField.font = bodyMonospacedNumbersFont
        desiredBloodGlucoseTextField.font = bodyMonospacedNumbersFont
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 3
        default: return 0
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
    
    func updatePlaceholder() {
        let placeholder = preferencesManager.bloodGlucoseUnit.rawValue
        correctiveFactorTextField.placeholder = placeholder
        desiredBloodGlucoseTextField.placeholder = placeholder
    }
}