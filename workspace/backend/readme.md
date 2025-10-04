# Speech-to-Text & Text-to-Speech API

A FastAPI-based REST API that provides speech-to-text (STT) and text-to-speech (TTS) capabilities using Deepgram's AI models.

## Features

- 🎤 **Speech-to-Text**: Convert audio files to text transcriptions
- 🔊 **Text-to-Speech**: Generate natural-sounding speech from text
- ⚡ **Fast & Accurate**: Powered by Deepgram's Nova-3 model
- 🚀 **Easy to Use**: Simple REST API endpoints

## Prerequisites

- Python 3.10 or higher
- Deepgram API key ([Get one free](https://console.deepgram.com/signup))

## Installation

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd <your-repo-name>
```

2. **Install dependencies**
```bash
pip install fastapi uvicorn deepgram-sdk python-dotenv python-multipart
```

3. **Set up environment variables**

Create a `.env` file in the project root:
```env
DEEPGRAM_API_KEY=your_api_key_here
```

## Usage

### Start the Server

```bash
uvicorn main:app --reload
```

The API will be available at `http://localhost:8000`

### API Documentation

Once the server is running, visit:
- **Interactive docs**: http://localhost:8000/docs
- **Alternative docs**: http://localhost:8000/redoc

## API Endpoints

### 1. Health Check
```http
GET /
```

**Response:**
```json
{
  "message": "Speech-to-Text API is running 🚀"
}
```

### 2. Speech-to-Text (STT)

Convert audio files to text.

```http
POST /stt
```

**Parameters:**
- `file` (form-data): Audio file (WAV, MP3, etc.)

**Example using cURL:**
```bash
curl -X POST "http://localhost:8000/stt" \
  -H "accept: application/json" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@audio.wav"
```

**Response:**
```json
{
  "transcript": "Hello, this is a sample transcription."
}
```

**Supported Audio Formats:**
- WAV
- MP3
- FLAC
- OGG
- And more...

### 3. Text-to-Speech (TTS)

Generate speech audio from text.

```http
GET /tts?text=Your+text+here&voice=aura-asteria-en
```

**Parameters:**
- `text` (query, required): Text to convert to speech
- `voice` (query, optional): Voice model to use
  - Default: `aura-asteria-en`
  - Options: See [Deepgram voices](https://developers.deepgram.com/docs/tts-models)

**Example using cURL:**
```bash
curl -X GET "http://localhost:8000/tts?text=Hello%20world&voice=aura-asteria-en" \
  --output speech.wav
```

**Example using Python:**
```python
import requests

response = requests.get(
    "http://localhost:8000/tts",
    params={
        "text": "Hello, this is a test",
        "voice": "aura-asteria-en"
    }
)

with open("output.mp3", "wb") as f:
    f.write(response.content)
```

**Available Voices:**
- `aura-asteria-en` (Default - Friendly female)
- `aura-luna-en` (Warm female)
- `aura-stella-en` (Professional female)
- `aura-athena-en` (Confident female)
- `aura-hera-en` (Authoritative female)
- `aura-orion-en` (Deep male)
- `aura-arcas-en` (Natural male)
- `aura-perseus-en` (Strong male)
- `aura-angus-en` (Friendly male)
- `aura-orpheus-en` (Smooth male)
- `aura-helios-en` (Energetic male)
- `aura-zeus-en` (Commanding male)

## Project Structure

```
.
├── main.py           # FastAPI application
├── .env              # Environment variables (create this)
├── .gitignore        # Git ignore file
├── requirements.txt  # Python dependencies
└── README.md         # This file
```

## Error Handling

All endpoints return error messages in the following format:

```json
{
  "error": "Error description here"
}
```

Common errors:
- **Invalid API key**: Check your `.env` file
- **Unsupported audio format**: Use WAV, MP3, or other supported formats
- **File too large**: Deepgram has file size limits

## Development

### Install Development Dependencies

```bash
pip install -r requirements.txt
```

### Run in Development Mode

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `DEEPGRAM_API_KEY` | Your Deepgram API key | Yes |

## Security Notes

⚠️ **Important:**
- Never commit your `.env` file to version control
- Add `.env` to your `.gitignore`
- Keep your API key secure
- Use environment variables in production

## Requirements.txt

```txt
fastapi==0.104.1
uvicorn==0.24.0
deepgram-sdk==3.2.0
python-dotenv==1.0.0
python-multipart==0.0.6
```

## License

[Your License Here]

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues and questions:
- Deepgram Documentation: https://developers.deepgram.com/
- FastAPI Documentation: https://fastapi.tiangolo.com/

## Acknowledgments

- Powered by [Deepgram](https://deepgram.com/)
- Built with [FastAPI](https://fastapi.tiangolo.com/)