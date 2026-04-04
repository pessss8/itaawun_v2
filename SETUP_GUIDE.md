# iTa'awun - Complete Supabase Setup Guide

## Overview
This guide walks you through setting up the complete database infrastructure for iTa'awun in Supabase. Follow these steps in order.

---

## STEP 1: Go to Supabase Dashboard

1. Open https://supabase.com/dashboard
2. Select your project: `fyahebgkacjsxmiwteny` (or create a new one)

---

## STEP 2: Run the SQL Setup Script

1. In Supabase Dashboard, go to **SQL Editor** (left sidebar)
2. Click **"New Query"**
3. Open the file: `SUPABASE_COMPLETE_SETUP.sql` (in this folder)
4. Copy ALL the SQL content
5. Paste into the SQL Editor
6. Click **"Run"** (or press Ctrl+Enter)
7. Wait for success message (should take 2-5 seconds)

**Expected Result:** You should see "Success. No rows returned" for each statement.

---

## STEP 3: Create Your Admin Account

1. Go to **Authentication** > **Users** (left sidebar)
2. Click **"Add user"** > **"Create new user"**
3. Fill in:
   - **Email:** Your email (e.g., `admin@itaawun.com`)
   - **Password:** Your password (min 6 chars)
   - **Confirm Password:** Same password
4. Click **"Create user"**

**Alternative:** Use the signup page on your website:
1. Open `index.html` in browser
2. Click "Create Account"
3. Fill in the form and sign up

---

## STEP 4: Make Yourself Admin

1. Go to **Table Editor** (left sidebar)
2. Select **profiles** table
3. Find your row (by email)
4. Click the **role** cell
5. Change from `student` to `admin`
6. Press Enter to save

---

## STEP 5: Verify Setup

1. Go to **Table Editor**
2. You should see 5 tables:
   - ✅ `profiles`
   - ✅ `services`
   - ✅ `bookings`
   - ✅ `ratings`
   - ✅ `reports`

3. Check RLS is enabled:
   - Go to **Authentication** > **Policies**
   - You should see policies for all 5 tables

---

## STEP 6: Test the System

### Test 1: Login
1. Open `index.html` in browser
2. Login with your admin account
3. Should redirect to `home.html`

### Test 2: Create Service
1. From home, click **"Create Service"**
2. Fill in the form:
   - Service Type: Offered
   - Title: Test Service
   - Description: This is a test
   - Price: 10
   - Category: Design
   - Location: Test Location
   - Time: Flexible
   - Contact: your email
   - WhatsApp: 60123456789
   - Telegram: yourusername
   - Image: (leave blank for placeholder)
3. Click **"Submit Service"**
4. Should show success alert and redirect to `find.html`

### Test 3: View Service
1. On `find.html`, you should see your service card
2. Test the **Contact** and **Book** buttons

### Test 4: Admin Dashboard
1. Open `admin.html`
2. Should NOT redirect (you're admin)
3. Click **"Services"** tab
4. You should see your service listed
5. Test **Deactivate** and **Activate** buttons

### Test 5: Logout
1. Click profile picture (top right)
2. Click **"Logout"**
3. Should redirect to `index.html` with `?logged=out`

---

## Troubleshooting

### Problem: "Could not find column" error
**Solution:** Run the SQL script again. The table schema might be outdated.

### Problem: Admin page redirects to home
**Solution:**
1. Go to Table Editor > profiles
2. Make sure your role is `admin` (not `student`)

### Problem: Services don't appear after creation
**Solution:**
1. Check browser console (F12) for errors
2. Verify RLS policies are set correctly
3. Make sure you're logged in

### Problem: "Row-level security policy" error
**Solution:** The SQL script enables RLS. Make sure you ran the complete script.

---

## Database Schema Reference

### profiles
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key (auth.users reference) |
| email | text | User email |
| full_name | text | Display name |
| student_id | text | University ID |
| role | text | student/vendor/admin |
| is_b40 | boolean | B40 welfare status |
| is_approved | boolean | Vendor approval status |
| cgpa | numeric | Academic CGPA |
| avatar_url | text | Profile picture URL |

### services
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| vendor_id | uuid | Creator (auth.users reference) |
| title | text | Service title |
| description | text | Service description |
| price | numeric | Price in RM |
| category | text | Category |
| location | text | Location |
| time | text | Available time |
| contact | text | Contact email |
| whatsapp | text | WhatsApp number |
| telegram | text | Telegram username |
| image | text | Image URL |
| type | text | offered/needed |
| status | text | active/inactive/pending |

### bookings
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| service_id | uuid | Reference to services |
| student_id | uuid | Student who booked |
| vendor_id | uuid | Vendor providing service |
| note | text | Booking note |
| status | text | pending/accepted/done/cancelled |

### ratings
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| booking_id | uuid | Reference to bookings |
| reviewer_id | uuid | Who wrote the rating |
| target_id | uuid | Who received the rating |
| score | integer | 1-5 stars |
| comment | text | Rating comment |

### reports
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| reporter_id | uuid | Who reported |
| service_id | uuid | Reported service |
| reason | text | Report reason |
| status | text | pending/reviewed/dismissed |

---

## File Checklist

Before pushing to GitHub, ensure:

- [ ] SQL script ran successfully
- [ ] Admin account created
- [ ] Role changed to admin in profiles table
- [ ] All 5 tables exist
- [ ] Test service created and visible
- [ ] Logout works correctly
- [ ] Admin dashboard accessible

---

## Push to GitHub

```bash
cd "C:\Users\Iman Haqimi\Documents\Q\The Prodj\JV kutt\Codes\testitaawun"
git add .
git commit -m "Complete Supabase integration with full database schema"
git push
```

---

## Live URL

After pushing, your site will be live at:
`https://ipanboy.github.io/testitaawun/`

Allow 1-2 minutes for GitHub Pages to rebuild.
