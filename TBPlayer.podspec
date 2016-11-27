Pod::Spec.new do |s|
  s.name         = "TBPlayer"
  s.version      = "1.0"
  s.summary      = "An easy way to use avPlayer"
  s.description  = <<-DESC
                    TBPlayer is base on AVplayer
                   DESC
  s.homepage     = "https://github.com/suifengqjn/TBPlayer"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'qianjianeng' => '329426491@qq.comm' }
  s.source       = { :git => "https://github.com/suifengqjn/TBPlayer.git", :tag => '1.0' }
  s.source_files = 'TBPlayer/Classes/**/*.{h,m}'
  #s.resource     = 'TBPlayer/Classes/TBPlayer.bundle'
  #s.frameworks   = "CoreGraphics", "QuartzCore"
  s.requires_arc = true
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }
end