require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))


Pod::Spec.new do |s|
  s.name         = "RNNativeCiesdk"
  s.version      = package['version']
  s.summary      = "RNNativeCiesdk"
  s.description  = package['description']
  s.license      = package['description']
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/pagopa/io-cie-ios-sdk", :tag => "master" }
  s.source_files  = "RNNativeCiesdk/**/*.{h,m}"
  s.requires_arc = true
  s.homepage     = "https://github.com/pagopa/io-cie-ios-sdk"
  s.dependency "React"


end

  