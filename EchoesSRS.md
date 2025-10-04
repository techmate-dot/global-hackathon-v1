# Echoes — Product Requirements Document (PRD)

**Working name:** Echoes

**Tagline:** Turn conversations into timeless family stories.

**Purpose:** Build a polished Flutter prototype that captures grandparents’ spoken memories and converts them into (A) polished memory cards and (B) child-friendly bedtime stories. The prototype will emphasize a Duolingo-style gamified prompt system, high polish, and a demo-ready end-to-end flow using DeepGram (or Google Cloud STT) for Speech-to-Text, Supabase for Auth/Storage, and serverless Edge Functions for orchestration.

---

## 1. Vision & Core Value

Echoes preserves intergenerational knowledge by making it simple and delightful for grandparents to share life stories and for families to consume them as both archive posts and bedtime stories. The core value is emotional preservation and intergenerational bonding—delivered with high polish and playful, gamified UX inspired by Duolingo.

---

## 2. Target Users & Personas

* **Family Historian (Grandparent)**: Wants easy, low-friction way to tell stories; values accessibility (large buttons, voice-first).
* **Bedtime Reader (Parent / Child)**: Wants short, magical, narrated stories derived from family memories.
* **Archivist (Adult Family Member)**: Wants searchable, exportable, private family archive.

---

## 3. Success Criteria (aligned to judging rubric)

* **Craft (1–10):** Demonstrate a single feature executed exceptionally well: record → transcribe → polished memory + bedtime story → play. App must be smooth, accessible, and bug-free for demo.
* **Novelty (1–10):** The Duolingo-style gamified prompts + transformation into bedtime stories should feel original and unexpected.
* **Utility (1–10):** The product must solve the real problem of storing oral histories and making them usable by children and families.
* **Taste (1–10):** Design must be warm, playful, and refined. Use Duolingo-inspired mascot, bright palette, micro-interactions, and clear copy to impress judges.

Final score: sum of the four dimensions.

---

## 4. MVP Scope (hackathon-focused)

**MVP must include:**

1. Authentication & family creation (Supabase).
2. One-tap recording (WAV/FLAC), local save and upload to Supabase.
3. Processing pipeline (Edge Function / FastAPI): call DeepGram (or Google STT) to transcribe, then run an LLM-based `polish` step to create an adult memory and a bedtime story.
4. Bedtime story playback using `flutter_tts` (platform) and illustrated flipbook UI (use pre-generated illustrations or Stable Horde).
5. Gamified prompt system (Daily prompt + streaks + badges) in Duolingo style.
6. Simple Memory Library UI (list + detail + convert to bedtime story).

**Optional but valuable:** PDF export, shareable family-only links, high-quality TTS via server-side Coqui.

---

## 5. Tech Stack (preferred)

### Frontend

* Flutter (stable channel)
* go_router for navigation
* provider for state management
* flutter_sound for recording
* flutter_tts for playback
* hive for local cache
* dio for HTTP
* cached_network_image
* supabase_flutter for auth/storage integration

### Backend & Orchestration

* Supabase (Auth, Postgres, Storage) — main BaaS
* Supabase Edge Functions (or Vercel serverless) for secure third-party calls (DeepGram, LLM endpoints, Stable Horde)
* Processing service (FastAPI) — optional if you prefer a single server for heavy tasks

### ML / 3rd party

* Speech-to-text: **DeepGram** (preferred) or Google Cloud Speech-to-Text
* LLM for polishing: Hugging Face Inference API / OpenAI (if credits) or local LLM (small) — keep decisions pluggable
* Image generation: Stable Horde / pre-generated Stable Diffusion assets
* TTS (backup): platform TTS via `flutter_tts`; advanced: Coqui TTS server

### Dev tooling

* Flutter SDK, Dart, Supabase CLI, Docker (for local dev of edge functions or FastAPI), Make (Makefile) to automate dev tasks

---

## 6. Architecture & Data Flow

1. **Record (client)** → save locally and upload to Supabase `audio-raw` bucket.
2. **Start transcribe (Edge Function)** — client POSTs `memory_id` to `start-transcribe` endpoint.
3. **Edge Function** downloads audio, calls DeepGram for transcription (server-side API key), saves transcript to DB.
4. **Polish step**: Edge Function calls LLM or runs local polishing template to produce `polished_text` and `bedtime_story_text` and updates DB.
5. **Image generation (async)**: request illustration generation (optional). Store images in `images` bucket.
6. **Client** listens to Realtime DB changes and updates UI state; when published, child-friendly story appears in Storybook.

