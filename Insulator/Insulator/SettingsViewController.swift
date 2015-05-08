import UIKit
import StoreKit

class SettingsTableViewController: UITableViewController, SKProductsRequestDelegate {
    var products: [SKProduct] = []
    
    let preferencesManager = PreferencesManager.sharedInstance
    
    @IBOutlet weak var bloodGlucoseUnitLabel: UILabel!
    @IBOutlet weak var allowFloatingPointCarbohydratesSwitch: UISwitch!
    @IBOutlet weak var smallTipPriceLabel: UILabel!
    @IBOutlet weak var largeTipPriceLabel: UILabel!
    @IBOutlet weak var smallTipPriceActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var largeTipPriceActivityIndicator: UIActivityIndicatorView!
    
    
    @IBAction func closeModal(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func updateAllowFloatingPointCarbohydratePreference(sender: UISwitch) {
        preferencesManager.allowFloatingPointCarbohydrates = sender.on
    }
    
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateBloodGlucoseUnitLabel", name: PreferencesDidChangeNotification, object: nil)
        
        allowFloatingPointCarbohydratesSwitch.on = preferencesManager.allowFloatingPointCarbohydrates
        
        let productIdentifiers: Set = ["small_tip", "large_tip"]
        let productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: PreferencesDidChangeNotification, object: nil)
    }
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        products = response.products as! [SKProduct]
        
        for product in products {
            switch product.productIdentifier {
            case "small_tip":
                smallTipPriceLabel.text = product.price.description
                smallTipPriceLabel.hidden = false
                smallTipPriceActivityIndicator.stopAnimating()
            case "large_tip":
                largeTipPriceLabel.text = product.price.description
                largeTipPriceLabel.hidden = false
                largeTipPriceActivityIndicator.stopAnimating()
            default:
                smallTipPriceLabel.text = ""
                largeTipPriceLabel.text = ""
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 3
        case 2: return 2
        default: return 0
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                println("Email")
            case 1:
                println("Twitter")
            case 2:
                println("App Store")
            default:
                return
            }
        case 2:
            switch indexPath.row {
            case 0:
                println("Small Tip")
            case 1:
                println("Large Tip")
            default:
                return
            }
        default:
            return
        }
        
        tableView.reloadData()
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
        if let bloodGlucoseUnit = BloodGlucoseUnit.fromInt(indexPath.row) {
            preferencesManager.bloodGlucoseUnit = bloodGlucoseUnit
        }
        
        tableView.reloadData()
    }
}