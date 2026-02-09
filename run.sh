export name="$1"
export dump="$2"
DUMPO=0
DUMPC=0
COMMANDS=""
WAVE=0

for VAR in "$@"
do
    case $VAR in
        "-d")
            DUMPO=1
            DUMPC=1
            ;;
        "-dc")
            DUMPC=1
            ;;
        "-do")
            DUMPO=1
            ;;
        -w)
            WAVE=1
            ;;
        +*)
            COMMANDS+=" $VAR"
            ;;
        *)
            ;;
    esac
done

if [ -e $name ]
then
    echo "Running '$name':"
else
    echo "No Project Found"
    exit 1
fi

cd $name
ls .

if [ -e build ]
then
    rm -r build
fi
mkdir "build"

if [ -e work ]
then
    rm -r work
fi

echo "------Start------"

nvc -a $name.vhd cpu_package.vhd ${name}_tb.vhd
nvc -e ${name}_tb
nvc -r ${name}_tb --wave=build/wave.fst

if [ -f build/wave.fst ]
then
    if [ $WAVE -eq 1 ]; then
        if [ -f wave_names.txt ]; then
            cp wave_names.txt build/wave_names.txt
            nohup gtkwave build/wave.fst --script=../add_waves.tcl s > build/wave.txt &
        else nohup gtkwave build/wave.fst --script=../add_waves.tcl s > build/wave.txt &
        fi
    fi
fi
