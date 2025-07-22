# Greenhouse Tracking Application Project

## Overview

This project is a full-stack application for managing and tracking greenhouse operations. It consists of a Flutter mobile app (frontend) and a Node.js/Express backend server with a PostgreSQL database. The system supports user authentication, greenhouse and batch management, disease tracking, and harvest recording.

---

## Features

- User authentication (login/logout)
- Greenhouse management
- Product and batch management with customizable harvest periods
- Disease and daily check tracking
- Harvest recording and reporting
- Image upload (Cloudinary integration)
- Responsive Flutter UI

---

## Project Structure

```
tracking_app/
  lib/                # Flutter app source code
  pubspec.yaml        # Flutter dependencies
  tracking-app-server/
    src/              # Backend source code (Node.js/Express)
    prisma/           # Prisma schema and migrations
    package.json      # Backend dependencies
    .env              # Backend environment variables (not committed)
  .env                # Flutter environment variables (not committed)
```

---

## Prerequisites

- Flutter SDK (latest stable)
- Node.js (v16+ recommended)
- PostgreSQL database

---

## Environment Variables

### Flutter (.env in project root)

```
API_BASE_URL=http://localhost:3000/api
FLUTTER_ENV=development
DEBUG_LOGGING=true
ANDROID_EMULATOR=false
ENABLE_TOKEN_REFRESH=true
ENABLE_RETRY=true
ENABLE_OFFLINE_MODE=false
```

### Backend (.env in tracking-app-server/)

```
DATABASE_URL=postgresql://user:password@localhost:5432/yourdb
JWT_SECRET=your_jwt_secret
CLOUDINARY_CLOUD_NAME=your_cloudinary_name
CLOUDINARY_API_KEY=your_cloudinary_api_key
CLOUDINARY_API_SECRET=your_cloudinary_api_secret
```

---

## Setup Instructions

### 1. Clone the Repository

```
git clone https://github.com/kop-san/Greenhouse-Tracking-Application-Project.git
cd Greenhouse-Tracking-Application-Project
```

### 2. Flutter App Setup

- Create a `.env` file in the project root (see above for example).
- Install dependencies:
  ```
  flutter pub get
  ```
- Run the app:
  ```
  flutter run
  ```

### 3. Backend Server Setup

- Go to the backend directory:
  ```
  cd tracking-app-server
  ```
- Create a `.env` file (see above for example).
- Install dependencies:
  ```
  npm install
  ```
- Run database migrations:
  ```
  npx prisma migrate deploy
  ```
- Start the server:
  ```
  npm run dev
  ```

---

## Notes

- Do **not** commit your `.env` files to git. Use `.env.example` for sharing variable names.
- For production, update all environment variables and secure your secrets.
- For any issues, please open an issue or pull request on GitHub.

---

## License

MIT
