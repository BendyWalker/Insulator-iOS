//
//  ViewController.swift
//  Insulator
//
//  Created by Ben Walker on 19/01/2015.
//  Copyright (c) 2015 Ben David Walker. All rights reserved.
//

import UIKit

class VariablesViewController: UIViewController {

    @IBOutlet weak var correctiveDoseLabel: UILabel!
    @IBOutlet weak var carbohydrateDoseLabel: UILabel!
    @IBOutlet weak var currentBloodGlucoseLevelTextField: UITextField!
    @IBOutlet weak var carbohydratesInMealTextField: UITextField!
    @IBOutlet weak var suggestedDoseLabel: UILabel!
    
    @IBAction func calculateDose(sender: AnyObject) {
        let currentBloodGlucoseLevel = (currentBloodGlucoseLevelTextField.text as NSString).doubleValue
        let carbohydratesInMeal = (carbohydratesInMealTextField.text as NSString).doubleValue
        
        let calculator = Calculator(currentBloodGlucoseLevel: currentBloodGlucoseLevel, carbohydratesInMeal: carbohydratesInMeal)
        let suggestedDose : String = "\(calculator.getSuggestedDose(true))"
        let carbohydrateDose : String = "\(calculator.getCarbohydrateDose(true))"
        let correctiveDose : String = "\(calculator.getCorrectiveDose(true))"
        
        suggestedDoseLabel.text = suggestedDose
        carbohydrateDoseLabel.text = carbohydrateDose
        correctiveDoseLabel.text = correctiveDose
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateBloodGlucoseUnitPlaceholder()
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "defaultsDidChange:", name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    func defaultsDidChange(notification : NSNotification) {
        updateBloodGlucoseUnitPlaceholder()
    }
    
    func updateBloodGlucoseUnitPlaceholder() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let bloodGlucoseUnit = userDefaults.valueForKey("blood_glucose_units_preference") as String
        let isMmolSelected = bloodGlucoseUnit.isEqual("mmol")
        
        var placeholder : String
        
        if isMmolSelected {
            placeholder = "mmol/L"
        } else {
            placeholder = "mg/dL"
        }
        
        currentBloodGlucoseLevelTextField.placeholder = placeholder
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

