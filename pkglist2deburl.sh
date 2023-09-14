#!/usr/bin/bash

# This script reads a list of packages from a text file (list.txt) and outputs a
# list of URLs to the corresponding Debian packages. The URLs are written to
# list-deb.txt

# The script is intended to be used to download Debian packages from a local
# mirror. The mirror is specified in the variable MIRROR. The script can be
# modified to use a different mirror. The default mirror is
# http://ftp.fr.debian.org/debian/. The mirror can be given using the option -m.
# This argument is optional.

# The mandatory argument is the name of the file containing the list of packages
# to download. The file must contain one package name per line. 

# Examples: 
# get https://github.com/mathworks-ref-arch/container-images/blob/main/matlab-deps/r2023b/ubuntu22.04/base-dependencies.txt
# today (sept. 2023) on Ubuntu 20.04, use : ./pkglist2deburl.sh -m "fr.archive.ubuntu.com/ubuntu/" base-dependencies.txt
# today (sept. 2023) on Debian 12, use : ./pkglist2deburl.sh base-dependencies.txt

# Process command line arguments
while getopts ":m:" opt; do
  case $opt in
    m)
      MIRROR=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# The mirror is optional. If it is not specified, use the default mirror
if [ -z "$MIRROR" ]; then
  MIRROR="http://ftp.fr.debian.org/debian/"
fi

# Remove the options from the command line arguments
shift $((OPTIND-1))

# The first argument is the name of the file containing the list of packages to
# download
LISTFILE=$1

# get the name of the file without the extension
LIST=${LISTFILE%.*}

# Read the list of packages from the file
PACKAGES=$(cat $LISTFILE)

echo '' > $LIST-deb.txt

# For each package, execute the command apt-cache show <package> | grep Filename (Keep only the first line) to get the base URL of the package
for PACKAGE in $PACKAGES; do
  URL=$(apt-cache show $PACKAGE | grep Filename | head -n 1 | cut -d " " -f 2)
  echo $MIRROR$URL >> $LIST-deb.txt
done
