Pod::Spec.new do |s|
    s.name             = 'DJIFileManager'
    s.version          = '1.3.0'
    s.summary          = 'A file management component for DJISDK-iOS'
    s.homepage         = 'https://github.com/gzkiwiinc/DJIFileManager'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.authors          = { "Kyle" => "lacklock@gmail.com",
                           "Hanson" => "hansenhs21@live.com" }
    s.source           = { :git => 'https://github.com/gzkiwiinc/DJIFileManager.git', :tag => s.version.to_s }
    
    s.ios.deployment_target = '10.0'
    s.swift_version = '5.0'
    s.xcconfig = { 'VALID_ARCHS' => 'arm64 arm64e' }
    
    s.source_files = 'DJIFileManager/*.swift'
    s.resource_bundles = {
        'DJIFileManager' => ['DJIFileManager/Assets/*']
    }

    s.dependency 'DJI-SDK-iOS', '~> 4.11'
    s.dependency 'SnapKit'
    s.dependency 'PromiseKit'
    s.dependency 'MJRefresh'
    s.dependency 'DJISDKExtension'
    
    s.frameworks = 'UIKit'
    
end
