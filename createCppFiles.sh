#!/bin/bash

##
## Function: shows the help message
##
function show_help() {
    echo "Usage: $0 [options] <FileName>"
    echo ""
    echo "Options are:"
    echo "  -h             Prints this help message and exits."
    echo "  -q             Suppress info outputs."
    echo "  -f             Force: overwrite existing files." 
    echo "  -m MESSAGE     A brief description of this file."
    echo "                 This is used for doxygen documentation."
    echo "  -p PROJECT     A path to the parent project. Default is '.'"
    echo "  -n NAMESPACE   Namespace for this file. Nested namespaces can be seperated by ::"
    echo "  -a AUTHOR      Author information. Example: 'First Last <example@email.com>'"
    echo "                 This is used for doxygen documentation."
    echo "  -t TYPE        Type of the file to be created."
    echo "                 Options are (Default = class):"
    echo "                   - class : C++ source and header class with a basic class definition."
    echo "                   - cpp : C++ source file with associated header."
    echo "                   - hpp : C++ header file without associated source file."
    echo "  -v VERSION     Version string."
    echo ""
    echo "Mandatory arguments are:"
    echo "  FileName      Name of the file to be created without file name extension."
    echo ""
}

##
## Function: handles verbose outputs
##
function echo_verbose() {
    if [ $quiet -eq 1 ] ; then
	return
    fi

    echo "$@"
}

##
## Function: handles fatal errors
##
function check_error() {

    if [ $? -eq 0 ] ; then
	return
    fi

    echo $1
    exit 1
}

##
## Split string into array
##
function parse_namespaces() {
    s="$@"
    OIFS=$IFS
    IFS="::"
    array=($s)
    IFS=
    parsed_namespaces=(${array[@]})
    IFS=$OIFS
}

##
## Parse Command line
##
OPTIND=1

quiet=0
force=0
fileBrief=""
projectPath="."
namespace=""
authorInfo=""
type="class"
version="0.0"

while getopts "h?qfm:p:n:b:a:t:v:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    q)  quiet=1
        ;;
    f)  force=1
	;;
    m)  fileBrief=$OPTARG
	;;
    p)  projectPath=$OPTARG
	;;
    n)  namespace=$OPTARG
	;;
    a)  authorInfo=$OPTARG
	;;
    t)  type=$OPTARG
	;;
    v)  version=$OPTARG
	;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

