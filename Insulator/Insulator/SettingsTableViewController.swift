import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var bloodGlucoseUnitSegmentedControl: UISegmentedControl!
    @IBOutlet weak var allowFloatingPointCarbohydratesSwitch: UISwitch!
    
    
    @IBAction func closeModal(sender: UIBarButtonItem) {
    }
    
    @IBAction func updateBloodGlucoseUnitPreference(sender: UISegmentedControl) {
    }
    
    @IBAction func updateAllowFloatingPointCarbohydratePreference(sender: UISwitch) {
    }
    
}