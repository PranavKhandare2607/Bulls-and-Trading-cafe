# Bull's & Trading Cafe — Complete Setup & Deployment Guide
## Production-Ready Cafe Management System

---

## SYSTEM ARCHITECTURE OVERVIEW

```
┌─────────────────────────────────────────────────────────────┐
│                    BULL'S & TRADING CAFE CMS                │
├─────────────────────────────────────────────────────────────┤
│  Frontend (Vercel)          Backend (Supabase)              │
│  ┌─────────────────┐        ┌──────────────────────────┐   │
│  │  Next.js 15     │◄──────►│  PostgreSQL Database      │   │
│  │  TypeScript     │        │  Supabase Auth            │   │
│  │  Tailwind CSS   │        │  Row Level Security       │   │
│  │  ShadCN UI      │        │  Realtime Subscriptions   │   │
│  │  Recharts       │        │  Edge Functions           │   │
│  │  React Hook Form│        │  Storage (images)         │   │
│  └─────────────────┘        └──────────────────────────┘   │
│                                                             │
│  Roles:  Owner → Full access                                │
│          Staff → Operational only                           │
│          Customer → Self-service portal                     │
└─────────────────────────────────────────────────────────────┘
```

---

## STEP 1 — CREATE SUPABASE PROJECT

1. Go to **https://supabase.com** → Sign in
2. Click **New Project**
3. Fill in:
   - **Project Name:** `bulls-trading-cafe`
   - **Database Password:** Create a strong password (save it!)
   - **Region:** `ap-south-1` (Mumbai — closest to Shirur)
4. Click **Create new project**
5. Wait ~2 minutes for setup to complete

---

## STEP 2 — RUN DATABASE SCHEMA

1. In Supabase dashboard → go to **SQL Editor**
2. Click **+ New Query**
3. Copy the entire contents of `supabase-schema.sql`
4. Paste into the editor
5. Click **Run** (green button)
6. You should see: `Success. No rows returned`

Then repeat for `rls-policies.sql`.

---

## STEP 3 — CONFIGURE SUPABASE AUTH

### 3.1 Email Settings
1. Supabase Dashboard → **Authentication** → **Email Templates**
2. Customize the **Confirm signup** email:

**Subject:** `Welcome to Bull's & Trading Cafe! 🐂`

**Body:**
```html
<h2>Welcome to Bull's & Trading Cafe!</h2>
<p>Hi {{ .Name }},</p>
<p>You've successfully joined our loyalty program. You start with <strong>50 bonus points!</strong></p>
<p>Click below to verify your email and start earning rewards:</p>
<p><a href="{{ .ConfirmationURL }}" style="background:#22C55E;color:#000;padding:12px 24px;border-radius:8px;text-decoration:none;font-weight:bold">✅ Verify Email</a></p>
<p>Trade Smart. Eat Better. 🐂</p>
```

3. Customize the **Reset Password** email:

**Subject:** `Reset your Bull's & Trading Cafe password`

**Body:**
```html
<h2>Password Reset</h2>
<p>Click below to reset your password. This link expires in 1 hour.</p>
<a href="{{ .ConfirmationURL }}">Reset Password</a>
```

### 3.2 URL Configuration
1. Authentication → **URL Configuration**
2. Set **Site URL:** `https://your-domain.vercel.app`
3. Add **Redirect URLs:**
   - `https://your-domain.vercel.app/auth/callback`
   - `http://localhost:3000/auth/callback` (for development)

### 3.3 Enable Providers (Optional)
- Authentication → Providers
- Enable **Google** (optional) — add OAuth credentials

---

## STEP 4 — CREATE OWNER ACCOUNT

Since the owner account needs the `owner` role, create it manually:

1. Supabase Dashboard → **Authentication** → **Users**
2. Click **+ Add user** → **Create new user**
3. Enter:
   - Email: `owner@bulls.cafe` (or your real email)
   - Password: (strong password)
4. Click **Create User** — note the User UUID
5. Go to **SQL Editor** → run:

```sql
-- Set owner role (replace UUID with actual user UUID)
UPDATE profiles
SET role = 'owner', full_name = 'Cafe Owner'
WHERE id = 'PASTE-USER-UUID-HERE';
```

---

## STEP 5 — CREATE STAFF ACCOUNTS

Option A: Owner creates via the dashboard (UI)

Option B: SQL method:
```sql
-- After staff member signs up, promote them to staff role:
UPDATE profiles
SET role = 'staff', full_name = 'Ravi Kulkarni'
WHERE id = 'STAFF-USER-UUID';

INSERT INTO staff (id, staff_role, created_by)
VALUES ('STAFF-USER-UUID', 'Head Chef', 'OWNER-UUID');
```

---

## STEP 6 — GET API KEYS

