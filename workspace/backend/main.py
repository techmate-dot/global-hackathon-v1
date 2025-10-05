from fastapi import FastAPI, File, UploadFile, Query
from fastapi.responses import FileResponse
from deepgram import DeepgramClient
from google import genai
import os
from dotenv import load_dotenv
import asyncio
import uuid

app = FastAPI()

# Load API key (you should put this in .env)
load_dotenv()
DEEPGRAM_API_KEY = os.getenv("DEEPGRAM_API_KEY")
dg_client = DeepgramClient(api_key=DEEPGRAM_API_KEY)
client = genai.Client()

def text_to_story(text, style="creative", length="medium"):
    """
    Converts input text into a story using Gemini API.
    
    Args:
        text (str): The input text to convert into a story
        style (str): Story style - "creative", "dramatic", "humorous", "mysterious"
        length (str): Story length - "short", "medium", "long"
    
    Returns:
        str: Generated story based on the input text
    """
   
    
    # Define length guidelines
    length_guide = {
        "short": "around 150-200 words",
        "medium": "around 300-400 words",
        "long": "around 600-800 words"
    }
    
    # Create the prompt
    prompt = f"""
    Take the following text and transform it into a {style} story. 
    Use the context, themes, and elements from the text to create an engaging narrative.
    The story should be {length_guide.get(length, "around 300-400 words")}.
    
    Original text:
    {text}
    
    Create a compelling story that captures the essence of this text while adding 
    narrative elements like characters, dialogue, setting, and plot development where appropriate.
    """
    
    # Generate the story
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=prompt
    )
    
    return response.text

def text_to_speech_function(text, voice="aura-asteria-en", output_file="output.mp3"):
    """
    Converts text to speech using Deepgram TTS API.
    
    Args:
        text (str): Text to convert to speech
        voice (str): Deepgram TTS voice (default: "aura-asteria-en")
        output_file (str): Output file path (default: "output.mp3")
    
    Returns:
        str: Path to the generated audio file if successful, None if error
    """
    try:
        # Initialize Deepgram client
        dg_client = DeepgramClient()
        
        # Generate speech
        response = dg_client.speak.v1.audio.generate(
            text=text,
        )
        
        # Save the audio file
        with open(output_file, "wb") as audio_file:
            for chunk in response:
                audio_file.write(chunk)
        
        return output_file
    
    except Exception as e:
        print(f"Error: {str(e)}")
        return None


@app.get("/")
async def root():
    return {"message": "Speech-to-Text API is running 🚀"}


@app.post("/stt-with-story")
async def speech_to_text_with_story(file: UploadFile = File(...)):
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

        # Generate story
        story = text_to_story(transcript, style="creative", length="short")

        # Convert story to speech
        audio_path = text_to_speech_function(story, voice="aura-asteria-en", output_file="story_output.mp3")
        if audio_path:
              # Clean up temporary file
            os.remove(temp_file)
            return {"audio" : FileResponse(audio_path, media_type="audio/wav", filename="story.mp3"), "transcript": transcript, "story": story}
        else:
            return {"error": "Text-to-speech conversion failed"}
      


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

