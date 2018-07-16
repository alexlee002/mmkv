Pod::Spec.new do |s|
  s.name         = "almmkv"

  # ver = `/usr/libexec/PlistBuddy -c 'print CFBundleShortVersionString' Info.plist`
  # abort("No version detected") if ver.nil?
  s.version      = "1.0"

  s.summary      = "A high performance and thread-safe KV cache component for iOS & OS X apps."
  s.description  = <<-DESC
  A high performance and thread-safe KV cache component for iOS & OS X apps.
  Inspired by Tencent's blog post: https://cloud.tencent.com/developer/article/1066229 .
                   DESC

  s.homepage     = "https://github.com/alexlee002/mmkv"
  s.license      =  { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.author             = { "Alex Lee" => "alexlee002@hotmail.com" }

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"

  #s.source       = { :git => "https://github.com/alexlee002/mmkv.git", :tag => "#{s.version}" }
  s.source       = { :git => "https://github.com/alexlee002/mmkv.git", :branch => "master" }

  s.source_files  = "mmkv", "mmkv/**/*.{h,m,mm,hpp,cpp}"
  s.public_header_files = "mmkv/**/*.h"

  s.dependency "Protobuf" #, "~> 3.6.0", 
  # Cocoapods only support 3.5, so in your podfile you should specified the protobuf like this:
  #   pod 'Protobuf', :git => 'https://github.com/google/protobuf.git'

end
