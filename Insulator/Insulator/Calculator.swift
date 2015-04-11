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
    
    init(bloodGlucoseUnit: BloodGlucoseUnit, carbohydrateFactor: Double = 0.0, correctiveFactor: Double = 0.0, desiredBloodGlucoseLevel: Double = 0.0, currentBloodGlucoseLevel: Double = 0.0, carbohydratesInMeal: Double = 0.0, totalDailyDose: Double = 0.0) {
        self.bloodGlucoseUnit = bloodGlucoseUnit
        self.carbohydrateFactor = carbohydrateFactor
        self.correctiveFactor = correctiveFactor
        self.desiredBloodGlucoseLevel = desiredBloodGlucoseLevel
        self.currentBloodGlucoseLevel = currentBloodGlucoseLevel
        self.carbohydratesInMeal = carbohydratesInMeal
        self.totalDailyDose = totalDailyDose
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
        
        carbohydrateDose = roundDouble(carbohydrateDose)
        return carbohydrateDose
    }
    
    func getCorrectiveDose() -> Double {
        var correctiveDose = 0.0
        
        if currentBloodGlucoseLevel != 0 {
            correctiveDose = (convertBloodGlucose(currentBloodGlucoseLevel) - convertBloodGlucose(desiredBloodGlucoseLevel)) / correctiveFactor
        }
        
        correctiveDose = roundDouble(correctiveDose)
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
        var carbohydrateFactor = 500 / totalDailyDose
        carbohydrateFactor = roundDouble(carbohydrateFactor)
        return carbohydrateFactor
    }
    
    func getCorrectiveFactor() -> Double {
        var correctiveFactor = 0.0
        switch bloodGlucoseUnit {
        case .mmol:
            correctiveFactor = 100 / totalDailyDose
        case .mgdl:
            correctiveFactor = (100 / totalDailyDose) * mgdlConversionValue
        }
        
        correctiveFactor = roundDouble(correctiveFactor)
        return correctiveFactor
    }
    
    func roundDouble(double: Double) -> Double {
        return (round(10 * double)) / 10
    }
}