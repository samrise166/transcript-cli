@echo off
REM Transcript CLI Script for Windows
REM Usage: transcript-cli.bat [command] [options]

setlocal enabledelayedexpansion

echo.
echo =========================================
echo      Transcript CLI - Docker Mode
echo =========================================
echo.

REM Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not running!
    echo Please start Docker Desktop and try again.
    pause
    exit /b 1
)

REM Check if transcript-generator-cli image exists, try to pull from GitHub if not found
docker image inspect ghcr.io/twinrise/transcript-generator-cli:1.0.0 >nul 2>&1
if %errorlevel% neq 0 (
    echo GitHub transcript-generator-cli image not found. Trying to pull from GitHub...
    echo.
    
    REM Try to pull from GitHub Container Registry
    echo Pulling image from GitHub Container Registry...
    docker pull ghcr.io/twinrise/transcript-generator-cli:1.0.0
    if %errorlevel% neq 0 (
        echo Failed to pull from GitHub Container Registry.
        echo.
        echo OPTIONS:
        echo 1. Login to GitHub Container Registry: docker login ghcr.io
        echo 2. Run scripts\setup_docker_windows.bat to build locally
        echo 3. Make repository/package public in GitHub settings
        echo 4. Check if you have access to the GitHub repository
        echo.
        pause
        exit /b 1
    )
)

REM Default values for transcribe command
set COMMAND=%1
set INPUT_PATH=%2
set OUTPUT_DIR=./transcripts
set MODEL=medium
set LANGUAGE=auto
set FORMAT=srt
set DEVICE=auto
set JOBS=4
set RECURSIVE=
set COMPUTE_TYPE=float16

REM Show help if no arguments
if "%1"=="" goto :show_help
if "%1"=="--help" goto :show_help
if "%1"=="-h" goto :show_help

REM Handle non-transcribe commands directly
if not "%COMMAND%"=="transcribe" goto :run_direct

REM Parse transcribe arguments
shift
shift

:parse_args
if "%~1"=="" goto :run_transcription
if "%~1"=="-o" (
    set OUTPUT_DIR=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--output-dir" (
    set OUTPUT_DIR=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-m" (
    set MODEL=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--model" (
    set MODEL=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-l" (
    set LANGUAGE=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--language" (
    set LANGUAGE=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-f" (
    set FORMAT=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--format" (
    set FORMAT=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-d" (
    set DEVICE=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--device" (
    set DEVICE=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-j" (
    set JOBS=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--jobs" (
    set JOBS=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--recursive" (
    set RECURSIVE=--recursive
    shift
    goto :parse_args
)
if "%~1"=="--compute-type" (
    set COMPUTE_TYPE=%~2
    shift
    shift
    goto :parse_args
)
shift
goto :parse_args

:run_transcription
REM Check if input path is provided
if "%INPUT_PATH%"=="" (
    echo ERROR: Input path is required for transcribe command!
    echo.
    goto :show_help
)

REM Convert Windows paths to container paths
set CONTAINER_INPUT=%INPUT_PATH%
set CONTAINER_OUTPUT=%OUTPUT_DIR%

REM Convert Windows paths to Unix paths for Docker (like batch-direct.bat)
set UNIX_INPUT_PATH=%INPUT_PATH:\=/%
set UNIX_OUTPUT_DIR=%OUTPUT_DIR:\=/%

REM If paths are relative, make them fixed container paths
if not "%UNIX_INPUT_PATH:~0,1%"=="/" (
    set CONTAINER_INPUT=/app/data/input
) else (
    set CONTAINER_INPUT=%UNIX_INPUT_PATH%
)

if not "%UNIX_OUTPUT_DIR:~0,1%"=="/" (
    set CONTAINER_OUTPUT=/app/data/output
) else (
    set CONTAINER_OUTPUT=%UNIX_OUTPUT_DIR%
)

echo Input Path: %INPUT_PATH%
echo Output Directory: %OUTPUT_DIR%
echo Model: %MODEL%
echo Language: %LANGUAGE%
echo Format: %FORMAT%
echo Device: %DEVICE%
echo Jobs: %JOBS%
echo Compute Type: %COMPUTE_TYPE%
if not "%RECURSIVE%"=="" echo Recursive: Yes
echo.

