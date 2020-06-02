import glob
import argparse
import re
import os
import fileinput
import subprocess

excluded_platform_string = ""

def update_podspec_excluded(excluded_platforms, short_name):
	global excluded_platform_string
	excluded_platforms = excluded_platforms.split(',')
	included_platforms = ["ios", "watchos", "osx", "tvos"] 
	platformLookup = {"ios": "9.0", "watchos": "3.0", "osx": "10.11", "tvos": "9.0"}
	for platform in excluded_platforms:
		included_platforms.remove(platform)
		subprocess.call([f"sed -i '' 's/full.{platform}.exclude_files = .*/&,\"tealium\\/{short_name}\\/\\*\" /' tealium-swift.podspec"], shell=True)
	for platform in included_platforms:
		version = platformLookup[platform]
		excluded_platform_string += f"newline    {short_name}.{platform}.deployment_target = \"{version}\""	

def update_podspec_full(short_name):
	subprocess.call([f"sed -i '' 's/full.source_files  = .*/&,\"tealium\\/{short_name}\\/\\*\" /' tealium-swift.podspec"], shell=True)   	

def update_podspec_version(version):
	reg = re.compile("\d.\d.\d")
	for line in fileinput.input("tealium-swift.podspec", inplace=True):
		newline = reg.sub(version, line)
		print(newline, end="")


def add_module_podspec(full_name, short_name):
	global excluded_platform_string
	subprocess.call([f"sed -i '' '$s/$/>end> s.subspec \"{full_name}\" do |{short_name}|{excluded_platform_string}newline    {short_name}.source_files = \"tealium\\/{short_name}\\/\\*\"newline    {short_name}.dependency \"tealium-swift\\/Core\"newline  endnewlinenewlineend/'  tealium-swift.podspec && sed -e 's/newline/\\'$'\n/g' tealium-swift.podspec > tealium-swift-new.podspec && mv tealium-swift-new.podspec tealium-swift.podspec && sed -e 's/end>end>/\'$' /g' tealium-swift.podspec > tealium-swift-new.podspec && mv tealium-swift-new.podspec tealium-swift.podspec"], shell=True)

def update_package(full_name, short_name):
	subprocess.call([f"sed -i '' 's/products: \\[.*/& newline    .library(newline      name: \"{full_name}\",newline      targets: [\"{full_name}\"]),/' Package.swift && sed -e 's/newline/\\'$'\n/g' Package.swift > Package-new.swift && mv Package-new.swift Package.swift"], shell=True)   
	text_to_search = "path: \"tealium/core/\""
	replacement_text = f"path: \"tealium/core/\"\n    ),\n    .target(\n      name: \"{full_name}\",\n      dependencies: [\"TealiumCore\"],\n      path: \"tealium/{short_name}/\",\n      swiftSettings: [.define(\"{short_name}\")]"
	with fileinput.FileInput("Package.swift", inplace=True) as file:
		for line in file:
			print(line.replace(text_to_search, replacement_text), end='')
 
parser = argparse.ArgumentParser()
parser.add_argument("-v", "--version", help="New version number.")
parser.add_argument("-f", "--full_name", help="Full module name.")
parser.add_argument("-s", "--short_name", help="Short and lowercased module name.")                    
parser.add_argument("-e", "--excluded_platforms", help="Array of excluded platforms (if applicable)")
parser.add_argument("--debug", action="store_true")
args = parser.parse_args()

if args.full_name and args.short_name:
	update_package(args.full_name, args.short_name)  
	update_podspec_full(args.short_name) #python3 ./new-module.py -s 'newmodule' --debug
	if args.excluded_platforms:
		update_podspec_excluded(args.excluded_platforms, args.short_name) #python python3 ./new-module.py -s 'newmodule' -e 'tvos,osx' --debug
	add_module_podspec(args.full_name, args.short_name) #python3 ./new-module.py -s 'newmodule' -e 'tvos,osx' -f 'TealiumNewModule' --debug

if args.version:
	update_podspec_version(args.version)

if args.debug:
    print(vars(args))
    update_package(args.full_name, args.short_name)  
    update_podspec_full(args.short_name) #python3 ./new-module.py -s 'newmodule' --debug
    update_podspec_excluded(args.excluded_platforms, args.short_name) #python python3 ./new-module.py -s 'newmodule' -e 'tvos,osx' --debug
    add_module_podspec(args.full_name, args.short_name) #python3 ./new-module.py -s 'newmodule' -e 'tvos,osx' -f 'TealiumNewModule' --debug