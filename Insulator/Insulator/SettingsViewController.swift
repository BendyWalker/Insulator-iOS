import UIKit
import StoreKit
import MessageUI

class SettingsTableViewController: UITableViewController, SKProductsRequestDelegate, MFMailComposeViewControllerDelegate {
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
        
        let priceFormatter = NSNumberFormatter()
        priceFormatter.formatterBehavior = NSNumberFormatterBehavior.Behavior10_4
        priceFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        
        for product in products {
            priceFormatter.locale = product.priceLocale
            switch product.productIdentifier {
            case "small_tip":
                smallTipPriceLabel.text = priceFormatter.stringFromNumber(product.price)
                smallTipPriceLabel.hidden = false
                smallTipPriceActivityIndicator.stopAnimating()
            case "large_tip":
                largeTipPriceLabel.text = priceFormatter.stringFromNumber(product.price)
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
                let mailComposer = MFMailComposeViewController()
                mailComposer.mailComposeDelegate = self
                mailComposer.setToRecipients(["mail@insulatorapp.com"])
                self.presentViewController(mailComposer, animated: true, completion: nil)
            case 1:
                UIApplication.sharedApplication().openURL(NSURL(string: "http://www.twitter.com/insulatorapp")!)
            case 2:
                println("App Store")
            default:
                return
            }
        case 2:
            switch indexPath.row {
            case 0:
                for product in products {
                    if product.productIdentifier == "small_tip" {
                        let payment = SKPayment(product: product)
                        SKPaymentQueue.defaultQueue().addPayment(payment)
                    }
                }
            case 1:
                for product in products {
                    if product.productIdentifier == "large_tip" {
                        let payment = SKPayment(product: product)
                        SKPaymentQueue.defaultQueue().addPayment(payment)
                    }
                }
            default:
                return
            }
        default:
            return
        }
        
        tableView.reloadData()
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func updateBloodGlucoseUnitLabel() {
        bloodGlucoseUnitLabel.text = preferencesManager.bloodGlucoseUnit.rawValue
        tableView.reloadData()
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