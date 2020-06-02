#!/bin/bash

#######################################################
# unit test script for tealium-swift-builder
#######################################################

# function declarations
BUILD_PATH="build"
function clean_build_folder {
    if [[ -d "${BUILD_PATH}" ]]; then
        rm -rf "${BUILD_PATH}"
    fi
}

function build_scheme {
    xcodebuild -project tealium-swift.xcodeproj -scheme "$1"
}

function test_scheme {
    xcodebuild -scheme "$1" -sdk iphonesimulator -destination "$2" test | xcpretty --test --color
}

#### start ####
clean_build_folder

# run tests first
ios_test_platform="platform=iOS Simulator,name=iPhone XS,OS=13.1"
tvos_test_platform="platform=tvOS Simulator,name=Apple TV 4K (at 1080p)"
watchos_test_platform="platform=watchOS Simulator,name=Apple Watch - 42mm"
macos_test_platform="platform=OS X,arch=x86_64"

test_scheme TealiumAppData-iOS "${ios_test_platform}"
test_scheme TealiumAppData-tvOS "${tvos_test_platform}"
test_scheme TealiumAppData-macOS "${macos_test_platform}"
test_scheme TealiumAttribution-iOS "${ios_test_platform}"
test_scheme TealiumAutotracking-iOS "${ios_test_platform}"
test_scheme TealiumConsentManager-iOS "${ios_test_platform}"
test_scheme TealiumConsentManager-tvOS "${tvos_test_platform}"
test_scheme TealiumConsentManager-macOS "${macos_test_platform}"
test_scheme TealiumCollect-iOS "${ios_test_platform}"
test_scheme TealiumCollect-tvOS "${tvos_test_platform}"
test_scheme TealiumCollect-macOS "${macos_test_platform}"
test_scheme TealiumConnectivity-iOS "${ios_test_platform}"
test_scheme TealiumConnectivity-tvOS "${tvos_test_platform}"
test_scheme TealiumConnectivity-macOS "${macos_test_platform}"
test_scheme TealiumCore-iOS "${ios_test_platform}"
test_scheme TealiumCore-tvOS "${tvos_test_platform}"
test_scheme TealiumCore-macOS "${macos_test_platform}"
test_scheme TealiumDelegate-iOS "${ios_test_platform}"
test_scheme TealiumDelegate-tvOS "${tvos_test_platform}"
test_scheme TealiumDelegate-macOS "${macos_test_platform}"
test_scheme TealiumDeviceData-iOS "${ios_test_platform}"
test_scheme TealiumDeviceData-tvOS "${tvos_test_platform}"
test_scheme TealiumDeviceData-macOS "${macos_test_platform}"
test_scheme TealiumDispatchQueue-iOS "${ios_test_platform}"
test_scheme TealiumDispatchQueue-tvOS "${tvos_test_platform}"
test_scheme TealiumDispatchQueue-macOS "${macos_test_platform}"
test_scheme TealiumLifecycle-iOS "${ios_test_platform}"
test_scheme TealiumLifecycle-tvOS "${tvos_test_platform}"
test_scheme TealiumLifecycle-macOS "${macos_test_platform}"
test_scheme TealiumLocation-iOS "${ios_test_platform}"
test_scheme TealiumLogger-iOS "${ios_test_platform}"
test_scheme TealiumLogger-tvOS "${tvos_test_platform}"
test_scheme TealiumLogger-macOS "${macos_test_platform}"
test_scheme TealiumPersistentData-iOS "${ios_test_platform}"
test_scheme TealiumPersistentData-tvOS "${tvos_test_platform}"
test_scheme TealiumPersistentData-macOS "${macos_test_platform}"
test_scheme TealiumRemoteCommands-iOS "${ios_test_platform}"
test_scheme TealiumTagManagement-iOS "${ios_test_platform}"
test_scheme TealiumVisitorService-iOS "${ios_test_platform}"
test_scheme TealiumVisitorService-tvOS "${tvos_test_platform}"
test_scheme TealiumVisitorService-macOS "${macos_test_platform}"
test_scheme TealiumVolatileData-iOS "${ios_test_platform}"
test_scheme TealiumVolatileData-tvOS "${tvos_test_platform}"
test_scheme TealiumVolatileData-macOS "${macos_test_platform}"

# build frameworks
build_scheme TealiumAppData
build_scheme TealiumAttribution
build_scheme TealiumAutotracking
build_scheme TealiumConsentManager
build_scheme TealiumCollect
build_scheme TealiumConnectivity
build_scheme TealiumCore
build_scheme TealiumDelegate
build_scheme TealiumDeviceData
build_scheme TealiumDispatchQueue
build_scheme TealiumLifecycle
build_scheme TealiumLocation
build_scheme TealiumLogger
build_scheme TealiumPersistentData
build_scheme TealiumRemoteCommands
build_scheme TealiumTagManagement
build_scheme TealiumVisitorService
build_scheme TealiumVolatileData


echo ""
echo "Done unit-tests script."
