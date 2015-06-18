import Foundation

enum BloodGlucoseUnit: String  {
    case mmol = "mmol/L"
    case mgdl = "mg/dL"
    
    static func fromString(string: String) -> BloodGlucoseUnit? {
        switch string {
        case BloodGlucoseUnit.mmol.rawValue: return .mmol
        case BloodGlucoseUnit.mgdl.rawValue: return .mgdl
        default: return nil
        }
    }
    
    static func fromInt(int: Int) -> BloodGlucoseUnit? {
        switch int {
        case 0: return .mmol
        case 1: return .mgdl
        default: return nil
        }
    }
    
    static func defaultUnit() -> BloodGlucoseUnit { return BloodGlucoseUnit.mmol }
    
    static func count() -> Int { return 2 }
}

func addDecimalPlace(string: String) -> String {
    let point: Character = "."
    let zero: Character = "0"
    
    var index = 0
    var editedString = ""
    
    for character in string.characters {
        if index == 0 {
            if character == zero {
            } else {
                editedString.append(character)
            }
        } else if index > 0 {
            if character == point {
            } else {
                editedString.append(character)
            }
        }
        index++
    }
    
    let length = editedString.characters.count
    index = 0
    var newString = ""
    
    for character in editedString.characters {
        if length == 1 {
            newString += "0.\(character)"
        } else {
            if index == length - 1 {
                newString.append(point)
            }
            newString.append(character)
        }
        
        index++
    }
    return newString
}