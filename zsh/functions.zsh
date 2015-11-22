# ====================
# Semantic version bumping like ng
# ====================
function bump() {
  if [ -z "$1" ]
    then
      echo "No argument supplied"
    else
      npm version $1 -m 'chore(package): bumping version to %s'
      changelog
  fi
}

# ====================
# Changelog
# ====================
function changelog() {
  conventional-changelog -p angular -i CHANGELOG.md -o CHANGELOG.md
  git c -am 'chore(CHANGELOG): update CHANGELOG.md'
}

# ====================
# Extract file with the specific program
# ====================
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)  tar -jxvf "$1"                        ;;
      *.tar.gz)   tar -zxvf "$1"                        ;;
      *.bz2)      bunzip2 "$1"                          ;;
      *.dmg)      hdiutil mount "$1"                    ;;
      *.gz)       gunzip "$1"                           ;;
      *.tar)      tar -xvf "$1"                         ;;
      *.tbz2)     tar -jxvf "$1"                        ;;
      *.tgz)      tar -zxvf "$1"                        ;;
      *.zip)      unzip "$1"                            ;;
      *.ZIP)      unzip "$1"                            ;;
      *.pax)      cat "$1" | pax -r                     ;;
      *.pax.Z)    uncompress "$1" --stdout | pax -r     ;;
      *.Z)        uncompress "$1"                       ;;
      *) echo "'$1' cannot be extracted/mounted via extract()" ;;
    esac
  else
     echo "'$1' is not a valid file to extract"
  fi
}

