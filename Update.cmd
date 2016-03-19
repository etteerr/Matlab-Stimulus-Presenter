@echo off
set gitexe=".\git\bin\git.exe"
set repo="https://github.com/etteerr/Matlab-Stimulus-Presenter"
set cmd="clone"
set target=%TEMP%\MSP-temp
set expdir=Experiments
set datadir=Data

rmdir /S /Q %target% > nul
 

:Question
echo When updating, ALL FILLES IN THIS DIRECTORY ARE REMOVED except:
echo %expdir%
echo %datadir%
echo.
set /P ans="Are you sure you want to update?(yes/n)"

if not %ans%==yes (
echo Update aborted.
goto END
)

goto Update


:Update
%gitexe% %cmd% %repo%  %target%

if %errorlevel%==0 ( goto Installing)
echo "Something went wrong!"
goto END


:Installing
echo "Removing old version..."
for %%i in (*) do (if not %%i==%0.cmd del /Q %%i )
for /D %%i in (*) do ( if not %%i==%expdir% if not %%i==%datadir% rmdir /S /Q %%i )
echo "Installing new version..."
move /Y %target%\* .\
for /D %%i in (%target%\*) do move /Y %%i .\

:Clean
echo "Cleaning..."
rmdir /S /Q %target% >nul

:END
pause