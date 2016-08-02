//
//  Color.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/5/26.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import RealmSwift

/// 颜色类
class Color: Object {
    
    /**
     将App预设的颜色拷贝入Document目录中，并加载到default.realm，在使用Color类之前必须进行
     
     - throws: RealmError
     */
    class func copyColorsToDocument() throws {
        let oldPath = NSBundle.mainBundle().pathForResource("Colors", ofType: "realm")!
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let targetPath = (documentPath as NSString).stringByAppendingPathComponent("Colors.realm")
        var config = Realm.Configuration()
        do {
            if NSFileManager.defaultManager().fileExistsAtPath(targetPath) {
                try NSFileManager.defaultManager().removeItemAtPath(targetPath)
            }
            try NSFileManager.defaultManager().copyItemAtPath(oldPath, toPath: targetPath)
            config.fileURL = NSURL(string: targetPath)!
            let realm = try Realm(configuration: config)
            let defaultRealm = try Realm()
            let colors = realm.objects(Color.self)
            try defaultRealm.write({
                for color in colors {
                    //let oneColor = Color(name: color.name, red: color.red, green: color.green, blue: color.blue, alpha: color.alpha, liked: color.liked)
                    defaultRealm.add(defaultRealm.create(Color.self, value: color, update: false))
                }
            })
        } catch {
            throw StoragedDataError.RealmError
        }
    }
    
    /**
     获取所有颜色的对象
     
     - throws: NoColorInStorage和RealmError
     
     - returns: 所有颜色对象组成的Results
     */
    class func getColors() throws -> Results<Color> {
        do {
            let realm = try Realm()
            let colors = realm.objects(Color.self)
            if colors.count > 0 {
                return colors
            }
            else {
                throw StoragedDataError.NoColorInStorage
            }
        } catch StoragedDataError.NoColorInStorage {
            throw StoragedDataError.NoColorInStorage
        }
        catch {
            throw StoragedDataError.RealmError
        }
    }
    
    /**
     获取颜色数量，在无数据时会返回0，方便统计count
     
     - returns: 颜色数量
     */
    class func getColorCount() -> Int {
        do {
            let realm = try Realm()
            return realm.objects(Color.self).count
        } catch {
            return 0
        }
    }
    
    /**
     删除所有default.realm中的颜色
     
     - throws: RealmError
     */
    class func deleteAllColor() throws {
        do {
            let colors = try getColors()
            let realm = try Realm()
            try realm.write({
                realm.delete(colors)
            })
        } catch {
            throw StoragedDataError.RealmError
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
        do {
            let realm = try Realm()
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
