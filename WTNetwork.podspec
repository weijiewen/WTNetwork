#
# Be sure to run `pod lib lint WTNetwork.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WTNetwork'
  s.version          = '1.0.3'
  s.summary          = '苍茫的天涯是我的爱绵绵的青山脚下花正开什么样的节奏是最呀最摇摆什么样的歌声才是最开怀'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
苍茫的天涯是我的爱
绵绵的青山脚下花正开
什么样的节奏是最呀最摇摆
什么样的歌声才是最开怀
弯弯的河水从天上来
流向那万紫千红一片海
哗啦啦的歌谣是我们的期待
一路边走边唱才是最自在
我们要唱就要唱得最痛快
                       DESC

  s.homepage         = 'https://github.com/weijiewen/WTNetwork'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'weijiewen' => 'txywjw@icloud.com' }
  s.source           = { :git => 'https://github.com/weijiewen/WTNetwork.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  #s.vendored_frameworks = 'Example/Framework/WTNetworking.framework'
  s.source_files = 'WTNetwork/Classes/**/*'
  
  # s.resource_bundles = {
  #   'WTNetwork' => ['WTNetwork/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
