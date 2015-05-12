//: Playground - noun: a place where people can play

import UIKit

var string = "555.55"

func addDecimalPlace(string: String) -> String {
    let point: Character = "."
    let zero: Character = "0"
    var index = 0
    var indexToRemove = 0
    var editedString = ""
    
    for character in string {
        if index == 0 {
            if character == zero {
            }
            editedString.append(character)
        } else if index > 0 {
            if character == point {
            } else {
                editedString.append(character)
            }
        }
        
        index++
    }
    
    let length = count(editedString)
    index = 0
    var newString = ""
    
    for character in editedString {
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
    println(index)
    return newString
}

string = addDecimalPlace(string)
string = addDecimalPlace(string)