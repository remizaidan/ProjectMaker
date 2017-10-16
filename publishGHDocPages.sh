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
    echo "  -i DIR         Path where to fetch the documentation files."
    echo "                 DIR can be absolute or relative to ProjectPath."
    echo "                 Default is docs/doxygen/html"
    echo "  -o DIR         Path where to publish the documentation files."
    echo "                 DIR can be absolute or relative to ProjectPath."
    echo "                 Default is docs/gh-pages"
    echo ""
    echo "Mandatory arguments are:"
    echo "  ProjectPath    Path to the project to be documented."
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
## Parse Command line
##
OPTIND=1 

quiet=0
inputDir="docs/doxygen/html"
outputDir="docs/gh-pages"

while getopts "h?qo:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    q)  quiet=1
        ;;
    o)  outputDir=$OPTARG
	;;
    i)  inputDir=$OPTARG
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
projectName=$(basename $projectPath)

echo_verbose "Publishing GitHub documentation page for project $projectName"
echo_verbose "  Project location: $projectPath"
echo_verbose "  Documetation origin: $inputDir"
echo_verbose "  Documetation destination: $outputDir"
echo_verbose ""


##
## Make sure project path actually exist and change to that directory.
##
if [ ! -d $projectPath ] ; then
    echo "$0: Project path does not exist."
    echo "Given path is: $projectPath"
    exit 1
fi
cd $projectPath
check_error "Failed to change directory to $projectPath"

echo_verbose "Project path: OK"


##
## Check if we are in a GitHub managed project
##
origin=$(git config --get remote.origin.url)

if [ -z "$origin" ] || [[ "$origin" != *"github.com"* ]]; then
    echo "$0: $projectName is not hosted on a GitHub repository."
    echo "Please setup the GitHub repository first."
    exit 1
fi

echo_verbose "GitHub repository: OK"


##
## Check if we have setup the gh-pages correctly
##
cd $outputDir
check_error "Failed to change directory to $outputDir"
branch=$(git branch)
if [[ "$branch" != *"gh-pages" ]] ; then
    echo "$0: $outputDir is not linked to a gh-pages branch."
    exit 1
fi

echo_verbose "gh-pages branch: OK"


##
## Replace existing content be our documentation html pages.
##
echo_verbose "Replacing existing contents in the destination folder."
rm -rf *
check_error "Failed to remove existing content."
cp -r $inputDir/* .
check_error "Failed to copy files to destination."


##
## Commit changes to GitHub
##
echo_verbose "Commit changes to GitHub"
git add .
check_error "Failed: git add ."
git commit -m "Update documentation"
check_error "Failed: git commit"
git push origin gh-pages
check_error "Failed: git push"

echo_verbose "All OK"

