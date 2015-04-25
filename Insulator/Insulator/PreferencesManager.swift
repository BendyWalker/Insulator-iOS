import Foundation

let PreferencesDidChangeNotification = "PreferencesDidChangeNotification"

class PreferencesStore {
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    
    private func postPreferenceDidChangeNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(PreferencesDidChangeNotification, object: nil)
    }
    
    func saveBool(bool: Bool, withKey key: String) {
        userDefaults.setBool(bool, forKey: key)
        postPreferenceDidChangeNotification()
    }
    
    func loadBoolWithKey(key: String) -> Bool {
        return userDefaults.boolForKey(key)
    }
    
    func saveObject(object: AnyObject, withKey key: String) {
        userDefaults.setObject(object, forKey:key)
        postPreferenceDidChangeNotification()
    }
    
    func loadObjectWithKey(key: String) -> AnyObject? {
        return userDefaults.objectForKey(key)
    }
    
    func saveDouble(double: Double, withKey key: String) {
        userDefaults.setDouble(double, forKey:key)
        postPreferenceDidChangeNotification()
    }
    
    func loadDoubleWithKey(key: String) -> Double {
        return userDefaults.doubleForKey(key)
    }
}

class PreferencesManager {
    
    // MARK: Store and storage keys
    
    private let store: PreferencesStore = PreferencesStore()
    
    private let BuildNumberKey = "BuildNumberKey"
    private let AllowFloatingPointCarbohydratesKey = "AllowFloatingPointCarbohydratesKey"
    private let BloodGlucoseUnitKey = "BloodGlucoseUnitKey"
    private let CarbohydrateFactorKey = "CarbohydrateFactorKey"
    private let CorrectiveFactorKey = "CorrectiveFactorKey"
    private let DesiredBloodGlucoseKey = "DesiredBloodGlucoseKey"
    
    // MARK: Properties
    
    var buildNumber: String {
        didSet {
            store.saveObject(buildNumber, withKey: BuildNumberKey)
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
    
    // MARK: Singleton
    
    class var sharedInstance: PreferencesManager {
        struct Static {
            static let instance: PreferencesManager = PreferencesManager()
        }
        return Static.instance
    }
    
    // MARK: Initialisation
    
    init() {
        self.allowFloatingPointCarbohydrates = store.loadBoolWithKey(AllowFloatingPointCarbohydratesKey)
        self.carbohydrateFactor = store.loadDoubleWithKey(CarbohydrateFactorKey)
        self.correctiveFactor = store.loadDoubleWithKey(CorrectiveFactorKey)
        self.desiredBloodGlucose = store.loadDoubleWithKey(DesiredBloodGlucoseKey)
        
        if let buildNumberString = store.loadObjectWithKey(BuildNumberKey) as? String {
            self.buildNumber = buildNumberString
        } else {
            self.buildNumber = ""
        }
        
        if let bloodGlucoseUnitString = store.loadObjectWithKey(BloodGlucoseUnitKey) as? String {
            if let bloodGlucoseUnit = BloodGlucoseUnit.fromString(bloodGlucoseUnitString) {
                self.bloodGlucoseUnit = bloodGlucoseUnit
            } else {
                self.bloodGlucoseUnit = BloodGlucoseUnit.defaultUnit()
            }
        } else {
            self.bloodGlucoseUnit = BloodGlucoseUnit.defaultUnit()
        }
        
    }
    
    func outputToLog() {
        println("Blood Glucose Unit: \(self.bloodGlucoseUnit.rawValue)")
        println("Allow Floating Point Carbohydrates: \(self.allowFloatingPointCarbohydrates)")
        println("Carbohydrate Factor: \(self.carbohydrateFactor)")
        println("Corrective Factor: \(self.correctiveFactor)")
        println("Desired Blood Glucose: \(self.desiredBloodGlucose)")
    }
}
