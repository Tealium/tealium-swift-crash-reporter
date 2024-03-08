# A script to verify that the repo is up to date and the versions are correct and then runs the pod trunk push command

podspecFile=$(<TealiumCrashModule.podspec)
podspecRegex="^.*s.version[[:space:]]*\= \"([0-9\.]*)\""

if [[ $podspecFile =~ $podspecRegex ]]
then
    podspecVersion=${BASH_REMATCH[1]}
else
    echo "Couldn't match the podspec version, exiting"
    exit 1
fi
echo Podspec Version  $podspecVersion

branch_name="$(git rev-parse --abbrev-ref HEAD)"
echo Current branch $branch_name
if [ $branch_name != "master" ]
then 
  echo "Check out to master branch before trying to publish. Current branch: ${branch_name}"
  exit 1
fi

git fetch --tags
if ! git diff --quiet remotes/origin/master
then
  echo "Make sure you are up to date with the remote before publishing"
  exit 1
fi

latestTag=$(git describe --tags --abbrev=0)

echo Latest tag $latestTag
if [ $latestTag != $podspecVersion ]
then
  echo "The latest published tag \"${latestTag}\" is different from the podspec version \"${podspecVersion}\".\nDid you forget to add the tag to the release or did you forget to update the podspec version?"
  exit 1
fi

echo "All checks are passed, ready to release to CocoaPods"

echo "Do you wish to publish to CocoaPods?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "Ok, running \"pod trunk push\" now."; pod trunk push; break;;
        No ) echo "Ok, skip the release for now."; exit;;
    esac
done