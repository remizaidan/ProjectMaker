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
    echo "  -o DIR         Path where to store the documentation files."
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

echo_verbose "Creating GitHub documentation page for project $projectName"
echo_verbose "  Project Location: $projectPath"
echo_verbose "  Documetation Directory: $outputDir"
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
## Check if a gh-pages branch exists 
##
branchExists=$(git ls-remote --heads $origin gh-pages | wc -l)
if [ $branchExists -eq 0 ] ; then
    echo "A GitHub Page is not setup for this repository."
    echo "Please setup a GitHub Page first."
    exit 1
fi

echo_verbose "GitHub Page: OK"


##
## Create a directory where to store the documentation html files
## Check first that it does not exist
##
if [ -d $outputDir ] ; then
    echo "The output directory already exists."
    echo "Please specify a different directory or delete the existing one."
    exit 1
fi
echo_verbose "Create output directory"
mkdir -p $outputDir
check_error "Failed to create output directory"
cd $outputDir
check_error "Failed to change to output directory"



##
## Link this directory to the gh-pages branch of our repository
##
echo_verbose "Link output directory to gh-pages branch"
git clone $origin .
check_error "Failed to clone remote repository"
git checkout origin/gh-pages -b gh-pages
check_error "Failed to checkout gh-pages branch"
git branch -d master
check_error "Failed to remove master branch"



##
## Remove the default contents and replace our own.
## For now create a dummy README file to be able to commit our changes.
## The script publishGHDocPages.sh should be used to push the actual files.
##
echo_verbose "Remove default content and replace by our own."
rm -rf *
check_error "Failed to remove default contents."
echo "Creating documentation" > README.md
git add .
check_error "Failed: git add ."
git commit -m "Create documentation"
check_error "Failed: git commit"
git push origin gh-pages
check_error "Failed: git push"


echo_verbose "All OK"
