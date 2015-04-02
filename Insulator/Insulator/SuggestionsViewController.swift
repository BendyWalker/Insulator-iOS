import UIKit

class SuggestionsViewController: UITableViewController {
    
    @IBOutlet weak var totalDailyDoseTextField: UITextField!
    @IBOutlet weak var carbohydrateFactorLabel: UILabel!
    @IBOutlet weak var correctiveFactorLabel: UILabel!
    
    let preferencesManager = PreferencesManager(store: PreferencesStore())
    
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
        let carbohydrateFactor: Double = (500 / totalDailyDose)
        
        let correctiveFactor: Double = {
            switch bloodGlucoseUnit {
            case .mmol: return (100 / totalDailyDose)
            case .mgdl: return ((100 / totalDailyDose) * 18)
            }
            }()
        
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