State transitions: `draft` → `uploaded` → `transcribing` → `transcribed` → `polishing` → `polished` → `published`/`failed`.

---

## 7. Data Model

**User**: `id, email, name, avatar_url, created_at`

**Family**: `id, name, owner_id, created_at`

**Memory**: `id, family_id, author_id, title, raw_audio_url, transcript, polished_text, bedtime_story_text, illustration_urls[], tts_audio_url, tags[], is_child_friendly, privacy, state, created_at, processed_at`

**ExportJob**: `id, family_id, memory_ids[], status, result_url, created_at`

Supabase storage buckets: `audio-raw`, `audio-tts`, `images`, `exports`.

---

## 8. API Contracts (Edge Functions / FastAPI)

> All calls authenticate using Supabase JWT. Edge Functions validate tokens.

### `POST /api/v1/start-transcribe`

**Request**

```json
{ "memory_id": "uuid", "audio_path": "supabase://audio-raw/abc.wav", "language": "en-US" }
```

**Response**

```json
{ "job_id":"string", "status":"queued" }
```

### `POST /api/v1/polish`

**Request**

```json
{ "memory_id":"uuid", "transcript":"...", "target":"adult|bedtime", "reading_level":"5-7" }
```

**Response**

```json
{ "memory_id":"uuid", "polished_text":"...", "bedtime_story_text":"...", "tags":["childhood"], "status":"completed" }
```

### `POST /api/v1/generate-image`

**Request**

```json
{ "memory_id":"uuid", "prompt":"A watercolor illustration of a grandfather telling a story to a child, soft warm palette", "style":"watercolor", "count":3 }
```

**Response**

```json
{ "images":[{"url":"..."}], "status":"ready" }
```

### `POST /api/v1/tts` (optional high-quality server-side)

**Request**

```json
{ "memory_id":"uuid", "text":"Once upon a time...", "voice":"warm_female_v1", "format":"mp3" }
```

**Response**

```json
{ "tts_audio_url":"supabase://audio-tts/story123.mp3", "duration_seconds":120 }
```

---

## 9. UX / UI Requirements — Duolingo-style theme

**Design pillars:** playful, encouraging, high-contrast readability for elders, bright brand colors, tiny mascot (friendly owl-like creature), gamified microcopy and animations.

**Design tokens:**

* Primary: `#6CC644` (green) — Duolingo-ish friendly green
* Accent: `#FFB86B` (warm orange)
* Secondary: `#4A90E2` (calm blue)
* Background: `#FFFDF7` (warm off-white)
* Surface: `#FFFFFF` (cards)
* Text primary: `#0B1F2D` (very dark)
* Font family: system serif for story text (e.g., "Merriweather" or "Georgia") and sans for UI (e.g., "Inter").

**Mascot & micro-interactions:**

* Small mascot sits on the recording screen and cheers when a memory is saved.
* Streaks indicator on home: "+1 Memory Today" with confetti.
* Gentle onboarding tutorial with big, accessible copy.

**Key screens:**

1. **Onboarding / Family setup** — large CTAs, optional tutorial.
2. **Home / Prompt feed (Duolingo-style)** — daily card with a question prompt, big green "Record" button, streak & progress ring.
3. **Record screen** — large circular record button, waveform, mascot animation, skip / stop actions.
4. **Processing screen** — friendly progress states ("Whispering to the cloud..."), ability to cancel.
5. **Memory detail** — polished adult memory card (typography, margin), tags, convert to bedtime story button.
6. **Storybook** — flipbook UI, page-turn animation, illustrated background, play/pause narrator, reading level toggle.
7. **Library / Timeline** — Memory tree visualization with branches growing as stories added.
8. **Settings / Privacy** — sharing controls, delete, export.

**Copy examples:**

* Prompt: "Tell me about your favorite childhood hideout."
* On success toast: "Beautiful — we saved that memory! You've kept your streak alive. 🌿"
* Empty library nudge: "No memories yet — try answering today's prompt and watch your family tree grow!"

---

## 10. Component & Implementation Details (Flutter)

**Widgets/components to build:**

* `PromptCard` (home feed)
* `RecorderWidget` (waveform, record/stop)
* `ProcessingStatus` (state machine UI)
* `MemoryCard` (polished text view with tags)
* `StoryFlipbook` (paged builder + TTS controls)
* `MemoryTree` (timeline/graph view)
* `StreakBadge` (shows daily streak & pop animation)

