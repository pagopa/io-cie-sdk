
package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "RNNativeCiesdk"
  s.version      = "0.2.2"
  s.summary      = "RNNativeCiesdk"
  s.description  = <<-DESC
                  RNNativeCiesdk
                   DESC
  s.homepage     = "https://github.com/pagopa/io-cie-android-sdk"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "matteo.boschi@pagopa.it" }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/pagopa/io-cie-android-sdk.git", :tag => "0.2.2" }
  s.source_files  = "RNNativeCiesdk/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  #s.dependency "others"

end

  