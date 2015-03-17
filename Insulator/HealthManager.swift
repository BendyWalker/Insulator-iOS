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
    
    func readMostRecentSample(sampleType: HKSampleType, completion: ((HKSample!, NSError!) -> Void)!) {
        let past = NSDate.distantPast() as NSDate
        let now = NSDate()
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(past, endDate: now, options: .None)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let limit = 1
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor]) {
            (sampleQuery, results, error) -> Void in
            
            if let queryError = error {
                completion (nil, error)
                return
            }
            
            let mostRecentSample = results.first as? HKQuantitySample
            
            if completion != nil {
                completion (mostRecentSample, nil)
            }
        }
        
        self.healthKitStore.executeQuery(sampleQuery)
    }
}
