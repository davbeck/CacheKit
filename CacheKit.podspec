Pod::Spec.new do |spec|
  spec.name             = "CacheKit"
  spec.version          = "0.3.0"
  spec.summary          = "Easily cache objects in memory, to files, a database or not at all."
  spec.homepage         = "https://github.com/davbeck/CacheKit"
  spec.license          = 'MIT'
  spec.author           = { "David Beck" => "code@thinkultimate.com" }
  spec.source           = { :git => "https://github.com/davbeck/CacheKit.git", :tag => spec.version.to_s }
  spec.social_media_url = 'https://twitter.com/davbeck'
  
  spec.requires_arc = true

  spec.ios.deployment_target = '6.0'
  spec.osx.deployment_target = '10.8'
  
  spec.dependency 'FMDB', '~> 2.4'

  spec.subspec "Core" do |core_spec|
    core_spec.source_files = "Pod/Classes"
  end

  spec.subspec "FastImages" do |fast_images_spec|
    fast_images_spec.dependency 'CacheKit/Core'
    
    fast_images_spec.ios.source_files = 'Pod/FastImages'
    fast_images_spec.osx.source_files = ''
  end
end
