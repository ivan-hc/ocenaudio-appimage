#!/bin/sh

# CREATE A TEMPORARY FOLDER
mkdir tmp
cd tmp
# DOWNLOAD THE OFFICIAL DEB PACKAGE
wget https://www.ocenaudio.com/downloads/index.php/ocenaudio_debian9_64.deb
ar x ./*.deb
tar -xf ./*tar.xz
cd ..
# CREATE THE APPIMAGE'S DIRECTORY AND ITS STRUCTURE
mkdir ocenaudio.AppDir
mv ./tmp/opt/ocenaudio/* ./ocenaudio.AppDir
cp ./tmp/usr/share/icons/hicolor/128x128/apps/ocenaudio.png ./ocenaudio.AppDir/
cp ./tmp/usr/share/applications/ocenaudio.desktop ./ocenaudio.AppDir/
# THIS IS THE APPRUN SCRIPT NEEDED TO READ AND RUN THE CONTENT OF THE APPIMAGE
cat >> ./ocenaudio.AppDir/AppRun << 'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"
export UNION_PRELOAD="${HERE}"
export LD_PRELOAD=$(cd / && find . -name "libbz2*" 2>/dev/null | head -1 | cut -c 2-)
export QT_FONT_DPI=96
export QT_QPA_PLATFORMTHEME=$QT_QPA_PLATFORMTHEME
export PATH="${HERE}"/bin/:"${PATH}"
export LD_LIBRARY_PATH=/lib/:/lib64/:/lib/x86_64-linux-gnu/:/usr/lib/:/usr/lib/x86_64-linux-gnu/:/usr/lib64/:"${HERE}"/lib/:"${LD_LIBRARY_PATH}"
case "$1" in
	'') exec ${HERE}/bin/ocenaudio;;
	*) exec ${HERE}/bin/ocenvst "$*";;
esac
EOF
chmod a+x ./ocenaudio.AppDir/AppRun
# DOWNLOAD APPIMAGETOOL AND EXPORT THE DIRECTORY TO AN APPIMAGE
wget -q $(wget -q https://api.github.com/repos/probonopd/go-appimage/releases -O - | grep -v zsync | grep -i continuous | grep -i appimagetool | grep -i x86_64 | grep browser_download_url | cut -d '"' -f 4 | head -1) -O appimagetool
chmod a+x ./appimagetool
ARCH=x86_64 VERSION=$(./appimagetool -v | grep -o '[[:digit:]]*') ./appimagetool -s ./ocenaudio.AppDir
version=$(wget -q https://www.ocenaudio.com/fileinfo/ocenaudio_mint64.deb -O - | grep Versão | cut -c 43- | rev | cut -c 5- | rev)
mv ocenaudio-x86_64.AppImage ocenaudio-$version-x86_64.AppImage
rm -R -f ./tmp
