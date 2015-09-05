import UIKit

class ConstantsTableViewController: UITableViewController {
    let preferencesManager = PreferencesManager.sharedInstance


    @IBOutlet weak var carbohydrateFactorTextField: UITextField!
    @IBOutlet weak var correctiveFactorTextField: UITextField!
    @IBOutlet weak var desiredBloodGlucoseTextField: UITextField!
    
    
    @IBAction func closeModal(sender: AnyObject) {
        if let carbohydrateFactorText = carbohydrateFactorTextField.text {
            preferencesManager.carbohydrateFactor = carbohydrateFactorText.doubleValue
        }
        
        if let correctiveFactorText = correctiveFactorTextField.text {
            preferencesManager.correctiveFactor = correctiveFactorText.doubleValue
        }
        
        if let desiredBloodGlucoseText = desiredBloodGlucoseTextField.text {
            preferencesManager.desiredBloodGlucose = desiredBloodGlucoseText.doubleValue
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        carbohydrateFactorTextField.addTarget(self, action: "addDecimal", forControlEvents: UIControlEvents.EditingChanged)
        correctiveFactorTextField.addTarget(self, action: "addDecimal", forControlEvents: UIControlEvents.EditingChanged)
        desiredBloodGlucoseTextField.addTarget(self, action: "addDecimal", forControlEvents: UIControlEvents.EditingChanged)
        
        updateUi()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 3
        default: return 0
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                carbohydrateFactorTextField.becomeFirstResponder()
                carbohydrateFactorTextField.selectAll(self)
            case 1:
                correctiveFactorTextField.becomeFirstResponder()
                correctiveFactorTextField.selectAll(self)

            case 2:
                desiredBloodGlucoseTextField.becomeFirstResponder()
                desiredBloodGlucoseTextField.selectAll(self)

            default:
                return
            }
        default:
            return
        }
    }
    
    
    func addDecimal() {
        if let carbohydrateFactorText = carbohydrateFactorTextField.text {
            carbohydrateFactorTextField.text = addDecimalPlace(carbohydrateFactorText)
        }
        
        if preferencesManager.bloodGlucoseUnit == .mmol {
            if let correctiveFactorText = correctiveFactorTextField.text {
                correctiveFactorTextField.text = addDecimalPlace(correctiveFactorText)
            }
            
            if let desiredBloodGlucoseText = desiredBloodGlucoseTextField.text {
                desiredBloodGlucoseTextField.text = addDecimalPlace(desiredBloodGlucoseText)
            }
        }
    }
    
    func updateUi() {
        let bloodGlucoseUnit = preferencesManager.bloodGlucoseUnit
        let placeholder: String = bloodGlucoseUnit.rawValue

        correctiveFactorTextField.placeholder = placeholder
        desiredBloodGlucoseTextField.placeholder = placeholder
        
        carbohydrateFactorTextField.text = "\(preferencesManager.carbohydrateFactor)"
        correctiveFactorTextField.text = "\(preferencesManager.correctiveFactor)"
        desiredBloodGlucoseTextField.text = "\(preferencesManager.desiredBloodGlucose)"
    }
}
