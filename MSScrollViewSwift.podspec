Pod::Spec.new do |s|
s.name = 'MSScrollViewSwift'
s.version = '0.1.9'
s.summary = 'The easiest way to use Banner with Swift3.0 program language.'
s.homepage = 'https://github.com/yuanshuainiuniu/MSScrollViewSwift'
s.license = 'MIT'
s.author = { 'yuanshuai' => '717999274@qq.com' }
s.platform = :ios, '8.0'
s.source = { :git => 'https://github.com/yuanshuainiuniu/MSScrollViewSwift.git', :tag => s.version }
s.source_files = ["Source","Source/*.swift"]
s.resource     = 'Source/MSSource.bundle'
s.requires_arc = true
s.framework = "CFNetwork"
s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }
end
