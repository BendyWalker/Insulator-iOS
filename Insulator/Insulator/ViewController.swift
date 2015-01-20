//
//  ViewController.swift
//  Insulator
//
//  Created by Ben Walker on 19/01/2015.
//  Copyright (c) 2015 Ben David Walker. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var correctiveDoseLabel: UILabel!
    @IBOutlet weak var carbohydrateDoseLabel: UILabel!
    @IBOutlet weak var currentBloodGlucoseLevelTextField: UITextField!
    @IBOutlet weak var carbohydratesInMealTextField: UITextField!
    @IBOutlet weak var suggestedDoseLabel: UILabel!
    
    @IBAction func calculateDose(sender: AnyObject) {
        let currentBloodGlucoseLevel : Double = (currentBloodGlucoseLevelTextField.text as NSString).doubleValue
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
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

