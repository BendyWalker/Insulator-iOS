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
    
    @IBAction func closeModal(sender: UIBarButtonItem) {
        let carbohydrateFactor = (carbohydrateFactorLabel.text! as NSString).doubleValue
        let correctiveFactor = (correctiveFactorLabel.text! as NSString).doubleValue
        
        if saveCarbohydrateFactor { preferencesManager.carbohydrateFactor = carbohydrateFactor }
        if saveCorrectiveFactor { preferencesManager.correctiveFactor = correctiveFactor }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        totalDailyDoseTextField.addTarget(self, action: "calculateSuggestions:", forControlEvents: UIControlEvents.AllEvents)
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.estimatedRowHeight = 44
        tableView.reloadData()
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.reloadData()
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
}
