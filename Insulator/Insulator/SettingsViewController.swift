import UIKit

class SettingsTableViewController: UITableViewController {
    let preferencesManager = PreferencesManager.sharedInstance
    
    
    @IBOutlet weak var bloodGlucoseUnitLabel: UILabel!
    @IBOutlet weak var allowFloatingPointCarbohydratesSwitch: UISwitch!
    
    
    @IBAction func closeModal(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func updateAllowFloatingPointCarbohydratePreference(sender: UISwitch) {
        preferencesManager.allowFloatingPointCarbohydrates = sender.on
    }
    
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateBloodGlucoseUnitLabel", name: PreferencesDidChangeNotification, object: nil)
        
        allowFloatingPointCarbohydratesSwitch.on = preferencesManager.allowFloatingPointCarbohydrates
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: PreferencesDidChangeNotification, object: nil)
    }
    
    
    func updateBloodGlucoseUnitLabel() {
        bloodGlucoseUnitLabel.text = preferencesManager.bloodGlucoseUnit.rawValue
    }
}


class BloodGlucoseUnitTableViewController: UITableViewController {
    let preferencesManager = PreferencesManager.sharedInstance
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BloodGlucoseUnit.count()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("BloodGlucoseUnitCell") as! UITableViewCell
        
        if let bloodGlucoseUnit = BloodGlucoseUnit.fromInt(indexPath.row) {
            cell.textLabel?.text = bloodGlucoseUnit.rawValue

            if bloodGlucoseUnit == preferencesManager.bloodGlucoseUnit {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var currentBloodGlucoseUnit = preferencesManager.bloodGlucoseUnit
        var desiredBloodGlucose = preferencesManager.desiredBloodGlucose
        var correctiveFactor = preferencesManager.correctiveFactor
        let calculator = Calculator(bloodGlucoseUnit: currentBloodGlucoseUnit)
        
        if let selectedBloodGlucoseUnit = BloodGlucoseUnit.fromInt(indexPath.row) {
            switch selectedBloodGlucoseUnit {
            case .mmol:
                if currentBloodGlucoseUnit != .mmol {
                    currentBloodGlucoseUnit = .mmol;
                    desiredBloodGlucose = calculator.roundDouble(desiredBloodGlucose / calculator.mgdlConversionValue)
                    correctiveFactor = calculator.roundDouble(correctiveFactor / calculator.mgdlConversionValue);
                }
            case .mgdl:
                if currentBloodGlucoseUnit != .mgdl {
                    currentBloodGlucoseUnit = .mgdl;
                    desiredBloodGlucose = calculator.roundDouble(desiredBloodGlucose * calculator.mgdlConversionValue)
                    correctiveFactor = calculator.roundDouble(correctiveFactor * calculator.mgdlConversionValue);
                }
            }
            
            preferencesManager.bloodGlucoseUnit = currentBloodGlucoseUnit
            preferencesManager.desiredBloodGlucose = desiredBloodGlucose
            preferencesManager.correctiveFactor = correctiveFactor
        }
        
        tableView.reloadData()
    }
}