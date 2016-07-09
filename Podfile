platform :ios, '8.0'
use_frameworks!


target 'NKU Helper' do

pod 'pop'
pod 'UAProgressView'
pod 'MBProgressHUD'
pod 'AVOSCloud'
pod 'DZNEmptyDataSet'
pod 'MJRefresh'
pod 'NJKWebViewProgress'
pod 'Alamofire'
pod 'SVProgressHUD'
pod 'YYText'
pod 'SwiftyJSON'

# 主模块(必须)
pod 'ShareSDK3'
# Mob 公共库(必须) 如果同时集成SMSSDK iOS2.0:可看此注意事项：http://bbs.mob.com/thread-20051-1-1.html
pod 'MOBFoundation'

# UI模块(非必须，需要用到ShareSDK提供的分享菜单栏和分享编辑页面需要以下1行)
pod 'ShareSDK3/ShareSDKUI'

# 平台SDK模块(对照一下平台，需要的加上。如果只需要QQ、微信、新浪微博，只需要以下3行)
pod 'ShareSDK3/ShareSDKPlatforms/QQ'
pod 'ShareSDK3/ShareSDKPlatforms/WeChat'

end

post_install do |installer|
`find Pods -regex 'Pods/pop.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)pop\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`
end
