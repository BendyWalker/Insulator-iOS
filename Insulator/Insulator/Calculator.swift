import Foundation

class Calculator {
    let mgdlConversionValue = 18.0
    
    let carbohydrateFactor: Double
    let correctiveFactor: Double
    let desiredBloodGlucoseLevel: Double
    let currentBloodGlucoseLevel: Double
    let carbohydratesInMeal: Double
    let totalDailyDose: Double
    let bloodGlucoseUnit: BloodGlucoseUnit
    
    init(carbohydrateFactor: Double, correctiveFactor: Double, desiredBloodGlucoseLevel: Double, currentBloodGlucoseLevel: Double, carbohydratesInMeal: Double, bloodGlucoseUnit: BloodGlucoseUnit) {
        self.carbohydrateFactor = carbohydrateFactor
        self.correctiveFactor = correctiveFactor
        self.desiredBloodGlucoseLevel = desiredBloodGlucoseLevel
        self.currentBloodGlucoseLevel = currentBloodGlucoseLevel
        self.carbohydratesInMeal = carbohydratesInMeal
        self.bloodGlucoseUnit = bloodGlucoseUnit
        
        self.totalDailyDose = 0.0
    }
    
    init(totalDailyDose: Double, bloodGlucoseUnit: BloodGlucoseUnit) {
        self.totalDailyDose = totalDailyDose
        self.bloodGlucoseUnit = bloodGlucoseUnit
        
        self.carbohydrateFactor = 0.0
        self.correctiveFactor = 0.0
        self.desiredBloodGlucoseLevel = 0.0
        self.currentBloodGlucoseLevel = 0.0
        self.carbohydratesInMeal = 0.0
    }
    
    func convertBloodGlucose(bloodGlucose: Double) -> Double {
        switch bloodGlucoseUnit {
        case .mmol:
            return bloodGlucose
        case .mgdl:
            return bloodGlucose / mgdlConversionValue
        }
    }
    
    func getCarbohydrateDose() -> Double {
        var carbohydrateDose = 0.0
        
        if carbohydrateFactor != 0 {
            carbohydrateDose = carbohydratesInMeal / carbohydrateFactor
        }
        
        return carbohydrateDose
    }
    
    func getCorrectiveDose() -> Double {
        var correctiveDose = 0.0
        
        if currentBloodGlucoseLevel != 0 {
            correctiveDose = (convertBloodGlucose(currentBloodGlucoseLevel) - convertBloodGlucose(desiredBloodGlucoseLevel)) / correctiveFactor
        }
        
        return correctiveDose
    }
    
    func getSuggestedDose() -> Double {
        var suggestedDose = getCarbohydrateDose() + getCorrectiveDose()
        
        if suggestedDose < 0 {
            suggestedDose = 0
        }
        
        return suggestedDose
    }
    
    func getCarbohydrateFactor() -> Double {
        return 500 / totalDailyDose
    }
    
    func getCorrectiveFactor() -> Double {
        switch bloodGlucoseUnit {
        case .mmol:
            return 100 / totalDailyDose
        case .mgdl:
            return (100 / totalDailyDose) * mgdlConversionValue
        }
    }
    
    class func getString(value: Double) -> String {
        return String(format: "%.1f", value)
    }
}