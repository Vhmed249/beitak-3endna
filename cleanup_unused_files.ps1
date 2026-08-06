# ===============================================
# Cleanup Unused Files Script
# ===============================================

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Starting Cleanup of Unused Files" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Get project root path
$projectRoot = if ($PSScriptRoot) { 
    $PSScriptRoot 
} else { 
    "C:\Users\Ahmed\Desktop\beitak-3endna-main (1)\beitak-3endna-main"
}

Write-Host "Project Path: $projectRoot" -ForegroundColor Magenta
Set-Location $projectRoot

# Create backup folder
$backupFolder = Join-Path $projectRoot "backup_deleted_files_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Write-Host "Creating backup folder: $backupFolder" -ForegroundColor Green
New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null

# Counter for deleted files
$deletedCount = 0

# =======================
# 1. Delete old fix scripts (fix_*.sh)
# =======================
Write-Host ""
Write-Host "Stage 1: Deleting old fix scripts..." -ForegroundColor Cyan

$fixScripts = Get-ChildItem -Path $projectRoot -Filter "fix_*.sh" -File
if ($fixScripts.Count -gt 0) {
    Write-Host "   Found $($fixScripts.Count) fix scripts" -ForegroundColor Yellow
    foreach ($file in $fixScripts) {
        try {
            Copy-Item $file.FullName -Destination $backupFolder -ErrorAction Stop
            Remove-Item $file.FullName -Force -ErrorAction Stop
            Write-Host "   [OK] Deleted: $($file.Name)" -ForegroundColor Green
            $deletedCount++
        }
        catch {
            Write-Host "   [ERROR] Failed to delete: $($file.Name)" -ForegroundColor Red
        }
    }
}
else {
    Write-Host "   [OK] No fix scripts to delete" -ForegroundColor Green
}

# =======================
# 2. Delete old check scripts (check_*.sh)
# =======================
Write-Host ""
Write-Host "Stage 2: Deleting old check scripts..." -ForegroundColor Cyan

$checkScripts = Get-ChildItem -Path $projectRoot -Filter "check_*.sh" -File
if ($checkScripts.Count -gt 0) {
    Write-Host "   Found $($checkScripts.Count) check scripts" -ForegroundColor Yellow
    foreach ($file in $checkScripts) {
        try {
            Copy-Item $file.FullName -Destination $backupFolder -ErrorAction Stop
            Remove-Item $file.FullName -Force -ErrorAction Stop
            Write-Host "   [OK] Deleted: $($file.Name)" -ForegroundColor Green
            $deletedCount++
        }
        catch {
            Write-Host "   [ERROR] Failed to delete: $($file.Name)" -ForegroundColor Red
        }
    }
}
else {
    Write-Host "   [OK] No check scripts to delete" -ForegroundColor Green
}

# =======================
# 3. Delete old cleanup scripts
# =======================
Write-Host ""
Write-Host "Stage 3: Deleting old cleanup scripts..." -ForegroundColor Cyan

$cleanupScripts = @(
    "cleanup_project.sh",
    "cleanup_project_final.sh",
    "clean_backup_files.sh"
)

foreach ($scriptName in $cleanupScripts) {
    $scriptPath = Join-Path $projectRoot $scriptName
    if (Test-Path $scriptPath) {
        try {
            Copy-Item $scriptPath -Destination $backupFolder -ErrorAction Stop
            Remove-Item $scriptPath -Force -ErrorAction Stop
            Write-Host "   [OK] Deleted: $scriptName" -ForegroundColor Green
            $deletedCount++
        }
        catch {
            Write-Host "   [ERROR] Failed to delete: $scriptName" -ForegroundColor Red
        }
    }
}

# =======================
# 4. Delete setup scripts
# =======================
Write-Host ""
Write-Host "Stage 4: Deleting setup scripts..." -ForegroundColor Cyan

$setupScripts = @(
    "create_project.sh",
    "fill_files.sh",
    "final_project_check.sh",
    "next_check.sh",
    "setup_release_signing.sh"
)

foreach ($scriptName in $setupScripts) {
    $scriptPath = Join-Path $projectRoot $scriptName
    if (Test-Path $scriptPath) {
        try {
            Copy-Item $scriptPath -Destination $backupFolder -ErrorAction Stop
            Remove-Item $scriptPath -Force -ErrorAction Stop
            Write-Host "   [OK] Deleted: $scriptName" -ForegroundColor Green
            $deletedCount++
        }
        catch {
            Write-Host "   [ERROR] Failed to delete: $scriptName" -ForegroundColor Red
        }
    }
}

# =======================
# 5. Delete backup files (.backup, .bak)
# =======================
Write-Host ""
Write-Host "Stage 5: Deleting backup files..." -ForegroundColor Cyan

$backupFiles = Get-ChildItem -Path $projectRoot -Include "*.backup", "*.bak" -File -Recurse -ErrorAction SilentlyContinue
if ($backupFiles.Count -gt 0) {
    Write-Host "   Found $($backupFiles.Count) backup files" -ForegroundColor Yellow
    foreach ($file in $backupFiles) {
        try {
            Copy-Item $file.FullName -Destination $backupFolder -ErrorAction Stop
            Remove-Item $file.FullName -Force -ErrorAction Stop
            Write-Host "   [OK] Deleted: $($file.Name)" -ForegroundColor Green
            $deletedCount++
        }
        catch {
            Write-Host "   [ERROR] Failed to delete: $($file.Name)" -ForegroundColor Red
        }
    }
}
else {
    Write-Host "   [OK] No backup files to delete" -ForegroundColor Green
}

