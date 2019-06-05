#
# Be sure to run `pod lib lint JFJSKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JFJSKit'
  s.version          = '0.1.0'
  s.summary          = 'An iOS framework for sending messages between Obj-C and JavaScript in WKWebView and React-Native.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    1. Pluginization, be flexible to extend
    2. Support to WKWebView, React-Native
    3. Non-intrusive, independent of the container(webview, rctRootView)
    4. provide build-in basic plugin
                       DESC

  s.homepage         = 'https://github.com/huangdonghong/JFJSKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'huangdonghong' => 'huangdonghong2@yy.com' }
  s.source           = { :git => 'https://github.com/huangdonghong/JFJSKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'Source/Classes/**/*'
  
  # s.resource_bundles = {
  #   'JFJSKit' => ['Source/Assets/*.png']
  # }

   s.public_header_files = 'Source/Classes/**/*.h'
   s.frameworks = 'Foundation', 'UIKit', 'CommonCrypto', 'WebKit', 'CoreLocation'
   s.dependency 'React', '~> 0.51.0'
end
