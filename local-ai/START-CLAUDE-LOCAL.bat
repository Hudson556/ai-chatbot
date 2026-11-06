@echo off
REM Double-click to open Claude Code running on YOUR local AI (free, offline).
cd /d "%~dp0"
where ollama >nul 2>nul || (echo Ollama not found. Run INSTALL-WINDOWS.bat first. & pause & exit /b 1)
echo Building my-ai-claude (first time only)...
ollama create my-ai-claude -f "%~dp0Modelfile.claude" || (echo Build failed - is INSTALL-WINDOWS.bat finished? & pause & exit /b 1)
if not exist "%USERPROFILE%\ai-playground" mkdir "%USERPROFILE%\ai-playground"
cd /d "%USERPROFILE%\ai-playground"
echo.
echo Starting Claude Code on my-ai-claude in %CD%
echo (Ollama will offer to install Claude Code if you do not have it.)
echo.
ollama launch claude --model my-ai-claude
pause
