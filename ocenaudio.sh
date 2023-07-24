#!/bin/sh

APP=ocenaudio

mkdir tmp;
cd tmp;

# DOWNLOADING THE DEPENDENCIES
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-$(uname -m).AppImage -O appimagetool
wget https://raw.githubusercontent.com/ivan-hc/AM-application-manager/main/tools/pkg2appimage # 64 BIT ONLY (comment to disable)
# wget https://github.com/ivan-hc/pkg2appimage-32bit/releases/download/continuous/pkg2appimage-i386.AppImage -O pkg2appimage # 32 BIT ONLY (uncomment to enable)
chmod a+x ./appimagetool ./pkg2appimage

# CREATING THE APPIMAGE: APPDIR FROM A RECIPE...
PREVIOUSLTS=$(wget -q https://releases.ubuntu.com/ -O - | grep class | grep LTS | grep -m2 href | tail -n1 | sed -n 's/.*href="\([^"]*\).*/\1/p' | rev| cut -c 2- | rev)
echo "app: ocenaudio
union: true

ingredients:
  dist: $PREVIOUSLTS
  sources: 
    - deb http://us.archive.ubuntu.com/ubuntu/ $PREVIOUSLTS main universe
  script:
    - wget -q 'https://www.ocenaudio.com/download' -O - | grep Mint -C 2 | grep '<p>Vers' | head -n 1 | cut -d ' ' -f 2 | cut -d '<' -f 1 > VERSION
    - wget -c 'http://www.ocenaudio.com/downloads/ocenaudio_mint64.deb'

script:
  - cp -Rf opt/ocenaudio/* usr/
  - rm -rf opt/" >> recipe.yml;

./pkg2appimage ./recipe.yml;

# ...DOWNLOADING LIBUNIONPRELOAD...
#wget https://github.com/project-portable/libunionpreload/releases/download/amd64/libunionpreload.so
#chmod a+x libunionpreload.so
#mv ./libunionpreload.so ./$APP/$APP.AppDir/

# ...REPLACING THE EXISTING APPRUN WITH A CUSTOM ONE...
rm -R -f ./$APP/$APP.AppDir/AppRun
cat >> ./$APP/$APP.AppDir/AppRun << 'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"
export UNION_PRELOAD="${HERE}"
export QT_FONT_DPI=96
export QT_QPA_PLATFORMTHEME=$QT_QPA_PLATFORMTHEME
export PATH="${HERE}"/usr/bin/:"${HERE}"/usr/sbin/:"${HERE}"/usr/games/:"${HERE}"/bin/:"${HERE}"/sbin/:"${PATH}"
export LD_LIBRARY_PATH="${HERE}"/usr/lib/i386-linux-gnu/:"${HERE}"/usr/lib/x86_64-linux-gnu/:"${HERE}"/lib/:"${HERE}"/lib/i386-linux-gnu/:"${HERE}"/lib/x86_64-linux-gnu/:"${LD_LIBRARY_PATH}"
export XDG_DATA_DIRS="${HERE}"/usr/share/:"${XDG_DATA_DIRS}"
case "$1" in
	'') exec ${HERE}/usr/bin/ocenaudio;;
	*) exec ${HERE}/usr/bin/ocenvst "$*";;
esac
EOF
chmod a+x ./$APP/$APP.AppDir/AppRun

# IMPORT THE LAUNCHER AND THE ICON TO THE APPDIR IF THEY NOT EXIST
if test -f ./$APP/$APP.AppDir/*.desktop; then
	echo "The desktop file exists"
else
	echo "Trying to get the .desktop file"
	cp ./$APP/$APP.AppDir/usr/share/applications/*$(ls . | grep -i $APP | cut -c -4)*desktop ./$APP/$APP.AppDir/ 2>/dev/null
fi

ICONNAME=$(cat ./$APP/$APP.AppDir/*desktop | grep "Icon=" | head -1 | cut -c 6-)
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/22x22/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/24x24/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/32x32/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/48x48/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/64x64/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/128x128/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/256x256/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/512x512/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/scalable/apps/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null
cp ./$APP/$APP.AppDir/usr/share/applications/*$ICONNAME* ./$APP/$APP.AppDir/ 2>/dev/null

# ...EXPORT THE APPDIR TO AN APPIMAGE!
ARCH=x86_64 ./appimagetool -n ./$APP/$APP.AppDir
version=$(wget -q https://www.ocenaudio.com/fileinfo/ocenaudio_mint64.deb -O - | grep Versão | cut -c 43- | rev | cut -c 5- | rev)
cd ..
mv tmp/*.AppImage Ocenaudio-$version-x86_64.AppImage
rm -R -f ./tmp