REM Create data directories if they don't exist
if not exist "data\input" mkdir "data\input"
if not exist "data\output" mkdir "data\output"
if not exist "data\models" mkdir "data\models"

REM Build Docker command with GPU support, memory/CPU limits and progress bar environment variables
set DOCKER_CMD=docker run --rm --gpus all --memory="12g" --cpus="20" -v "%cd%\data:/app/data" -e HF_HUB_DISABLE_PROGRESS_BARS=false -e TRANSFORMERS_VERBOSITY=info -e HF_HUB_CACHE=/app/data/models -e HUGGINGFACE_HUB_CACHE=/app/data/models ghcr.io/twinrise/transcript-generator-cli:1.0.0 transcribe "%CONTAINER_INPUT%" "%CONTAINER_OUTPUT%"

set DOCKER_CMD=!DOCKER_CMD! --model "%MODEL%" --language "%LANGUAGE%" --format "%FORMAT%" --device "%DEVICE%" --parallel "%JOBS%" --compute-type "%COMPUTE_TYPE%" %RECURSIVE%

echo Starting transcription...
echo.
echo NOTE: First-time model download may take several minutes:
echo   - tiny: ~39MB (1-2 min)    - base: ~74MB (2-3 min)
echo   - small: ~244MB (3-5 min)  - medium: ~769MB (5-10 min)  
echo   - large: ~1550MB (10-20 min)
echo.
echo Your current model: %MODEL% - Please be patient during download...
echo.
echo NOTE: If this is the first time using this model, we'll use serial processing
echo to avoid download conflicts, then switch to parallel processing.
echo.
echo Command: !DOCKER_CMD!
echo.

REM Execute the command
!DOCKER_CMD!

goto :end_script

:run_direct
REM For non-transcribe commands, run directly
echo Executing: %*
echo.

docker run --rm --gpus all --memory="12g" --cpus="20" -v "%cd%\data:/app/data" -e HF_HUB_DISABLE_PROGRESS_BARS=false -e TRANSFORMERS_VERBOSITY=info ghcr.io/twinrise/transcript-generator-cli:1.0.0 %*

goto :end_script

:show_help
echo Usage: transcript-cli.bat [command] [options]
echo.
echo Commands:
echo   transcribe INPUT [options]      Transcribe audio/video files
echo   models                          List available models
echo   config [options]                Manage configuration
echo   info                            Show system information
echo   version                         Show version
echo   --help                          Show this help
echo.
echo Transcribe Options:
echo   -o, --output-dir DIR       Output directory (default: ./transcripts)
echo   -m, --model SIZE           Model size: tiny, base, small, medium, large (default: medium)
echo   -l, --language LANG        Language code: en, zh, auto (default: auto)
echo   -f, --format FORMAT        Output format: srt, vtt, txt, json, ass (default: srt)
echo   -d, --device DEVICE        Device: auto, cpu, cuda (default: auto)
echo   -j, --jobs NUM             Number of parallel jobs (default: 1)
echo   --recursive                Process directories recursively
echo   --compute-type TYPE        Compute type: float16, float32, int8 (default: float32)
echo.
echo Examples:
echo   transcript-cli.bat transcribe input.mp4
echo   transcript-cli.bat transcribe input.mp4 -o ./output -m large -f vtt
echo   transcript-cli.bat transcribe data/input -o data/output --recursive
echo   transcript-cli.bat transcribe ./media -j 4 -d cuda
echo   transcript-cli.bat models
echo   transcript-cli.bat config --show
echo.
echo File Locations:
echo   Place input files in: data\input\
echo   Output files will be in: data\output\
echo   Models cached in: data\models\
echo.
echo Prerequisites:
echo   1. Docker Desktop must be running
echo   2. Run scripts\setup_docker_windows.bat to build the image
echo.

:end_script
if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo       Command completed successfully!
    echo ========================================
) else (
    echo.
    echo ========================================
    echo           Command failed!
    echo ========================================
    echo Please check the error messages above.
)

echo.
pause