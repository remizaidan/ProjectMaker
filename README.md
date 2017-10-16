README
======

This repository contains three scripts to manage small C++ projects that are meant to work mostly standalone
with minimal external dependence.

You can read the story behind this project and find more docmentation here: <br>
<a href="https://remizaidan.github.io/ProjectMaker/">
https://remizaidan.github.io/ProjectMaker/
</a>

Below is a brief description and the usage of each script.

<br>

createProject.sh
----------------

This script creates the skeleton for an empty project with a working makefile.

```
Usage: createProject.sh [options] <ProjectPath>

Options are:
  -h             Prints this help message and exits.
  -q             Suppress info outputs.
  -f             Force: overwrite existing parent directory. 
  -t TITLE     A title for this project.
                        This is used for doxygen documentation and the README file.
  -m MESSAGE   A brief description of this project.
                        This is used for doxygen documentation and the README file.
  -n NAME      A name for the project if different from the project's parent directory.
                        This will determine the name of the library files if any is to be created.
  -r             Link to ROOT libraries

Mandatory arguments are:
  ProjectPath           Path to the project to be created.
```

<br>


createGHDocPages.sh
-------------------

This script is meant to be run on a git repository hosted on GitHub with an associated GitHub Page.
The script will remove the default content generated by GitHub and replace with our own,
for example with html files created by Doxygen.

```
Usage: createGHDocPages.sh [options] <ProjectPath>

Options are:
  -h             Prints this help message and exits.
  -q             Suppress info outputs.
  -o DIR       Path where to store the documentation files.
                        DIR can be absolute or relative to ProjectPath.
                        Default is docs/gh-pages

Mandatory arguments are:
  ProjectPath    Path to the project to be documented.
```

<br>


publishGHDocPages.sh
--------------------

This script is meant to be run every time the local documentation that was setup using createGHDocPages.sh
is updated and needs to be pushed to GitHub.

```
Usage: publishGHDocPages.sh [options] <ProjectPath>

Options are:
  -h             Prints this help message and exits.
  -q             Suppress info outputs.
  -i DIR       Path where to fetch the documentation files.
                        DIR can be absolute or relative to ProjectPath.
                        Default is docs/doxygen/html
  -o DIR       Path where to publish the documentation files.
                        DIR can be absolute or relative to ProjectPath.
                        Default is docs/gh-pages

Mandatory arguments are:
  ProjectPath    Path to the project to be documented.
```

<br>

