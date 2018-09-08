#!/bin/bash

function usage {
    echo "usage: compileProject.sh [-dv]"
    echo "  -c      remove compiled tests"
    echo "  -d      run compiled tests"
    echo "  -v      print program output"
    echo "  -h      display help"
    exit 1
}


function clean {
	for i in $(ls | grep $PUB_PATTERN | grep -v $TEST_PATTERN); do
		rm -f $i;
	done
	echo Project directory cleaned.	
}


PUB_PATTERN="^public[1-9]\{1,2\}";
TEST_PATTERN="$PUB_PATTERN\\.c";
C_PATTERN=".*\\.c";

for arg in "$@";
do
        case $arg in
		\-c)
			echo Cleaning project directory.
			clean;
			exit 0;
		;;
                \-d)
                        echo DEBUG ON;
                        DEBUG=true;
                ;;
                \-v)
                        echo VERBOSE;
                        VERBOSE=true;
                ;;
                *)
                        usage;
        esac
done

for i in $(ls $(pwd) | grep $TEST_PATTERN | grep ".*\\.c");
do
        OUT=$(echo $i | sed s,\\.c,,);
        gcc $(ls | grep -v $TEST_PATTERN | grep $C_PATTERN ) $i -ansi -pedantic-errors -Wall -fstack-protector-all -Werror -Wshadow  -o $OUT;
        if [ "$DEBUG" == true ]; then
                echo -e "-----Running $OUT-----\n";
                stdout=$($OUT);
                exc=$?;
		if [ $VERBOSE == true ]; then
			echo $stdout;
			echo -e "\n";
		fi
                if [ $exc == 0 ]; then
                        echo "Test of $OUT suceeded.";
                else
                        echo "Test of $OUT failed.";
		fi

 
                echo -e "\n-----DONE-----\n";
        fi
done
