//
//  ConstantsViewController.swift
//  Insulator
//
//  Created by Ben Walker on 26/01/2015.
//  Copyright (c) 2015 Ben David Walker. All rights reserved.
//

import UIKit

class ConstantsViewController: UIViewController {

    @IBOutlet weak var carbohydrateFactorTextField: UITextField!
    @IBOutlet weak var correctiveFactorTextField: UITextField!
    @IBOutlet weak var desiredBloodGlucoseTextField: UITextField!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    @IBAction func closeModal(sender: AnyObject) {
        let carbohydrateFactor = (carbohydrateFactorTextField.text as NSString).doubleValue
        let correctiveFactor = (correctiveFactorTextField.text as NSString).doubleValue
        let desiredBloodGlucose = (desiredBloodGlucoseTextField.text as NSString).doubleValue
        
        userDefaults.setValue(carbohydrateFactor, forKey: "carbohydrate_factor_preference")
        userDefaults.setValue(correctiveFactor, forKey: "corrective_factor_preference")
        userDefaults.setValue(desiredBloodGlucose, forKey: "desired_blood_glucose_preference")
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDynamicViewElements()
    }
    
    func updateDynamicViewElements() {
        // Update placeholder on glucose-related text fields
        let bloodGlucoseUnit = userDefaults.valueForKey("blood_glucose_units_preference") as String
        let isMmolSelected = bloodGlucoseUnit.isEqual("mmol")
        
        var placeholder : String
        
        if isMmolSelected {
            placeholder = "mmol/L"
        } else {
            placeholder = "mg/dL"
        }
        
        correctiveFactorTextField.placeholder = placeholder
        desiredBloodGlucoseTextField.placeholder = placeholder
        
        // Update actual values with those saved in userDefaults
        let carbohydrateFactor = userDefaults.valueForKey("carbohydrate_factor_preference") as Double
        let correctiveFactor = userDefaults.valueForKey("corrective_factor_preference") as Double
        let desiredBloodGlucose = userDefaults.valueForKey("desired_blood_glucose_preference") as Double
        
        carbohydrateFactorTextField.text = "\(carbohydrateFactor)"
        correctiveFactorTextField.text = "\(correctiveFactor)"
        desiredBloodGlucoseTextField.text = "\(desiredBloodGlucose)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
