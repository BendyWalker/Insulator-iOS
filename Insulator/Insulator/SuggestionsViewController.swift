import UIKit

class SuggestionsViewController: UITableViewController {
    
    @IBOutlet weak var totalDailyDoseTextField: UITextField!
    @IBOutlet weak var carbohydrateFactorLabel: UILabel!
    @IBOutlet weak var correctiveFactorLabel: UILabel!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    @IBAction func closeModal(sender: AnyObject) {
        let carbohydrateFactor = (carbohydrateFactorLabel.text! as NSString).doubleValue
        let correctiveFactor = (correctiveFactorLabel.text! as NSString).doubleValue
        
        userDefaults.setValue(carbohydrateFactor, forKey: "carbohydrate_factor_preference")
        userDefaults.setValue(correctiveFactor, forKey: "corrective_factor_preference")
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        totalDailyDoseTextField.addTarget(self, action: "calculateSuggestions:", forControlEvents: UIControlEvents.AllEvents)
    }
    
    func calculateSuggestions(sender: UITextField) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let bloodGlucoseUnit = userDefaults.valueForKey("blood_glucose_units_preference") as String
        let isMmolSelected = bloodGlucoseUnit.isEqual("mmol")
        
        let totalDailyDose = (totalDailyDoseTextField.text as NSString).doubleValue
        
        let carbohydrateFactor: Double = (500 / totalDailyDose)
        var correctiveFactor: Double
        
        if isMmolSelected {
            correctiveFactor = (100 / totalDailyDose)
        } else {
            correctiveFactor = ((100 / totalDailyDose) * 18)
        }
        
        var carbohydrateFactorString: String
        var correctiveFactorString: String
        
        if totalDailyDose == 0 {
            carbohydrateFactorString = "0.0";
            correctiveFactorString = "0.0";
        } else {
            carbohydrateFactorString = String(format: "%.1f", carbohydrateFactor);
            correctiveFactorString = String(format: "%.1f", correctiveFactor);
        }
        
        carbohydrateFactorLabel.text = carbohydrateFactorString
        correctiveFactorLabel.text = correctiveFactorString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