1. Supabase Dashboard → **Settings** → **API**
2. Copy:
   - **Project URL** → `NEXT_PUBLIC_SUPABASE_URL`
   - **anon public** key → `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - **service_role** key → `SUPABASE_SERVICE_ROLE_KEY` ⚠️ NEVER expose publicly!

---

## STEP 7 — SET UP NEXT.JS PROJECT

```bash
# 1. Create Next.js app
npx create-next-app@latest bulls-cafe-cms --typescript --tailwind --app --src-dir

# 2. Navigate to project
cd bulls-cafe-cms

# 3. Install dependencies
npm install @supabase/supabase-js @supabase/ssr
npm install @radix-ui/react-dialog @radix-ui/react-select @radix-ui/react-tabs
npm install @radix-ui/react-toast @radix-ui/react-switch @radix-ui/react-avatar
npm install class-variance-authority clsx tailwind-merge
npm install lucide-react recharts date-fns
npm install react-hook-form zod @hookform/resolvers

# 4. Install ShadCN UI
npx shadcn@latest init
# Choose: Default style, Zinc base color, CSS variables: yes

# 5. Add ShadCN components
npx shadcn@latest add button card dialog input label select switch table tabs toast

# 6. Create env file
cp .env.example .env.local
# Edit .env.local with your Supabase keys
```

---

## STEP 8 — PROJECT FILE STRUCTURE

```
bulls-cafe-cms/
├── src/
│   ├── app/
│   │   ├── layout.tsx                    # Root layout
│   │   ├── page.tsx                      # Home → redirect to login
│   │   ├── auth/
│   │   │   ├── login/page.tsx            # Login page
│   │   │   ├── signup/page.tsx           # Customer signup
│   │   │   ├── callback/route.ts         # Auth callback handler
│   │   │   └── reset-password/page.tsx   # Password reset
│   │   ├── dashboard/
│   │   │   ├── owner/
│   │   │   │   ├── layout.tsx            # Owner shell with sidebar
│   │   │   │   ├── page.tsx              # Owner dashboard
│   │   │   │   ├── analytics/page.tsx
│   │   │   │   ├── orders/page.tsx
│   │   │   │   ├── menu/page.tsx
│   │   │   │   ├── offers/page.tsx
│   │   │   │   ├── staff/page.tsx
│   │   │   │   ├── customers/page.tsx
│   │   │   │   ├── reviews/page.tsx
│   │   │   │   ├── reports/page.tsx
│   │   │   │   ├── audit/page.tsx
│   │   │   │   └── settings/page.tsx
│   │   │   ├── staff/
│   │   │   │   ├── layout.tsx
│   │   │   │   ├── page.tsx              # New order builder
│   │   │   │   ├── history/page.tsx
│   │   │   │   └── daily/page.tsx
│   │   │   └── customer/
│   │   │       ├── layout.tsx
│   │   │       ├── page.tsx              # Customer home
│   │   │       ├── menu/page.tsx
│   │   │       ├── offers/page.tsx
│   │   │       ├── profile/page.tsx
│   │   │       ├── orders/page.tsx
│   │   │       ├── reviews/page.tsx
│   │   │       ├── loyalty/page.tsx
│   │   │       └── visit/page.tsx
│   │   └── api/
│   │       ├── auth/callback/route.ts
│   │       ├── orders/route.ts
│   │       ├── orders/[id]/route.ts
│   │       ├── reviews/route.ts
│   │       ├── analytics/route.ts
│   │       ├── notifications/route.ts
│   │       ├── menu/route.ts
│   │       ├── staff/route.ts
│   │       └── loyalty/route.ts
│   ├── components/
│   │   ├── ui/                           # ShadCN components
│   │   ├── layout/
│   │   │   ├── Sidebar.tsx
│   │   │   ├── Topbar.tsx
│   │   │   └── MobileMenu.tsx
│   │   ├── dashboard/
│   │   │   ├── StatCard.tsx
│   │   │   ├── RevenueChart.tsx
│   │   │   ├── OrderTable.tsx
│   │   │   └── ReviewCard.tsx
│   │   ├── orders/
│   │   │   ├── OrderBuilder.tsx
│   │   │   ├── OrderCard.tsx
│   │   │   └── Receipt.tsx
│   │   ├── menu/
│   │   │   ├── MenuGrid.tsx
│   │   │   └── MenuItemCard.tsx
│   │   └── reviews/
│   │       ├── ReviewForm.tsx
│   │       └── StarRating.tsx
│   ├── hooks/
│   │   ├── useAuth.ts
│   │   ├── useRealtime.ts
│   │   └── useNotifications.ts
│   ├── lib/
│   │   ├── supabase/
│   │   │   ├── client.ts
│   │   │   └── server.ts
│   │   └── utils.ts
│   ├── types/
│   │   └── database.ts
│   └── middleware.ts
├── public/
├── .env.local
├── tailwind.config.ts
├── next.config.ts
└── package.json
```

---

## STEP 9 — AUTH CALLBACK ROUTE

Create `src/app/auth/callback/route.ts`:
```typescript
import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')
  const next = searchParams.get('next') ?? '/'

  if (code) {
    const supabase = await createClient()
    const { data, error } = await supabase.auth.exchangeCodeForSession(code)

    if (!error && data.user) {
      const { data: profile } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', data.user.id)
        .single()

      const role = profile?.role || 'customer'
      return NextResponse.redirect(`${origin}/dashboard/${role}`)
    }
  }

  return NextResponse.redirect(`${origin}/auth/login?error=callback_error`)
}
```

---

## STEP 10 — DEPLOY TO VERCEL

```bash
# 1. Install Vercel CLI
npm i -g vercel

