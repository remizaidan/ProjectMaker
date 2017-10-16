#!/bin/bash

##
## Function: shows the help message
##
function show_help() {
    echo "Usage: $0 [options] <ProjectPath>"
    echo ""
    echo "Options are:"
    echo "  -h             Prints this help message and exits."
    echo "  -q             Suppress info outputs."
    echo "  -f             Force: overwrite existing parent directory." 
    echo "  -t TITLE       A title for this project."
    echo "                 This is used for doxygen documentation and the README file."
    echo "  -m MESSAGE     A brief description of this project."
    echo "                 This is used for doxygen documentation and the README file."
    echo "  -n NAME        A name for the project if different from the project's parent directory."
    echo "                 This will determine the name of the library files if any is to be created."
    echo "  -r             Link to ROOT libraries"
    echo ""
    echo "Mandatory arguments are:"
    echo "  ProjectPath    Path to the project to be created."
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
## Created a directory and checks for errors
##
function create_dir() {

    echo_verbose "Creating directory $1"
    mkdir -p $1
    check_error "Failed to create directory $1"
}

##
## Prints a string of the same number of caracters of an input string
##
function underline() {
    
    printf '%*s' ${#2} | tr ' ' "$1"
}

##
## Parse Command line
##
OPTIND=1

quiet=0
force=0
projectName=""
projectTitle=""
projectBrief=""
useROOT="NO"

while getopts "h?qfm:n:r" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    q)  quiet=1
        ;;
    f)  force=1
	;;
    m)  projectBrief=$OPTARG
	;;
    n)  projectName=$OPTARG
	;;
    r)  useROOT="YES"
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
projectPath=$1

##
## Check if project already exists
##
if [ -d "$projectPath" ] ; then
    if [ $force -eq 1 ] ; then
	rm -rf $projectPath
	check_error "Failed to remove existing project parent directory"
    else
	echo "$0: Path to project already exists:"
	echo "Given path is: $projectPath"
	exit 1
    fi
fi

##
## Project's name, title and brief description
##
if [ -z "$projectName" ] ; then
    projectName=$(basename $projectPath)
fi
if [ -z "$projectTitle" ] ; then
    projectTitle="Project $projectName"
fi
if [ -z "$projectBrief" ] ; then
    projectBrief="$projectTitle"
fi

##
## Print what is about to be created
##
echo_verbose "Creating project: "
echo_verbose "   Name:        $projectName"
echo_verbose "   Location:    $projectPath"
echo_verbose "   Description: $projectBrief"
echo_verbose "   Using ROOT:  $useROOT"
echo_verbose ""


##
## Create parent directory
##
echo_verbose "Creating project parent directory:"
create_dir $projectPath

echo_verbose ""

##
## Create project sctructure
##
echo_verbose "Creating project sctructure:"
create_dir $projectPath/src
create_dir $projectPath/include
create_dir $projectPath/utils
create_dir $projectPath/docs
create_dir $projectPath/docs/figures

echo_verbose ""

##
## Create a README and a doxygen main page files
##
echo_verbose "Create README.md file"
titleLine=$(underline "=" "$projectTitle:")
cat > $projectPath/REAMDE.md <<EOF
$projectTitle:
$titleLine

$projectBrief
EOF
check_error "Failed to create a README file"
echo_verbose "Create docs/mainpage.md file"
cat > $projectPath/docs/mainpage.md <<EOF
$projectTitle: {#mainpage}
$titleLine

$projectBrief 
EOF
check_error "Failed to create doxygen main page"

echo_verbose ""

##
## Create the makefile
##
echo_verbose "Create makefile"

cp template.make $projectPath/makefile
check_error "Failed to create the makefile."

sed -i "s|@PROJECT_NAME@|$projectName|g" $projectPath/makefile
sed -i "s|@PROJECT_BRIEF@|$projectBrief|g" $projectPath/makefile

echo_verbose ""

##
## Update CXXFLAGS and LDFLAGS if linking to ROOT is requested
##
if [ "$useROOT" == "YES" ] ; then
    echo_verbose "Updating makefile to link to ROOT"
    CXXFLAGS='$(shell root-config --cflags)'
    LDFLAGS='$(shell root-config --ldflags --libs)'
    sed -i "s|EXT_LDFLAGS = |EXT_LDFLAGS = $LDFLAGS|g" $projectPath/makefile
    sed -i "s|EXT_CXXFLAGS = |EXT_CXXFLAGS = $CXXFLAGS|g" $projectPath/makefile
    echo_verbose ""
fi

echo_verbose "All OK"

