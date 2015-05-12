import UIKit
import StoreKit
import MessageUI
import Social

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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUi", name: PreferencesDidChangeNotification, object: nil)
        
        updateUi()
        
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers: Set = ["small_tip", "large_tip"]
            let productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
            productsRequest.delegate = self
            productsRequest.start()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.estimatedRowHeight = 100
        tableView.reloadData()
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.reloadData()
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
        if SKPaymentQueue.canMakePayments() {
            return 3
        } else {
            return 2
        }
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
                displayComposeMailViewController()
            case 1:
                displayTwitterActionSheet()
            case 2:
                openAppStoreAtReviews()
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
    
    
    func displayComposeMailViewController() {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setToRecipients(["mail@insulatorapp.com"])
        self.presentViewController(mailComposer, animated: true, completion: nil)
    }
    
    func displayTwitterActionSheet() {
        let viewProfileAlertAction = UIAlertAction(title: "View Profile", style: .Default) { alertAction in
            let twitterWebViewController = TwitterWebViewController()
            self.presentViewController(twitterWebViewController, animated: true, completion: nil)
        }
        
        let sendTweetAlertAction = UIAlertAction(title: "Send Tweet", style: .Default) { alertAction in
            let composeTweetViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            composeTweetViewController.setInitialText("@insulatorapp ")
            self.presentViewController(composeTweetViewController, animated: true, completion: nil)
        }
        
        let twitterAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        twitterAlertController.addAction(sendTweetAlertAction)
        twitterAlertController.addAction(viewProfileAlertAction)
        twitterAlertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(twitterAlertController, animated: true, completion: nil)
    }
    
    func openAppStoreAtReviews() {
        let identifer = 978321797
        UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&id=\(identifer)")!)
    }
    
    func updateUi() {
        bloodGlucoseUnitLabel.text = preferencesManager.bloodGlucoseUnit.rawValue
        allowFloatingPointCarbohydratesSwitch.on = preferencesManager.allowFloatingPointCarbohydrates

    }
}

class TwitterWebViewController: UINavigationController {
    let webView = UIWebView()
    let viewController = UIViewController()
    
    override func viewDidLoad() {
        viewController.view = webView
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "closeModal")
        self.showViewController(viewController, sender: nil)
        let urlRequest = NSURLRequest(URL: NSURL(string: "http://www.twitter.com/insulatorapp")!)
        webView.loadRequest(urlRequest)
    }
    
    func closeModal() {
        self.dismissViewControllerAnimated(true, completion: nil)
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