#!/bin/bash

function usage {
    echo "usage: compileProject.sh [-cdv]"
    echo "  -c      remove compiled tests"
    echo "  -d      run compiled tests"
    echo "  -v      print program output"
    echo "  -h      display help"
    exit 1
}


function clean {
	for i in $(ls | grep $TEST_OUT_PATTERN | grep -v $C_PATTERN | grep -v $IN_PATTERN | grep -v $OUT_PATTERN); do
		rm -f $i;
	done
	echo Project directory cleaned.
}


PUB_PATTERN="^public[0-9]\{1,2\}";
STU_PATTERN="^student[0-9]\{1,2\}";
TEST_PATTERN="\(\($PUB_PATTERN\)\|\($STU_PATTERN\)\)\.c";
TEST_OUT_PATTERN="\($PUB_PATTERN\)\|\($STU_PATTERN\)";
IN_PATTERN="^.*\\.input";
OUT_PATTERN="^.*\\.output";
C_PATTERN=".*\\.c";

echo $TEST_PATTERN
echo $(ls | grep $TEST_PATTERN)

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

#Start Debugging
#set -x
#echo "Running tests: $(ls | grep $TEST_PATTERN | grep -v $OUT_PATTERN)"

#Run assertion tests
for i in $(ls | grep $TEST_PATTERN | grep -v $OUT_PATTERN);
do
        echo $i;
        OUT=$(echo $i | sed s,\\.c,,);
        #echo "Now compiling $i with $(ls | grep -v $TEST_PATTERN | grep $C_PATTERN )"
        gcc $(ls | grep -v $TEST_PATTERN | grep $C_PATTERN ) $i -ansi -pedantic-errors -Wall -fstack-protector-all -Werror -Wshadow -g -o $OUT;
        if [ "$DEBUG" = true ]; then
                echo -e "-----Running $OUT-----\n";
                stdout=$($OUT);
                exc=$?;
		if [ "$VERBOSE" = true ]; then
			echo $stdout;
			echo -e "\n";
		fi
                if [ "$exc" == 0 ]; then
                        echo "Test of $OUT suceeded.";
                else
                        echo "Test of $OUT failed.";
		fi

                echo -e "\n-----DONE-----\n";
        fi
done

#stop Debugging
#set +x


#Run I/O tests

OUT=$(ls $(pwd) | grep $C_PATTERN | grep -v $TEST_PATTERN | sed s,\\.c,,);
gcc $(ls | grep -v $TEST_PATTERN | grep $C_PATTERN ) $i -ansi -pedantic-errors -Wall -fstack-protector-all -Werror -Wshadow -g -o $OUT;

for i in $(ls $(pwd) | grep $IN_PATTERN);
do
    OPF=$(echo $i | sed s,\\.input,.output,);
    if [ "$DEBUG" = true ]; then
        echo -e "-----Running with stdin=$i-----\n";
        echo "i=$i and OUT=$OUT";
        progout=$($OUT < $i);
        exc=$?;

        if [ "$VERBOSE" = "true" ]; then
            echo -e "\n-----VERBOSE OUTPUT-----\n";
            echo "$progout";
            echo -e "\n-----END OUTPUT-----\n";
        fi

        if [ $exc == 0 ]; then
            if [[ -e "$OPF" ]]; then
                if [[ -z $(echo "$progout" | diff - $OPF) ]]; then
                    echo "Test $OPF passed.";
                else
                    echo "Test $OPF failed.  Your output (left), expected output (right).\n";
                    echo $(echo "$progout" | diff - $OPF -y);
                fi
            else
                echo -e "File $OPF does not exist.  Cannot check your output, but here it is: \n"
                echo "$progout";
                echo -e "\n-----END OUTPUT-----";
            fi

        else
                echo "$OUT failed to execute.";
		fi

        echo -e "\n-----DONE-----\n";
    fi
done
