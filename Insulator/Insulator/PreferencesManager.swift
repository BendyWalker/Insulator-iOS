import Foundation

class PreferencesStore  {
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    func saveBool(bool: Bool, withKey key: String) {
        userDefaults.setBool(bool, forKey: key)
    }
    
    func loadBoolWithKey(key: String) -> Bool {
        return userDefaults.boolForKey(key)
    }
    
    func saveObject(object: AnyObject, withKey key: String) {
        return userDefaults.setObject(object, forKey:key)
    }
    
    func loadObjectWithKey(key: String) -> AnyObject? {
        return userDefaults.objectForKey(key)
    }
    
    func saveDouble(double: Double, withKey key: String) {
        return userDefaults.setDouble(double, forKey:key)
    }
    
    func loadDoubleWithKey(key: String) -> Double {
        return userDefaults.doubleForKey(key)
    }
    
}

class PreferencesManager {
    
    let store: PreferencesStore
    
    private let UseHalfUnitsKey = "UseHalfUnitsKey"
    private let AllowFloatingPointCarbohydratesKey = "AllowFloatingPointCarbohydratesKey"
    private let BloodGlucoseUnitKey = "BloodGlucoseUnitKey"
    private let CarbohydrateFactorKey = "CarbohydrateFactorKey"
    private let CorrectiveFactorKey = "CorrectiveFactorKey"
    private let DesiredBloodGlucoseKey = "DesiredBloodGlucoseKey"
    
    
    // MARK: Properties
    
    var useHalfUnits: Bool {
        didSet {
            store.saveBool(useHalfUnits, withKey: UseHalfUnitsKey)
        }
    }
    
    var allowFloatingPointCarbohydrates: Bool {
        didSet {
            store.saveBool(allowFloatingPointCarbohydrates, withKey: AllowFloatingPointCarbohydratesKey)
        }
    }
    
    var bloodGlucoseUnit: BloodGlucoseUnit {
        didSet {
            store.saveObject(bloodGlucoseUnit.rawValue, withKey: BloodGlucoseUnitKey)
        }
    }
    
    var carbohydrateFactor: Double {
        didSet {
            store.saveDouble(carbohydrateFactor, withKey: CarbohydrateFactorKey)
        }
    }
    
    
    var correctiveFactor: Double {
        didSet {
            store.saveDouble(correctiveFactor, withKey: CorrectiveFactorKey)
        }
    }
    
    var desiredBloodGlucose: Double {
        didSet {
            store.saveDouble(desiredBloodGlucose, withKey: DesiredBloodGlucoseKey)
        }
    }
    
    // MARK: Initialisation
    
    init(store: PreferencesStore, useHalfUnits: Bool, bloodGlucoseUnit: BloodGlucoseUnit, carbohydrateFactor: Double, correctiveFactor: Double, desiredBloodGlucose: Double, allowFloatingPointCarbohydrates: Bool)
    {
        self.store = store
        
        self.useHalfUnits = useHalfUnits
        self.bloodGlucoseUnit = bloodGlucoseUnit
        self.carbohydrateFactor = carbohydrateFactor
        self.correctiveFactor = correctiveFactor
        self.desiredBloodGlucose = desiredBloodGlucose
        self.allowFloatingPointCarbohydrates = allowFloatingPointCarbohydrates
    }
    
    init(store: PreferencesStore) {
        self.store = store
        
        let loadedUnit = store.loadObjectWithKey(BloodGlucoseUnitKey) as? String
        self.bloodGlucoseUnit = BloodGlucoseUnit.fromString(loadedUnit!)!
        
        self.useHalfUnits = store.loadBoolWithKey(UseHalfUnitsKey)
        self.carbohydrateFactor = store.loadDoubleWithKey(CarbohydrateFactorKey)
        self.correctiveFactor = store.loadDoubleWithKey(CorrectiveFactorKey)
        self.desiredBloodGlucose = store.loadDoubleWithKey(DesiredBloodGlucoseKey)
        self.allowFloatingPointCarbohydrates = store.loadBoolWithKey(AllowFloatingPointCarbohydratesKey)
    }
}
