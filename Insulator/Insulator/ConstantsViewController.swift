import UIKit

class ConstantsTableViewController: UITableViewController {

    @IBOutlet weak var carbohydrateFactorTextField: UITextField!
    @IBOutlet weak var correctiveFactorTextField: UITextField!
    @IBOutlet weak var desiredBloodGlucoseTextField: UITextField!
    
    let preferencesManager = PreferencesManager(existingStore: PreferencesStore())
    
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
        updateDynamicViewElements()
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func updateDynamicViewElements() {
        let bloodGlucoseUnit = self.preferencesManager.bloodGlucoseUnit
        
        let placeholder: String = {
            switch bloodGlucoseUnit {
            case .mmol: return "mmol/L"
            case .mgdl: return "mg/dL"
            }
            }()
        
        correctiveFactorTextField.placeholder = placeholder
        desiredBloodGlucoseTextField.placeholder = placeholder
        
        // Update actual values with those stored by the preference manager
        carbohydrateFactorTextField.text = "\(preferencesManager.carbohydrateFactor)"
        correctiveFactorTextField.text = "\(preferencesManager.correctiveFactor)"
        desiredBloodGlucoseTextField.text = "\(preferencesManager.desiredBloodGlucose)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
