@ECHO OFF
SETLOCAL
SET "sourcedir=docs"
PUSHD "%sourcedir%"
FOR /f "delims=" %%a IN (
 'dir /b /s /a-d "*.md" "*.html" "*.htm" ^| findstr /v /i /c:"\\tourguide" /c:"\\libref\\"'
 ) DO (
 IF /i "%%~xa"==".md" (
  IF NOT EXIST "%%~dpna.html" ECHO pandoc "%%a" -t html -o "%%~dpna.md"
 ) ELSE (
  IF NOT EXIST "%%~dpna.md" pandoc "%%a" -t html -o "%%~dpna.md"
 )
)
popd
GOTO :EOF