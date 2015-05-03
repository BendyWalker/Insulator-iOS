import Foundation
import HealthKit

class HealthManager {
    let healthKitStore: HKHealthStore = HKHealthStore()
    let preferencesManager = PreferencesManager.sharedInstance
    
    func authoriseHealthKit(completion: ((success: Bool, error: NSError!) -> Void)!) {
        let healthKitTypesToRead = NSSet(array:[
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)
            ])
        
        let healthKitTypesToWrite = NSSet(array: [])
        
        if !HKHealthStore.isHealthDataAvailable() {
            let error = NSError(domain: "com.bendywalker.Insulator", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available on this device"])
            
            if completion != nil {
                completion(success: false, error: error)
            }
            
            return
        }
        
        healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite as Set<NSObject>, readTypes: healthKitTypesToRead as Set<NSObject>) {
            (success, error) -> Void in
            
            if completion != nil {
                completion(success: success, error: error)
            }
        }
    }
    
    func queryBloodGlucose(completion: ((Double?) -> Void)) {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { query, results, error in
            if let samples = results as? [HKQuantitySample] {
                let sample = samples.first!
                let millgramsPerDeciliterOfBloodGlucose = sample.quantity.doubleValueForUnit(HKUnit(fromString: "mg/dL"))
                let bloodGlucoseUnit = self.preferencesManager.bloodGlucoseUnit
                
                let finalBloodGlucose: Double = {
                    switch bloodGlucoseUnit {
                    case .mmol: return Double(round((millgramsPerDeciliterOfBloodGlucose / 18) * 10) / 10)
                    case .mgdl: return Double(round(millgramsPerDeciliterOfBloodGlucose * 10) / 10)
                    }
                }()
                
                completion(finalBloodGlucose)
            }
        }
        
        self.healthKitStore.executeQuery(query)
    }
}
