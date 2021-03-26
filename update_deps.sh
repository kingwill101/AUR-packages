get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
} 

PROJECTS=(
osxmidi/LinVst3-X
osxmidi/LinVst3
)

for PROJECT in "${PROJECTS[@]}"; do
  echo $PROJECT
  pushd $PROJECT
  
  VERSION=$(get_latest_release $PROJECT)

  echo "updating to -> " $VERSION

  sed -i "/pkgver=/c pkgver=$VERSION" PKGBUILD
  
  echo "updating md5sum"

  updpkgsums

  makepkg --printsrcinfo > .SRCINFO

  echo "building PKGBUILD"
  popd
done



