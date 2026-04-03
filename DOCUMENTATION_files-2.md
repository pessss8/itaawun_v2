# iTa'awun — Project Documentation

## 1. Folder Structure (Reorganised)

```
testitaawun/
│
├── assets/
│   └── images/
│       ├── bi1.png                        ← login background
│       ├── ipey.jpeg                      ← default profile picture
│       ├── barber service.jpg
│       ├── barber service 2.jpg
│       ├── foodfest runner.jpg
│       ├── groceries runner.jpg
│       ├── iron service.jpg
│       ├── printing service.jpg
│       ├── runner cafe biruni.jpg
│       ├── runner parcel hub.jpg
│       ├── service colour printing.jpg
│       ├── service dobi.jpg
│       ├── sewing service.jpg
│       ├── slide presentation service.jpg
│       ├── download.jpg
│       ├── OIP.jpg
│       ├── Enid_Sinclair_29_001.webp
│       └── Gemini_Generated_Image_wx1ssnwx1ssnwx1s.png
│
├── index.html        ← Login page (entry point)
├── signup.html       ← Create account page (NEW)
├── forgot.html       ← Forgot password page (NEW)
├── home.html         ← Dashboard / landing after login
├── profile.html      ← User profile page
├── find.html         ← Browse services offered
├── needed.html       ← Browse services needed
├── create.html       ← Create a new service listing
│
└── [DELETE THESE]
    ├── login.html    ← Old duplicate of index.html, unused
    └── test.html     ← Duplicate of profile.html, unused
```

---

## 2. How to Move Images Without Breaking Things

When you move all images into `assets/images/`, you must update every `src` and `url()` reference in ALL html files.

**Find and replace in VS Code:**
- Press `Ctrl + Shift + H` (Find & Replace across all files)
- Find:    `src="ipey.jpeg"`
- Replace: `src="assets/images/ipey.jpeg"`

Do this for every image filename. The full list to update:
- `bi1.png` → `assets/images/bi1.png`
- `ipey.jpeg` → `assets/images/ipey.jpeg`
- All service images: prefix with `assets/images/`

The 4 files already provided to you (index, signup, forgot, home, profile) already use `assets/images/` paths.

---

## 3. File Status — Keep, Fix, or Delete

| File | Status | Reason |
|------|--------|--------|
| index.html | ✅ Keep (replace with fixed version) | Login page |
| signup.html | ✅ Keep (NEW) | Create account page |
| forgot.html | ✅ Keep (NEW) | Password reset page |
| home.html | ✅ Keep (replace with fixed version) | Main dashboard |
| profile.html | ✅ Keep (replace with fixed version) | User profile |
| find.html | 🔧 Keep, needs Supabase added later | Browse services |
| needed.html | 🔧 Keep, needs Supabase added later | Service requests |
| create.html | 🔧 Keep, needs Supabase added later | Post a service |
| login.html | ❌ DELETE | Old unused duplicate |
| test.html | ❌ DELETE | Old unused duplicate |

---

## 4. Bug Fixes Applied

### Bug 1: Logout in home.html not working
**Cause:** `home.html` was using `import { supabase } from './supabase.js'` which fails
on `file://` and required a module that didn't exist properly.
**Fix:** Replaced with CDN script tag + `db.auth.signOut()` using the global `db` client.

### Bug 2: Logout in profile.html redirects back to home
**Cause:** `window.location.href = 'index.html'` does not clear browser history stack.
Supabase session was still cached, so the session check on `index.html` immediately
redirected back to `home.html`.
**Fix:** Used `window.location.replace('index.html')` and called `db.auth.signOut()`
properly before redirect, which clears the session token.

### Bug 3: Login and Signup on same page
**Fix:** Separated into three dedicated pages: `index.html` (login only), `signup.html`
(create account with full name + student ID), `forgot.html` (password reset email).

### Bug 4: Profile page showing hardcoded "Username123"
**Fix:** Profile page now reads real data from the `profiles` Supabase table and displays
the logged-in user's actual name, student ID, email, phone, and role.

### Bug 5: Dropdown on home.html required JS click
**Fix:** Converted to pure CSS hover using `.profile-container:hover .dropdown { display: block }`.
Added smooth fade-in animation. Improved visual style with purple hover highlight and
red color for logout option.

---

## 5. Project Overview (For Submission/Presentation)

**Project Name:** iTa'awun (IT'aawun)
**Tagline:** Student Freelance Collaboration Platform
**Target Users:** CFS IIUM students
**Platform:** Web (mobile-responsive), hosted on GitHub Pages
**Backend:** Supabase (free tier) — PostgreSQL database + authentication

### Core Features (MVP)
1. Student registration and login with email authentication
2. Browse service listings posted by verified student vendors
3. Browse service requests posted by students in need
4. Post a service listing (vendors only, admin-approved)
5. User profiles with role display (student / vendor / admin)
6. Admin dashboard for vendor approval and monitoring
7. Rating and review system after completed bookings

### Tech Stack
| Layer | Technology | Cost |
|-------|-----------|------|
| Frontend | HTML, CSS, Vanilla JS | Free |
| Backend/Database | Supabase (PostgreSQL) | Free tier |
| Authentication | Supabase Auth | Free tier |
| Hosting | GitHub Pages | Free |
| Icons | Font Awesome CDN | Free |

### Islamic Framework
Built on the principle of **Ta'awun** (تعاون) — mutual cooperation and assistance.
Grounded in Al-Ma'idah 5:2: *"Cooperate in righteousness and piety."*
Targets the underprivileged (B40/Zakat recipient) student demographic to provide
dignified, monitored work opportunities within a regulated campus framework.

---

## 6. Supabase Database Tables

| Table | Purpose |
|-------|---------|
| profiles | User data (name, student ID, role, CGPA, B40 status) |
| services | Service listings posted by vendors |
| bookings | Booking requests from students to vendors |
| ratings | Post-booking reviews (1–5 stars + comment) |
| reports | Flagged listings reported by users |

---

## 7. Deployment Checklist

- [ ] All images moved to `assets/images/`
- [ ] All HTML files updated to use `assets/images/` paths
- [ ] `login.html` and `test.html` deleted
- [ ] Supabase Email Confirmation turned OFF for MVP testing
- [ ] All 5 database tables created in Supabase
- [ ] Row Level Security (RLS) policies set on all tables
- [ ] Final push to GitHub → GitHub Pages live
- [ ] Tested on mobile (Chrome DevTools → iPhone SE)
- [ ] 3–5 real student testers onboarded
