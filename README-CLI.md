# Transcript CLI

> Local batch audio/video transcription using Faster-Whisper

A simplified command-line tool for batch transcription of audio and video files. This is a streamlined version of the original transcript-generator-cli, focused purely on local processing without requiring complex infrastructure like databases, message queues, or web APIs.

## ✨ Features

- **Local Processing**: No API servers or databases required
- **Batch Transcription**: Process multiple files at once
- **Multiple Formats**: Support for audio and video files
- **Various Outputs**: SRT, VTT, TXT, JSON, ASS subtitle formats
- **GPU Acceleration**: CUDA support for faster processing
- **Progress Tracking**: Rich progress bars and status displays
- **Configurable**: Flexible configuration system
- **Easy Installation**: Simple setup with pip or Docker

## 🚀 Quick Start

### Installation

#### Option 1: Using Installation Script (Recommended)

```bash
# Unix/Linux/macOS
chmod +x scripts/install-cli.sh
./scripts/install-cli.sh

# Windows
scripts\install-cli.bat
```

#### Option 2: Manual Installation

```bash
# Clone repository
git clone <repository-url>
cd transcript-generator-cli

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements-cli.txt

# Install the package
pip install -e .
```

#### Option 3: Direct Usage

```bash
# Without installation, use the standalone script
python transcript-cli-new.py --help
```

### Basic Usage

```bash
# Transcribe a single file
transcript-cli transcribe input.mp4 output.srt

# Batch process a directory
transcript-cli transcribe ./audio_files ./transcripts --recursive

# Specify model and format
transcript-cli transcribe input.mp4 output.vtt --model large --format vtt

# Process with custom language
transcript-cli transcribe input.mp4 output.srt --language zh --model medium
```

## 📋 Command Reference

### Main Commands

```bash
# Transcribe files
transcript-cli transcribe INPUT_PATH [OUTPUT_PATH] [OPTIONS]

# Show available models
transcript-cli models

# Manage configuration
transcript-cli config [OPTIONS]

# Show system information
transcript-cli info

# Show version
transcript-cli version
```

### Transcribe Options

```bash
-m, --model TEXT           Whisper model size [tiny|base|small|medium|large|large-v2|large-v3]
-f, --format TEXT          Output format [srt|vtt|txt|json|ass]
-l, --language TEXT        Language code (e.g., en, zh, fr) or "auto"
-r, --recursive            Process directories recursively
-p, --parallel INTEGER     Number of parallel workers (default: 4)
--device TEXT              Processing device [auto|cpu|cuda]
--compute-type TEXT        Compute precision [float16|float32|int8] (default: float16)
```

### Configuration Commands

```bash
# Show current configuration
transcript-cli config --show

# Set configuration values
transcript-cli config models.default large
transcript-cli config device.type cuda

# Reset to defaults
transcript-cli config --reset
```

## 🔧 Configuration

Configuration is managed through YAML files and environment variables.

### Configuration File Locations

- **User Config**: `~/.config/transcript-cli/config.yaml` (Linux/macOS)
- **User Config**: `%APPDATA%/transcript-cli/config.yaml` (Windows)
- **Project Config**: `./config/default.yaml`
- **Environment**: `.env` file

### Example Configuration

```yaml
models:
  default: medium
  download_root: ~/.cache/transcript-cli/models

device:
  type: auto  # auto, cpu, cuda
  compute_type: float16

processing:
  max_workers: 4
  vad_filter: true

output:
  default_format: srt
  encoding: utf-8

paths:
  input: ./data/input
  output: ./data/output
  temp: ./data/temp
```

### Environment Variables

```bash
# Model settings
WHISPER_MODEL_SIZE=medium
WHISPER_DEVICE=auto
WHISPER_COMPUTE_TYPE=float16

# Processing settings
MAX_WORKERS=4
LOG_LEVEL=INFO

# Path settings
INPUT_DIR=./data/input
OUTPUT_DIR=./data/output

# Progress and cache settings
HF_HUB_DISABLE_PROGRESS_BARS=false
TRANSFORMERS_VERBOSITY=info
HF_HUB_CACHE=./data/models
HUGGINGFACE_HUB_CACHE=./data/models
```

## 🐳 Docker Usage

### Build and Run

```bash
# Build the container
docker build -f Dockerfile-cli -t transcript-cli .

# Or pull from GitHub Container Registry
docker pull ghcr.io/twinrise/transcript-generator-cli:1.0.0

# Run with volume mounts
docker run -v ./data:/app/data transcript-cli transcribe /app/data/input /app/data/output --recursive
```

