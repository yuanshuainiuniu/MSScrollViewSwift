Pod::Spec.new do |s|
s.name = 'MS_ScrollViewSwift'
s.version = '0.1.1'
s.summary = 'The easiest way to use Banner with Swift3.0 program language.'
s.homepage = 'https://github.com/yuanshuainiuniu/MSScrollViewSwift'
s.license = 'MIT'
s.author = { 'yuanshuai' => '717999274@qq.com' }
s.platform = :ios, '8.0'
s.source = { :git => 'https://github.com/yuanshuainiuniu/MSScrollViewSwift.git', :tag => s.version }
s.source_files = 'MSScrollView/**/*.{h,m}'
s.resource     = 'MSScrollView/MSSource.bundle'
s.requires_arc = true
end
