import Foundation
import HealthKit

class HealthManager {
    let healthKitStore: HKHealthStore = HKHealthStore()
    
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
        
        healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: healthKitTypesToRead) {
            (success, error) -> Void in
            
            if completion != nil {
                completion(success: success, error: error)
            }
        }
    }
}
