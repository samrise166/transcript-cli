#!/usr/bin/env powershell
# Transcript CLI Script for PowerShell
# Usage: transcript-cli.ps1 [command] [options]

[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [string]$Command,
    
    [Parameter(Position=1)]
    [string]$InputPath,
    
    [Alias("o")]
    [string]$OutputDir = "./transcripts",
    
    [Alias("m")]
    [string]$Model = "medium",
    
    [Alias("l")]
    [string]$Language = "auto",
    
    [Alias("f")]
    [string]$Format = "srt",
    
    [Alias("d")]
    [string]$Device = "auto",
    
    [Alias("j")]
    [int]$Jobs = 1,
    
    [switch]$Recursive,
    
    [string]$ComputeType = "float32",
    
    [switch]$Help,
    
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$RemainingArgs
)

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "     Transcript CLI - Docker Mode" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

# Check if Docker is running
try {
    docker info *>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker not running"
    }
} catch {
    Write-Host "ERROR: Docker is not running!" -ForegroundColor Red
    Write-Host "Please start Docker Desktop and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if transcript-cli image exists, try to pull from GitHub if not found
try {
    docker image inspect transcript-cli *>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Image not found"
    }
} catch {
    Write-Host "Local transcript-cli image not found. Trying to pull from GitHub..." -ForegroundColor Yellow
    Write-Host ""
    
    # Try to pull from GitHub Container Registry
    try {
        Write-Host "Pulling image from GitHub Container Registry..." -ForegroundColor Cyan
        docker pull ghcr.io/twinrise/transcript-generator-cli:1.0.0
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Successfully pulled image from GitHub!" -ForegroundColor Green
            Write-Host "Creating local tag 'transcript-cli'..." -ForegroundColor Cyan
            docker tag ghcr.io/twinrise/transcript-generator-cli:1.0.0 transcript-cli
            Write-Host ""
        } else {
            throw "Pull failed"
        }
    } catch {
        Write-Host "Failed to pull from GitHub Container Registry." -ForegroundColor Red
        Write-Host ""
        Write-Host "OPTIONS:" -ForegroundColor Yellow
        Write-Host "1. Run scripts/setup_docker_windows.bat to build locally" -ForegroundColor White
        Write-Host "2. Check if you have access to the GitHub repository" -ForegroundColor White
        Write-Host "3. Make sure Docker is logged in: docker login ghcr.io" -ForegroundColor White
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Show help if requested or no arguments
if ($Help -or -not $Command) {
    Write-Host "Usage: transcript-cli.ps1 [command] [options]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  transcribe INPUT [options]      Transcribe audio/video files"
    Write-Host "  models                          List available models"
    Write-Host "  config [options]                Manage configuration"
    Write-Host "  info                            Show system information"
    Write-Host "  version                         Show version"
    Write-Host "  -Help                           Show this help"
    Write-Host ""
    Write-Host "Transcribe Options:"
    Write-Host "  -OutputDir, -o DIR       Output directory (default: ./transcripts)"
    Write-Host "  -Model, -m SIZE          Model size: tiny, base, small, medium, large (default: medium)"
    Write-Host "  -Language, -l LANG       Language code: en, zh, auto (default: auto)"
    Write-Host "  -Format, -f FORMAT       Output format: srt, vtt, txt, json, ass (default: srt)"
    Write-Host "  -Device, -d DEVICE       Device: auto, cpu, cuda (default: auto)"
    Write-Host "  -Jobs, -j NUM            Number of parallel jobs (default: 1)"
    Write-Host "  -Recursive               Process directories recursively"
    Write-Host "  -ComputeType TYPE        Compute type: float16, float32, int8 (default: float32)"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\transcript-cli.ps1 transcribe input.mp4"
    Write-Host "  .\transcript-cli.ps1 transcribe input.mp4 -o ./output -m large -f vtt"
    Write-Host "  .\transcript-cli.ps1 transcribe data/input -o data/output -Recursive"
    Write-Host "  .\transcript-cli.ps1 transcribe ./media -j 4 -d cuda"
    Write-Host "  .\transcript-cli.ps1 models"
    Write-Host "  .\transcript-cli.ps1 config -Help"
    Write-Host ""
    Write-Host "Parameter Details:"
    Write-Host "  ┌─────────────────┬────────┬───────────────┬─────────────────────────────────────────┐"
    Write-Host "  │ Parameter       │ Short  │ Default       │ Description                             │"
    Write-Host "  ├─────────────────┼────────┼───────────────┼─────────────────────────────────────────┤"
    Write-Host "  │ -OutputDir      │ -o     │ ./transcripts │ Output directory                        │"
    Write-Host "  │ -Model          │ -m     │ medium        │ Model size: tiny, base, small, medium, large │"
    Write-Host "  │ -Language       │ -l     │ auto          │ Language code: en, zh, auto etc.       │"
    Write-Host "  │ -Format         │ -f     │ srt           │ Output format: srt, vtt, txt, json, ass │"
    Write-Host "  │ -Device         │ -d     │ auto          │ Device: auto, cpu, cuda                 │"
    Write-Host "  │ -Jobs           │ -j     │ 1             │ Number of parallel jobs                 │"
    Write-Host "  │ -Recursive      │ None   │ No            │ Recursively search subdirectories      │"
    Write-Host "  └─────────────────┴────────┴───────────────┴─────────────────────────────────────────┘"
    Write-Host ""
    Write-Host "File Locations:"
    Write-Host "  Place input files in: data/input/"
    Write-Host "  Output files will be in: data/output/"
    Write-Host "  Models cached in: data/models/"
    Write-Host ""
    Write-Host "Prerequisites:"
    Write-Host "  1. Docker Desktop must be running"
    Write-Host "  2. Run scripts/setup_docker_windows.bat to build the image"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 0
}

# Handle non-transcribe commands directly
if ($Command -ne "transcribe") {
    Write-Host "Executing: $Command $RemainingArgs" -ForegroundColor Cyan
    Write-Host ""
    
    $allArgs = @($Command) + $RemainingArgs
    docker run --rm -v "${PWD}/data:/app/data" transcript-cli $allArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "      Command completed successfully!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Red
        Write-Host "          Command failed!" -ForegroundColor Red
        Write-Host "========================================" -ForegroundColor Red
        Write-Host "Please check the error messages above." -ForegroundColor Yellow
    }
    
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit $LASTEXITCODE
}

