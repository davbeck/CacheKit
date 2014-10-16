Pod::Spec.new do |s|
  s.name             = "CacheKit"
  s.version          = "0.1.0"
  s.summary          = "Simple and flexible caching mechanism for in memory and persistent caches."
  s.description      = <<-DESC
                       Easily cache objects in memory, to files, a database or not at all.
                       DESC
  s.homepage         = "https://github.com/davbeck/CacheKit"
  s.license          = 'MIT'
  s.author           = { "David Beck" => "code@thinkultimate.com" }
  s.source           = { :git => "https://github.com/davbeck/CacheKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/davbeck'

  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'
  s.requires_arc = true

  s.default_subspec = 'standard'

  s.resource_bundles = {
    'CacheKit' => ['Pod/Assets/*.png']
  }

  s.subspec 'common' do |ss|
      ss.source_files = 'Pod/Classes'
  end

  # use the standard FMDB version
  s.subspec 'standard' do |ss|
    ss.dependency 'FMDB', '~> 2.4'
    ss.dependency 'CacheKit/common'
  end

  # use the standalone FMDB version
  s.subspec 'standalone' do |ss|
    ss.dependency 'FMDB/standalone', '~> 2.4'
    ss.dependency 'CacheKit/common'
  end

end
