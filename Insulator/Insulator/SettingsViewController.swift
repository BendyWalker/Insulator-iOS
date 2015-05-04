import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var allowFloatingPointCarbohydratesSwitch: UISwitch!
    
    
    @IBAction func closeModal(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func updateBloodGlucoseUnitPreference(sender: UISegmentedControl) {
    }
    
    @IBAction func updateAllowFloatingPointCarbohydratePreference(sender: UISwitch) {
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
}

class BloodGlucoseUnitTableViewController: UITableViewController {
    
}