# 2. Login to Vercel
vercel login

# 3. Deploy
vercel

# 4. Set environment variables in Vercel dashboard:
# Project Settings → Environment Variables → Add:
# NEXT_PUBLIC_SUPABASE_URL = your_supabase_url
# NEXT_PUBLIC_SUPABASE_ANON_KEY = your_anon_key
# SUPABASE_SERVICE_ROLE_KEY = your_service_role_key
# NEXT_PUBLIC_SITE_URL = https://your-project.vercel.app

# 5. Redeploy with production settings
vercel --prod
```

Or deploy via GitHub:
1. Push code to GitHub repository
2. Go to **vercel.com** → Import Project → Select your repo
3. Add environment variables
4. Click Deploy

---

## STEP 11 — SUPABASE REALTIME SETUP

Enable realtime for live order updates:

```sql
-- In Supabase SQL Editor:
ALTER PUBLICATION supabase_realtime ADD TABLE orders;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE order_items;
```

---

## STEP 12 — SUPABASE STORAGE (for food images)

1. Supabase Dashboard → **Storage**
2. Create bucket: `menu-images` (Public)
3. Create bucket: `avatars` (Private)
4. Set policies:

```sql
-- Allow public to view menu images
CREATE POLICY "Public menu images"
ON storage.objects FOR SELECT
USING (bucket_id = 'menu-images');

-- Allow owner to upload menu images
CREATE POLICY "Owner upload menu images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'menu-images'
  AND is_owner()
);

-- Allow users to manage their avatar
CREATE POLICY "Users manage avatars"
ON storage.objects FOR ALL
USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
```

---

## SECURITY CHECKLIST

- [x] Row Level Security enabled on all tables
- [x] JWT authentication via Supabase Auth
- [x] Role-based access control (owner/staff/customer)
- [x] Service role key kept server-side only
- [x] Email verification required for customers
- [x] Input validation on all API routes (Zod)
- [x] CSRF protection via Next.js middleware
- [x] Password hashing via Supabase (bcrypt)
- [x] Audit logs for all sensitive actions
- [x] Rate limiting (add via Vercel middleware or Upstash)

### Additional Rate Limiting (Upstash):
```bash
npm install @upstash/ratelimit @upstash/redis
```

Add to middleware:
```typescript
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '10 s'),
})
```

---

## PRODUCTION CHECKLIST

### Pre-Launch
- [ ] Run SQL schema successfully
- [ ] Run RLS policies successfully  
- [ ] Owner account created and tested
- [ ] Staff accounts created
- [ ] Menu items seeded
- [ ] Offers seeded
- [ ] Email templates customized
- [ ] Auth callback URLs configured
- [ ] Environment variables set in Vercel
- [ ] Domain configured (custom domain)

### Testing
- [ ] Customer signup → email verification → login
- [ ] Customer submits review → owner notified
- [ ] Staff creates order → receipt generated
- [ ] Owner views analytics → correct data
- [ ] Owner adds menu item → visible to all
- [ ] Loyalty points awarded on review
- [ ] Password reset email works
- [ ] RLS: customer cannot view other customer's orders

### Post-Launch
- [ ] Set up Supabase backups (automatic)
- [ ] Set up Vercel analytics
- [ ] Monitor Supabase usage/quotas
- [ ] Set up uptime monitoring (UptimeRobot - free)

---

## SUPABASE FREE TIER LIMITS

| Resource | Free Tier | Notes |
|----------|-----------|-------|
| Database | 500 MB | Enough for ~2 years of orders |
| Auth | 50,000 MAU | More than enough |
| Storage | 1 GB | For menu images |
| Realtime | 200 concurrent | Sufficient for café |
| Edge Functions | 500K invocations/month | Sufficient |

**Upgrade to Pro ($25/month) when:**
- Database > 400 MB
- Need daily backups
- Need custom domains for auth

---

## INSTAGRAM INTEGRATION

To link to your Instagram in the website:
```
URL: https://www.instagram.com/bulls_and_tradingcafe?igsh=MTkyczd3dDc4NXlkbw==
```

This link is already embedded in:
- Navigation bar
- Visit Us section
- Footer
- Birthday section
- CTA section

---

## SUPPORT & UPDATES

**Supabase Docs:** https://supabase.com/docs  
**Next.js Docs:** https://nextjs.org/docs  
**Vercel Docs:** https://vercel.com/docs  
**ShadCN UI:** https://ui.shadcn.com  

---

*Bull's & Trading Cafe Management System — Trade Smart. Eat Better. 🐂*
