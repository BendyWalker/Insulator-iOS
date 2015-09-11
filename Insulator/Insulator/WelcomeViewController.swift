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
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    
    
    @IBAction func onRightBarButtonTouched(sender: AnyObject) {
        if carbohydrateFactorTextField.editing {
            carbohydrateFactorTextField.resignFirstResponder()
        } else if correctiveFactorTextField.editing {
            carbohydrateFactorTextField.resignFirstResponder()
        } else if desiredBloodGlucoseTextField.editing {
            desiredBloodGlucoseTextField.resignFirstResponder()
        } else {
            if let carbohydrateFactorText = carbohydrateFactorTextField.text {
                preferencesManager.carbohydrateFactor = carbohydrateFactorText.doubleValue
            }
            
            if let correctiveFactorText = correctiveFactorTextField.text {
                preferencesManager.correctiveFactor = correctiveFactorText.doubleValue
            }
            
            if let desiredBloodGlucoseText = desiredBloodGlucoseTextField.text {
                preferencesManager.desiredBloodGlucose = desiredBloodGlucoseText.doubleValue
            }
            
            performSegueWithIdentifier("ReadyToUse", sender: UIBarButtonItem())
        }
    }
    
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
    
    
    override func viewDidLoad() {
        carbohydrateFactorTextField.addTarget(self, action: "addDecimal", forControlEvents: UIControlEvents.EditingChanged)
        carbohydrateFactorTextField.addTarget(self, action: "toggleRightBarButtonItem", forControlEvents: UIControlEvents.EditingDidBegin)
        carbohydrateFactorTextField.addTarget(self, action: "toggleRightBarButtonItem", forControlEvents: UIControlEvents.EditingDidEnd)
        
        correctiveFactorTextField.addTarget(self, action: "addDecimal", forControlEvents: UIControlEvents.EditingChanged)
        correctiveFactorTextField.addTarget(self, action: "toggleRightBarButtonItem", forControlEvents: UIControlEvents.EditingDidBegin)
        correctiveFactorTextField.addTarget(self, action: "toggleRightBarButtonItem", forControlEvents: UIControlEvents.EditingDidEnd)
        
        desiredBloodGlucoseTextField.addTarget(self, action: "addDecimal", forControlEvents: UIControlEvents.EditingChanged)
        desiredBloodGlucoseTextField.addTarget(self, action: "toggleRightBarButtonItem", forControlEvents: UIControlEvents.EditingDidBegin)
        desiredBloodGlucoseTextField.addTarget(self, action: "toggleRightBarButtonItem", forControlEvents: UIControlEvents.EditingDidEnd)
        
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
        
        toggleRightBarButtonItem()
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
    
    func toggleRightBarButtonItem() {
        if carbohydrateFactorTextField.editing || correctiveFactorTextField.editing || desiredBloodGlucoseTextField.editing {
            rightBarButtonItem.style = UIBarButtonItemStyle.Done
            rightBarButtonItem.title = "Done"
            rightBarButtonItem.enabled = true
        } else {
            rightBarButtonItem.style = UIBarButtonItemStyle.Plain
            rightBarButtonItem.title = "Next"
            rightBarButtonItem.enabled = (!carbohydrateFactorTextField.text!.isEmpty) && (!correctiveFactorTextField.text!.isEmpty) && (!desiredBloodGlucoseTextField.text!.isEmpty)
        }
    }
}