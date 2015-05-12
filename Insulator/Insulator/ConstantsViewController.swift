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
    
    
    override func viewDidLoad() {
        carbohydrateFactorTextField.addTarget(self, action: "addDecimal", forControlEvents: UIControlEvents.EditingChanged)
        correctiveFactorTextField.addTarget(self, action: "addDecimal", forControlEvents: UIControlEvents.EditingChanged)
        desiredBloodGlucoseTextField.addTarget(self, action: "addDecimal", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        updateUi()

        tableView.estimatedRowHeight = 100
        tableView.reloadData()
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.reloadData()
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
    
    
    func addDecimal() {
        carbohydrateFactorTextField.text = addDecimalPlace(carbohydrateFactorTextField.text)
        
        if preferencesManager.bloodGlucoseUnit == .mmol {
            correctiveFactorTextField.text = addDecimalPlace(correctiveFactorTextField.text)
            desiredBloodGlucoseTextField.text = addDecimalPlace(desiredBloodGlucoseTextField.text)
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
    
    func addDecimalPlace(string: String) -> String {
        let point: Character = "."
        let zero: Character = "0"
        
        var index = 0
        var indexToRemove = 0
        var editedString = ""
        
        for character in string {
            if index == 0 {
                if character == zero {
                } else {
                    editedString.append(character)
                }
            } else if index > 0 {
                if character == point {
                } else {
                    editedString.append(character)
                }
            }
            index++
        }
        
        let length = count(editedString)
        index = 0
        var newString = ""
        
        for character in editedString {
            if length == 1 {
                newString += "0.\(character)"
            } else {
                if index == length - 1 {
                    newString.append(point)
                }
                newString.append(character)
            }
            
            index++
        }
        println(index)
        return newString
    }
}
