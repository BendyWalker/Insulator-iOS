import Foundation

class PreferencesManager {
    private let useHalfUnitsKey = "UseHalfUnitsKey"
    var useHalfUnits: Bool {
        didSet {
            let useHalfUnitsObject = NSNumber(bool: useHalfUnits)
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(useHalfUnitsObject, forKey:useHalfUnitsKey)
        }
    }
    
    
    private let allowFloatingPointCarbohydratesKey = "AllowFloatingPointCarbohydratesKey"
    var allowFloatingPointCarbohydrates: Bool
    
    private let bloodGlucoseKey = "bloodGlucoseKey"
    var bloodGlucoseUnit: BloodGlucoseUnit
    
    
    private let carbohydrateFactorKey = "CarbohydrateFactorKey"
    var carbohydrateFactor: Double {
        didSet {
            let carbohydrateFactorObject = NSNumber(double: carbohydrateFactor)
            let userDefaults = NSUserDefaults.standardUserDefaults()
            NSUserDefaults.standardUserDefaults().setObject(carbohydrateFactorObject, forKey:carbohydrateFactorKey)
        }
    }
    
    
    var correctiveFactor: Double
    var desiredBloodGlucose: Double
    
    init(useHalfUnits: Bool, bloodGlucoseUnit: BloodGlucoseUnit, carbohydrateFactor: Double, correctiveFactor: Double, desiredBloodGlucose: Double, allowFloatingPointCarbohydrates: Bool)
    {
        self.useHalfUnits = useHalfUnits
        self.bloodGlucoseUnit = bloodGlucoseUnit
        self.carbohydrateFactor = carbohydrateFactor
        self.correctiveFactor = correctiveFactor
        self.desiredBloodGlucose = desiredBloodGlucose
        self.allowFloatingPointCarbohydrates = allowFloatingPointCarbohydrates
    }
    
    init() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        self.useHalfUnits = userDefaults.boolForKey(useHalfUnitsKey)
        
        self.useHalfUnits = userDefaults.boolForKey(useHalfUnitsKey)
        self.bloodGlucoseUnit = userDefaults.setObject(self.bloodGlucoseUnit.toString, forKey: bloodGlucoseKey)
        self.carbohydrateFactor = userDefaults.boolForKey(useHalfUnitsKey)
        self.correctiveFactor = userDefaults.boolForKey(useHalfUnitsKey)
        self.allowFloatingPointCarbohydrates = userDefaults.boolForKey(useHalfUnitsKey)
    }
}
