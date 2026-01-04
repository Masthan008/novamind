# Fix quick_ref_snippets.dart by converting all triple-quoted strings to raw strings
$file = "c:\Users\masth\students-os\lib\data\quick_ref_snippets.dart"
$content = Get-Content $file -Raw

# Replace ''' with r''' for all snippet strings
# This regex looks for patterns like: 'Key': '''
$content = $content -replace "('[\w\s&/]+'):\s*'''", '$1: r'''

Set-Content $file $content -NoNewline

Write-Host "Converted all snippet strings to raw strings (r''')"
