//
//  EvaluateDetailTableViewCell.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/21/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

protocol EvaluateDetailStepperProtocol {
    func stepperDidChangeOnCell(cell: EvaluateDetailTableViewCell,toValue value: String)
}

class EvaluateDetailTableViewCell: UITableViewCell {

    var delegate: EvaluateDetailStepperProtocol?
    
    @IBOutlet var evaluateContentLabel: UILabel!
    @IBOutlet var pointLabel: UILabel!
    @IBOutlet var stepper: UIStepper!
    var maxValue: Double! {
        didSet {
            stepper.stepValue = maxValue % 2 == 0 ? 2 : 1
            stepper.minimumValue = maxValue % 2 == 0 ? 2 : 1
            stepper.maximumValue = maxValue
            stepper.value = maxValue
        }
    }
    
    var stepperValueString: String {
        return NSString(format: "%.0lf", stepper.value) as String
    }
    
    @IBAction func stepperDidChangeValue(sender: UIStepper) {
        pointLabel.text = "\(stepperValueString)"
        self.delegate?.stepperDidChangeOnCell(self, toValue: stepperValueString)
    }
    
}