**State management:** Use `provider` with `AuthProvider`, `FamilyProvider`, `RecordProvider`, `MemoryProvider`.

**Routing:** Use `go_router` with deep links for sharing (e.g., `/memory/:id`).

---

## 11. Acceptance Criteria (for each major feature)

**Recording Flow:**

* Given a logged-in user, when they press "Record" and speak for up to 3 minutes, the app saves locally and uploads successfully; memory state moves to `uploaded`.

**Transcription Flow:**

* Given an audio file, the processing service returns a transcript with >80% word confidence for clear speech in English (for demo use DeepGram/medium model)..

**Polish & Story Conversion:**

* Given a transcript, the `polish` API returns an adult memory and a bedtime story less than 300 words, maintaining factual anchors.

**Storybook Playback:**

* Tapping Play reads the story with platform TTS; user can pause/resume and switch reading level.

**Gamification:**

* Completing 1+ memory per day increments streak; streak persists and unlocks a badge at 7-day streak.

---

## 12. Security & Privacy (developer must implement)

* Use Supabase Auth; verify JWT in all Edge Functions.
* Never embed DeepGram/LLM keys in client; store secrets in serverless environment variables.
* Consent modal before first recording & clear sharing settings.
* Provide delete API that cascades to remove storage objects.

---

## 13. Roadmap & Prioritization

**Phase 1 — Hackathon MVP (48–72 hours)**

* Supabase setup, Flutter skeleton, record screen (local), upload + start-transcribe edge function (DeepGram), canned polish outputs for quick demo, storybook with platform TTS, pre-generated illustrations, Duolingo-style prompt card and streak badge.

**Phase 2 — Post-hackathon (2–6 weeks)**

* LLM polishing integration, live image generation, server-side TTS, export PDF, full privacy controls, testing & QA.

**Phase 3 — Production**

* Scale processing, add multi-language, transcription diarization, voice-cloning (with consent), advanced search & analytics, paid subscriptions for printed books.

---

## 14. Metrics & KPIs (for judges/product)

* End-to-end time (record → polished story) — ideally < 30s for short clips in demo.
* Number of memories saved per family (engagement).
* Streak retention rate (measure gamification).
* Average story playback completions per session (utility).

---

## 15. Testing & QA Plan

* Unit tests: domain logic (Dart)
* Widget tests: main UI flows
* Integration tests: login → record → upload → transcribe (mock DeepGram) → polish
* Backend tests: Edge Function simulations (mock DeepGram/LLM responses)

---

## 16. Makefile & Prototype Automation (detailed prompt + Make targets)

Below is a rich Makefile and companion shell scripts that will bootstrap and run your prototype locally. Use `make` to orchestrate local dev: start Supabase (if using supabase CLI), run Flutter, run Edge Functions, and run a lightweight FastAPI mock worker for transcribe/polish during development.

### Files to create alongside Makefile

* `Makefile` (see below)
* `scripts/start_supabase.sh` (optional)
* `scripts/start_edge_functions.sh` (optional)
* `scripts/mock_processor.py` (FastAPI mock server for DeepGram responses)
* `.env.local` (local env variables for Supabase, DEEPGRAM_KEY placeholder)

### Example `Makefile`

```makefile
# Echoes Makefile - Dev & Demo tasks
.PHONY: help install deps start flutter run clean supabase start-mock stop-mock build-apk

help:
	@echo "Available targets: install deps, start, flutter, run, supabase, start-mock, stop-mock, build-apk"

install-deps:
	# Install Python deps for mock processor
	python3 -m venv .venv || true
	. .venv/bin/activate && pip install -r requirements.txt
	# Flutter pub get
	flutter pub get

start: supabase start-mock flutter

supabase:
	# Start Supabase locally (requires supabase CLI) - optional
	if command -v supabase >/dev/null 2>&1; then \
		supabase start || true; \
	else \
		echo "Supabase CLI not installed - skipping local start"; \
	fi

start-mock:
	# Start mock processing service (FastAPI) in background
	. .venv/bin/activate && uvicorn scripts.mock_processor:app --reload --port 8001 &
	@echo "Mock processor started on http://localhost:8001"

stop-mock:
	# Kill uvicorn process (naive)
	pkill -f uvicorn || true
	@echo "Mock processor stopped"

flutter:
	# Run Flutter in debug mode
	flutter run -d all

run:
	# Alias to run the app with mock infra
	make start

build-apk:
	flutter build apk --split-per-abi

clean:
	rm -rf .venv
	flutter clean

```