### Docker Compose

```bash
# Edit docker-compose-cli.yml as needed
docker-compose -f docker-compose-cli.yml up
```

### GPU Support

```bash
# For NVIDIA GPU support with resource limits
docker run --gpus all --memory="12g" --cpus="20" -v ./data:/app/data transcript-cli transcribe /app/data/input /app/data/output --device cuda
```

## 🎯 Supported Formats

### Input Formats

**Audio**: MP3, WAV, FLAC, M4A, AAC, OGG, WMA
**Video**: MP4, AVI, MOV, MKV, WebM, FLV, M4V

### Output Formats

- **SRT**: SubRip subtitle format
- **VTT**: WebVTT subtitle format  
- **TXT**: Plain text transcription
- **JSON**: Structured JSON with timestamps
- **ASS**: Advanced SubStation Alpha format

## 🏆 Model Information

| Model | Size | Speed | Accuracy | GPU Memory | Download Time |
|-------|------|-------|----------|------------|---------------|
| tiny | 39 MB | 32x | Low | 1 GB | 1-2 min |
| base | 74 MB | 16x | Medium | 1 GB | 2-3 min |
| small | 244 MB | 8x | Good | 2 GB | 3-5 min |
| medium | 769 MB | 6x | High | 2 GB | 5-10 min |
| large | 1550 MB | 4x | Very High | 4 GB | 10-20 min |
| large-v2 | 1550 MB | 4x | Very High | 4 GB | 10-20 min |
| large-v3 | 1550 MB | 4x | Very High | 4 GB | 10-20 min |

**Note**: Models are cached after first download. The CLI uses serial processing for first-time model downloads to avoid conflicts, then switches to parallel processing for subsequent runs.

## 📊 Examples

### Basic Transcription

```bash
# Single file with default settings
transcript-cli transcribe interview.mp4

# Specify output location and format
transcript-cli transcribe interview.mp4 interview.srt --format srt
```

### Batch Processing

```bash
# Process all files in a directory
transcript-cli transcribe ./recordings ./transcripts

# Recursive processing with specific model
transcript-cli transcribe ./media ./output --recursive --model large

# Parallel processing
transcript-cli transcribe ./audio ./output --parallel 2
```

### Advanced Usage

```bash
# Chinese language with large model
transcript-cli transcribe chinese_audio.mp3 --language zh --model large

# GPU processing with high precision
transcript-cli transcribe video.mp4 --device cuda --compute-type float16

# JSON output with metadata
transcript-cli transcribe audio.wav output.json --format json
```

## 🛠️ Development

### Project Structure

```
src/transcript_cli/
├── __init__.py           # Package initialization
├── main.py               # CLI entry point
├── cli/                  # Command-line interface
│   ├── commands.py       # CLI commands
│   └── progress.py       # Progress display
├── core/                 # Core functionality
│   ├── transcriber.py    # Transcription engine
│   └── processor.py      # Batch processor
└── utils/                # Utilities
    ├── config.py         # Configuration management
    ├── exceptions.py     # Exception classes
    └── formats.py        # Format conversion
```

### Running Tests

```bash
# Install development dependencies
pip install -e ".[dev]"

# Run tests
pytest

# Run with coverage
pytest --cov=transcript_cli
```

### Code Formatting

```bash
# Format code
black src/

# Check formatting
black --check src/
```

## 🔍 Troubleshooting

### Common Issues

**1. FFmpeg not found**
```bash
# Install ffmpeg
sudo apt install ffmpeg  # Ubuntu/Debian
brew install ffmpeg      # macOS
choco install ffmpeg     # Windows (Chocolatey)
```

**2. CUDA not detected**
```bash
# Check CUDA installation
nvidia-smi
python -c "import torch; print(torch.cuda.is_available())"

# Use CPU fallback
transcript-cli transcribe input.mp4 --device cpu
```

**3. Out of memory**
```bash
# Use smaller model
transcript-cli transcribe input.mp4 --model small

# Use CPU processing
transcript-cli transcribe input.mp4 --device cpu

# Use lower precision
transcript-cli transcribe input.mp4 --compute-type int8
```

### Debug Mode

```bash
# Enable verbose logging
export LOG_LEVEL=DEBUG
transcript-cli transcribe input.mp4

# Check system information
transcript-cli info
```

## 📝 License

MIT License - see LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📞 Support

- **Issues**: GitHub Issues
- **Documentation**: This README
- **Examples**: See `examples/` directory

---

**Simplified from transcript-generator-cli for local batch processing**