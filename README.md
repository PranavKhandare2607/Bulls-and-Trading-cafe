# 🐂 Bull's & Trading Cafe — Full-Stack Management System

> **Trade Smart. Eat Better.**  
> A complete café management system for Bull's & Trading Cafe, Shirur, Maharashtra.

🌐 **Live Website:** https://pranavkhandare2607.github.io/Bulls-and-Trading-cafe/  
📦 **GitHub:** https://github.com/PranavKhandare2607/Bulls-and-Trading-cafe  
📍 **Location:** Highway Center Building, Baburao Nagar, Shirur, MH 412210  
📷 **Instagram:** [@bulls_and_tradingcafe](https://www.instagram.com/bulls_and_tradingcafe)

---

## 📁 Project Structure

```
Bulls-and-Trading-cafe/
│
├── bulls-trading-cafe.html          # 🌐 Public-facing café website
├── bulls-cafe-management.html       # ⚙️  Full management system (Owner + Staff + Customer)
│
└── database/
    ├── supabase-schema.sql          # 📊 Full PostgreSQL schema (12 tables, triggers, seed data)
    ├── rls-policies.sql             # 🔒 Row Level Security policies (35+ policies)
    ├── fix-signup-rls.sql           # 🔧 Fix for customer signup RLS bug
    └── SETUP-GUIDE.md              # 📋 Step-by-step deployment guide
```

---

## ✨ Features

### 🌐 Public Website (`bulls-trading-cafe.html`)
- Animated ticker with live offers
- Full menu with categories
- Photo gallery & Instagram section
- Birthday registration
- Google Maps integration
- Mobile-first responsive design
- 👤 Login link → opens management system

### 👑 Owner Dashboard
- **Dashboard** — live revenue, orders, weekly bar chart, category breakdown
- **Analytics** — 7-day trend charts, revenue by category
- **Reports** — generate & print daily/weekly/monthly reports
- **All Orders** — view, filter, update status (pending → preparing → completed)
- **Menu Management** — add, edit, delete, toggle availability
- **Offers & Deals** — create, activate, pause, delete offers
- **Staff Management** — view staff, disable accounts
- **Customers** — full customer directory with loyalty points & spend
- **Reviews** — read all reviews, reply to customers
- **📧 Nightly Email Report** — automatic daily summary sent at 10 PM via Resend API
- **Audit Logs** — full action trail (login, create, update, delete)
- **Settings** — café info, Supabase config, email settings

### 👨‍🍳 Staff Dashboard
- **New Order** — live order builder with +/− quantity controls
- **Order History** — searchable order list with receipt viewer
- **Daily Summary** — today's revenue, order counts by status
- **View Menu** — read-only menu reference

### 🛍️ Customer Portal
- Full public café website loads after login (iframe, Blob URL approach)
- Member ribbon with name, loyalty points, logout
- Hidden via role-based routing — customers never see Owner/Staff options

### 🔒 Authentication
- **Customers** — self-signup via email/password (email verification supported)
- **Owner/Staff** — hidden behind secret logo tap: tap 🐂 **7 times in 5 seconds** → enter code `BTC2026` → choose role
- All auth via **Supabase Auth** — JWT, session persistence, password reset

---

## 🗄️ Database (Supabase PostgreSQL)

### Tables (12)
| Table | Description |
|---|---|
| `profiles` | Extends `auth.users` — role, name, phone |
| `customers` | Loyalty points, total orders, spend, birthday |
| `staff` | Staff role, hire date, orders today |
| `menu_items` | Name, category, price, emoji, availability |
| `orders` | Order number, status, totals, staff/customer ref |
| `order_items` | Line items snapshot per order |
| `offers` | Active deals with pricing |
| `reviews` | 5-category star ratings + owner replies |
| `notifications` | In-app alerts for owner |
| `audit_logs` | Full action trail |
| `loyalty_transactions` | Points earned/redeemed |
| `daily_analytics` | Daily revenue snapshots |

### Roles (PostgreSQL enum)
```sql
'owner' | 'staff' | 'customer'
```

### Key Triggers
- `handle_new_user()` — auto-creates `profiles` + `customers` rows on signup, awards 50 welcome points
- `award_review_points()` — awards 20 points when customer submits a review
- `notify_owner_review()` — creates notification for owner on new review
- `update_customer_stats()` — updates total orders + spend when order completed

---

## 🚀 Setup & Deployment

### Prerequisites
- [Supabase](https://supabase.com) account (free tier works)
- [Resend](https://resend.com) account for nightly emails (free tier: 3,000/month)
- A static hosting service: [GitHub Pages](https://pages.github.com), [Netlify](https://netlify.com), or [Vercel](https://vercel.com)

### Step 1 — Supabase Setup
1. Create a new Supabase project (region: `ap-south-1` Mumbai)
2. Go to **SQL Editor** → run `supabase-schema.sql`
3. Run `rls-policies.sql`
4. Run `fix-signup-rls.sql` (fixes customer signup trigger)
5. Go to **Authentication → Users** → create owner account manually
6. Run in SQL Editor:
   ```sql
   UPDATE profiles SET role = 'owner', full_name = 'Your Name'
   WHERE id = 'PASTE-OWNER-USER-UUID';
   ```

### Step 2 — Configure the Management File
The file `bulls-cafe-management.html` already has Supabase credentials hardcoded.  
If you fork this project with your own Supabase instance, update these two lines near the top of the `<script>` block:
```js
const sb = window.supabase.createClient(
  "https://YOUR-PROJECT-ID.supabase.co",
  "YOUR-ANON-KEY-HERE"
);
```

### Step 3 — Nightly Email (optional)
1. Sign up at [resend.com](https://resend.com) — free
2. Create an API key
3. Owner Dashboard → **Nightly Email** → paste API key → save
4. Report sends automatically at **10:00 PM IST** every night

### Step 4 — Deploy to GitHub Pages
```bash
git clone https://github.com/PranavKhandare2607/Bulls-and-Trading-cafe
cd Bulls-and-Trading-cafe

# Copy files
cp bulls-trading-cafe.html index.html
cp bulls-cafe-management.html bulls-cafe-management.html

git add .
git commit -m "Deploy Bull's & Trading Cafe"
git push origin main
```
Enable GitHub Pages: **Settings → Pages → Source: main branch → / (root)**

---

## 🔑 Secret Admin Access

To prevent customers from seeing Owner/Staff login options, they are hidden behind a secret gesture:

1. On the welcome/login screen, tap the **🐂 logo 7 times within 5 seconds**
2. A modal appears asking for the **Admin Access Code**
3. Enter `BTC2026`
4. Choose **Owner** or **Staff** → existing login page opens

> ⚠️ Change the access code by editing `ADMIN_ACCESS_CODE = 'BTC2026'` in the script.

---

## 🛡️ Security

- ✅ Row Level Security (RLS) enabled on all 12 tables
- ✅ Customers can only access their own data
- ✅ Staff see only operational data (orders, menu)
- ✅ Owner has full access via database policies
- ✅ `handle_new_user()` trigger is `SECURITY DEFINER` — bypasses RLS safely during signup
- ✅ No user can self-assign `owner` role — must be set manually via SQL
- ✅ Staff accounts require owner to grant `staff` role via SQL
- ✅ Anon key is safe to expose publicly (it's read-only without auth)

---

## 🤝 Open Source

This project is open source. Feel free to:
- Fork it for your own café or restaurant
- Adapt the schema for different menu categories
- Submit issues or pull requests

If you use this project, a ⭐ star on GitHub is appreciated!

---

## 🧑‍💻 Built With

| Tech | Purpose |
|---|---|
| **HTML / CSS / JS** | Single-file architecture — no build step |
| **Supabase** | PostgreSQL database + Auth + Realtime |
| **Supabase Auth** | Email/password authentication, JWT sessions |
| **Row Level Security** | Database-level access control |
| **Resend API** | Automated nightly email reports |
| **Blob URL** | Embedding public site in customer portal without parser issues |
| **GitHub Pages** | Static hosting |

---

## 📄 License

MIT License — free to use, modify, and distribute with attribution.

```
MIT License

Copyright (c) 2025 Pranav Khandare — Bull's & Trading Cafe

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```

---

*Bull's & Trading Cafe · Shirur, Maharashtra · Trade Smart. Eat Better. 🐂*
