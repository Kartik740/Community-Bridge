# CommunityBridge 🌉

> From scattered surveys to smart volunteer dispatch — powered by Gemini AI

CommunityBridge is a full-stack platform that helps NGO organisers collect structured community needs data from field volunteers, analyse it using Google Gemini AI, visualise it on heatmaps, and intelligently dispatch volunteers to the most critical areas.

Built for **Google Solution Challenge 2026**.

---

## 🔗 Live Links

| | Link |
|---|---|
| 🌐 Web Dashboard | [community-bridge-4a87d.web.app](https://community-bridge-4a87d.web.app/) |
| 📱 APK Download | [Download app-release.apk](https://github.com/Kartik740/Community-Bridge/releases/tag/v1.0.0) |
| 🎥 Demo Video | [YouTube](https://youtu.be/fBr4zbMAxfI) |

---

## 📖 What It Does

Local NGOs collect community needs data through paper surveys and field reports — but this data is scattered, unstructured, and impossible to act on at scale. CommunityBridge solves this end-to-end:

1. **NGO organisers** create dynamic survey forms on the web dashboard
2. **Field volunteers** collect data via offline-first mobile app
3. Data **auto-syncs** to the cloud when internet returns
4. **Gemini AI** analyses responses, scores urgency 1-10, and generates action plans
5. **Google Maps heatmap** shows where crises are concentrated
6. **Smart matching algorithm** dispatches the best volunteers via push notification

---

## 🏗️ Project Structure

```
CommunityBridge/
├── web/          # React web dashboard for NGO organisers
├── mobile/       # Flutter mobile app for field volunteers
└── backend/      # Node.js + Express backend with Gemini AI
```

---

## ⚙️ Tech Stack

| Layer | Technology |
|---|---|
| Web Frontend | React 18, Tailwind CSS, React Router v6 |
| Mobile App | Flutter, Hive (offline), Firebase plugins |
| Backend | Node.js, Express.js |
| Database | Firebase Firestore |
| Auth | Firebase Authentication |
| AI | Google Gemini API (gemini-1.5-flash) |
| Maps | Google Maps Platform |
| Notifications | Firebase Cloud Messaging (FCM) |
| Hosting | Firebase Hosting (web), Render.com (backend) |

---

## 🚀 Setup Instructions

### Prerequisites

Make sure you have these installed:
- Node.js v18+
- Flutter SDK (latest stable)
- Firebase CLI (`npm install -g firebase-tools`)
- Git

---

### 1. Clone the Repository

```bash
git clone https://github.com/Kartik740/Community-Bridge.git
cd Community-Bridge
```

---

### 2. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or use existing `community-bridge-4a87d`
3. Enable these services:
   - Firestore Database
   - Authentication (Email/Password)
   - Storage
   - Cloud Messaging
4. Download config files:
   - Web config → used in `web/src/services/firebase.js`
   - `google-services.json` → place in `mobile/android/app/`

---

### 3. Web Dashboard Setup

```bash
cd web

# Install dependencies
npm install

# Create environment file
cp .env.example .env
```

Fill in your `.env` file:

```env
VITE_FIREBASE_API_KEY=your_firebase_api_key
VITE_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your_project_id
VITE_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
VITE_FIREBASE_APP_ID=your_app_id
VITE_GOOGLE_MAPS_API_KEY=your_google_maps_key
VITE_BACKEND_URL=https://your-backend.onrender.com
```

```bash
# Run in development
npm run dev

# Build for production
npm run build
```

---

### 4. Backend Setup

```bash
cd backend

# Install dependencies
npm install

# Create environment file
cp .env.example .env
```

Fill in your `.env` file:

```env
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_CLIENT_EMAIL=your_service_account_email
FIREBASE_PRIVATE_KEY="your_private_key"
GEMINI_API_KEY=your_gemini_api_key
PORT=8080
```

To get Firebase service account credentials:
1. Firebase Console → Project Settings → Service Accounts
2. Click **Generate new private key**
3. Copy `project_id`, `client_email`, and `private_key` into your `.env`

```bash
# Run in development
npm run dev

# Run in production
node src/app.js
```

---

### 5. Seed Demo Data (Optional)

Populate the database with realistic test data for Bhopal, India:

```bash
cd backend
node src/scripts/seedData.js
```

This creates:
- 1 demo NGO organisation
- 10 volunteers with different skills
- 80 survey responses across 6 areas of Bhopal

---

### 6. Flutter Mobile App Setup

```bash
cd mobile

# Install dependencies
flutter pub get
```

Make sure `google-services.json` is in `android/app/`:
```
mobile/
└── android/
    └── app/
        └── google-services.json  ← must be here
```

```bash
# Run in development (with device connected or emulator running)
flutter run

# Build release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

### 7. Deploy

**Web to Firebase Hosting:**
```bash
cd web
npm run build
cd ..
firebase deploy --only hosting
```

**Backend to Render.com:**
- Push to GitHub → Render auto-deploys on every push

---

## 📱 Demo Credentials

| Role | Email | Password |
|---|---|---|
| NGO Organiser | as4868731@gmail.com | ramsingh4545 |
| Volunteer | kartikay@gmaio.com | 123456789 |

---

## 🔄 Full Demo Flow

1. Login as organiser → create a survey → note the survey code
2. Login as volunteer on mobile → enter survey code
3. Turn off internet → fill and submit form
4. Turn internet back on → watch auto-sync
5. Back on web → approve the response
6. Click **Run AI Analysis** → see urgency scores and heatmap
7. Click **Notify Volunteer** on a critical task
8. Volunteer receives push notification → marks task complete

---

## 📁 Environment Files

Never commit `.env` files. Use `.env.example` as a template:

```
web/.env.example
backend/.env.example
```

---

## 🤝 Team

- **Team Name:** Vertex Voyagers
- **Event:** Google Solution Challenge 2026
- **Track:** [Smart Resource Allocation] Data-Driven Volunteer Coordination for Social Impact

---

## 📄 License

MIT License — feel free to use and build on this project.
