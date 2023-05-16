platform :ios, '13.0'

target 'Client' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Client

  target 'ClientTests' do
    inherit! :search_paths
    # Pods for testing
  end

  pod 'ConnectWalletConnectAdapter', '0.1.52'
  pod 'ConnectEVMAdapter', '0.1.52'
  pod 'ConnectSolanaAdapter', '0.1.52'
  pod 'ConnectPhantomAdapter', '0.1.52'
  pod 'ParticleConnect', '0.1.52'
  pod 'ConnectCommon', '0.1.52'
  pod 'WalletConnectSwift', :git => 'https://github.com/SunZhiC/WalletConnectSwift', :branch => 'master'
  
  pod 'ParticleWalletAPI', '0.12.0'
  pod 'ParticleNetworkBase', '0.12.0'
  pod 'ParticleAuthService', '0.12.0'
  pod 'SDWebImage'
  pod 'SnapKit'
  pod 'SVProgressHUD'
  pod 'iOSDropDown'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end

target 'CredentialProvider' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CredentialProvider

end

target 'NotificationService' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for NotificationService

end

target 'RustMozillaAppServices' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for RustMozillaAppServices

end

target 'Shared' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Shared

  target 'SharedTests' do
    # Pods for testing
  end

end

target 'ShareTo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ShareTo

end

target 'Storage' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Storage

  target 'StoragePerfTests' do
    # Pods for testing
  end

  target 'StorageTests' do
    # Pods for testing
  end

end

target 'Today' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Today

end

target 'WidgetKitExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for WidgetKitExtension

end
