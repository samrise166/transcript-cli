# Transcript CLI

> 使用 Faster-Whisper 进行本地批量音频/视频转录

一个简化的命令行工具，用于批量转录音频和视频文件。这是原始 transcript-generator-cli 的精简版本，专注于本地处理，无需复杂的基础架构，如数据库、消息队列或 Web API。

## ✨ 特性

- **本地处理**：无需 API 服务器或数据库
- **批量转录**：一次处理多个文件
- **多种格式**：支持音频和视频文件
- **多种输出**：SRT、VTT、TXT、JSON、ASS 字幕格式
- **GPU 加速**：CUDA 支持，加快处理速度
- **进度跟踪**：丰富的进度条和状态显示
- **可配置**：灵活的配置系统
- **易于安装**：使用 pip 或 Docker 简单设置

## 🚀 快速开始

### 安装

#### 方式 1：使用安装脚本（推荐）

```bash
# Unix/Linux/macOS
chmod +x scripts/install-cli.sh
./scripts/install-cli.sh

# Windows
scripts\install-cli.bat
```

#### 方式 2：手动安装

```bash
# 克隆仓库
git clone <repository-url>
cd transcript-generator-cli

# 创建虚拟环境
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 安装依赖
pip install -r requirements-cli.txt

# 安装包
pip install -e .
```

#### 方式 3：直接使用

```bash
# 不安装，使用独立脚本
python transcript-cli-new.py --help
```

### 基本用法

```bash
# 转录单个文件
transcript-cli transcribe input.mp4 output.srt

# 批量处理目录
transcript-cli transcribe ./audio_files ./transcripts --recursive

# 指定模型和格式
transcript-cli transcribe input.mp4 output.vtt --model large --format vtt

# 使用自定义语言处理
transcript-cli transcribe input.mp4 output.srt --language zh --model medium
```

## 📋 命令参考

### 主要命令

```bash
# 转录文件
transcript-cli transcribe INPUT_PATH [OUTPUT_PATH] [OPTIONS]

# 显示可用模型
transcript-cli models

# 管理配置
transcript-cli config [OPTIONS]

# 显示系统信息
transcript-cli info

# 显示版本
transcript-cli version
```

### 转录选项

```bash
-m, --model TEXT           Whisper 模型大小 [tiny|base|small|medium|large|large-v2|large-v3]
-f, --format TEXT          输出格式 [srt|vtt|txt|json|ass]
-l, --language TEXT        语言代码 (如 en, zh, fr) 或 "auto"
-r, --recursive            递归处理目录
-p, --parallel INTEGER     并行工作进程数 (默认: 4)
--device TEXT              处理设备 [auto|cpu|cuda]
--compute-type TEXT        计算精度 [float16|float32|int8] (默认: float16)
```

### 配置命令

```bash
# 显示当前配置
transcript-cli config --show

# 设置配置值
transcript-cli config models.default large
transcript-cli config device.type cuda

# 重置为默认值
transcript-cli config --reset
```

## 🔧 配置

配置通过 YAML 文件和环境变量进行管理。

### 配置文件位置

- **用户配置**: `~/.config/transcript-cli/config.yaml` (Linux/macOS)
- **用户配置**: `%APPDATA%/transcript-cli/config.yaml` (Windows)
- **项目配置**: `./config/default.yaml`
- **环境变量**: `.env` 文件

### 配置示例

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

### 环境变量

```bash
# 模型设置
WHISPER_MODEL_SIZE=medium
WHISPER_DEVICE=auto
WHISPER_COMPUTE_TYPE=float16

# 处理设置
MAX_WORKERS=4
LOG_LEVEL=INFO

# 路径设置
INPUT_DIR=./data/input
OUTPUT_DIR=./data/output

# 进度和缓存设置
HF_HUB_DISABLE_PROGRESS_BARS=false
TRANSFORMERS_VERBOSITY=info
HF_HUB_CACHE=./data/models
HUGGINGFACE_HUB_CACHE=./data/models
```

## 🐳 Docker 使用

### 构建和运行

```bash
# 构建容器
docker build -f Dockerfile-cli -t transcript-cli .

# 或从 GitHub Container Registry 拉取
docker pull ghcr.io/twinrise/transcript-generator-cli:1.0.0

# 使用卷挂载运行
docker run -v ./data:/app/data transcript-cli transcribe /app/data/input /app/data/output --recursive
```

### Docker Compose

```bash
# 根据需要编辑 docker-compose-cli.yml
docker-compose -f docker-compose-cli.yml up
```

### GPU 支持

```bash
# NVIDIA GPU 支持，带资源限制
docker run --gpus all --memory="12g" --cpus="20" -v ./data:/app/data transcript-cli transcribe /app/data/input /app/data/output --device cuda
```