# Handle transcribe command
if (-not $InputPath) {
    Write-Host "ERROR: Input path is required for transcribe command!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Usage: transcript-cli.ps1 transcribe INPUT [options]"
    Read-Host "Press Enter to exit"
    exit 1
}

# Convert Windows paths to container paths
$containerInput = $InputPath
$containerOutput = $OutputDir

# If using relative paths, assume they're in data directory
if (-not [System.IO.Path]::IsPathRooted($InputPath)) {
    $containerInput = "/app/data/$InputPath"
}
if (-not [System.IO.Path]::IsPathRooted($OutputDir)) {
    $containerOutput = "/app/data/$OutputDir"
}

Write-Host "Input Path: $InputPath" -ForegroundColor Cyan
Write-Host "Output Directory: $OutputDir" -ForegroundColor Cyan
Write-Host "Model: $Model" -ForegroundColor Cyan
Write-Host "Language: $Language" -ForegroundColor Cyan
Write-Host "Format: $Format" -ForegroundColor Cyan
Write-Host "Device: $Device" -ForegroundColor Cyan
Write-Host "Jobs: $Jobs" -ForegroundColor Cyan
Write-Host "Compute Type: $ComputeType" -ForegroundColor Cyan
if ($Recursive) { Write-Host "Recursive: Yes" -ForegroundColor Cyan }
Write-Host ""

# Create data directories if they don't exist
$dataDirs = @("data/input", "data/output", "data/models")
foreach ($dir in $dataDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# Build Docker command
$dockerArgs = @(
    "run", "--rm", "-v", "${PWD}/data:/app/data", "transcript-cli", 
    "transcribe", $containerInput, $containerOutput
)

$dockerArgs += @(
    "--model", $Model,
    "--language", $Language,
    "--format", $Format,
    "--device", $Device,
    "--parallel", $Jobs,
    "--compute-type", $ComputeType
)

if ($Recursive) {
    $dockerArgs += "--recursive"
}

Write-Host "Starting transcription..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Command: docker $($dockerArgs -join ' ')" -ForegroundColor Gray
Write-Host ""

# Execute the command
& docker $dockerArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "      Command completed successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "          Command failed!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Please check the error messages above." -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Press Enter to exit"
exit $LASTEXITCODE