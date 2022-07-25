Pod::Spec.new do |s|

    # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.name         = "TealiumCrashModule"
    s.module_name  = "TealiumCrashModule"
    s.version      = "2.3.0"
    s.summary      = "Crash module for Tealium Swift v2.0.0+"
    s.description  = <<-DESC
    Adds crashing data reporting to the Tealium Swift SDK.
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
    s.ios.deployment_target = "11.0"
    s.tvos.deployment_target = "9.0"
    s.osx.deployment_target = "10.11"

    # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.source       = { :git => "https://github.com/Tealium/tealium-swift-crash-reporter.git", :tag => "#{s.version}" }

    s.default_subspec = "Crash"
    s.static_framework = true

    s.subspec "Crash" do |crash|
        # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
        crash.source_files      = "TealiumCrashModule/TealiumCrashModule/*.{swift}"
        # ――― Dependencies ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
        crash.dependency 'tealium-swift/Core'
        crash.dependency 'PLCrashReporter'
    end

end
