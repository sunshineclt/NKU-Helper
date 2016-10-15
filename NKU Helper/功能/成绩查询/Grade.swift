//
//  Grade.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/19/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation

enum GradeValue {
    case ok(grade: Double, credit:Double)
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
    
    init(className: String, classType: String, grade: GradeValue) {
        self.className = className
        self.classType = classType
        self.grade = grade
    }
    
    init(className: String, classType: String, grade: String, credit: String, retakeGrade: String) {
        self.className = className
        self.classType = classType
        if grade == "未评价" {
            self.grade = .notEvaluate
            return
        }
        if grade.contains("通过") {
            if grade == "通过" {
                self.grade = .pass
            }
            else {
                self.grade = .notPass
            }
            return
        }
        if retakeGrade != "" {
            self.grade = .retakeDone(grade: (retakeGrade as NSString).doubleValue, credit: (credit as NSString).doubleValue)
            return
        }
        if ((grade as NSString).doubleValue > 0) && ((grade as NSString).doubleValue < 60) && ((credit as NSString).doubleValue == 0) {
            self.grade = .needRetake(grade: (grade as NSString).doubleValue)
            return
        }
        if ((grade as NSString).doubleValue > 0) && ((credit as NSString).doubleValue >= 0) {
            self.grade = .ok(grade: (grade as NSString).doubleValue, credit: (credit as NSString).doubleValue)
            return
        }
        self.grade = .unKnown
    }
    
    var gradeString: String {
        switch grade {
        case .ok(let grade, _):
            return NSString(format: "%.1lf", grade) as String
        case .notEvaluate:
            return "未评教"
        case .pass:
            return "通过"
        case .notPass:
            return "未通过"
        case .needRetake(let grade):
            return NSString(format: "%.1lf", grade) as String
        case .retakeDone(let grade, _):
            return NSString(format: "%.1lf", grade) as String
        case .unKnown:
            return "不清楚"
        }
    }
    
    var creditString: String {
        switch grade {
        case .ok(_, let credit):
            return NSString(format: "%.1lf", credit) as String
        case .notEvaluate:
            return "未评教"
        case .pass:
            return "通过"
        case .notPass:
            return "未通过"
        case .needRetake:
            return "需重修"
        case .retakeDone(_, let credit):
            return NSString(format: "%.1lf", credit) as String
        case .unKnown:
            return "不清楚"
        }
    }
    
    /**
     计算学分绩
     
     - parameter grades:     Grade数组
     - parameter courseType: 哪些类型的课程列入计算
     - parameter isAverage:  是否按照算数平均数算
     
     - returns: 学分绩
     */
    class func computeGradeCreditSum(_ grades: [Grade], WithCourseType courseType: [String], isAverage: Bool) -> Double {
        var gradeCreditSum:Double = 0
        var credit:Double = 0
        for grade in grades {
            if courseType.contains(grade.classType) {
                switch grade.grade {
                case .ok(let thisGrade, let thisCredit):
                    if isAverage {
                        gradeCreditSum += thisGrade
                        credit += 1
                    }
                    else {
                        gradeCreditSum += thisGrade * thisCredit
                        credit += thisCredit
                    }
                case .notEvaluate:
                    break
                case .pass, .notPass:
                    break
                case .needRetake:
                    break
                case .retakeDone(let thisGrade, let thisCredit):
                    if isAverage {
                        gradeCreditSum += thisGrade
                        credit += 1
                    }
                    else {
                        gradeCreditSum += thisGrade * thisCredit
                        credit += thisCredit
                    }
                case .unKnown:
                    break
                }
            }
        }
        if credit == 0 {
            return 0
        }
        return gradeCreditSum / credit
    }
    
    /**
     计算GPA
     
     - parameter grades:             Grade数组
     - parameter gpaCalculateMethod: 使用哪种GPA算法
     - parameter courseType:         哪些类型的课程列入计算
     
     - returns: GPA
     */
    class func computeGRA(_ grades: [Grade], WithGPACalculateMethod gpaCalculateMethod: GPACalculateMethod, AndCourseType courseType: [String]) -> Double {
        var gpa:Double = 0
        var credit:Double = 0
        for grade in grades {
            if courseType.contains(grade.classType) {
                switch grade.grade {
                case .ok(let thisGrade, let thisCredit):
                    gpa += gpaCalculateMethod.transformGradeToGPAMethod(thisGrade) * thisCredit
                    credit += thisCredit
                case .notEvaluate:
                    break
                case .pass, .notPass:
                    break
                case .needRetake:
                    break
                case .retakeDone(let thisGrade, let thisCredit):
                    gpa += gpaCalculateMethod.transformGradeToGPAMethod(thisGrade) * thisCredit
                    credit += thisCredit
                case .unKnown:
                    break
                }
            }
        }
        if credit == 0 {
            return 0
        }
        return gpa / credit
    }
    
