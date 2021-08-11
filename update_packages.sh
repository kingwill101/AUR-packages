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
  
  JSON=$(curl -s https://api.github.com/repos/${PROJECT}/releases/latest)
  
  FILENAME=$( echo ${JSON} | jq '.assets[0].name')

  if [ "${PROJECT}" == "osxmidi/LinVst3" ]; then
      VERSION=$( echo ${FILENAME} | cut -d - -f 2)
  else
    VERSION=$( echo ${FILENAME} | cut -d - -f 3)
  fi

  DOWNLOAD_URL=$( echo ${JSON}  | jq '.assets[0].browser_download_url')

  echo "filename -> " $FILENAME
  echo "url -> " $DOWNLOAD_URL
  echo "updating to -> " $VERSION

  sed -i "/pkgver=/c pkgver=$VERSION" PKGBUILD
  sed -i "/suffix=/c suffix=\"Manjaro\"" PKGBUILD
  sed -i "/source=/c source=($DOWNLOAD_URL)" PKGBUILD

  #TODO figure how to script the release version
  #set to 1 for now
  sed -i "/pkgrel=/c pkgrel=1" PKGBUILD
  
  echo "updating md5sum"

  updpkgsums

  makepkg --printsrcinfo > .SRCINFO

  echo "verifying build"

  makepkg -C -f --noconfirm

  git add PKGBUILD .SRCINFO

  git commit -m "roll package version to $VERSION using package: ${FILENAME}"

  git push

  popd
done
