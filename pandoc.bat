@ECHO OFF
SETLOCAL
SET "sourcedir=docs"
PUSHD "%sourcedir%"
FOR /f "delims=" %%a IN (
 'dir /b /s /a-d "*.md" "*.html" "*.htm" ^| findstr /v /i /c:"\\tourguide" /c:"\\libref\\"'
 ) DO (
 (
  pandoc "%%a" -f html -t markdown -o "%%~dpna.md"
 )
)
popd
GOTO :EOF