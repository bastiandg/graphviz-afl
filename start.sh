#!/usr/bin/env bash

user="builder"
project="graphviz"
git_repo="https://github.com/ellson/graphviz.git"
testbinary="$1"
export CC="/usr/local/bin/afl-gcc"
export CXX="/usr/local/bin/afl-g++"

if [ "$(whoami)" != "$user" ] ; then
	echo "wrong user (should be $user)" >&2
	exit 2
fi

if [ -d "/home/$user/$project" ] ; then
	cd "/home/$user/$project"
	git pull
	ret="$?"
	if [ "$ret" != "0" ]; then
		if [ "$ret" == "128" ] ; then
			cd ..
			git clone "$git_repo" "$project"
			cd "$project"
		else
			echo "invalid git repository" >&2
			exit 1
		fi
	fi
else
	cd "/home/$user/"
	git clone "$git_repo" "$project"
	cd "$project"
fi

make clean
./autogen.sh
./configure --prefix="/home/$user/$project" --enable-perl=no
make
make install

cd ~

AFL_SKIP_CPUFREQ=1 afl-fuzz -i testcases/ -o output/ "graphviz/bin/$testbinary"
