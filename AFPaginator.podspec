#
# Be sure to run `pod lib lint AFPaginator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AFPaginator'
  s.version          = '1.0.0'
  s.summary          = 'The library that helps to manage paginated sources'

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
  s.source           = { :git => 'https://github.com/anton-filimonov/Paginator.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/AntonFilimon'

  s.ios.deployment_target = '8.0'
  s.default_subspec = 'Core'

  s.subspec 'Core' do |cs|
    cs.source_files = 'Paginator/Classes/*.{h,m}'
  end

  s.subspec 'ParametersProviders' do |cps|
    cps.source_files = 'Paginator/Classes/PagingParametersProviders/*.{h,m}'
    cps.dependency 'AFPaginator/Core'
  end
end
