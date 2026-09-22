@echo off
setlocal

pushd "%~dp0"
if not exist "build" mkdir "build"

cl /nologo /c /O2 /GS- /Zl /W4 /WX fltused_fixture.c /Fo"build\fltused_fixture.obj"
if errorlevel 1 goto failed

dumpbin /symbols "build\fltused_fixture.obj" | findstr /C:"_fltused" >nul
if errorlevel 1 goto failed

"%~dp0..\..\..\odin.exe" run . -no-crt -no-thread-local -out:"build\windows_no_crt.exe"
if errorlevel 1 goto failed

popd
exit /b 0

:failed
popd
exit /b 1
