//
//  Grade.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/19/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
//

import Foundation

enum GradeValue {
    case OK(grade: Double, credit:Double)
    case notEvaluate
    case pass
    case notPass
    case needRetake(grade: Double)
    case retakeDone(grade: Double, credit:Double)
    case unKnown
}

class Grade {
    
    var className: String
    var classType: String
    var grade: GradeValue
    
    init(className:NSString, classType:NSString, grade:NSString, credit:NSString, retakeGrade:NSString) {
        self.className = className as String
        self.classType = classType as String
        if grade == "未评价" {
            self.grade = .notEvaluate
            return
        }
        if grade.containsString("通过") {
            if grade == "通过" {
                self.grade = .pass
            }
            else {
                self.grade = .notPass
            }
            return
        }
        if retakeGrade != "" {
            self.grade = .retakeDone(grade: grade.doubleValue, credit: credit.doubleValue)
            return
        }
        if (grade.doubleValue > 0) && (grade.doubleValue < 60) && (credit.doubleValue == 0) {
            self.grade = .needRetake(grade: grade.doubleValue)
            return
        }
        if (grade.doubleValue > 0) && (credit.doubleValue > 0) {
            self.grade = .OK(grade: grade.doubleValue, credit: credit.doubleValue)
            return
        }
        self.grade = .unKnown
    }
    
    var gradeString: String {
        switch grade {
        case .OK(let grade, _):
            return "\(grade)"
        case .notEvaluate:
            return "未评教"
        case .pass:
            return "通过"
        case .notPass:
            return "未通过"
        case .needRetake(let grade):
            return "\(grade)"
        case .retakeDone(let grade, _):
            return "\(grade)"
        case .unKnown:
            return "不清楚"
        }
    }
    
    var creditString: String {
        switch grade {
        case .OK(_, let credit):
            return "\(credit)"
        case .notEvaluate:
            return "未评教"
        case .pass:
            return "通过"
        case .notPass:
            return "未通过"
        case .needRetake:
            return "需重修"
        case .retakeDone(_, let credit):
            return "\(credit)"
        case .unKnown:
            return "不清楚"
        }
    }
    
    class func computeGPA(grades: [Grade], WithCourseType courseType: [String]) -> Double {
        var GPA:Double = 0
        var credit:Double = 0
        for grade in grades {
            if courseType.contains(grade.classType) {
                switch grade.grade {
                case .OK(let thisGrade, let thisCredit):
                    GPA += thisGrade * thisCredit
                    credit += thisCredit
                case .notEvaluate:
                    break
                case .pass, .notPass:
                    break
                case .needRetake:
                    break
                case .retakeDone(let thisGrade, let thisCredit):
                    GPA += thisGrade * thisCredit
                    credit += thisCredit
                case .unKnown:
                    break
                }
            }
        }
        if credit == 0 {
            return 0
        }
        return GPA / credit
    }
    
    class func computeCredit(grades: [Grade], WithCourseType courseType: [String]) -> Double {
        var credit:Double = 0
        for grade in grades {
            if courseType.contains(grade.classType) {
                switch grade.grade {
                case .OK(_, let thisCredit):
                    credit += thisCredit
                case .notEvaluate:
                    break
                case .pass, .notPass:
                    break
                case .needRetake:
                    break
                case .retakeDone(_, let thisCredit):
                    credit += thisCredit
                case .unKnown:
                    break
                }
            }
        }
        return credit
    }
    
}