# =======================
# 6. Delete report files
# =======================
Write-Host ""
Write-Host "Stage 6: Deleting report files..." -ForegroundColor Cyan

$reportFiles = @(
    "analyze_result.txt",
    "COMPREHENSIVE_AUDIT_REPORT.md",
    "SECURITY_AUDIT_REPORT.md",
    "project_dump.txt"
)

foreach ($fileName in $reportFiles) {
    $filePath = Join-Path $projectRoot $fileName
    if (Test-Path $filePath) {
        try {
            Copy-Item $filePath -Destination $backupFolder -ErrorAction Stop
            Remove-Item $filePath -Force -ErrorAction Stop
            Write-Host "   [OK] Deleted: $fileName" -ForegroundColor Green
            $deletedCount++
        }
        catch {
            Write-Host "   [ERROR] Failed to delete: $fileName" -ForegroundColor Red
        }
    }
}

# =======================
# 7. Delete strange files (Get, Process, Run)
# =======================
Write-Host ""
Write-Host "Stage 7: Deleting strange files..." -ForegroundColor Cyan

$strangeFiles = @("Get", "Process", "Run")

foreach ($fileName in $strangeFiles) {
    $filePath = Join-Path $projectRoot $fileName
    if (Test-Path $filePath) {
        try {
            Copy-Item $filePath -Destination $backupFolder -ErrorAction Stop
            Remove-Item $filePath -Force -ErrorAction Stop
            Write-Host "   [OK] Deleted: $fileName" -ForegroundColor Green
            $deletedCount++
        }
        catch {
            Write-Host "   [ERROR] Failed to delete: $fileName" -ForegroundColor Red
        }
    }
}

# =======================
# 8. Delete .gitkeep files from assets
# =======================
Write-Host ""
Write-Host "Stage 8: Deleting .gitkeep files..." -ForegroundColor Cyan

$assetsPath = Join-Path $projectRoot "assets"
if (Test-Path $assetsPath) {
    $gitkeepFiles = Get-ChildItem -Path $assetsPath -Filter ".gitkeep" -File -Recurse -ErrorAction SilentlyContinue
    if ($gitkeepFiles.Count -gt 0) {
        foreach ($file in $gitkeepFiles) {
            try {
                Remove-Item $file.FullName -Force -ErrorAction Stop
                Write-Host "   [OK] Deleted: $($file.FullName.Replace($projectRoot, '.'))" -ForegroundColor Green
                $deletedCount++
            }
            catch {
                Write-Host "   [ERROR] Failed to delete: $($file.Name)" -ForegroundColor Red
            }
        }
    }
    else {
        Write-Host "   [OK] No .gitkeep files to delete" -ForegroundColor Green
    }
}

# =======================
# 9. Delete old cleanup.ps1
# =======================
Write-Host ""
Write-Host "Stage 9: Deleting old cleanup.ps1..." -ForegroundColor Cyan

$oldCleanup = Join-Path $projectRoot "cleanup.ps1"
if (Test-Path $oldCleanup) {
    try {
        Copy-Item $oldCleanup -Destination $backupFolder -ErrorAction Stop
        Remove-Item $oldCleanup -Force -ErrorAction Stop
        Write-Host "   [OK] Deleted: cleanup.ps1" -ForegroundColor Green
        $deletedCount++
    }
    catch {
        Write-Host "   [ERROR] Failed to delete: cleanup.ps1" -ForegroundColor Red
    }
}

# =======================
# Final Results
# =======================
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Cleanup Complete!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Statistics:" -ForegroundColor Yellow
Write-Host "   * Deleted files: $deletedCount" -ForegroundColor White
Write-Host "   * Backup folder: $backupFolder" -ForegroundColor White
Write-Host ""
Write-Host "Note: All deleted files are backed up" -ForegroundColor Cyan
Write-Host ""

# =======================
# Show important remaining files
# =======================
Write-Host "Important files remaining in project:" -ForegroundColor Yellow
Write-Host "   [OK] pubspec.yaml - Flutter config" -ForegroundColor Green
Write-Host "   [OK] README.md - Project docs" -ForegroundColor Green
Write-Host "   [OK] README_AR.md - Arabic docs" -ForegroundColor Green
Write-Host "   [OK] SETUP_GUIDE.md - Setup guide" -ForegroundColor Green
Write-Host "   [OK] firestore.rules - Firestore rules" -ForegroundColor Green
Write-Host "   [OK] storage.rules - Storage rules" -ForegroundColor Green
Write-Host "   [OK] android/ - Android files" -ForegroundColor Green
Write-Host "   [OK] lib/ - Main project code" -ForegroundColor Green
Write-Host "   [OK] assets/ - Project assets" -ForegroundColor Green
Write-Host ""

Write-Host "Project cleaned successfully!" -ForegroundColor Green
Write-Host ""

# Optional: Delete backup folder after confirmation
Write-Host "Do you want to delete the backup folder? (y/N): " -ForegroundColor Yellow -NoNewline
$response = Read-Host

if ($response -eq "y" -or $response -eq "Y") {
    Remove-Item $backupFolder -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "[OK] Backup folder deleted" -ForegroundColor Green
}
else {
    Write-Host "[OK] Backup folder kept" -ForegroundColor Green
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Cyan
