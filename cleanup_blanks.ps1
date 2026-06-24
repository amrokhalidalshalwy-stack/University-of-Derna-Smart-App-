$dartFiles = Get-ChildItem -Path "c:\Users\AL-Reada\Documents\omar khaled alkhawga\My_App\flutter_project\lib" -Recurse -Filter "*.dart"
$count = 0
foreach ($file in $dartFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $lines = $content -split "`n"
    $newLines = @()
    $blankCount = 0
    foreach ($line in $lines) {
        if ($line.Trim() -eq "") {
            $blankCount++
            if ($blankCount -le 1) {
                $newLines += $line
            }
        } else {
            $blankCount = 0
            $newLines += $line
        }
    }
    $newContent = $newLines -join "`n"
    if ($newContent -ne $content) {
        $count++
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
    }
}
Write-Output "Done! Cleaned $count files"