    /**
     计算总学分
     
     - parameter grades:     Grade数组
     - parameter courseType: 哪些类型的课程列入计算
     
     - returns: 总学分
     */
    class func computeCredit(_ grades: [Grade], WithCourseType courseType: [String]) -> Double {
        var credit:Double = 0
        for grade in grades {
            if courseType.contains(grade.classType) {
                switch grade.grade {
                case .ok(_, let thisCredit):
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

/// GPA算法类
class GPACalculateMethod {
    
    static let methods = [standard, improved1, improved2, PKUOld, PKUNew, canada]
    // 每种方法的总分
    static let methodsSum = [4.0, 4.0, 4.0, 4.0, 4.0, 4.3]
    static let standard = GPACalculateMethodBuilder.buildGPACalculateMethod("标准4.0", rules: [
        (left: 90, right: 100, gpa: 4),
        (left: 80, right: 89, gpa: 3),
        (left: 70, right: 79, gpa: 2),
        (left: 60, right: 69, gpa: 1)])
    static let improved1 = GPACalculateMethodBuilder.buildGPACalculateMethod("改进4.0(1)", rules: [
        (left: 85, right: 100, gpa: 4.0),
        (left: 70, right: 84, gpa: 3.0),
        (left: 60, right: 69, gpa: 2.0)])
    static let improved2 = GPACalculateMethodBuilder.buildGPACalculateMethod("改进4.0(2)", rules: [
        (left: 85, right: 100, gpa: 4.0),
        (left: 75, right: 84, gpa: 3.0),
        (left: 60, right: 74, gpa: 2.0)])
    static let PKUOld = GPACalculateMethodBuilder.buildGPACalculateMethod("北京大学旧4.0", rules: [
        (left: 90, right: 100, gpa: 4),
        (left: 85, right: 89, gpa: 3.7),
        (left: 82, right: 84, gpa: 3.3),
        (left: 78, right: 81, gpa: 3.0),
        (left: 75, right: 77, gpa: 2.7),
        (left: 72, right: 74, gpa: 2.3),
        (left: 68, right: 71, gpa: 2.0),
        (left: 64, right: 67, gpa: 1.5),
        (left: 60, right: 63, gpa: 1.0)])
    static private let PKUNewFunction = { (grade: Double) -> Double in
        let temp = 100 - grade
        let GPA = 4 - 3 * temp * temp / 1600;
        return GPA
    }
    static let PKUNew = GPACalculateMethod(methodName: "北京大学新4.0", description: [(interval: "X(60<=x<=100)", gpa: "GPA=4-3*(100-X)^2/1600")], transformGradeToGPAMethod: PKUNewFunction)
    static let canada = GPACalculateMethodBuilder.buildGPACalculateMethod("加拿大4.3", rules: [
        (left: 90, right: 100, gpa: 4.3),
        (left: 85, right: 89, gpa: 4.0),
        (left: 80, right: 84, gpa: 3.7),
        (left: 75, right: 79, gpa: 3.3),
        (left: 70, right: 74, gpa: 3.0),
        (left: 65, right: 69, gpa: 2.7),
        (left: 60, right: 64, gpa: 2.3)])
    
    
    var methodName: String
    var description: [GPACalculateMethodDescription]
    var transformGradeToGPAMethod: (Double) -> Double

    init(methodName: String, description:[GPACalculateMethodDescription], transformGradeToGPAMethod: @escaping (Double) -> Double) {
        self.methodName = methodName
        self.description = description
        self.transformGradeToGPAMethod = transformGradeToGPAMethod
    }
}

typealias GPACalculateMethodDescription = (interval: String, gpa: String)

class GPACalculateMethodBuilder {
    
    class func buildGPACalculateMethod(_ methodName: String, rules: [(left: Double, right: Double, gpa: Double)]) -> GPACalculateMethod {
        var description = [GPACalculateMethodDescription]()
        var judgments = [{ (grade: Double) -> Double in
            return 0
        }]
        for rule in rules {
            description.append((interval: "\(rule.left)~\(rule.right)", gpa: "\(rule.gpa)"))
            let lastJudgement = judgments.last!
            let newJudgment = { (grade: Double) -> Double in
                if (grade >= rule.left) && (grade <= rule.right) {
                    return rule.gpa
                }
                else {
                    return lastJudgement(grade)
                }
            }
            judgments.append(newJudgment)
        }
        return GPACalculateMethod(methodName: methodName, description: description, transformGradeToGPAMethod: judgments.last!)
    }
    
}
