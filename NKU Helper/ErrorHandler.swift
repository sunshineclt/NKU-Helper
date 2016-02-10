//
//  ErrorHandler.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/9/23.
//  Copyright © 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

protocol ErrorHandlerProtocol {
    
    static var title:String {get}
    static var message:String {get}
    static var cancelButtonTitle:String {get}
}


struct ErrorHandler {
    struct NetworkError:ErrorHandlerProtocol {
        static let title = "网络错误"
        static let message = "请检查网络"
        static let cancelButtonTitle = "知道啦，我去检查一下！"
    }
    struct UserNameOrPasswordWrong:ErrorHandlerProtocol {
        static let title = "登录失败"
        static let message = "用户不存在或密码错误"
        static let cancelButtonTitle = "好，重新设置用户名和密码"
    }
    struct ValidateCodeWrong:ErrorHandlerProtocol {
        static let title = "登录失败"
        static let message = "验证码错误"
        static let cancelButtonTitle = "好，重新输入验证码"
    }
    struct NotLoggedIn:ErrorHandlerProtocol {
        static let title = "尚未登录"
        static let message = "登陆后才可使用此功能，请到设置中登陆"
        static let cancelButtonTitle = "知道了！"
    }
    struct ClassNotExist:ErrorHandlerProtocol {
        static let title = "尚未获取课程表"
        static let message = "请到课程表页面获取课程表"
        static let cancelButtonTitle = "好！"
    }
    struct GetNotiFailed:ErrorHandlerProtocol {
        static let title = "获取通知列表失败"
        static let message = "请稍后再试或通知开发者"
        static let cancelButtonTitle = "好"
    }
    struct SelectCourseFail:ErrorHandlerProtocol {
        static let title = "选课失败"
        static let message = "选课失败"
        static let cancelButtonTitle = "好"
    }
    struct HtmlAnalyseFail:ErrorHandlerProtocol {
        static let title = "解析失败"
        static let message = "请重试,若仍然出现问题请通知开发者"
        static let cancelButtonTitle = "好"
    }
    struct EvaluateSystemNotOpen:ErrorHandlerProtocol {
        static let title = "评教系统未开"
        static let message = "若评教系统实际已开放请练习开发者"
        static let cancelButtonTitle = "好"
    }
    struct EvaluateHasDone:ErrorHandlerProtocol {
        static let title = "已评教"
        static let message = "此课程已评教"
        static let cancelButtonTitle = "好"
    }
    struct EvaluateSubmitFail:ErrorHandlerProtocol {
        static let title = "评教失败"
        static let message = "评教提交失败"
        static let cancelButtonTitle = "好"
    }
    struct shareFail:ErrorHandlerProtocol {
        static let title = "分享失败"
        static let message = "请检查网络"
        static let cancelButtonTitle = "好"
    }
    
    static func alert(error:ErrorHandlerProtocol) -> UIAlertController {
        let alert = UIAlertController(title: error.dynamicType.title, message: error.dynamicType.message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: error.dynamicType.cancelButtonTitle, style: .Cancel, handler: nil))
        return alert
    }
    
    static func alertWithAlertTitle(title: String?, message: String?, cancelButtonTitle: String?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: nil))
        return alert
    }
}