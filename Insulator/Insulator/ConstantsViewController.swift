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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
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
    
    func keyboardWasShown(notification: NSNotification) {
        let info: NSDictionary = notification.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
        
        var rect = self.view.frame
        rect.size.height = (rect.size.height - keyboardSize.height)
        
        if !CGRectContainsPoint(rect, desiredBloodGlucoseTextField.frame.origin) {
            self.tableView.scrollRectToVisible(desiredBloodGlucoseTextField.frame, animated: true)
        }
    }
}
