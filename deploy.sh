#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

SOURCE_BRANCH="source"
TARGET_BRANCH="master"

function doCompile {
  #echo ENV['GH_TOKEN']
  git pull
  #echo 'building'
  git branch
  git checkout $SOURCE_BRANCH
  bash spelling.sh
  find source -iname '*.jpg' -print0 | xargs -0 jpegoptim -m50
  find source -iname '*.png' -print0 | xargs -0 optipng -fix 2>&1 | grep -Ei 'error|Processing' 
  bundle exec middleman build | grep -E '\b(create|delete|error|update)\b'

  #echo '$ mv build ../'
  mv build ../
  #echo 'listing branches'
  git branch
  #echo 'branching'
  git pull
  git checkout -b $TARGET_BRANCH
  #echo 'branch:'
  git branch
  #echo '$ rm -rf *'
  rm -rf *
  #echo '$ mv ../build/* .'
  mv ../build/* .
  #echo '$ git add -A && git commit -am "add build"' 
  #git add -A && git commit -am "add build"
  
  #echo '$ git push origin master'
  #git push origin master

}
cp -r vendor .bundle Gemfile Gemfile.lock ../
#echo $TRAVIS_BRANCH
# Pull requests and commits to other branches shouldn't try to deploy, just build to verify
if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "$SOURCE_BRANCH" ]; then
    echo "Skipping deploy; just doing a build."
    doCompile
    exit 0
fi

# Save some useful information
REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=`git rev-parse --verify HEAD`

#pwd
#tree
# Clone the existing gh-pages for this repo into out/
# Create a new empty branch if gh-pages doesn't exist yet (should only happen on first deply)
git clone --quiet $REPO out
cd out
git checkout $TARGET_BRANCH || git checkout --orphan $TARGET_BRANCH
cd ..

# Clean out existing contents
rm -rf out/**/* || exit 0

# Run our compile script
doCompile

# Now let's go have some fun with the cloned repo
#cd out
git config user.name "Travis CI"
git config user.email "$COMMIT_AUTHOR_EMAIL"

# If there are no changes to the compiled out (e.g. this is a README update) then just bail.
if [ -z `git diff --exit-code` ]; then
    echo "No changes to the output on this push; exiting."
    exit 0
fi

# Commit the "changes", i.e. the new version.
# The delta will show diffs between new and old versions.
echo '$ git add .'
git add .
#tree
echo '$ git commit -m "Deploy to GitHub Pages: '${SHA}'"'
git commit --quiet -m "Deploy to GitHub Pages: ${SHA}"


# Get the deploy key by using Travis's stored variables to decrypt deploy_key.enc
#ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
#ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
#ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
#ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}

# Now that we're all set up, we can push.
#echo $ git push $SSH_REPO $TARGET_BRANCH
#git push $SSH_REPO $TARGET_BRANCH
#echo git push --force --quiet "https://${GITHUB_TOKEN}@$github.com/${GITHUB_REPO}.git" master:$TARGET_BRANCH
git push --force --quiet "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git" master:$TARGET_BRANCH
wget -q feedburner.google.com/fb/a/pingSubmit\?bloglink\=http%3A%2F%2Ffeeds.feedburner.com%2Fteam1432 -O /dev/null
#echo '$ tree'
#tree
echo '$ git branch'
git branch

#echo '$ git checkout source'
#git checkout source
#echo '$ git pull origin source'
#git pull origin source

#echo '$ tree'
#tree
#echo '$ git branch'
#git branch

cp -r ../vendor ../.bundle ../Gemfile ../Gemfile.lock .
