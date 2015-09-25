//
//  ErrorHandler.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/9/23.
//  Copyright © 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

struct ErrorHandler {
    struct NetworkError {
        static let title = "网络错误"
        static let message = "请检查网络"
        static let cancelButtonTitle = "知道啦，我去检查一下！"
        
    }
    struct UserNameOrPasswordWrong {
        static let title = "登录失败"
        static let message = "用户不存在或密码错误"
        static let cancelButtonTitle = "好，重新设置用户名和密码"
    }
    struct ValidateCodeWrong {
        static let title = "登录失败"
        static let message = "验证码错误"
        static let cancelButtonTitle = "好，重新输入验证码"
    }
    struct NotLoggedIn {
        static let title = "尚未登录"
        static let message = "登陆后才可使用此功能，请到设置中登陆"
        static let cancelButtonTitle = "知道了！"
    }
    struct ClassNotExist {
        static let title = "尚未获取课程表"
        static let message = "请到课程表页面获取课程表"
        static let cancelButtonTitle = "好！"
    }
}