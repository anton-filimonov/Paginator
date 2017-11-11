#
# Be sure to run `pod lib lint Paginator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Paginator'
  s.version          = '0.1.0'
  s.summary          = 'The library that helps when you have to load list of data divided into pages'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This library performs operations that are common for loading lists of data divided into pages: preventing races of page loading, checking whether there's more data to load and so forth. It also provides classes that could handle page parameters calculations for the most basic cases.
                       DESC

  s.homepage         = 'https://github.com/anton-filimonov/Paginator'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Anton Filimonov' => 'anton.s.filimonov@gmail.com' }
  s.source           = { :git => 'https://github.com/Anton Filimonov/Paginator.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/AntonFilimon'

  s.ios.deployment_target = '8.0'
  s.default_subspecs = 'Core', 'ParametersProviders'

  s.subspec 'Core' do |cs|
    cs.source_files = 'Paginator/Classes/*.{h,m}'
  end

  s.subspec 'ParametersProviders' do |cps|
    cps.source_files = 'Paginator/Classes/PagingParametersProviders/*.{h,m}'
    cps.dependency 'Paginator/Core'
  end

# s.source_files = 'Paginator/Classes/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
