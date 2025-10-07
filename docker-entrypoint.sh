#!/bin/bash
set -e

gosu plone python /docker-initialize.py

if [ -z "$GIT_URL" ]; then
  GIT_URL="https://github.com"
fi

if [ -z "$GIT_BRANCH" ]; then
  GIT_BRANCH="master"
fi

if [ -z "$GIT_USER" ]; then
  GIT_USER="eea"
fi

LOCATION=$(pwd)
if [ ! -z "$DEVELOP" ]; then
  for dev in $DEVELOP; do
    if [ ! -d $dev ]; then
      GIT=`echo $GIT_URL/$dev | sed "s|src|$GIT_USER|g"`
      echo "Cloning from $GIT"
      gosu plone git clone -v $GIT $dev
      cd $dev
      if [ ! -z "$GIT_CHANGE_ID" ]; then
        GIT_BRANCH=PR-${GIT_CHANGE_ID}
        gosu plone git fetch origin pull/$GIT_CHANGE_ID/head:$GIT_BRANCH
      fi
      gosu plone git checkout $GIT_BRANCH
      cd $LOCATION
    fi
  done

  if [ -e "custom.cfg" ]; then
    echo -e "[versions]" >> custom.cfg
    for addon in $ADDONS; do
      addon="$(echo $addon | sed 's|\[.*\]||g')"
      echo -e "$addon =" >> custom.cfg
    done
  fi
fi

if [[ "$1" == "zptlint"* ]]; then
  echo "Running bin/zptlint src/"
  find src -regex ".*\.[c|z]*pt" -print0 | xargs -0 -r bin/zptlint
  exit
fi

if [ -e "custom.cfg" ]; then
  buildout -c custom.cfg
  chown -R plone:plone /plone
fi

if [[ "$1" == "coverage"* ]]; then
    cd src/$GIT_NAME
    ../../bin/coverage run ../../bin/xmltestreport --test-path $(pwd) -v -vv -s $GIT_NAME
    ../../bin/report xml --include=*$GIT_NAME*
    exit 0
fi

if [[ "$1" == "-"* ]]; then
  exec bin/test "$@"
fi

exec /plone-entrypoint.sh "$@"
