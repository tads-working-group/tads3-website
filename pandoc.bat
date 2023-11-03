@ECHO OFF
SETLOCAL
SET "sourcedir=docs"
PUSHD "%sourcedir%"
FOR /f "delims=" %%a IN (
 'dir /b /s /a-d *.md *.html *.htm '
 ) DO (
 IF /i "%%~xa"==".md" (
  IF NOT EXIST "%%~dpna.html" ECHO pandoc "%%a" -t gfm-raw_html -o "%%~dpna.md"
 ) ELSE (
  IF NOT EXIST "%%~dpna.md" pandoc "%%a" -t gfm-raw_html -o "%%~dpna.md"
 )
)
popd
GOTO :EOF