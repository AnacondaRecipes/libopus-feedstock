mkdir build
cd build
if errorlevel 1 exit /b 1

echo "PACKAGE_VERSION=%PKG_VERSION%" > %SRC_DIR%\package_version
if errorlevel 1 exit /b 1

set "DNN_FLAGS="
if "%target_platform%" == "win-arm64" (
    REM DNN-based features (DRED, Deep PLC, OSCE/BWE) are disabled on win-arm64
    REM because opus's CMake build has a known bug on ARM targets: the RTCD
    REM dispatcher (arm_dnn_map.c) gets compiled, but the actual generic-C and
    REM NEON implementation files are not reliably included in the source list,
    REM causing unresolved external symbol errors at link time
    REM (e.g. compute_activation_c, compute_conv2d_neon).
    REM See: https://github.com/xiph/opus/pull/340
    REM The core Opus codec (encoding/decoding) is unaffected by this change.
    REM This does not affect win-64, where the DNN build works correctly.
    set "DNN_FLAGS=-DOPUS_DNN=OFF -DOPUS_DEEP_PLC=OFF -DOPUS_DRED=OFF -DOPUS_OSCE=OFF"
)

cmake -G "Ninja" ^
	-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
	-DBUILD_SHARED_LIBS=ON ^
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
	-DCMAKE_BUILD_TYPE=Release ^
	%DNN_FLAGS% ^
	%CMAKE_ARGS% ^
	%SRC_DIR%

if errorlevel 1 exit /b 1

ninja install
echo === CONTENTS OF LIBRARY_PREFIX (recursive) ===
dir /s /b %LIBRARY_PREFIX%
echo === END LISTING ===
if errorlevel 1 exit /b 1