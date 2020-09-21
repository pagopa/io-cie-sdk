
package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "react-native-cie"
  s.version      = "0.2.10"
  s.summary      = "react-native-cie"
  s.description  = <<-DESC
                  react-native-cie
                   DESC
  s.homepage     = "https://github.com/pagopa/io-cie-android-sdk"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "matteo.boschi@pagopa.it" }
  s.platform     = :ios, "10.0"

  s.source       = { :git => "https://github.com/pagopa/io-cie-android-sdk.git", :tag => "0.2.2" }
  
  s.source_files = "ios/*.{h,m}"
  s.public_header_files = "ios/*.h" 
  
  s.vendored_frameworks = "ios/iociesdkios.framework"


  s.frameworks = "Foundation", "CoreFoundation", "iociesdkios"


 # s.source       = { :git => "https://github.com/pagopa/io-cie-android-sdk.git", :tag => "0.2.2" }
 # s.source_files = "RNNativeCiesdk/**/*.{c,cpp,h,m,mm,swift}"
 # s.header_dir   = "include"
 # s.header_mappings_dir = 'include'
 # s.requires_arc = true
 # s.public_header_files = "include/**/*.h" 
 # s.vendored_libraries = "libcrypto.a", "libssl.a", "libcurl_iOS.a", "libnghttp2_iOS.a"
 # s.libraries = 'z', 'crypto', 'ssl', 'curl_iOS', 'nghttp2_iOS'
 # s.xcconfig = { 'HEADER_SEARCH_PATHS' => "${PODS_ROOT}/#{s.name}/include/**" }
 # s.preserve_paths = 'include/openssl/*.h', 'include/curl/*.h'

  s.dependency "React"
  #s.dependency "others"

end

  
