//
//  ErrorHandler.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/9/23.
//  Copyright © 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

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
}