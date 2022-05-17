#
# Be sure to run `pod lib lint WLAsyncDisplay.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WLAsyncDisplay'
  s.version          = '1.1.0'
  s.summary          = 'A short description of WLAsyncDisplay.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'iOS CoreText 异步绘制'

  s.homepage         = 'https://github.com/Weang/WLAsyncDisplay'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'w704444178@qq.com' => 'w704444178@qq.com' }
  s.source           = { :git => 'https://github.com/Weang/WLAsyncDisplay.git', :tag => '1.0.2' }

  s.ios.deployment_target = '9.0'

  s.source_files = 'WLAsyncDisplay/Classes/**/*'
  
  s.swift_versions = "5.0"
  
end
