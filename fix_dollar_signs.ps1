# Fix dollar signs in quick_ref_snippets.dart
$file = "c:\Users\masth\students-os\lib\data\quick_ref_snippets.dart"
$content = Get-Content $file -Raw

# Replace all $ with \$ except when followed by { (which is Dart interpolation)
$content = $content -replace '\$(?!\{)', '\$'

Set-Content $file $content -NoNewline

Write-Host "Fixed dollar signs in quick_ref_snippets.dart"
