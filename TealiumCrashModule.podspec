Pod::Spec.new do |s|

    # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.name         = "TealiumCrashModule"
    s.module_name  = "TealiumCrashModule"
    s.version      = "2.1.0"
    s.summary      = "Crash module for Tealium Swift v2.0.0+"
    s.description  = <<-DESC
    Crash module for Tealium Swift v2.0.0+
    DESC
    s.homepage     = "https://github.com/Tealium/tealium-swift-crash-reporter"

    # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.license      = { :type => "Commercial", :file => "LICENSE.txt" }
    
    # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.authors            = { "Tealium Inc." => "tealium@tealium.com",
        "craigrouse"   => "craig.rouse@tealium.com"}
    s.social_media_url   = "https://twitter.com/tealium"

    # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.swift_version = "5.0"
    s.platform     = :ios, "10.0"
    s.ios.deployment_target = "10.0"    

    # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.source       = { :git => "https://github.com/Tealium/tealium-swift-crash-reporter", :tag => "#{s.version}" }

    s.default_subspec = "Crash"

    # s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'EXCLUDED_ARCHS[sdk=iphoneos*]' => 'arm64'}
    # s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'EXCLUDED_ARCHS[sdk=iphoneos*]' => 'arm64'}

    s.subspec "Crash" do |crash|
        # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
        crash.ios.source_files      = "TealiumCrashModule/TealiumCrashModule/*.{swift}"
        # ――― Dependencies ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
        crash.ios.dependency 'tealium-swift/Core'
        crash.ios.dependency 'PLCrashReporter', '1.8'
    end

end
