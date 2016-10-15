//
//  Color.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/5/26.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import RealmSwift

/**
 颜色类
 * * * * *
 
 last modified:
 - date: 2016.10.12
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
class Color: Object {
    
// MARK:- Property
    
    /// 名称
    dynamic var name = "unknown"
    /// 红
    dynamic var red = 0.0
    /// 绿
    dynamic var green = 0.0
    /// 蓝
    dynamic var blue = 0.0
    /// alpha
    dynamic var alpha = 0.0
    /// 是否喜欢
    dynamic var liked = true
    
    /// 创建一个颜色对象
    ///
    /// - parameter name:  名称
    /// - parameter red:   红
    /// - parameter green: 绿
    /// - parameter blue:  蓝
    /// - parameter alpha: alpha
    /// - parameter liked: 是否喜欢
    ///
    /// - returns: 创建的颜色对象
    convenience init(name: String, red: Double, green: Double, blue: Double, alpha: Double, liked: Bool) {
        self.init()
        self.name = name
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
        self.liked = liked
    }
    
// MARK:- 类方法
    
    /// 将App预设的颜色拷贝入Document目录中，并加载到default.realm
    /// - important: 在使用Color类之前必须进行
    ///
    /// - throws: StoragedDataError.realmError
    class func copyColorsToDocument() throws {
        let oldPath = Bundle.main.path(forResource: "Colors", ofType: "realm")!
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let targetPath = (documentPath as NSString).appendingPathComponent("Colors.realm")
        var config = Realm.Configuration()
        do {
            if FileManager.default.fileExists(atPath: targetPath) {
                try FileManager.default.removeItem(atPath: targetPath)
            }
            try FileManager.default.copyItem(atPath: oldPath, toPath: targetPath)
            config.fileURL = URL(string: targetPath)!
            let realm = try Realm(configuration: config)
            let defaultRealm = try Realm()
            let colors = realm.objects(Color.self)
            try defaultRealm.write({
                for color in colors {
                    defaultRealm.add(defaultRealm.create(Color.self, value: color, update: false))
                }
            })
        } catch {
            throw StoragedDataError.realmError
        }
    }
    
    /// 获取所有的颜色
    ///
    /// - throws: StoragedDataError.noColorInStorage、StoragedDataError.realmError
    ///
    /// - returns: 所有颜色对象
    class func getAllColors() throws -> Results<Color> {
        do {
            let realm = try Realm()
            let colors = realm.objects(Color.self)
            if colors.count > 0 {
                return colors
            }
        } catch {
            throw StoragedDataError.realmError
        }
        throw StoragedDataError.noColorInStorage
    }
    
    /// 获取颜色数量
    /// - note: 在无数据时会返回0，方便统计count
    ///
    /// - returns: 颜色数量
    class func getColorCount() -> Int {
        do {
            let realm = try Realm()
            return realm.objects(Color.self).count
        } catch {
            return 0
        }
    }
    
    /// 删除所有default.realm中的颜色
    ///
    /// - throws: StoragedDataError.realmError
    class func deleteAllColors() throws {
        do {
            let colors = try getAllColors()
            let realm = try Realm()
            try realm.write({
                realm.delete(colors)
            })
        } catch {
            throw StoragedDataError.realmError
        }
    }
    
// MARK:- 实例方法
    
    /// 转化为UIColor
    ///
    /// - returns: UIColor
    func convertToUIColor() -> UIColor {
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    
    /// 改变喜欢/不喜欢
    func toggleLike() {
        do {
            let realm = try Realm()
            try realm.write({
                self.liked = !self.liked
            })
        } catch {
        }
    }
    
}
