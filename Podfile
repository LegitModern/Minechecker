# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
use_frameworks!

target 'Minechecker' do

pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
pod 'Alamofire', '~> 4.0'
pod 'MBProgressHUD', '~> 1.0'
pod 'Spring', :git => 'https://github.com/MengTo/Spring.git'
pod 'RealmSwift'
pod 'Firebase/Analytics', '~> 3.6'
pod 'Firebase/Crash', '~> 3.6'
pod 'Firebase/Messaging', '~> 3.6'

end

target 'MinecheckerTests' do

pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
pod 'Alamofire', '~> 4.0'
pod 'MBProgressHUD', '~> 1.0'
pod 'Spring', :git => 'https://github.com/MengTo/Spring.git'
pod 'RealmSwift'
pod 'Firebase/Analytics', '~> 3.6'
pod 'Firebase/Crash', '~> 3.6'
pod 'Firebase/Messaging', '~> 3.6'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
