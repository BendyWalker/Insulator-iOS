import UIKit

class ConstantsTableViewController: UITableViewController {
    let preferencesManager = PreferencesManager.sharedInstance


    @IBOutlet weak var carbohydrateFactorTextField: UITextField!
    @IBOutlet weak var correctiveFactorTextField: UITextField!
    @IBOutlet weak var desiredBloodGlucoseTextField: UITextField!
    
    
    @IBAction func closeModal(sender: AnyObject) {
        let carbohydrateFactor = (carbohydrateFactorTextField.text as NSString).doubleValue
        let correctiveFactor = (correctiveFactorTextField.text as NSString).doubleValue
        let desiredBloodGlucose = (desiredBloodGlucoseTextField.text as NSString).doubleValue
        
        preferencesManager.carbohydrateFactor = carbohydrateFactor
        preferencesManager.correctiveFactor = correctiveFactor
        preferencesManager.desiredBloodGlucose = desiredBloodGlucose
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        updateUi()
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
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
    
    
    func updateUi() {
        let bloodGlucoseUnit = preferencesManager.bloodGlucoseUnit
        let placeholder: String = bloodGlucoseUnit.rawValue
        var keyboardType: UIKeyboardType
        
        switch bloodGlucoseUnit {
        case .mmol: keyboardType = .DecimalPad
        case .mgdl: keyboardType = .NumberPad
        }
        
        correctiveFactorTextField.placeholder = placeholder
        desiredBloodGlucoseTextField.placeholder = placeholder
        correctiveFactorTextField.keyboardType = keyboardType
        desiredBloodGlucoseTextField.keyboardType = keyboardType
        
        carbohydrateFactorTextField.text = "\(preferencesManager.carbohydrateFactor)"
        correctiveFactorTextField.text = "\(preferencesManager.correctiveFactor)"
        desiredBloodGlucoseTextField.text = "\(preferencesManager.desiredBloodGlucose)"
    }
}
