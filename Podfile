# Define the global platform for your project
platform :ios, '13.0'

target 'AAM' do
  # Use dynamic frameworks
  use_frameworks!

  # Pods for AAM
  pod 'GoogleSignIn'
  pod 'Firebase/Auth'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Database'
  pod 'Firebase/Messaging'
  pod 'IQKeyboardManagerSwift'
  pod 'NVActivityIndicatorView'
  pod 'FSPagerView'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'FittedSheets'
  pod 'Branch'
  pod 'SDWebImage', '~> 5.0'
  pod 'Firebase/Core'
  pod 'Firebase/Functions'
  pod 'Alamofire'
  pod 'StripePaymentSheet'
  
end

# Post-installation hook to enforce deployment target
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Set the deployment target to 12.0
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end

