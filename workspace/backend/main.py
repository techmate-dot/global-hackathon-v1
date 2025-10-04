from fastapi import FastAPI, File, UploadFile, Query
from fastapi.responses import FileResponse
from deepgram import DeepgramClient
import os
from dotenv import load_dotenv
import asyncio
import uuid

app = FastAPI()

# Load API key (you should put this in .env)
load_dotenv()
DEEPGRAM_API_KEY = os.getenv("DEEPGRAM_API_KEY")
dg_client = DeepgramClient(api_key=DEEPGRAM_API_KEY)


@app.get("/")
async def root():
    return {"message": "Speech-to-Text API is running 🚀"}


@app.post("/stt")
async def speech_to_text(file: UploadFile = File(...)):
    try:
        # Save uploaded audio temporarily
        temp_file = f"temp_{file.filename}_{uuid.uuid4().hex}"
        with open(temp_file, "wb") as f:
            f.write( await file.read())

        # Send to Deepgram for transcription
        with open(temp_file, "rb") as audio_file:
            response = dg_client.listen.v1.media.transcribe_file(request=audio_file.read(),model="nova-3",punctuate=True) # type: ignore
            print(response)

        # Extract transcript
        transcript = response.results.channels[0].alternatives[0].transcript # type: ignore
        # Clean up temporary file
        os.remove(temp_file)
        return {"transcript": transcript}

    except Exception as e:
        return {"error": str(e)}


@app.get("/tts")
async def text_to_speech(
    text: str = Query(..., description="Text to convert to speech"),
    voice: str = Query("aura-asteria-en", description="Deepgram TTS voice")
):
    output_file = "output.mp3"

    try:
        response = dg_client.speak.v1.audio.generate(
            text=text,
        ) # type: ignore
        # Save the audio file
        with open(output_file, "wb") as audio_file:
            for chunk in response:
                audio_file.write(chunk)

        return FileResponse(output_file, media_type="audio/wav", filename="speech.wav")

    except Exception as e:
        return {"error": str(e)}

