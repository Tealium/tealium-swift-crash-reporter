#!/bin/bash

#######################################################
# xcframework builder script for TealiumCrashModule
#######################################################

# variable declarations
BUILD_PATH="build"
XCFRAMEWORK_PATH="TealiumCrashModule.xcframework"
ZIP_PATH="TealiumCrashModule.xcframework.zip"
XCODE_PROJECT="TealiumCrashModule"
MACOS_SDKROOT="SDKROOT = macosx;"
IOS_SDKROOT="SDKROOT = \"iphoneos\";"
LATEST_MAJOR="2."
declare -a PRODUCT_NAME
# destinations
IOS_SIM_DESTINATION="generic/platform=iOS Simulator"
IOS_DESTINATION="generic/platform=iOS"
TVOS_SIM_DESTINATION="generic/platform=tvOS Simulator"
TVOS_DESTINATION="generic/platform=tvOS"
MACOS_DESTINATION="generic/platform=macOS"
# xcarchives
IOS_SIM_ARCHIVE="ios-sim.xcarchive"
IOS_ARCHIVE="ios.xcarchive"
TVOS_SIM_ARCHIVE="tvos-sim.xcarchive"
TVOS_ARCHIVE="tvos.xcarchive"
MACOS_ARCHIVE="macos.xcarchive"

# function declarations
function define_product_name {
    case $1 in
        *"$LATEST_MAJOR"*)
            PRODUCT_NAME=(TealiumCrashModule)
            ;;
        *)
            echo "ERROR, VERSION NUMBER INVALID"
            ;;
    esac    
}

function clean_build_folder {
    if [[ -d "${BUILD_PATH}" ]]; then
        rm -rf "${BUILD_PATH}"
    fi
    if [[ -d "${ZIP_PATH}" ]]; then
        rm "${ZIP_PATH}"
    fi
}

function check_architecture {
    local archs=( "$@" )
    for arch in "${archs[@]}"
    do 
        if ! echo "$1" | grep -q "${arch}"; then
            echo "ERROR, ARCHITECTURE MISSING!!!"
        else              # uncomment for debugging
            echo "+found ${arch}"
        fi
    done
}

# create indv archive
function archive {
    xcodebuild archive \
    -project "${XCODE_PROJECT}.xcodeproj" \
    -scheme "${1}" \
    -destination "${2}" \
    -archivePath "${3}" \
    -sdk "${4}" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    BUILD_SCRIPT=YES
    echo "Archiving ${1} ${2} ${3} ${4}"   
}

# create xcframeworks for products supporting all platforms
function create_xcframework_all {
    xcodebuild -create-xcframework \
    -framework "${BUILD_PATH}/${IOS_SIM_ARCHIVE}/Products/Library/Frameworks/${1}.framework" \
    -framework "${BUILD_PATH}/${IOS_ARCHIVE}/Products/Library/Frameworks/${1}.framework" \
    -framework "${BUILD_PATH}/${TVOS_SIM_ARCHIVE}/Products/Library/Frameworks/${1}.framework" \
    -framework "${BUILD_PATH}/${TVOS_ARCHIVE}/Products/Library/Frameworks/${1}.framework" \
    -framework "${BUILD_PATH}/${MACOS_ARCHIVE}/Products/Library/Frameworks/${1}.framework" \
    -output "${1}".xcframework;
}

# create xcframework for each product that contains all supported platforms
function create_xcframework {
    create_xcframework_all "${1}"
}

# create archives for products supporting all platforms
function create_archives_all {
    archive "$1" "${IOS_SIM_DESTINATION}" "${BUILD_PATH}/${IOS_SIM_ARCHIVE}" "iphonesimulator"
    archive "$1" "${IOS_DESTINATION}" "${BUILD_PATH}/${IOS_ARCHIVE}" "iphoneos"
    archive "$1" "${TVOS_SIM_DESTINATION}" "${BUILD_PATH}/${TVOS_SIM_ARCHIVE}" "appletvsimulator"
    archive "$1" "${TVOS_DESTINATION}" "${BUILD_PATH}/${TVOS_ARCHIVE}" "appletvos"
    archive "$1" "${MACOS_DESTINATION}" "${BUILD_PATH}/${MACOS_ARCHIVE}" "macosx"
    create_xcframework "$1" 
}

# create all archives for each product and platform
function create_archives {
    if [ -z "$1" ]
      then
        echo "WARNING, NO VERSION NUMBER ENTERED. ASSUMING LATEST."
        define_product_name "${LATEST_MAJOR}"
    else
        define_product_name "$1"
    fi
    for i in "${PRODUCT_NAME[@]}"; 
        do
            create_archives_all "$i" 
        done    
}

# zip all the xcframeworks
function zip_xcframeworks {
    if [[ -d "${XCFRAMEWORK_PATH}" ]]; then
        zip -r "${ZIP_PATH}" "${XCFRAMEWORK_PATH}"
        rm -rf "${XCFRAMEWORK_PATH}"
    fi
}

#### start ####
clean_build_folder

# do the work
create_archives "$1"
zip_xcframeworks

mv "${ZIP_PATH}" "../"

echo ""
echo "Done! Upload ${ZIP_PATH} to GitHub when you create the release."
