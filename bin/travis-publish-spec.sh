#!/bin/bash

set | grep TRAVIS

if [ "$TRAVIS_REPO_SLUG" == "$GIT_PUB_REPO" ]; then
    echo -e "Setting up for publication...\n"

    mkdir $HOME/pubroot
    cp -R build/xproc30 $HOME/pubroot/xproc30
    cp -R build/steps30 $HOME/pubroot/steps30

    cd $HOME
    git config --global user.email ${GIT_EMAIL}
    git config --global user.name ${GIT_NAME}
    git clone --quiet --branch=gh-pages https://${GH_TOKEN}@github.com/${GIT_PUB_REPO} gh-pages > /dev/null

    if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
        echo -e "Publishing specification...\n"

        TIP=${TRAVIS_TAG:="head"}

        cd gh-pages
        git rm -rf ./${TRAVIS_BRANCH}/${TIP}/xproc30
        git rm -rf ./${TRAVIS_BRANCH}/${TIP}/steps30
        mkdir -p ./${TRAVIS_BRANCH}/${TIP}/xproc30
        mkdir -p ./${TRAVIS_BRANCH}/${TIP}/steps30
        cp -Rf $HOME/pubroot/xproc30/* ./${TRAVIS_BRANCH}/${TIP}/xproc30
        cp -Rf $HOME/pubroot/steps30/* ./${TRAVIS_BRANCH}/${TIP}/steps30

        if [ "$GITHUB_CNAME" != "" ]; then
            echo $GITHUB_CNAME > CNAME
        fi

        git add -f .
        git commit -m "Successful travis build $TRAVIS_BUILD_NUMBER"
        git push -fq origin gh-pages > /dev/null

        echo -e "Published specification to gh-pages.\n"
    else
        echo -e "Publication cannot be performed on pull requests.\n"
    fi
fi
