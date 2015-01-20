import Foundation

class Calculator {
    let carbohydrateFactor : Double
    let correctiveFactor : Double
    let desiredBloodGlucoseLevel : Double
    let currentBloodGlucoseLevel : Double
    let carbohydratesInMeal : Double
    let isMmolSelected : Bool
    let isHalfUnitsEnabled : Bool
    
    init(currentBloodGlucoseLevel : Double, carbohydratesInMeal : Double) {
        self.currentBloodGlucoseLevel = currentBloodGlucoseLevel
        self.carbohydratesInMeal = carbohydratesInMeal
        self.carbohydrateFactor = 9.0
        self.correctiveFactor = 2.0
        self.desiredBloodGlucoseLevel = 7.0
        self.isMmolSelected = true
        self.isHalfUnitsEnabled = true
    }
    
    func convertBloodGlucose(bloodGlucose : Double, isMmolSelected : Bool) -> Double {
        if isMmolSelected {
            return bloodGlucose / 18
        } else {
            return bloodGlucose
        }
    }
    
    func getCarbohydrateDose(isRounded : Bool) -> Double {
        var carbohydrateDose = carbohydratesInMeal / carbohydrateFactor
        
        if isRounded {
            carbohydrateDose = roundNumber(carbohydrateDose)
        }
        
        return carbohydrateDose
    }
    
    func getCorrectiveDose(isRounded : Bool) -> Double {
        var correctiveDose = 0.0
        
        if currentBloodGlucoseLevel != 0 {
            correctiveDose = (currentBloodGlucoseLevel - desiredBloodGlucoseLevel) / correctiveFactor
        }
        
        if isRounded {
            correctiveDose = roundNumber(correctiveDose)
        }
        
        return correctiveDose
    }
    
    func getSuggestedDose(isRounded : Bool) -> Double {
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
    
    func roundNumber(number : Double) -> Double {
        var output : Double
        
        if isHalfUnitsEnabled {
            output = (round(number * 2)) * 0.5
        } else {
            output = round(number)
        }
        
        return output
    }
}
