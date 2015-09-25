//
//  PlusCircleView.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/9/17.
//  Copyright © 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

class PlusCircleView: UIView {

    private struct DrawSizeCollection {
        static let circleLineWidth:CGFloat = 10
        static let circleBackgroundExtraRadius:CGFloat = 8
    }
    
    override func drawRect(rect: CGRect) {
        
        super.drawRect(rect)
        
        let plusButton = self.subviews[0] as! UIButton
        let plusButtonFrame = plusButton.frame
        let plusRadius:CGFloat = plusButtonFrame.size.width / 2
        
        //draw Plus Circle Background
        let circleBackground = UIBezierPath(arcCenter: plusButton.center, radius: plusRadius + DrawSizeCollection.circleBackgroundExtraRadius, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
        UIColor.whiteColor().setFill()
        circleBackground.fill()
        
        //draw Plus Circle
        let circle = UIBezierPath(arcCenter: plusButton.center, radius: plusRadius, startAngle: CGFloat(M_PI_2), endAngle: -CGFloat(M_PI_2 + M_PI_4), clockwise: false)
        circle.lineWidth = DrawSizeCollection.circleLineWidth
        circle.lineCapStyle = .Round
        circle.lineJoinStyle = .Round
        UIColor(red: 128/255, green: 173/255, blue: 174/255, alpha: 1).setStroke()
        //UIColor(red: 128/255, green: 173/255, blue: 174/255, alpha: 1).setFill()
        circle.stroke()
        //circle.fill()
        
        
    }
    
}
