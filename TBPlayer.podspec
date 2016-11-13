Pod::Spec.new do |s|
    s.name         = 'TBPlayer'
    s.version      = '1.1'
    s.summary      = 'An easy way to use avPlayer'
    s.homepage     = 'https://github.com/suifengqjn/TBPlayer'
    s.license      = 'MIT'
    s.authors      = {'MJ Lee' => '199109106@qq.com'}
    s.platform     = :ios, '7.0'
    s.source       = {:git => 'https://github.com/suifengqjn/TBPlayer.git', :tag => s.version}
    s.source_files = 'TBPlayer/**/*.{h,m}'
    s.resource     = 'TBPlayer/TBPlayer.bundle'
    s.requires_arc = true
end