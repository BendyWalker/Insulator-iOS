import Foundation

enum BloodGlucoseUnit: String  {
    case mmol = "mmol"
    case mgdl = "mgdl"
    
    static func fromString(string: String) -> BloodGlucoseUnit? {
        switch string {
        case BloodGlucoseUnit.mmol.rawValue: return .mmol
        case BloodGlucoseUnit.mgdl.rawValue: return .mgdl
        default: return nil
        }
    }
}


class Calculator {
    let carbohydrateFactor: Double
    let correctiveFactor: Double
    let desiredBloodGlucoseLevel: Double
    let currentBloodGlucoseLevel: Double
    let carbohydratesInMeal: Double
    let bloodGlucoseUnit: BloodGlucoseUnit
    let isHalfUnitsEnabled: Bool
    
    init(carbohydrateFactor: Double, correctiveFactor: Double, desiredBloodGlucoseLevel: Double, currentBloodGlucoseLevel: Double, carbohydratesInMeal: Double, bloodGlucoseUnit: BloodGlucoseUnit, isHalfUnitsEnabled: Bool) {
        self.carbohydrateFactor = carbohydrateFactor
        self.correctiveFactor = correctiveFactor
        self.desiredBloodGlucoseLevel = carbohydrateFactor
        self.currentBloodGlucoseLevel = currentBloodGlucoseLevel
        self.carbohydratesInMeal = carbohydratesInMeal
        self.bloodGlucoseUnit = bloodGlucoseUnit
        self.isHalfUnitsEnabled = isHalfUnitsEnabled
    }
    
    func convertBloodGlucose(bloodGlucose: Double) -> Double {
        
        switch bloodGlucoseUnit {
        case .mmol:
            return bloodGlucose
        case .mgdl:
            return bloodGlucose / 18
        }
    
    }
    
    func getCarbohydrateDose(isRounded: Bool) -> Double {
        var carbohydrateDose = carbohydratesInMeal / carbohydrateFactor
        
        if isRounded {
            carbohydrateDose = roundNumber(carbohydrateDose)
        }
        
        return carbohydrateDose
    }
    
    func getCorrectiveDose(isRounded: Bool) -> Double {
        var correctiveDose = 0.0
        
        if currentBloodGlucoseLevel != 0 {
            correctiveDose = (convertBloodGlucose(currentBloodGlucoseLevel) - convertBloodGlucose(desiredBloodGlucoseLevel)) / correctiveFactor
        }
        
        if isRounded {
            correctiveDose = roundNumber(correctiveDose)
        }
        
        return correctiveDose
    }
    
    func getSuggestedDose(isRounded: Bool) -> Double {
        var suggestedDose = getCarbohydrateDose(false) + getCorrectiveDose(false)
        
        if suggestedDose < 0 {
            suggestedDose = 0
        } else {
            if isRounded {
                suggestedDose = roundNumber(suggestedDose)
            }
        }
        
        return suggestedDose
    }
    
    func roundNumber(number: Double) -> Double {
        var output: Double
        
        if isHalfUnitsEnabled {
            output = (round(number * 2)) * 0.5
        } else {
            output = round(number)
        }
        
        return output
    }
}
