Pod::Spec.new do |s|
    s.name = 'MSScrollViewSwift'
    s.version = '0.3.5'
    s.summary = 'The easiest way to use Banner with Swift program language.'
    s.homepage = 'https://github.com/yuanshuainiuniu/MSScrollViewSwift'
    s.license = 'MIT'
    s.author = { 'yuanshuai' => '717999274@qq.com' }
    s.platform = :ios, '8.0'
    s.source = { :git => 'https://github.com/yuanshuainiuniu/MSScrollViewSwift.git', :tag => s.version }
    s.source_files = ["Source","Source/*.swift"]
    #s.resource     = 'Source/MSSource.bundle'
    s.requires_arc = true
    s.framework = "CFNetwork"
    s.swift_version         = "5.0"
    s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    
    #pod trunk push MSScrollViewSwift.podspec --verbose

end
