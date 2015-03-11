Pod::Spec.new do |s|
  s.name             = "CacheKit"
  s.version          = "0.1.1"
  s.summary          = "Easily cache objects in memory, to files, a database or not at all."
  s.homepage         = "https://github.com/davbeck/CacheKit"
  s.license          = 'MIT'
  s.author           = { "David Beck" => "code@thinkultimate.com" }
  s.source           = { :git => "https://github.com/davbeck/CacheKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/davbeck'

  s.platform = :ios, '6.0'
  s.requires_arc = true

  s.default_subspec = 'standard'

  s.resource_bundles = {
    'CacheKit' => ['Pod/Assets/*.png']
  }

  # use the standard FMDB version
  s.subspec 'standard' do |ss|
    ss.source_files = 'Pod/Classes'
    ss.dependency 'FMDB', '~> 2.4'
  end

  # use the standalone FMDB version
  s.subspec 'standalone' do |ss|
    ss.source_files = 'Pod/Classes'
    ss.dependency 'FMDB/standalone', '~> 2.4'
  end

end
