@echo off

setlocal EnableDelayedExpansion

rem build the .lib files already exist

if /I "%VSCMD_ARG_TGT_ARCH%" == "x64" (
	set "vendor_arch=."
) else if /I "%VSCMD_ARG_TGT_ARCH%" == "arm64" (
	set "vendor_arch=arm64"
) else (
	echo ERROR: run this from an MSVC x64 or arm64 native tools command prompt.
	popd
	exit /b 1
)

if not exist "vendor\stb\lib\%vendor_arch%\*.lib" (
	pushd vendor\stb\src
		call build.bat
	popd
)

if not exist "vendor\miniaudio\lib\%vendor_arch%\*.lib" (
	pushd vendor\miniaudio\src
		call build.bat
	popd
)


if not exist "vendor\cgltf\lib\%vendor_arch%\*.lib" (
	pushd vendor\cgltf\src
		call build.bat
	popd
)