## 🎯 支持的格式

### 输入格式

**音频**: MP3, WAV, FLAC, M4A, AAC, OGG, WMA
**视频**: MP4, AVI, MOV, MKV, WebM, FLV, M4V

### 输出格式

- **SRT**: SubRip 字幕格式
- **VTT**: WebVTT 字幕格式
- **TXT**: 纯文本转录
- **JSON**: 带时间戳的结构化 JSON
- **ASS**: Advanced SubStation Alpha 格式

## 🏆 模型信息

| 模型 | 大小 | 速度 | 准确度 | GPU 内存 | 下载时间 |
|------|------|------|--------|-----------|----------|
| tiny | 39 MB | 32x | 低 | 1 GB | 1-2 分钟 |
| base | 74 MB | 16x | 中等 | 1 GB | 2-3 分钟 |
| small | 244 MB | 8x | 良好 | 2 GB | 3-5 分钟 |
| medium | 769 MB | 6x | 高 | 2 GB | 5-10 分钟 |
| large | 1550 MB | 4x | 非常高 | 4 GB | 10-20 分钟 |
| large-v2 | 1550 MB | 4x | 非常高 | 4 GB | 10-20 分钟 |
| large-v3 | 1550 MB | 4x | 非常高 | 4 GB | 10-20 分钟 |

**注意**: 模型在首次下载后会被缓存。CLI 对首次模型下载使用串行处理以避免冲突，然后在后续运行中切换到并行处理。

## 📊 示例

### 基础转录

```bash
# 使用默认设置转录单个文件
transcript-cli transcribe interview.mp4

# 指定输出位置和格式
transcript-cli transcribe interview.mp4 interview.srt --format srt
```

### 批量处理

```bash
# 处理目录中的所有文件
transcript-cli transcribe ./recordings ./transcripts

# 使用特定模型进行递归处理
transcript-cli transcribe ./media ./output --recursive --model large

# 并行处理
transcript-cli transcribe ./audio ./output --parallel 2
```

### 高级用法

```bash
# 中文语言，大模型
transcript-cli transcribe chinese_audio.mp3 --language zh --model large

# GPU 处理，高精度
transcript-cli transcribe video.mp4 --device cuda --compute-type float16

# JSON 输出，包含元数据
transcript-cli transcribe audio.wav output.json --format json
```

## 🛠️ 开发

### 项目结构

```
src/transcript_cli/
├── __init__.py           # 包初始化
├── main.py               # CLI 入口点
├── cli/                  # 命令行界面
│   ├── commands.py       # CLI 命令
│   └── progress.py       # 进度显示
├── core/                 # 核心功能
│   ├── transcriber.py    # 转录引擎
│   └── processor.py      # 批处理器
└── utils/                # 工具
    ├── config.py         # 配置管理
    ├── exceptions.py     # 异常类
    └── formats.py        # 格式转换
```

### 运行测试

```bash
# 安装开发依赖
pip install -e ".[dev]"

# 运行测试
pytest

# 运行覆盖率测试
pytest --cov=transcript_cli
```

### 代码格式化

```bash
# 格式化代码
black src/

# 检查格式
black --check src/
```

## 🔍 故障排除

### 常见问题

**1. 找不到 FFmpeg**
```bash
# 安装 ffmpeg
sudo apt install ffmpeg  # Ubuntu/Debian
brew install ffmpeg      # macOS
choco install ffmpeg     # Windows (Chocolatey)
```

**2. 未检测到 CUDA**
```bash
# 检查 CUDA 安装
nvidia-smi
python -c "import torch; print(torch.cuda.is_available())"

# 使用 CPU 回退
transcript-cli transcribe input.mp4 --device cpu
```

**3. 内存不足**
```bash
# 使用较小的模型
transcript-cli transcribe input.mp4 --model small

# 使用 CPU 处理
transcript-cli transcribe input.mp4 --device cpu

# 使用较低精度
transcript-cli transcribe input.mp4 --compute-type int8
```

### 调试模式

```bash
# 启用详细日志
export LOG_LEVEL=DEBUG
transcript-cli transcribe input.mp4

# 检查系统信息
transcript-cli info
```

## 📝 许可证

MIT 许可证 - 详见 LICENSE 文件。

## 🤝 贡献

1. Fork 仓库
2. 创建功能分支
3. 进行更改
4. 如适用，添加测试
5. 提交拉取请求

## 📞 支持

- **问题**: GitHub Issues
- **文档**: 本 README
- **示例**: 请参见 `examples/` 目录

---

**从 transcript-generator-cli 简化而来，专用于本地批量处理** 