# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

target 'YLPhotoBrowser' do
# Uncomment the next line if you're using Swift or would like to use dynamic frameworks
use_frameworks!

# Pods for YLPhotoBrowser


pod 'Kingfisher', '~> 4.0.1'


end

# 使用的是 Xcode 8，那么将下面代码复制到您的 Podfile 底部，以便在必要的时候更新 Swift 的版本：
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.0'
        end
    end
end
