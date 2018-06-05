#!/usr/bin/env bash

set -e

RESET_COLOR="\\033[0m"
RED_COLOR="\\033[0;31m"
GREEN_COLOR="\\033[0;32m"
BLUE_COLOR="\\033[0;34m"

function reset_color() {
    echo -e "${RESET_COLOR}\\c"
}

function red_color() {
    echo -e "${RED_COLOR}\\c"
}

function green_color() {
    echo -e "${GREEN_COLOR}\\c"
}

function blue_color() {
    echo -e "${BLUE_COLOR}\\c"
}

function hello() {
    blue_color
    echo "                                              "
    echo "               Backup My GitHub               "
    echo "                                              "
    echo "                                              "
    echo "This script will clone all your repositories from provided username to your machine"
    echo "It will prompt you for your username account and personal access token"
    echo "To generate token, please, refer this guide - https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line"
    echo "Make sure, that your token has full access to repo scope!"
    reset_color
}

function checkForCurl() {
    if ! [ "$(command -v curl)" ]; then
        red_color
        echo "You don't have installed curl"
        exit 1
    else
        green_color
        echo "curl is present on your machine, continue..."
    fi

    reset_color
}

function checkForJQ() {
    if ! [ "$(command -v jq)" ]; then
        red_color
        echo "You don't have installed jq"
        exit 1
    else
        green_color
        echo "jq is present on your machine, continue..."
    fi

    reset_color
}

function cloneRepositories() {
    green_color
    echo
    read -r -p "What is your username on GitHub: " username
    read -r -p "What is your personal access token: " token
    echo
    blue_color

    mkdir -p my
    pushd my

    repository_count=$(curl -XGET -s https://"${username}":"${token}"@api.github.com/users/"${username}" | jq -c --raw-output ".public_repos")
    repositories=$(curl -XGET -s https://"${username}":"${token}"@api.github.com/users/"${username}"/repos?per_page="${repository_count}" | jq -c --raw-output ".[].ssh_url")

    green_color
    echo "Cloning ${repository_count} repositories"

    blue_color
    for repository in ${repositories}; do
        echo "Cloning ${repository}..."
        git clone --quiet "${repository}"
    done

    popd

    green_color
    echo "All your repositories are successfully cloned in ./my directory"
}

function cloneStars() {
    green_color
    echo
    read -r -p "What is your username on GitHub: " username
    read -r -p "What is your personal access token: " token
    echo
    blue_color

    mkdir -p stars
    pushd stars

    repository_pages=$(curl -XGET -s https://"${username}":"${token}"@api.github.com/user/starred?per_page=100 -D - -o /dev/null | sed -nEe 's/^Link.+page=([[:digit:]]+)>; rel="last"/\1/p' | tr -d '[:space:]')

    green_color
    echo "Cloning ${repository_pages} pages of 100 repositories"

    blue_color
    bad=0
    count=1
    for page in `seq 1 $repository_pages`; do
        echo "Getting page ${page}..."
        repo_pairs=$(curl -XGET -s https://"${username}":"${token}"@api.github.com/user/starred?per_page=100\&page="${page}" | jq -c --raw-output ".[]|{url:.ssh_url,name:.full_name}")
        for repo in ${repo_pairs}; do
            url=$(echo $repo | jq -c --raw-output ".url")
            name=$(echo $repo | jq -c --raw-output ".name")
            echo "$count. Cloning ${name} from ${url}..."
            mkdir -p $(dirname $name)
            git clone --quiet "${url}" "${name}" || (let bad+=1; continue)
            let count+=1
        done
    done

    popd

    green_color
    echo "${count} starred repositories are successfully cloned in ./stars directory"
    echo "${bad} repositories had errors"
}

hello
checkForCurl
checkForJQ
# Todo: use env vars for github login/token
cloneRepositories
cloneStars
