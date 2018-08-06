#
# Be sure to run `pod lib lint ScrollSegmentsSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#


Pod::Spec.new do |s|
s.name             = 'ScrollSegmentsSwift'
s.version          = `git describe --abbrev=0 --tags`
s.summary          = 'Scrollable segments with animation for iOS.'
s.description      = <<-DESC
'Scrollable segments with animation for iOS.'
DESC
s.homepage         = 'https://github.com/raketenok/ScrollSegmentsSwift'
# s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Ievgen Iefimenko' => 'raketenok@gmail.com' }
s.source           = { :git => 'https://github.com/raketenok/ScrollSegmentsSwift.git', :tag => s.version }
s.ios.deployment_target = '8.0'
s.source_files = 'ScrollSegmentsSwift/**/*'
s.swift_version = '4.0'
end

#git describe --abbrev=0 --tags
