#!/bin/bash
set -e


#gosu plone python /app/docker-initialize.py



if [ -z "$GIT_URL" ]; then
  GIT_URL="https://github.com"
fi

if [ -z "$GIT_BRANCH" ]; then
  GIT_BRANCH="master"
fi

if [ -z "$GIT_USER" ]; then
  GIT_USER="eea"
fi

cd /app/


LOCATION=$(pwd)
if [ ! -z "$DEVELOP" ]; then
  for dev in $DEVELOP; do
    dev=$(echo "$dev" | sed 's#/app/##')	  
    if [ ! -d $dev ]; then
      GIT=`echo $GIT_URL/$dev | sed "s|src|$GIT_USER|g"`
      echo $dev
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

fi

COVERAGE_DIR="/app/coverage"

if [[ "$@" == "start" ]] || [ $# -eq 0 ]; then
  if [ -n "$DEVELOP" ]; then
    mkdir -p "$COVERAGE_DIR"

    for dev in $DEVELOP; do
      if [ -d $dev ]; then
        dev=$(echo "$dev" | sed 's#/app/##')

        /app/plone-entrypoint.sh bin/coverage run \
          --source="/app/$dev" \
          --parallel-mode \
          -m zope.testrunner \
          --auto-color \
          --auto-progress \
          --test-path "/app/$dev"
      fi
    done
  fi
  /app/plone-entrypoint.sh bin/coverage combine || exit 1
  /app/plone-entrypoint.sh bin/coverage xml -o "$COVERAGE_DIR/coverage.xml" || exit 1
else
  exec /app/plone-entrypoint.sh "$@"
fi
