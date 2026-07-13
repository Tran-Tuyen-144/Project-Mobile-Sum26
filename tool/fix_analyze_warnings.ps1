$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param(
        [string]$Path,
        [string]$Content
    )

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

function Update-FileText {
    param(
        [string]$Path,
        [scriptblock]$Updater
    )

    if (-not (Test-Path $Path)) {
        return
    }

    $oldText = Get-Content -Raw -Encoding UTF8 $Path
    $newText = & $Updater $oldText

    if ($newText -ne $oldText) {
        Write-Utf8NoBom -Path $Path -Content $newText
        Write-Host "Fixed: $Path"
    }
}

function Remove-Line {
    param(
        [string]$Path,
        [string]$LineToRemove
    )

    if (-not (Test-Path $Path)) {
        return
    }

    $lines = Get-Content -Encoding UTF8 $Path
    $newLines = $lines | Where-Object {
        $_.Trim() -ne $LineToRemove.Trim()
    }

    Write-Utf8NoBom -Path $Path -Content ($newLines -join "`r`n")
    Write-Host "Removed line in: $Path"
}

function Keep-Only-One-Line {
    param(
        [string]$Path,
        [string]$LineToKeep
    )

    if (-not (Test-Path $Path)) {
        return
    }

    $lines = Get-Content -Encoding UTF8 $Path
    $seen = $false
    $newLines = New-Object System.Collections.Generic.List[string]

    foreach ($line in $lines) {
        if ($line.Trim() -eq $LineToKeep.Trim()) {
            if ($seen) {
                continue
            }

            $seen = $true
            $newLines.Add($line)
        } else {
            $newLines.Add($line)
        }
    }

    Write-Utf8NoBom -Path $Path -Content ($newLines -join "`r`n")
    Write-Host "Deduplicated line in: $Path"
}

# 1. Xóa duplicate import.
Keep-Only-One-Line `
    -Path "lib\routes\app_router.dart" `
    -LineToKeep "import '../screens/admin/admin_main_screen.dart';"

# 2. Xóa unused import đã thấy trong analyze.
Remove-Line `
    -Path "lib\services\cloudinary_upload_service.dart" `
    -LineToRemove "import 'dart:io';"

Remove-Line `
    -Path "lib\screens\admin\manage\admin_manage_screen.dart" `
    -LineToRemove "import '../staff/admin_staff_screen.dart';"

Remove-Line `
    -Path "lib\screens\admin\pet\admin_pet_form_screen.dart" `
    -LineToRemove "import 'dart:io';"

Remove-Line `
    -Path "lib\screens\admin\shifts\admin_shift_assign_screen.dart" `
    -LineToRemove "import '../../../theme/app_colors.dart';"

# 3. Sửa prefer_final_fields.
Update-FileText "lib\screens\admin\shifts\admin_shift_assign_screen.dart" {
    param($text)

    $text = $text.Replace(
        "Map<String, String> _shiftAssignment = {};",
        "final Map<String, String> _shiftAssignment = {};"
    )

    $text = $text.Replace(
        'print("Kết quả xếp ca: $_shiftAssignment");',
        'debugPrint("Kết quả xếp ca: $_shiftAssignment");'
    )

    return $text
}

# 4. Sửa withOpacity deprecated trong toàn bộ lib.
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | ForEach-Object {
    $path = $_.FullName

    Update-FileText $path {
        param($text)

        return [regex]::Replace(
            $text,
            '\.withOpacity\(([^()\r\n]+)\)',
            '.withValues(alpha: $1)'
        )
    }
}

# 5. Sửa activeColor deprecated ở màn tạo bài viết.
Update-FileText "lib\screens\customer\community\create_community_post_screen.dart" {
    param($text)

    return $text.Replace(
        "activeColor: AppColors.primary,",
        "activeThumbColor: AppColors.primary,"
    )
}

# 6. File test Cloudinary là tool script, cho phép print.
Update-FileText "tool\cloudinary_test.dart" {
    param($text)

    if ($text -match "ignore_for_file: avoid_print") {
        return $text
    }

    return "// ignore_for_file: avoid_print`r`n" + $text
}

Write-Host ""
Write-Host "Done fixing common analyze warnings."
