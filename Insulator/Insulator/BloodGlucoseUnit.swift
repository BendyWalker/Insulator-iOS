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
    
    static func defaultUnit () -> BloodGlucoseUnit { return BloodGlucoseUnit.mmol }
}