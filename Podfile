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

end

post_install do |installer|
`find Pods -regex 'Pods/pop.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)pop\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`
end