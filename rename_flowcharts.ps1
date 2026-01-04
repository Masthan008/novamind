# PowerShell script to rename C Programming flowcharts

# Rename numbered flowcharts to descriptive names
Rename-Item "c:\Users\masth\students-os\assets\images\flowcharts\1.webp" "flowchart_even_odd.webp" -ErrorAction SilentlyContinue
Rename-Item "c:\Users\masth\students-os\assets\images\flowcharts\2.webp" "flowchart_largest_three.webp" -ErrorAction SilentlyContinue
Rename-Item "c:\Users\masth\students-os\assets\images\flowcharts\3.webp" "flowchart_factorial.webp" -ErrorAction SilentlyContinue
Rename-Item "c:\Users\masth\students-os\assets\images\flowcharts\4.webp" "flowchart_prime_check.webp" -ErrorAction SilentlyContinue
Rename-Item "c:\Users\masth\students-os\assets\images\flowcharts\5.webp" "flowchart_reverse_number.webp" -ErrorAction SilentlyContinue
Rename-Item "c:\Users\masth\students-os\assets\images\flowcharts\6.webp" "flowchart_fibonacci.webp" -ErrorAction SilentlyContinue
Rename-Item "c:\Users\masth\students-os\assets\images\flowcharts\7.webp" "flowchart_linear_search.webp" -ErrorAction SilentlyContinue
Rename-Item "c:\Users\masth\students-os\assets\images\flowcharts\8.webp" "flowchart_bubble_sort.webp" -ErrorAction SilentlyContinue
Rename-Item "c:\Users\masth\students-os\assets\images\flowcharts\9.webp" "flowchart_sum_digits.webp" -ErrorAction SilentlyContinue
Rename-Item "c:\Users\masth\students-os\assets\images\flowcharts\10.webp" "flowchart_calculator.webp" -ErrorAction SilentlyContinue

Write-Host "All C Programming flowcharts renamed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Renamed files:" -ForegroundColor Cyan
Write-Host "1.webp -> flowchart_even_odd.webp" -ForegroundColor White
Write-Host "2.webp -> flowchart_largest_three.webp" -ForegroundColor White
Write-Host "3.webp -> flowchart_factorial.webp" -ForegroundColor White
Write-Host "4.webp -> flowchart_prime_check.webp" -ForegroundColor White
Write-Host "5.webp -> flowchart_reverse_number.webp" -ForegroundColor White
Write-Host "6.webp -> flowchart_fibonacci.webp" -ForegroundColor White
Write-Host "7.webp -> flowchart_linear_search.webp" -ForegroundColor White
Write-Host "8.webp -> flowchart_bubble_sort.webp" -ForegroundColor White
Write-Host "9.webp -> flowchart_sum_digits.webp" -ForegroundColor White
Write-Host "10.webp -> flowchart_calculator.webp" -ForegroundColor White
