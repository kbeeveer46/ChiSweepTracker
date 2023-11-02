# Uncomment the next line to define a global platform for your project
 platform :ios, '14.3'

target 'ChiSweepTracker' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
	
	pod 'IQKeyboardManagerSwift'
	pod 'THLabel', '~> 1.4.0'
  pod 'OneSignal', '>= 3.0.0', '< 4.0'
  pod 'Alamofire', '~> 5.2'

end

target 'OneSignalNotificationServiceExtension' do
  use_frameworks!
  
  pod 'OneSignal', '>= 3.0.0', '< 4.0'
  
end

target 'Shortcuts' do
  use_frameworks!
  
  pod 'Alamofire', '~> 5.2'
  
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.3'
               end
          end
   end
end
