#!/bin/bash

set -eux

if [ "$(uname)" != "Darwin" ] ; then
	echo "Not macOS!"
	exit 1
fi

# ホームディレクトリにcomamndsディレクトリを作成
mkdir -p ~/commands
cd ~/commands

# sssh
if !(type "sssh" > /dev/null 2>&1); then
  curl "https://gist.githubusercontent.com/yuki777/e6feba842934e3100ecd45370969a9a9/raw/sssh?clearCache=`date +%Y%m%d%H%M%S`" -o sssh
  chmod u+x sssh
fi
