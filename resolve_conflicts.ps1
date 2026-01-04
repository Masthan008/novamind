# Script to resolve all Git merge conflicts by keeping HEAD version
# This removes conflict markers and keeps only the HEAD (current) changes

$files = @(
    "lib\widgets\user_badge.dart",
    "lib\services\timetable_service.dart",
    "lib\services\study_companion_service.dart",
    "lib\services\notification_service.dart",
    "lib\widgets\glass_bottom_nav.dart",
    "lib\services\enhanced_data_management_service.dart",
    "lib\services\dashboard_service.dart",
    "lib\services\backup_service.dart",
    "lib\services\ai_service.dart",
    "lib\screens\settings_screen.dart",
    "lib\screens\timetable_screen.dart",
    "lib\screens\settings\notification_settings_screen.dart",
    "lib\screens\settings\main_settings_screen.dart",
    "lib\screens\leaderboard_screen.dart",
    "lib\screens\home_screen.dart",
    "lib\screens\enhanced_settings_screen.dart",
    "lib\screens\about_screen.dart"
)

$conflictStart = "<<<<<<< HEAD"
$conflictMiddle = "======="
$conflictEnd = ">>>>>>> 80e675fe805a18c20f686481d3df5a5e2695732f"

foreach ($file in $files) {
    $filePath = Join-Path $PSScriptRoot $file
    
    if (Test-Path $filePath) {
        Write-Host "Processing: $file"
        
        $content = Get-Content $filePath -Raw
        $lines = Get-Content $filePath
        
        $newLines = @()
        $inConflict = $false
        $inHead = $false
        
        foreach ($line in $lines) {
            if ($line -match [regex]::Escape($conflictStart)) {
                $inConflict = $true
                $inHead = $true
                continue
            }
            elseif ($line -match [regex]::Escape($conflictMiddle) -and $inConflict) {
                $inHead = $false
                continue
            }
            elseif ($line -match [regex]::Escape($conflictEnd) -and $inConflict) {
                $inConflict = $false
                $inHead = $false
                continue
            }
            
            # Only add lines that are either outside conflicts or in HEAD section
            if (-not $inConflict -or $inHead) {
                $newLines += $line
            }
        }
        
        # Write back to file
        $newLines | Set-Content $filePath -Encoding UTF8
        Write-Host "  ✓ Resolved conflicts in $file"
    }
    else {
        Write-Host "  ⚠ File not found: $file"
    }
}

Write-Host "`nAll conflicts resolved! Keeping HEAD version."
