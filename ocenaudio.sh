#!/bin/sh

APP=ocenaudio

# DOWNLOAD APPIMAGETOOL
if ! test -f ./appimagetool; then
	wget -q https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
	chmod a+x ./appimagetool
fi

# CREATE A TEMPORARY FOLDER
mkdir tmp && cd tmp || exit 1

# DOWNLOAD THE OFFICIAL DEB PACKAGE
if ! test -f ./*.deb; then
	wget "https://www.ocenaudio.com/downloads/index.php/$(curl -Ls https://www.ocenaudio.com/download | tr '/"' '\n' | grep -i "$APP.*deb" | head -1)?" -O "$APP".deb
	ar x ./*.deb
	tar xf ./data.tar*
	tar xf ./control.tar*
fi
VERSION=$(cat ./control | grep -i "^version" | cut -c 10-)
cd .. || exit 1

# CREATE THE APPIMAGE'S DIRECTORY AND ITS STRUCTURE
rm -Rf ./"$APP".AppDir/*
mkdir -p ./"$APP".AppDir
mv ./tmp/opt/"$APP"/* ./"$APP".AppDir/
cp ./tmp/usr/share/icons/hicolor/128x128/apps/"$APP".png ./"$APP".AppDir/
cp ./tmp/usr/share/applications/"$APP".desktop ./"$APP".AppDir/

# THIS IS THE APPRUN SCRIPT NEEDED TO READ AND RUN THE CONTENT OF THE APPIMAGE
cat >> ./"$APP".AppDir/AppRun << 'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"
export UNION_PRELOAD="${HERE}"
export PATH="${HERE}"/bin/:"${PATH}"
export LD_LIBRARY_PATH="${HERE}"/lib/:"${LD_LIBRARY_PATH}"
case "$1" in
	'') exec ${HERE}/bin/ocenaudio;;
	*) exec ${HERE}/bin/ocenvst "$*";;
esac
EOF
chmod a+x ./"$APP".AppDir/AppRun

# DOWNLOAD APPIMAGETOOL AND EXPORT THE DIRECTORY TO AN APPIMAGE
ARCH=x86_64 ./appimagetool --comp zstd --mksquashfs-opt -Xcompression-level --mksquashfs-opt 20 ./"$APP".AppDir
mv ./*.AppImage ./"$APP"-"$VERSION"-x86_64.AppImage
rm -R -f ./tmp
