#!/bin/sh

error () {
  echo "ERROR: $@"
  echo "USAGE: $0 [ --force ] [ --verbose ] [ --dry-run ] [ config ]
"
  exit 1
}

while [ -n "$1" ]
do
  case "$1" in
    "--force")
      force="yes"
      shift
    ;;
    "--dry-run")
      dry="yes"
      shift
    ;;
    "--verbose")
      verbose="yes"
      shift
    ;;
    *)
      [ -n "$config" ] && error "to much parameters"
      config=$1
      shift
  esac
done

run_obnam () {
  [ "$verbose" = "yes" ] || [ "$dry" = "yes" ] && echo "obnam --no-default-config --config=$1 $2"
  [ "$dry" = "yes" ] || obnam --no-default-config --config="$1" "$2"
}

run_backup () {
  [ -f "$file" ] || error "$file does not exists"
  [ "$force" = "yes" ] && run_obnam $1 force-lock
  run_obnam $1 backup
  run_obnam $1 forget
}


if [ -n "$config" ]
then
  file="/etc/obnam/${config}.conf"
  run_backup "$file"
else
  for file in /etc/obnam/*.conf
  do
    run_backup "$file"
  done
fi
