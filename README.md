# RentTn

RentTn is a modern car rental web application for Tunisia, built with Vue 3, TypeScript, and Supabase.

The app provides real-time fleet browsing, booking management, user authentication, and location-based car pickup/dropoff workflows in a clean, responsive UI.

## Features

- User authentication (register, login, logout, profile)
- Real-time fleet listing powered by Supabase Realtime
- Advanced car search and filtering
- Car detail pages with specs and features
- Booking flow with date, location, and pricing summary
- My Bookings page with status tracking and cancellation
- Tunisia branch locations page
- Deals page with discounted vehicles

## Tech Stack

- Frontend: Vue 3 + TypeScript + Vite
- State management: Pinia
- Routing: Vue Router
- Backend and database: Supabase (PostgreSQL + Auth + Realtime)
- Styling: Tailwind CSS v4 + custom design system
- Icons: lucide-vue-next

## Project Structure

- `src/views`: Main pages (home, fleet, booking, auth, profile, deals, locations)
- `src/components`: Reusable UI components
- `src/stores`: Pinia stores for auth and booking state
- `src/composables`: Data-fetching and realtime logic
- `src/lib`: Shared utilities and Supabase client
- `sql/schema.sql`: Database schema, policies, and seed data

## Getting Started

### 1. Install dependencies

```sh
npm install
```

### 2. Configure environment variables

Create a `.env.local` file in the project root:

```env
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_PUBLISHABLE_KEY=your_supabase_anon_key
```

### 3. Set up the database

Run `sql/schema.sql` in the Supabase SQL Editor.

This file includes:

- Table creation
- RLS policies
- Realtime publication setup
- Seed data for locations and cars

### 4. Run development server

```sh
npm run dev
```

Open the local URL shown in the terminal (usually `http://localhost:5173`).

## Scripts

- `npm run dev`: Start development server
- `npm run build`: Type-check and build for production
- `npm run preview`: Preview production build locally
- `npm run type-check`: Run Vue/TypeScript type checks

## Build for Production

```sh
npm run build
```

The production output will be generated in `dist/`.

## Notes

- If booking insert fails with RLS errors, confirm your `bookings` policies in Supabase match `auth.uid() = user_id`.
- If signup returns email rate limit errors, adjust Supabase auth email rate settings or wait before retrying.

## License

This project is currently private and maintained by the repository owner.
