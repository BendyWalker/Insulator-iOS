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
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
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