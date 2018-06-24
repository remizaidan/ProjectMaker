#!/bin/bash

##
## Function: shows the help message
##
function show_help() {
    echo "Usage: $0 [options] <ClassName>"
    echo ""
    echo "Options are:"
    echo "  -h             Prints this help message and exits."
    echo "  -q             Suppress info outputs."
    echo "  -f             Force: overwrite existing files." 
    echo "  -m MESSAGE     A brief description of this class."
    echo "                 This is used for doxygen documentation."
    echo "  -p PROJECT     A path to the parent project. Default is '.'"
    echo "  -n NAMESPACE   Namespace for this class. Nested namespaces can be seperated by ::"
    echo "  -a AUTHOR      Author information. Example: 'First Last <example@email.com>'"
    echo "                 This is used for doxygen documentation."
    echo ""
    echo "Mandatory arguments are:"
    echo "  ClassName      Name of the class to be created."
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
classBrief=""
projectPath="."
namespace=""
authorInfo=""
version="0.0"

while getopts "h?qfm:p:n:a:v:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    q)  quiet=1
        ;;
    f)  force=1
	;;
    m)  classBrief=$OPTARG
	;;
    p)  projectPath=$OPTARG
	;;
    n)  namespace=$OPTARG
	;;
    a)  authorInfo=$OPTARG
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
className=$1

##
## Some derived settings
##
headerFile="${projectPath}/include/${className}.h"
sourceFile="${projectPath}/src/${className}.cxx"

if [ -z "$classBrief" ] ; then
    classBrief="Class $className"
fi

##
## Check if files already exists
##
if [ -f "$headerFile" ] || [ -f "$sourceFile" ] ; then
    if [ $force -eq 1 ] ; then
	rm -rf $headerFile $sourceFile
	check_error "Failed to remove existing existing files"
    else
	echo "$0: class files already exists:"
	echo "Given class name is: $className"
	echo "Given project path is: $projectPath"
	exit 1
    fi
fi

##
## Print what is about to be created
##
echo_verbose "Creating class: "
echo_verbose "   Name:        $className"
echo_verbose "   Namespace:   $namespace"
echo_verbose "   Project:     $projectPath"
echo_verbose "   Description: $classBrief"
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
echo " *"                                      >> $headerFile
echo " * @file    $(basename $headerFile)"     >> $headerFile
if [ ! -z "$authorInfo" ] ; then
echo " * @author  $authorInfo"                 >> $headerFile
fi
echo " * @date    $(date +%d/%m/%Y)"           >> $headerFile
echo " * @version $version"                    >> $headerFile
echo " *"                                      >> $headerFile 
echo " */"                                     >> $headerFile
echo ""                                        >> $headerFile 
echo "#ifndef ${className}_H"                  >> $headerFile  
echo "#define ${className}_H"                  >> $headerFile 
echo ""                                        >> $headerFile 
echo ""                                        >> $headerFile 
tab=""
for ((i=0; i<${#namespaces[@]}; ++i)); do
echo "${tab}namespace ${namespaces[$i]} { "    >> $headerFile
echo ""                                        >> $headerFile 
tab=$tab"  "
done
echo "${tab}/**"                               >> $headerFile
echo "${tab} * @brief $classBrief"             >> $headerFile
echo "${tab} *"                                >> $headerFile 
echo "${tab} */"                               >> $headerFile 
echo "${tab}class $className { "               >> $headerFile
echo ""                                        >> $headerFile  
echo "${tab}public: "                          >> $headerFile 
tab=$tab"  "
echo ""                                        >> $headerFile
echo "${tab}$className();"                     >> $headerFile
echo "${tab}~$className();"                    >> $headerFile
echo ""                                        >> $headerFile 
tab=${tab::-2}  
echo "${tab}}; "                               >> $headerFile
for ((i=0; i<${#namespaces[@]}; ++i)); do 
tab=${tab::-2}  
echo "${tab}} "                                >> $headerFile
done 
echo ""                                        >> $headerFile 
echo ""                                        >> $headerFile 
echo "#endif // ${className}_H"                >> $headerFile 

##
## Create Source file
##
touch $sourceFile
echo "/**"                                     >> $sourceFile 
echo " *"                                      >> $sourceFile
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
echo "${tab}${className}::~${className}()"     >> $sourceFile
echo "${tab}{"                                 >> $sourceFile 
echo ""                                        >> $sourceFile  
echo "${tab}}"                                 >> $sourceFile 
echo ""                                        >> $sourceFile 
echo ""                                        >> $sourceFile
for ((i=0; i<${#namespaces[@]}; ++i)); do 
tab=${tab::-2}  
echo "${tab}} "                                >> $sourceFile
done 
echo ""                                        >> $sourceFile 
echo ""                                        >> $sourceFile 

echo_verbose "All OK"

