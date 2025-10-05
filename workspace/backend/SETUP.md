# 🎙️ Echoes Backend Setup Guide

This guide will help you set up the FastAPI backend for the Echoes app, which provides speech-to-text, story generation, and text-to-speech capabilities.

## 🔑 Required API Keys

You'll need to obtain these API keys:

### 1. Deepgram API Key (Speech-to-Text & Text-to-Speech)
- Visit: https://console.deepgram.com/signup
- Sign up for a free account
- Get $200 worth of free credits
- Copy your API key from the dashboard

### 2. Google Gemini API Key (Story Generation)
- Visit: https://aistudio.google.com/app/apikey
- Sign in with your Google account
- Click "Create API Key"
- Copy the generated key

## 🚀 Quick Setup

1. **Navigate to the backend directory:**
   ```bash
   cd workspace/backend
   ```

2. **Update the .env file:**
   Open `.env` and replace the placeholder values:
   ```env
   DEEPGRAM_API_KEY=your_actual_deepgram_key_here
   GOOGLE_GEMINI_API_KEY=your_actual_gemini_key_here
   ```

3. **Run the startup script:**
   ```bash
   ./start.sh
   ```

## 📋 Manual Setup (Alternative)

If you prefer manual setup:

1. **Create virtual environment:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Start the server:**
   ```bash
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```

## 🌐 API Endpoints

Once running, the backend provides:

- **Base URL:** http://localhost:8000
- **API Docs:** http://localhost:8000/docs
- **Health Check:** GET http://localhost:8000/

### Main Endpoints:

1. **Upload Audio & Generate Story**
   - POST `/stt-with-story`
   - Upload audio file, get story with TTS audio back

2. **Text-to-Speech**
   - GET `/tts?text=your_text&voice=aura-asteria-en`
   - Convert text to speech audio

## 🔧 Flutter Integration

The Flutter app is already configured to connect to `http://localhost:8000`. Make sure:

1. Backend server is running on port 8000
2. Your device/emulator can reach localhost
3. For physical devices, you may need to use your computer's IP address instead of localhost

## ⚠️ Troubleshooting

### "Module not found" errors:
```bash
pip install deepgram-sdk google-generativeai python-dotenv
```

### API key errors:
- Check that your .env file has the correct API keys
- Ensure no extra spaces or quotes around the keys
- Verify your API keys are active on the respective platforms

### Connection errors from Flutter:
- For Android emulator: Use `http://10.0.2.2:8000`
- For iOS simulator: Use `http://localhost:8000`
- For physical devices: Use `http://YOUR_COMPUTER_IP:8000`

## 📊 Testing the Backend

You can test the API using the interactive docs at http://localhost:8000/docs or with curl:

```bash
# Test TTS
curl "http://localhost:8000/tts?text=Hello world" --output test.mp3

# Test file upload (replace with actual audio file)
curl -X POST "http://localhost:8000/stt-with-story" \
     -F "file=@your_audio_file.m4a" \
     --output story_audio.mp3
```

## 🎯 Next Steps

1. Set up your API keys in the .env file
2. Run the backend server
3. Test the Flutter app recording functionality
4. The app should now upload recordings and play back generated stories!