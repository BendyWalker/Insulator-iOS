import UIKit

class SuggestionsViewController: UITableViewController {
    
    @IBOutlet weak var totalDailyDoseTextField: UITextField!
    @IBOutlet weak var carbohydrateFactorLabel: UILabel!
    @IBOutlet weak var correctiveFactorLabel: UILabel!
    
    let preferencesManager = PreferencesManager.sharedInstance
    
    @IBAction func closeModal(sender: AnyObject) {
        let carbohydrateFactor = (carbohydrateFactorLabel.text! as NSString).doubleValue
        let correctiveFactor = (correctiveFactorLabel.text! as NSString).doubleValue
        
        preferencesManager.carbohydrateFactor = carbohydrateFactor
        preferencesManager.correctiveFactor = correctiveFactor
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        totalDailyDoseTextField.addTarget(self, action: "calculateSuggestions:", forControlEvents: UIControlEvents.AllEvents)
    }
    
    func calculateSuggestions(sender: UITextField) {
        let bloodGlucoseUnit = self.preferencesManager.bloodGlucoseUnit
        let totalDailyDose = (totalDailyDoseTextField.text as NSString).doubleValue
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
