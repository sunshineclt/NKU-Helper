//
//  Color.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/5/26.
//  Copyright (c) 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

import RealmSwift

/// 颜色类
class Color: Object {
    
    /**
     将App预设的颜色拷贝入Document目录中，在使用Color类之前必须进行
     
     - throws: 不存在预设颜色文件，无法拷贝入Document目录（容量不足等）
     */
    class func copyColorsToDocument() throws {
        let oldPath = NSBundle.mainBundle().pathForResource("Colors", ofType: "realm")!
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let targetPath = (documentPath as NSString).stringByAppendingPathComponent("Colors.realm")
        do {
            if NSFileManager.defaultManager().fileExistsAtPath(targetPath) {
                try NSFileManager.defaultManager().removeItemAtPath(targetPath)
            }
            try NSFileManager.defaultManager().copyItemAtPath(oldPath, toPath: targetPath)
        } catch let err as NSError {
            throw err
        }
    }
    
    /**
     获取所有颜色的对象
     
     - throws: Document文件夹中没有数据库，访问失败
     
     - returns: 所有颜色对象组成的Results
     */
    class func getColors() throws -> Results<Color> {
        var config = Realm.Configuration()
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let path = (documentPath as NSString).stringByAppendingPathComponent("Colors.realm")
        guard let url = NSURL(string: path) else {
            throw StoragedDataError.NoColorInStorage
        }
        config.fileURL = url
        do {
            let realm = try Realm(configuration: config)
            let colors = realm.objects(Color.self)
            if colors.count > 0 {
                return colors
            }
            else {
                throw StoragedDataError.NoColorInStorage
            }
        } catch let err {
            throw err
        }
    }
    
    /**
     获取颜色数量，在无数据时会返回0，方便统计count
     
     - returns: 颜色数量
     */
    class func getColorCount() -> Int {
        var config = Realm.Configuration()
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let path = (documentPath as NSString).stringByAppendingPathComponent("Colors.realm")
        guard let url = NSURL(string: path) else {
            return 0
        }
        config.fileURL = url
        do {
            let realm = try Realm(configuration: config)
            return realm.objects(Color.self).count
        } catch {
            return 0
        }
    }
    
    /**
     生成UIColor
     
     - returns: UIColor
     */
    func convertToUIColor() -> UIColor {
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    
    /**
     改变喜欢/不喜欢
     */
    func toggleLike() {
        var config = Realm.Configuration()
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let path = (documentPath as NSString).stringByAppendingPathComponent("Colors.realm")
        guard let url = NSURL(string: path) else {
            return
        }
        config.fileURL = url
        do {
            let realm = try Realm(configuration: config)
            try realm.write({
                self.liked = !self.liked
            })
        } catch {
            return
        }
    }
    
    dynamic var name = "unknown"
    dynamic var red = 0.0
    dynamic var green = 0.0
    dynamic var blue = 0.0
    dynamic var alpha = 0.0
    dynamic var liked = true
    
    convenience init(name: String, red: Double, green: Double, blue: Double, alpha: Double, liked: Bool) {
        self.init()
        self.name = name
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
        self.liked = liked
    }
}