### `scripts/mock_processor.py` (FastAPI minimal mock for local dev)

```python
# scripts/mock_processor.py
from fastapi import FastAPI, UploadFile, File
from pydantic import BaseModel
import uvicorn

app = FastAPI()

class PolishRequest(BaseModel):
    memory_id: str
    transcript: str
    target: str = "adult"

@app.post('/api/v1/start-transcribe')
async def start_transcribe(memory_id: str):
    # naive mock: return queued
    return {"job_id": "mock-job-123", "status": "queued"}

@app.post('/api/v1/polish')
async def polish(req: PolishRequest):
    # naive polish: echo back
    adult = req.transcript.capitalize() + "\n\n(Polished)"
    bedtime = "Once upon a time... " + req.transcript[:140]
    return {"memory_id": req.memory_id, "polished_text": adult, "bedtime_story_text": bedtime, "tags": ["demo"], "status": "completed"}

if __name__ == '__main__':
    uvicorn.run(app, host='0.0.0.0', port=8001)
```

### `.env.local` sample

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=ANON_KEY
SUPABASE_SERVICE_ROLE_KEY=SERVICE_ROLE_KEY
DEEPGRAM_API_KEY=replace_with_key_or_leave_blank_for_mock
PROCESSOR_URL=http://localhost:8001
```

### Development workflow using `make`

1. `make install-deps` — install python venv & flutter deps.
2. `make supabase` — optionally start supabase locally (if available).
3. `make start-mock` — start local processing mock server.
4. `make flutter` — run Flutter app; app configured to call `PROCESSOR_URL` for `start-transcribe` and `polish`.

This Makefile allows a single-command demo orchestration for a hackathon judge run.

---

## 17. Developer Prompt (detailed) — use this with an AI assistant or to brief a developer to create the prototype

**Goal:** Create a Flutter prototype for Echoes (Memory Keeper → Bedtime Stories) that demonstrates: record → transcribe (mock or DeepGram) → polish → bedtime story flipbook + TTS. Prioritize UX polish and Duolingo-inspired gamification.

**Deliverables:**

1. Flutter app with the screens listed in this PRD.
2. Supabase project with tables & storage buckets for `users`, `families`, `memories`.
3. Edge Function or mock processing service implementing `/api/v1/start-transcribe` and `/api/v1/polish` (mock acceptable for hackathon).
4. Makefile and scripts to run everything locally.
5. Demo script and sample audio to show end-to-end flow.

**Acceptance tests:**

* Run `make start` and demo: create family, record memory, wait for `polish` result, convert to bedtime story, play TTS.
* UI must show Duolingo-style prompt card & streak badge.
* Storybook must support play/pause and page turn animation.

**Design & microcopy guidance (copy-paste for developer/designer):**

* Use green `#6CC644` for primary CTAs, generous padding, 44px minimum tap targets, and 18–22pt body text for readability.
* Recording screen headline: "Tell us a story — we’ll save it forever."
* Success toast: "Saved! Your family tree just grew."
* Prompt microcopy examples:

  * "What was the best adventure you had as a kid?"
  * "Who taught you how to cook?"
  * "Tell us about your favorite song."

**Developer note:** keep API keys server-side. For the hackathon, mock responses are fine as long as the pipeline and UI look real and polished.

---

## 18. Demo Script (what to show judges)

1. Onboard quickly: create family & invite (or pre-seed a demo family).
2. Show Home with prompt card + streak badge.
3. Tap Record and answer a prompt live (or use sample audio).
4. Show Processing UI while the mock/processing server runs.
5. Reveal polished memory card.
6. Convert to bedtime story → open Storybook → play narration + show illustrations.
7. Export PDF (optional canned).

**Talking points:** privacy-first, gamified daily prompts, converts real-life memories into bedtime stories — unique and emotionally valuable.

---

## 19. Next steps (I can deliver immediately)

* Generate `pubspec.yaml` + starter Flutter skeleton with `go_router` & `provider` wired.
* Create FastAPI edge function templates to call DeepGram and LLM (with environment variable placeholders).
* Produce Supabase SQL for table creation.
* Write a polished `Makefile` and an extended mock processor with sample transcripts and canned image URLs.

Tell me which of the next steps you want now and I will generate the code/files ready to copy-paste.

*End of document.*
