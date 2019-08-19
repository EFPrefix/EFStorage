#
# Be sure to run `pod lib lint EFStorage.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EFStorage'
  s.version          = '0.0.2'
  s.summary          = 'Store anything anywhere with ease.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    EFStorage is an easy way to store anything anywhere.
  DESC

  s.homepage         = 'https://github.com/EFPrefix/EFStorage'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ApolloZhu' => 'public-apollonian@outlook.com' }
  s.source           = { :git => 'https://github.com/EFPrefix/EFStorage.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/zhuzhiyu_'

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.swift_version = "5.0"
  s.source_files = 'Sources/**/*.swift'

  s.frameworks = 'Foundation'
  
  s.subspec 'Core' do |sp|
    sp.source_files = 'Sources/EFStorageCore'
  end
  
  s.subspec 'KeychainAccess' do |sp|
    sp.source_files = 'Sources/EFStorageKeychainAccess'
    sp.dependency 'KeychainAccess', '~> 3.2.0'
    sp.dependency 'EFStorage/Core'
  end
  
  s.subspec 'UserDefaults' do |sp|
    sp.source_files = 'Sources/EFStorageUserDefaults'
    sp.dependency 'EFStorage/Core'
  end
  
  s.subspec 'YYCache' do |sp|
    sp.source_files = 'Sources/YYCache'
    sp.dependency 'YYCache', '~> 1.0.4'
    sp.dependency 'EFStorage/Core'
  end
end
