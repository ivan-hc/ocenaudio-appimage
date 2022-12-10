#!/bin/sh

mkdir tmp
cd tmp
wget https://www.ocenaudio.com/downloads/ocenaudio_mint64.deb
ar x ./*.deb
tar -xf ./*tar.xz
cd ..
mkdir ocenaudio.AppDir
mv ./tmp/opt/ocenaudio/* ./ocenaudio.AppDir
cp ./tmp/usr/share/icons/hicolor/128x128/apps/ocenaudio.png ./ocenaudio.AppDir/
cp ./tmp/usr/share/applications/ocenaudio.desktop ./ocenaudio.AppDir/
cat >> ./ocenaudio.AppDir/AppRun << 'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"
export UNION_PRELOAD="${HERE}"
export LD_PRELOAD="${HERE}/libunionpreload.so"
export PATH="${HERE}"/usr/bin/:"${HERE}"/usr/sbin/:"${HERE}"/usr/games/:"${HERE}"/bin/:"${HERE}"/sbin/:"${PATH}"
export LD_LIBRARY_PATH="${HERE}"/usr/lib/:"${HERE}"/usr/lib/i386-linux-gnu/:"${HERE}"/usr/lib/x86_64-linux-gnu/:"${HERE}"/usr/lib32/:"${HERE}"/usr/lib64/:"${HERE}"/lib/:"${HERE}"/lib/i386-linux-gnu/:"${HERE}"/lib/x86_64-linux-gnu/:"${HERE}"/lib32/:"${HERE}"/lib64/:"${LD_LIBRARY_PATH}"
export PYTHONPATH="${HERE}"/usr/share/pyshared/:"${PYTHONPATH}"
export PYTHONHOME="${HERE}"/usr/
export XDG_DATA_DIRS="${HERE}"/usr/share/:"${XDG_DATA_DIRS}"
export PERLLIB="${HERE}"/usr/share/perl5/:"${HERE}"/usr/lib/perl5/:"${PERLLIB}"
export GSETTINGS_SCHEMA_DIR="${HERE}"/usr/share/glib-2.0/schemas/:"${GSETTINGS_SCHEMA_DIR}"
export QT_PLUGIN_PATH="${HERE}"/usr/lib/qt4/plugins/:"${HERE}"/usr/lib/i386-linux-gnu/qt4/plugins/:"${HERE}"/usr/lib/x86_64-linux-gnu/qt4/plugins/:"${HERE}"/usr/lib32/qt4/plugins/:"${HERE}"/usr/lib64/qt4/plugins/:"${HERE}"/usr/lib/qt5/plugins/:"${HERE}"/usr/lib/i386-linux-gnu/qt5/plugins/:"${HERE}"/usr/lib/x86_64-linux-gnu/qt5/plugins/:"${HERE}"/usr/lib32/qt5/plugins/:"${HERE}"/usr/lib64/qt5/plugins/:"${QT_PLUGIN_PATH}"
EXEC=$(grep -e '^Exec=.*' "${HERE}"/*.desktop | head -n 1 | cut -d "=" -f 2- | sed -e 's|%.||g')
exec ${EXEC} "$@"
EOF
chmod a+x ./ocenaudio.AppDir/AppRun
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-$(uname -m).AppImage -O appimagetool
chmod a+x ./appimagetool
ARCH=x86_64 ./appimagetool -n ./ocenaudio.AppDir
version=$(wget -q https://www.ocenaudio.com/fileinfo/ocenaudio_mint32.deb -O - | grep Versão | cut -c 43- | rev | cut -c 5- | rev)
mv ocenaudio-x86_64.AppImage ocenaudio-$version-x86_64.AppImage
rm -R -f ./tmp