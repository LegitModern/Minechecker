# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
use_frameworks!

target 'Minechecker' do

pod 'SwiftyJSON'
pod 'Alamofire', '~> 4.4'
pod 'MBProgressHUD', '~> 1.0'
pod 'Spring', :git => 'https://github.com/MengTo/Spring.git'
pod 'RealmSwift'
pod 'Firebase/Analytics'
pod 'Firebase/Crash'
pod 'Firebase/Messaging'

end

target 'MinecheckerTests' do

pod 'SwiftyJSON'
pod 'Alamofire', '~> 4.4'
pod 'MBProgressHUD', '~> 1.0'
pod 'Spring', :git => 'https://github.com/MengTo/Spring.git'
pod 'RealmSwift'
pod 'Firebase/Analytics'
pod 'Firebase/Crash'
pod 'Firebase/Messaging'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
