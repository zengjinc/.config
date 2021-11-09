#!/bin/bash
 
# svn提交时，忽略.svnignore文件中的列表
if ! [ -e $(which readlink) ]; then
  echo "Can't find readlink program, please make sure to have it installed"
  exit -1
fi

if [ "$1" = "commit" ] || [ "$1" = "ci" ] && [ "$2" = "-m" ]; then

  files=""

  tmpfile=.svnfiles
  tmpmodified=.modified
  tmpmodified_t=.modified_t

  # global ignore file
  ignorefile=~/.svnignore_global
  
  svn status | grep "^[M|A|D]" >$tmpmodified

  if ! [ -z "$ignorefile" ]; then
    cat $ignorefile | while read line; do
      ### improve with regex
      grep -v $line $tmpmodified >$tmpmodified_t
      #exit
      cp $tmpmodified_t $tmpfile
      cp $tmpmodified $tmpmodified_t
      cp $tmpfile $tmpmodified
    done
  fi

  rm -f $tmpfile

  #svn status | grep -v module.mk | grep -v Makefile | grep "^[M|A]" | while read line
  cat $tmpmodified | while read line; do
    file=$(echo $line | cut -f 2 -d " ")
    ### echo found modified file $file
    #files=$file" "$files

    echo $file >>$tmpfile
  done

  if [ -e "$tmpfile" ]; then
    files=$(cat $tmpfile)

    echo here are the commit files
    echo $files

    rm -f $tmpfile
    rm -f $tmpmodified
    rm -f $tmpmodified_t

    read -p "confirm?[y/n]:" confirm
    if [ "$confirm" = 'y' ]; then
      echo "checking in ..."
      svn "$@" $files
    fi

  else
    echo "Nothing to do, there are no modifications"
    rm -f $tmpmodified
    rm -f $tmpmodified_t
  fi

else
  svn "$@"
fi

