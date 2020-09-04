
package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "RNNativeCiesdk"
  s.version      = "0.2.3"
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
  s.source_files = "ios/**/*.{c,cpp,h,m,mm,swift}"
  s.header_dir   = "ios/include"
  s.public_header_files = "ios/include/**/*.h" 
  s.vendored_libraries = "libcrypto.a", "libssl.a", "libcurl_iOS.a", "libnghttp2_iOS.a"
  s.libraries = 'z', 'crypto', 'ssl', 'curl_iOS', 'nghttp2_iOS'
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => "${PODS_ROOT}/#{s.name}/include/**" }
  s.preserve_paths = 'include/openssl/*.h', 'include/curl/*.h'

  s.requires_arc = true

  s.dependency "React"
  #s.dependency "others"

end

  