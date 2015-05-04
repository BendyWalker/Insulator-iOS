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