##
## There is one mandatory argument: Project location
##
if [ $# -lt 1 ] ; then
    echo "$0: Not enough arguments"
    echo ""
    show_help
    exit 1
fi
fileName=$1

##
## Some derived settings
##
headerFile="${projectPath}/include/${fileName}.h"
sourceFile="${projectPath}/src/${fileName}.cxx"
if [ "$type" = "class" ] ; then
    className=$(basename ${fileName})
fi

if [ -z "$fileBrief" ] ; then
    fileBrief="File $fileName"
fi

##
## Check if files already exists
##
if [ -f "$headerFile" ] || [ -f "$sourceFile" ] ; then
    if [ $force -eq 1 ] ; then
	rm -rf $headerFile $sourceFile
	check_error "Failed to remove existing existing files"
    else
	echo "$0: files already exists:"
	echo "Given file name is: $fileName"
	echo "Given project path is: $projectPath"
	exit 1
    fi
fi

##
## Print what is about to be created
##
echo_verbose "Creating files: "
echo_verbose "   Name:        $fileName"
echo_verbose "   Namespace:   $namespace"
if [ ! -z "$className" ] ; then
echo_verbose "   Class:       $className"
fi
echo_verbose "   Project:     $projectPath"
echo_verbose "   Description: $fileBrief"
echo_verbose "   Files:       $headerFile $sourceFile"
echo_verbose ""

##
## Parse namespace
##
parse_namespaces "$namespace"
namespaces=(${parsed_namespaces[@]})
echo_verbose "Parsed namespaces: "
for ((i=0; i<${#namespaces[@]}; ++i)); do
    echo_verbose "   ${namespaces[$i]}";
done

##
## Create Header file
##
touch $headerFile
echo "/**"                                     >> $headerFile 
echo " * @file    $(basename $headerFile)"     >> $headerFile
if [ ! -z "$authorInfo" ] ; then
echo " * @author  $authorInfo"                 >> $headerFile
fi
echo " * @date    $(date +%d/%m/%Y)"           >> $headerFile
echo " * @version $version"                    >> $headerFile
echo " *"                                      >> $headerFile 
echo " */"                                     >> $headerFile
echo ""                                        >> $headerFile 
echo "#ifndef ${fileName}_H"                  >> $headerFile  
echo "#define ${fileName}_H"                  >> $headerFile 
echo ""                                        >> $headerFile 
echo ""                                        >> $headerFile 
tab=""
for ((i=0; i<${#namespaces[@]}; ++i)); do
echo "${tab}namespace ${namespaces[$i]} { "    >> $headerFile
echo ""                                        >> $headerFile 
tab=$tab"  "
done
if [ "$type" = "class" ] ; then
echo "${tab}/**"                               >> $headerFile
echo "${tab} * @brief $fileBrief"             >> $headerFile
echo "${tab} *"                                >> $headerFile 
echo "${tab} */"                               >> $headerFile 
echo "${tab}class $className "                 >> $headerFile
echo "${tab}{ "                                >> $headerFile
echo ""                                        >> $headerFile  
echo "${tab}public: "                          >> $headerFile 
tab=$tab"  "
echo ""                                        >> $headerFile
echo "${tab}$className();"                     >> $headerFile
echo "${tab}~$className();"                    >> $headerFile
echo ""                                        >> $headerFile 
tab=${tab::-2}  
echo "${tab}}; "                               >> $headerFile
fi
for ((i=0; i<${#namespaces[@]}; ++i)); do 
tab=${tab::-2}  
echo "${tab}} "                                >> $headerFile
done 
echo ""                                        >> $headerFile 
echo ""                                        >> $headerFile 
echo "#endif // ${fileName}_H"                >> $headerFile 

##
## Create Source file
##
if [ "$type" != "hpp" ] ; then
touch $sourceFile
echo "/**"                                     >> $sourceFile 
echo " * @file    $(basename $sourceFile)"     >> $sourceFile
if [ ! -z "$authorInfo" ] ; then
echo " * @author  $authorInfo"                 >> $sourceFile
fi
echo " * @date    $(date +%d/%m/%Y)"           >> $sourceFile
echo " * @version $version"                    >> $sourceFile
echo " *"                                      >> $sourceFile 
echo " */"                                     >> $sourceFile
echo ""                                        >> $sourceFile 
echo "#include \"$(basename ${headerFile})\""  >> $sourceFile
echo ""                                        >> $sourceFile 
echo ""                                        >> $sourceFile 
tab=""
for ((i=0; i<${#namespaces[@]}; ++i)); do
echo "${tab}namespace ${namespaces[$i]} { "    >> $sourceFile
echo ""                                        >> $sourceFile 
tab=$tab"  "
done
if [ "$type" = "class" ] ; then
echo "${tab}/**"                               >> $sourceFile
echo "${tab} * @brief Constructor"             >> $sourceFile
echo "${tab} *"                                >> $sourceFile 
echo "${tab} */"                               >> $sourceFile 
echo "${tab}${className}::${className}()"      >> $sourceFile
echo "${tab}{"                                 >> $sourceFile 
echo ""                                        >> $sourceFile  
echo "${tab}}"                                 >> $sourceFile 
echo ""                                        >> $sourceFile 
echo ""                                        >> $sourceFile
echo "${tab}/**"                               >> $sourceFile
echo "${tab} * @brief Destructor"              >> $sourceFile
echo "${tab} *"                                >> $sourceFile 
echo "${tab} */"                               >> $sourceFile  
echo "${tab}${className}::~${className}()"     >> $sourceFile
echo "${tab}{"                                 >> $sourceFile 
echo ""                                        >> $sourceFile  
echo "${tab}}"                                 >> $sourceFile 
echo ""                                        >> $sourceFile 
echo ""                                        >> $sourceFile
fi
for ((i=0; i<${#namespaces[@]}; ++i)); do 
tab=${tab::-2}  
echo "${tab}} "                                >> $sourceFile
done 
echo ""                                        >> $sourceFile 
echo ""                                        >> $sourceFile 
fi

echo_verbose "All OK"

