import Foundation
import HealthKit

class HealthManager {
    let healthKitStore: HKHealthStore = HKHealthStore()
    let preferencesManager = PreferencesManager.sharedInstance
    let bloodGlucoseType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)
    
    func authoriseHealthKit(completion: ((success: Bool, error: NSError!) -> Void)!) {
        let typesToShare = Set<HKSampleType>()
        let typesToRead = Set<HKObjectType>(arrayLiteral: bloodGlucoseType!);
        
        if !HKHealthStore.isHealthDataAvailable() {
            let error = NSError(domain: "com.bendywalker.Insulator", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available on this device"])
            
            if completion != nil {
                completion(success: false, error: error)
            }
            
            return
        }
        
        healthKitStore.requestAuthorizationToShareTypes(typesToShare, readTypes: typesToRead) {
            (success, error) -> Void in
            
            if completion != nil {
                completion(success: success, error: error)
            }
        }
    }
    
    func getAuthorisationStatus(completion: ((authorisationStatus: HKAuthorizationStatus) -> Void)!) {
        let authorisation = healthKitStore.authorizationStatusForType(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)!)
        
        completion(authorisationStatus: authorisation)
    }
    
    func enableBackgroundUpdates() {
        healthKitStore.enableBackgroundDeliveryForType(bloodGlucoseType!, frequency: HKUpdateFrequency.Immediate) { success, error in
        }
    }
    
    func observeBloodGlucose(completion: ((Double?) -> Void)) {
        let query = HKObserverQuery(sampleType: bloodGlucoseType!, predicate: nil) { query, completionHandler, error in
            self.queryBloodGlucose() { sample in
                if let bloodGlucose = sample {
                    completion(bloodGlucose)
                } else {
                    completion(nil)
                }
            }
            
            completionHandler()
        }
        
        self.healthKitStore.executeQuery(query)
    }
    
    func queryBloodGlucose(completion: ((Double?) -> Void)) {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let oneDayAgo = NSDate(timeIntervalSinceNow: -86400)
        let now = NSDate()
        let lastDayPredicate = HKQuery.predicateForSamplesWithStartDate(oneDayAgo, endDate: now, options: .None)
        
        let query = HKSampleQuery(sampleType: bloodGlucoseType!, predicate: lastDayPredicate, limit: 1, sortDescriptors: [sortDescriptor]) { query, results, error in
            if let samples = results as? [HKQuantitySample] {
                if !samples.isEmpty {
                    let sample = samples.first!
                    
                    let bloodGlucoseUnit = self.preferencesManager.bloodGlucoseUnit
                    var bloodGlucose = 0.0
                    switch bloodGlucoseUnit {
                    case .mmol:
                        let millimoles = HKUnit.moleUnitWithMetricPrefix(HKMetricPrefix.Milli, molarMass: HKUnitMolarMassBloodGlucose)
                        let litre = HKUnit.literUnit()
                        let millimolesPerLitre = millimoles.unitDividedByUnit(litre)
                        bloodGlucose = sample.quantity.doubleValueForUnit(millimolesPerLitre)
                    case .mgdl:
                        let milligrams = HKUnit.gramUnitWithMetricPrefix(HKMetricPrefix.Milli)
                        let decilitre = HKUnit.literUnitWithMetricPrefix(HKMetricPrefix.Deci)
                        let milligramsPerDecilitre = milligrams.unitDividedByUnit(decilitre)
                        bloodGlucose = sample.quantity.doubleValueForUnit(milligramsPerDecilitre)
                    }
                    
                    bloodGlucose = Calculator(bloodGlucoseUnit: bloodGlucoseUnit).roundDouble(bloodGlucose)
                    completion(bloodGlucose)
                } else {
                    completion(nil)
                }
            }
        }
        
        self.healthKitStore.executeQuery(query)
    }
}
