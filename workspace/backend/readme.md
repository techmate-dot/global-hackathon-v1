# Speech-to-Text Story Generator API

A FastAPI application that converts speech to text, generates creative stories using AI, and converts those stories back to speech.

## Features

- **Speech-to-Text**: Transcribe audio files using Deepgram's Nova-3 model
- **AI Story Generation**: Transform text into creative stories using Google's Gemini AI
- **Text-to-Speech**: Convert text/stories to natural-sounding audio using Deepgram TTS
- **Complete Pipeline**: Upload audio → Get transcript → Generate story → Receive audio story

---

## Prerequisites

- Python 3.8 or higher
- Deepgram API Key
- Google Gemini API Key

---

## Installation

### 1. Clone or Download the Project

```bash
# If using git
git clone <your-repo-url>
cd <project-folder>
```

### 2. Install Dependencies

```bash
pip install fastapi uvicorn deepgram-sdk google-generativeai python-dotenv python-multipart
```

### 3. Set Up Environment Variables

Create a `.env` file in the project root:

```env
DEEPGRAM_API_KEY=your_deepgram_api_key_here
GEMINI_API_KEY=your_gemini_api_key_here
```

**How to get API keys:**

- **Deepgram**: Sign up at [https://deepgram.com](https://deepgram.com) and get your API key from the dashboard
- **Gemini**: Get your key from [https://ai.google.dev](https://ai.google.dev)

### 4. Run the Server

```bash
uvicorn main:app --reload
```

The API will be available at: `http://localhost:8000`

---

## API Endpoints

### 1. **Root Endpoint** - Check if API is running

**GET** `/`

```bash
curl http://localhost:8000/
```

**Response:**
```json
{
  "message": "Speech-to-Text API is running 🚀"
}
```

---

### 2. **Text-to-Speech** - Convert text to audio

**GET** `/tts`

**Parameters:**
- `text` (required): Text to convert to speech
- `voice` (optional): Voice model (default: "aura-asteria-en")

**Example:**

```bash
curl "http://localhost:8000/tts?text=Hello%20World&voice=aura-asteria-en" --output speech.mp3
```

**Using Python:**

```python
import requests

response = requests.get(
    "http://localhost:8000/tts",
    params={
        "text": "Hello! This is a test of text to speech.",
        "voice": "aura-asteria-en"
    }
)

with open("output.mp3", "wb") as f:
    f.write(response.content)
```

---

### 3. **Speech-to-Text with Story** - Complete Pipeline

**POST** `/stt-with-story`

Uploads an audio file, transcribes it, generates a creative story, and returns the story as audio.

**Parameters:**
- `file` (required): Audio file (MP3, WAV, M4A, etc.)

**Example using cURL:**

```bash
curl -X POST "http://localhost:8000/stt-with-story" \
  -F "file=@your_audio_file.mp3" \
  --output response.json
```

**Using Python:**

```python
import requests

# Upload audio file
with open("recording.mp3", "rb") as audio_file:
    files = {"file": audio_file}
    response = requests.post(
        "http://localhost:8000/stt-with-story",
        files=files
    )
    
    result = response.json()
    print("Transcript:", result["transcript"])
    print("Story:", result["story"])
    
    # The audio file is saved as "story_output.mp3" on the server
```

**Using Postman:**
1. Set method to `POST`
2. URL: `http://localhost:8000/stt-with-story`
3. Go to "Body" tab
4. Select "form-data"
5. Add key: `file`, type: `File`
6. Upload your audio file
7. Click "Send"

**Response:**

```json
{
  "audio": "<FileResponse object>",
  "transcript": "Your transcribed speech here",
  "story": "Once upon a time... [generated creative story]"
}
```

---

## Story Customization

The `text_to_story` function supports customization:

**Style options:**
- `creative` (default)
- `dramatic`
- `humorous`
- `mysterious`

**Length options:**
- `short` (150-200 words)
- `medium` (300-400 words, default)
- `long` (600-800 words)

To customize, modify the function call in the code:

```python
story = text_to_story(transcript, style="mysterious", length="long")
```

---

## Voice Options (Deepgram TTS)

Available voices include:
- `aura-asteria-en` (default - female, expressive)
- `aura-luna-en` (female, warm)
- `aura-stella-en` (female, professional)
- `aura-athena-en` (female, confident)
- `aura-hera-en` (female, authoritative)
- `aura-orion-en` (male, deep)
- `aura-arcas-en` (male, casual)
- `aura-perseus-en` (male, professional)
- `aura-angus-en` (male, narrative)
- `aura-orpheus-en` (male, storytelling)
- `aura-helios-en` (male, energetic)
- `aura-zeus-en` (male, commanding)

---

## Troubleshooting

### Error: "DEEPGRAM_API_KEY not found"
- Make sure you created the `.env` file
- Check that the API key is correctly set
- Restart the server after adding the `.env` file

### Error: "Module not found"
```bash
pip install fastapi uvicorn deepgram-sdk google-generativeai python-dotenv python-multipart
```

### Audio file not uploading
- Check file format (MP3, WAV, M4A are supported)
- Ensure file size is reasonable (under 25MB recommended)
- Check server logs for detailed error messages

### Server not starting
```bash
# Make sure no other app is using port 8000
uvicorn main:app --reload --port 8001
```

---

## Example Workflow

1. **Record or prepare an audio file** with some content (e.g., "I love exploring new places and trying different foods")

2. **Upload to the API:**
```python
import requests

with open("my_recording.mp3", "rb") as f:
    response = requests.post(
        "http://localhost:8000/stt-with-story",
        files={"file": f}
    )
    
data = response.json()
print("Original:", data["transcript"])
print("\nStory:", data["story"])
```

3. **The API will:**
   - Transcribe your audio
   - Generate a creative story based on the transcription
   - Convert the story to speech
   - Return everything in the response

4. **Download the audio story** (saved as `story_output.mp3` on the server)

---

## Project Structure

```
project/
├── main.py              # Main FastAPI application
├── .env                 # Environment variables (API keys)
├── README.md            # This file
├── temp_*               # Temporary uploaded audio files (auto-deleted)
├── output.mp3           # TTS output from /tts endpoint
└── story_output.mp3     # Story audio from /stt-with-story
```

---

## API Documentation

Once the server is running, visit:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

These provide interactive API documentation where you can test endpoints directly in your browser.

---

## Notes

- Temporary audio files are automatically cleaned up after processing
- The API uses Gemini 2.5 Flash for fast story generation
- Deepgram Nova-3 provides high-accuracy transcription
- All responses include proper error handling

---

## Need Help?

If you encounter issues:
1. Check the server logs in your terminal
2. Verify your API keys are valid
3. Ensure all dependencies are installed
4. Check the audio file format is supported

Happy storytelling! 🎙️📖🔊