//
//  courseCurrentTableViewCell.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/16.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class courseCurrentTableViewCell: UITableViewCell {    
    
    let courseCurrentViewHeight:CGFloat = 260
    
    @IBOutlet var currentCourseNameLabel: UILabel!
    @IBOutlet var currentCourseClassroomLabel: UILabel!
    @IBOutlet var currentCourseTimeLabel: UILabel!
    @IBOutlet var animateView: UIView!
    @IBOutlet var graphicsView: UIView!
    @IBOutlet var statusLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        currentCourseNameLabel.adjustsFontSizeToFitWidth = true
        currentCourseClassroomLabel.adjustsFontSizeToFitWidth = true
        currentCourseTimeLabel.adjustsFontSizeToFitWidth = true
        
        statusLabel.adjustsFontSizeToFitWidth = true
     
        self.backgroundColor = UIColor.clearColor()

        // 绘制轨道
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 200), false, 0)
        let refTrack = UIGraphicsGetCurrentContext()
        CGContextAddArc(refTrack, UIScreen.mainScreen().bounds.width / 2, courseCurrentViewHeight / 2, courseCurrentViewHeight / 2 - 5, CGFloat(-M_PI_2), CGFloat(M_PI + M_PI_2), 0)
        let layerTrack:CAShapeLayer = CAShapeLayer()
        layerTrack.strokeColor = UIColor(red: 135/255, green: 175/255, blue: 196/255, alpha: 0.3).CGColor
        layerTrack.lineWidth = 12
        layerTrack.fillColor = nil
        layerTrack.lineCap = kCALineCapRound
        layerTrack.path = CGContextCopyPath(refTrack)
        UIGraphicsEndImageContext()
        self.graphicsView.layer.addSublayer(layerTrack)
        
        // 绘制目前课程背景
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 200), false, 0)
        let refCourse = UIGraphicsGetCurrentContext()
        CGContextAddArc(refCourse, UIScreen.mainScreen().bounds.width / 2, courseCurrentViewHeight / 2, courseCurrentViewHeight / 2 - 10, CGFloat(-M_PI), 0, 0)
        let layerCourse:CAShapeLayer = CAShapeLayer()
        layerCourse.lineWidth = 1
        layerCourse.fillColor = UIColor(red: 250/255, green: 128/255, blue: 114/255, alpha: 1).CGColor
        layerCourse.strokeColor = UIColor(red: 95/255, green: 94/255, blue: 106/255, alpha: 1).CGColor
        layerCourse.path = CGContextCopyPath(refCourse)
        UIGraphicsEndImageContext()
        self.graphicsView.layer.addSublayer(layerCourse)
        
        // 绘制上课地点背景
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 200), false, 0)
        let refClassroom = UIGraphicsGetCurrentContext()
        CGContextAddArc(refClassroom, UIScreen.mainScreen().bounds.width / 2, courseCurrentViewHeight / 2, courseCurrentViewHeight / 2 - 10, CGFloat(M_PI_2), CGFloat(M_PI), 0)
        CGContextAddLineToPoint(refClassroom, UIScreen.mainScreen().bounds.width / 2, courseCurrentViewHeight / 2)
        CGContextClosePath(refClassroom)
        let layerClassroom:CAShapeLayer = CAShapeLayer()
        layerClassroom.lineWidth = 1
        layerClassroom.fillColor = UIColor(red: 144/255, green: 238/255, blue: 144/255, alpha: 1).CGColor
        layerClassroom.strokeColor = UIColor(red: 95/255, green: 94/255, blue: 106/255, alpha: 1).CGColor
        layerClassroom.path = CGContextCopyPath(refClassroom)
        UIGraphicsEndImageContext()
        self.graphicsView.layer.addSublayer(layerClassroom)
        
        // 绘制教师背景
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 200), false, 0)
        let refTeacher = UIGraphicsGetCurrentContext()
        CGContextAddArc(refTeacher, UIScreen.mainScreen().bounds.width / 2, courseCurrentViewHeight / 2, courseCurrentViewHeight / 2 - 10, 0, CGFloat(M_PI_2), 0)
        CGContextAddLineToPoint(refTeacher, UIScreen.mainScreen().bounds.width / 2, courseCurrentViewHeight / 2)
        CGContextClosePath(refTeacher)
        let layerTeacher:CAShapeLayer = CAShapeLayer()
        layerTeacher.lineWidth = 1
        layerTeacher.fillColor = UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1).CGColor
        layerTeacher.strokeColor = UIColor(red: 95/255, green: 94/255, blue: 106/255, alpha: 1).CGColor
        layerTeacher.path = CGContextCopyPath(refTeacher)
        UIGraphicsEndImageContext()
        self.graphicsView.layer.addSublayer(layerTeacher)
        
        
        // 绘制进度条
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 200), false, 0)
        let ref = UIGraphicsGetCurrentContext()
        CGContextAddArc(ref, UIScreen.mainScreen().bounds.width / 2, courseCurrentViewHeight / 2, courseCurrentViewHeight / 2 - 5, CGFloat(-M_PI_2), CGFloat(M_PI + M_PI_2), 0)
        let layer:CAShapeLayer = CAShapeLayer()
        layer.strokeColor = UIColor.orangeColor().CGColor
        layer.lineWidth = 5
        layer.fillColor = nil
        layer.lineCap = kCALineCapRound
        layer.path = CGContextCopyPath(ref)
        UIGraphicsEndImageContext()
        layer.strokeEnd = 0
        self.animateView.layer.addSublayer(layer)
        
    }
    
}
