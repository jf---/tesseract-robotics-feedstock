@echo off

if exist src rmdir /s /q src
mkdir src
echo */ci/*> tar_excludes.txt
tar xf source.tar.gz --strip-components=1 -C src -X tar_excludes.txt

:: Fixes carried until upstream merges them; see build.sh
for %%p in ("%RECIPE_DIR%\patches\*.patch") do (
  patch -d src -p1 --binary --forward --no-backup-if-mismatch -i "%%p"
  if errorlevel 1 exit 1
)

cmake -GNinja ^
  %CMAKE_ARGS% ^
  -DBUILD_SHARED_LIBS=ON ^
  -DUSE_MSVC_RUNTIME_LIBRARY_DLL=ON ^
  -DTESSERACT_ENABLE_TESTING=OFF ^
  -DTESSERACT_ENABLE_EXAMPLES=OFF ^
  -DCMAKE_VERBOSE_MAKEFILE=ON ^
  -S src ^
  -B build_dir
if %errorlevel% neq 0 exit %errorlevel%
cmake --build build_dir --config Release -j 4
if %errorlevel% neq 0 exit %errorlevel%
cmake --build build_dir --config Release --target install
if %errorlevel% neq 0 exit %errorlevel%
