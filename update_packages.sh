get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
} 

PROJECTS=(
osxmidi/LinVst3-X
osxmidi/LinVst3
)


git submodule update 
git submodule foreach git checkout master 
git submodule foreach git pull origin master

for PROJECT in "${PROJECTS[@]}"; do
  echo $PROJECT
  pushd $PROJECT
  
  VERSION=$(get_latest_release $PROJECT)

  echo "updating to -> " $VERSION

  sed -i "/pkgver=/c pkgver=$VERSION" PKGBUILD
  sed -i "/suffix=/c suffix=\"Manjaro\"" PKGBUILD

  #TODO figure how to script the release version
  #set to 1 for now
  sed -i "/pkgrel=/c pkgrel=1" PKGBUILD
  
  echo "updating md5sum"

  updpkgsums

  makepkg --printsrcinfo > .SRCINFO

  echo "verifying build"

  makepkg -C -f --noconfirm

  git add PKGBUILD .SRCINFO

  git commit -m "roll package version to $VERSION"

  git push

  popd
done



