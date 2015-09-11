import UIKit

class SuggestionsViewController: UITableViewController {
    var saveCarbohydrateFactor = false
    var saveCorrectiveFactor = false
    
    let preferencesManager = PreferencesManager.sharedInstance

    
    @IBOutlet weak var totalDailyDoseTextField: UITextField!
    @IBOutlet weak var carbohydrateFactorLabel: UILabel!
    @IBOutlet weak var correctiveFactorLabel: UILabel!
    @IBOutlet weak var carbohydrateFactorTableViewCell: UITableViewCell!
    @IBOutlet weak var correctiveFactorTableViewCell: UITableViewCell!
    
    @IBAction func onRightBarButtonTouched(sender: UIBarButtonItem) {
        if totalDailyDoseTextField.editing {
            totalDailyDoseTextField.resignFirstResponder()
        } else {
            if let carbohydrateFactorText = carbohydrateFactorLabel.text {
                if saveCarbohydrateFactor { preferencesManager.carbohydrateFactor = carbohydrateFactorText.doubleValue }
            }
            
            if let correctiveFactorText = correctiveFactorLabel.text {
                if saveCorrectiveFactor { preferencesManager.correctiveFactor = correctiveFactorText.doubleValue }
            }
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        totalDailyDoseTextField.addTarget(self, action: "calculateSuggestions:", forControlEvents: UIControlEvents.AllEvents)
        
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
        
        
        totalDailyDoseTextField.font = bodyMonospacedNumbersFont
        carbohydrateFactorLabel.font = bodyMonospacedNumbersFont
        correctiveFactorLabel.font = bodyMonospacedNumbersFont
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.estimatedRowHeight = 100
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 2
        default: return 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                self.totalDailyDoseTextField.becomeFirstResponder()
                self.totalDailyDoseTextField.selectAll(self)
            default:
                return
            }
        case 1:
            switch indexPath.row {
            case 0:
                saveCarbohydrateFactor = !saveCarbohydrateFactor
                if saveCarbohydrateFactor {
                    carbohydrateFactorTableViewCell.accessoryType = .Checkmark
                } else {
                    carbohydrateFactorTableViewCell.accessoryType = .None
                }
            case 1:
                saveCorrectiveFactor = !saveCorrectiveFactor
                if saveCorrectiveFactor {
                    correctiveFactorTableViewCell.accessoryType = .Checkmark
                } else {
                    correctiveFactorTableViewCell.accessoryType = .None
                }
            default:
                return
            }
            tableView.reloadData()
        default:
            return
        }
    }
    
    
    func calculateSuggestions(sender: UITextField) {
        let bloodGlucoseUnit = self.preferencesManager.bloodGlucoseUnit
        
        if let totalDailyDoseText = totalDailyDoseTextField.text {
            let totalDailyDose = totalDailyDoseText.doubleValue
            let calculator = Calculator(bloodGlucoseUnit: bloodGlucoseUnit, totalDailyDose: totalDailyDose)
            var carbohydrateFactorString: String
            var correctiveFactorString: String
            
            if totalDailyDose == 0 {
                carbohydrateFactorString = "0.0";
                correctiveFactorString = "0.0";
            } else {
                carbohydrateFactorString = "\(calculator.getCarbohydrateFactor())";
                correctiveFactorString = "\(calculator.getCorrectiveFactor())";
            }
            
            carbohydrateFactorLabel.text = carbohydrateFactorString
            correctiveFactorLabel.text = correctiveFactorString
        }
    }
}
