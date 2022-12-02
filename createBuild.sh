#!/bin/bash

buildDir="build"
launchPadDataDir="launchpad"
srcDir="src"
fileHooksPath="src/lua/CompMod_FileHooks.lua"
licenseFile="LICENSE"
readMeFile="README.md"

# Attempt to extract revision numbers from Filehooks file
current_revision="$(cat $fileHooksPath | grep -oP 'g_compModRevision = \K[0-9]+')"
current_beta_revision="$(cat $fileHooksPath | grep -oP 'g_compModBeta = \K[0-9]+')"

test -z "$current_revision" && { echo "Failed to lookup current revision"; exit 1; }
test -z "$current_beta_revision" && { echo "Failed to lookup current beta revision"; exit 1; }

revision_string="$current_revision"
test "$current_beta_revision" -eq 0 || revision_string="$revision_string beta $current_beta_revision"

# Check for outstanding commits
test -n "$(git status --porcelain)" && { echo "ERROR: You have outstanding commits, please commit before creating a build"; exit 1; }

echo "Creating build..."
echo
echo "CompMod Revision: $revision_string"

# Re-create the build dir
test -d "$buildDir" && rm -rf "$buildDir"
mkdir $buildDir

# Create LaunchPad project skeleton
if [ "$current_beta_revision" -eq 0 ]; then
    cp $launchPadDataDir/release/mod.settings $buildDir/mod.settings
    cp $launchPadDataDir/release/preview.jpg $buildDir/preview.jpg
else
    cp $launchPadDataDir/beta/mod.settings $buildDir/mod.settings
    cp $launchPadDataDir/beta/preview.jpg $buildDir/preview.jpg
fi
mkdir $buildDir/source
cp -R $srcDir $buildDir/output
cp $licenseFile $buildDir/output/LICENSE
cp $readMeFile $buildDir/output/README.md

sed -i "s/\%\%revision_string\%\%/$revision_string/g" $buildDir/mod.settings

echo "Build created"
