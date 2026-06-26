// ═══════════════════════════════════════════════════════════════
// BULL'S & TRADING CAFE — NEXT.JS 15 + SUPABASE
// Complete Source Code · TypeScript · Tailwind · ShadCN UI
// ═══════════════════════════════════════════════════════════════

// ─────────────────────────────────────────
// FILE: package.json
// ─────────────────────────────────────────
/*
{
  "name": "bulls-trading-cafe-cms",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "next": "^15.0.0",
    "react": "^18.3.0",
    "react-dom": "^18.3.0",
    "@supabase/supabase-js": "^2.45.0",
    "@supabase/ssr": "^0.5.0",
    "@radix-ui/react-dialog": "^1.1.0",
    "@radix-ui/react-dropdown-menu": "^2.1.0",
    "@radix-ui/react-select": "^2.1.0",
    "@radix-ui/react-tabs": "^1.1.0",
    "@radix-ui/react-toast": "^1.2.0",
    "@radix-ui/react-switch": "^1.1.0",
    "@radix-ui/react-avatar": "^1.1.0",
    "class-variance-authority": "^0.7.0",
    "clsx": "^2.1.0",
    "tailwind-merge": "^2.3.0",
    "lucide-react": "^0.400.0",
    "recharts": "^2.12.0",
    "date-fns": "^3.6.0",
    "react-hook-form": "^7.52.0",
    "zod": "^3.23.0",
    "@hookform/resolvers": "^3.6.0"
  },
  "devDependencies": {
    "typescript": "^5.5.0",
    "@types/react": "^18.3.0",
    "@types/react-dom": "^18.3.0",
    "@types/node": "^20.14.0",
    "tailwindcss": "^3.4.0",
    "autoprefixer": "^10.4.0",
    "postcss": "^8.4.0",
    "eslint": "^8.57.0",
    "eslint-config-next": "^15.0.0"
  }
}
*/

// ─────────────────────────────────────────
// FILE: .env.local
// ─────────────────────────────────────────
/*
NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=YOUR_ANON_KEY_HERE
SUPABASE_SERVICE_ROLE_KEY=YOUR_SERVICE_ROLE_KEY_HERE
NEXT_PUBLIC_SITE_URL=https://your-domain.vercel.app
*/

// ─────────────────────────────────────────
// FILE: src/lib/supabase/client.ts
// ─────────────────────────────────────────
export const supabaseClientCode = `
import { createBrowserClient } from '@supabase/ssr'
import type { Database } from '@/types/database'

export function createClient() {
  return createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
`;

// ─────────────────────────────────────────
// FILE: src/lib/supabase/server.ts
// ─────────────────────────────────────────
export const supabaseServerCode = `
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'
import type { Database } from '@/types/database'

export async function createClient() {
  const cookieStore = await cookies()
  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return cookieStore.getAll() },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            )
          } catch {}
        },
      },
    }
  )
}
`;

// ─────────────────────────────────────────
// FILE: src/types/database.ts  (Supabase generated types)
// ─────────────────────────────────────────
export const databaseTypes = `
export type UserRole = 'owner' | 'staff' | 'customer'
export type OrderStatus = 'pending' | 'preparing' | 'ready' | 'completed' | 'cancelled'
export type ItemCategory = 'pizza' | 'burger' | 'mocktail' | 'dessert' | 'other'

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          role: UserRole
          full_name: string
          phone: string | null
          avatar_url: string | null
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: Omit<Database['public']['Tables']['profiles']['Row'], 'created_at' | 'updated_at'>
        Update: Partial<Database['public']['Tables']['profiles']['Insert']>
      }
      customers: {
        Row: {
          id: string
          loyalty_points: number
          birthday: string | null
          instagram_handle: string | null
          total_orders: number
          total_spent: number
          last_visit: string | null
          created_at: string
        }
        Insert: Omit<Database['public']['Tables']['customers']['Row'], 'created_at' | 'total_orders' | 'total_spent'>
        Update: Partial<Database['public']['Tables']['customers']['Insert']>
      }
      menu_items: {
        Row: {
          id: string
          name: string
          description: string | null
          category: ItemCategory
          price: number
          emoji: string
          image_url: string | null
          is_available: boolean
          is_featured: boolean
          sort_order: number
          created_by: string | null
          created_at: string
          updated_at: string
        }
        Insert: Omit<Database['public']['Tables']['menu_items']['Row'], 'id' | 'created_at' | 'updated_at'>
        Update: Partial<Database['public']['Tables']['menu_items']['Insert']>
      }
      orders: {
        Row: {
          id: string
          order_number: string
          customer_id: string | null
          staff_id: string | null
          status: OrderStatus
          subtotal: number
          tax: number
          discount: number
          total: number
          notes: string | null
          created_at: string
          updated_at: string
        }
        Insert: Omit<Database['public']['Tables']['orders']['Row'], 'id' | 'order_number' | 'created_at' | 'updated_at'>
        Update: Partial<Database['public']['Tables']['orders']['Insert']>
      }
      order_items: {
        Row: {
          id: string
          order_id: string
          menu_item_id: string
          name: string
          price: number
          quantity: number
          subtotal: number
          created_at: string
        }
        Insert: Omit<Database['public']['Tables']['order_items']['Row'], 'id' | 'subtotal' | 'created_at'>
        Update: Partial<Database['public']['Tables']['order_items']['Insert']>
      }
      reviews: {
        Row: {
          id: string
          customer_id: string
          order_id: string | null
          rating_overall: number
          rating_food: number
          rating_service: number
          rating_ambience: number
          rating_cleanliness: number
          review_text: string | null
          owner_reply: string | null
          reply_at: string | null
          is_published: boolean
          points_awarded: number
          created_at: string
          updated_at: string
        }
        Insert: Omit<Database['public']['Tables']['reviews']['Row'], 'id' | 'created_at' | 'updated_at'>
        Update: Partial<Database['public']['Tables']['reviews']['Insert']>
      }
      notifications: {
        Row: {
          id: string
          user_id: string
          title: string
          body: string | null
          type: string
          is_read: boolean
          data: Record<string, unknown> | null
          created_at: string
        }
        Insert: Omit<Database['public']['Tables']['notifications']['Row'], 'id' | 'created_at'>
        Update: Partial<Database['public']['Tables']['notifications']['Insert']>
      }
    }
    Functions: {
      get_user_role: { Returns: UserRole }
      is_owner: { Returns: boolean }
      is_staff_or_owner: { Returns: boolean }
    }
  }
}
`;

// ─────────────────────────────────────────
// FILE: src/middleware.ts  (Auth protection)
// ─────────────────────────────────────────
export const middlewareCode = `
import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return request.cookies.getAll() },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value))
          supabaseResponse = NextResponse.next({ request })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  const { data: { user } } = await supabase.auth.getUser()
  const { pathname } = request.nextUrl

  // Protected routes
  const ownerRoutes = ['/dashboard/owner']
  const staffRoutes = ['/dashboard/staff']
  const customerRoutes = ['/dashboard/customer']

  if (!user) {
    if ([...ownerRoutes, ...staffRoutes, ...customerRoutes].some(r => pathname.startsWith(r))) {
      return NextResponse.redirect(new URL('/auth/login', request.url))
    }
    return supabaseResponse
  }

  // Get user role
  const { data: profile } = await supabase
    .from('profiles')
    .select('role')
    .eq('id', user.id)
    .single()

  const role = profile?.role

  // Role-based route protection
  if (ownerRoutes.some(r => pathname.startsWith(r)) && role !== 'owner') {
    return NextResponse.redirect(new URL('/unauthorized', request.url))
  }
  if (staffRoutes.some(r => pathname.startsWith(r)) && role !== 'staff' && role !== 'owner') {
    return NextResponse.redirect(new URL('/unauthorized', request.url))
  }
  if (customerRoutes.some(r => pathname.startsWith(r)) && role !== 'customer') {
    return NextResponse.redirect(new URL('/unauthorized', request.url))
  }

  return supabaseResponse
}

export const config = {
  matcher: ['/dashboard/:path*', '/auth/:path*'],
}
`;

// ─────────────────────────────────────────
// FILE: src/app/auth/login/page.tsx
// ─────────────────────────────────────────
export const loginPageCode = `
'use client'
import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const router = useRouter()
  const supabase = createClient()

  async function handleLogin(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    setError('')

    const { data, error } = await supabase.auth.signInWithPassword({ email, password })

    if (error) {
      setError(error.message)
      setLoading(false)
      return
    }

    if (data.user) {
      const { data: profile } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', data.user.id)
        .single()

      const role = profile?.role
      if (role === 'owner') router.push('/dashboard/owner')
      else if (role === 'staff') router.push('/dashboard/staff')
      else router.push('/dashboard/customer')
    }
  }

  return (
    <div className="min-h-screen bg-[#0A0F0A] flex items-center justify-center p-6">
      <div className="w-full max-w-md bg-[#111811] border border-white/10 rounded-2xl p-8">
        <div className="text-center mb-8">
          <div className="text-5xl mb-4">🐂</div>
          <h1 className="text-2xl font-bold text-white">Bull's & Trading Cafe</h1>
          <p className="text-white/50 text-sm mt-1">Management System</p>
        </div>

        <form onSubmit={handleLogin} className="space-y-4">
          {error && (
            <div className="bg-red-500/10 border border-red-500/20 rounded-lg p-3 text-red-400 text-sm">
              {error}
            </div>
          )}
          <div>
            <label className="text-xs font-bold text-white/50 uppercase tracking-wider">Email</label>
            <input
              type="email" value={email} onChange={e => setEmail(e.target.value)}
              className="w-full mt-1.5 px-3.5 py-3 bg-[#0F160F] border border-white/10 rounded-xl text-white text-sm outline-none focus:border-green-500/40"
              placeholder="your@email.com" required
            />
          </div>
          <div>
            <label className="text-xs font-bold text-white/50 uppercase tracking-wider">Password</label>
            <input
              type="password" value={password} onChange={e => setPassword(e.target.value)}
              className="w-full mt-1.5 px-3.5 py-3 bg-[#0F160F] border border-white/10 rounded-xl text-white text-sm outline-none focus:border-green-500/40"
              placeholder="••••••••" required
            />
          </div>
          <button
            type="submit" disabled={loading}
            className="w-full py-3.5 bg-green-500 text-black font-black rounded-xl hover:bg-green-400 transition disabled:opacity-50"
          >
            {loading ? 'Signing in...' : '🚀 Sign In'}
          </button>
        </form>

        <div className="mt-6 text-center">
          <a href="/auth/signup" className="text-green-400 text-sm font-semibold hover:underline">
            New customer? Create account →
          </a>
        </div>
      </div>
    </div>
  )
}
`;

// ─────────────────────────────────────────
// FILE: src/app/auth/signup/page.tsx
// ─────────────────────────────────────────
export const signupPageCode = `
'use client'
import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'

export default function SignupPage() {
  const [form, setForm] = useState({ name: '', email: '', phone: '', password: '' })
  const [loading, setLoading] = useState(false)
  const [success, setSuccess] = useState(false)
  const [error, setError] = useState('')
  const router = useRouter()
  const supabase = createClient()

  async function handleSignup(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    setError('')

    const { data, error } = await supabase.auth.signUp({
      email: form.email,
      password: form.password,
      options: {
        data: {
          full_name: form.name,
          phone: form.phone,
          role: 'customer',
        },
        emailRedirectTo: \`\${window.location.origin}/auth/callback\`,
      },
    })

    if (error) { setError(error.message); setLoading(false); return }
    if (data.user) {
      if (data.user.identities?.length === 0) {
        setError('Email already registered. Please sign in.')
        setLoading(false)
        return
      }
      setSuccess(true)
    }
  }

  if (success) return (
    <div className="min-h-screen bg-[#0A0F0A] flex items-center justify-center p-6">
      <div className="text-center">
        <div className="text-5xl mb-4">✅</div>
        <h2 className="text-2xl font-bold text-white mb-2">Account Created!</h2>
        <p className="text-white/50">Check your email to verify your account. You earned 50 welcome points!</p>
        <button onClick={() => router.push('/auth/login')} className="mt-6 px-6 py-3 bg-green-500 text-black font-bold rounded-xl">
          Sign In →
        </button>
      </div>
    </div>
  )

  return (
    <div className="min-h-screen bg-[#0A0F0A] flex items-center justify-center p-6">
      <div className="w-full max-w-md bg-[#111811] border border-white/10 rounded-2xl p-8">
        <div className="text-center mb-6">
          <div className="text-4xl mb-3">🐂</div>
          <h1 className="text-xl font-bold text-white">Create Account</h1>
          <p className="text-white/40 text-sm mt-1">Join Bull's & Trading Cafe · Earn loyalty points</p>
        </div>
        <form onSubmit={handleSignup} className="space-y-4">
          {error && <div className="bg-red-500/10 border border-red-500/20 rounded-lg p-3 text-red-400 text-sm">{error}</div>}
          {['name', 'email', 'phone', 'password'].map(field => (
            <div key={field}>
              <label className="text-xs font-bold text-white/50 uppercase tracking-wider">{field === 'name' ? 'Full Name' : field.charAt(0).toUpperCase() + field.slice(1)}</label>
              <input
                type={field === 'password' ? 'password' : field === 'email' ? 'email' : 'text'}
                value={(form as any)[field]}
                onChange={e => setForm(f => ({...f, [field]: e.target.value}))}
                className="w-full mt-1.5 px-3.5 py-3 bg-[#0F160F] border border-white/10 rounded-xl text-white text-sm outline-none focus:border-green-500/40"
                placeholder={field === 'name' ? 'Your full name' : field === 'email' ? 'your@email.com' : field === 'phone' ? '+91 98765 43210' : '••••••••'}
                required={field !== 'phone'}
              />
            </div>
          ))}
          <button type="submit" disabled={loading} className="w-full py-3.5 bg-green-500 text-black font-black rounded-xl hover:bg-green-400 transition disabled:opacity-50">
            {loading ? 'Creating...' : '🎉 Create Account (+50 pts)'}
          </button>
        </form>
        <div className="mt-4 text-center">
          <a href="/auth/login" className="text-white/40 text-sm hover:text-white">Already have an account? Sign in</a>
        </div>
      </div>
    </div>
  )
}
`;

// ─────────────────────────────────────────
// FILE: src/app/api/orders/route.ts
// ─────────────────────────────────────────
export const ordersApiCode = `
import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(request: Request) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })

  const { data: profile } = await supabase.from('profiles').select('role').eq('id', user.id).single()

  let query = supabase
    .from('orders')
    .select(\`
      *,
      order_items (
        id, name, price, quantity, subtotal,
        menu_item_id
      ),
      profiles!orders_customer_id_fkey (full_name, phone),
      staff_profile:profiles!orders_staff_id_fkey (full_name)
    \`)
    .order('created_at', { ascending: false })

  if (profile?.role === 'customer') {
    query = query.eq('customer_id', user.id)
  }

  const { data, error } = await query.limit(50)
  if (error) return NextResponse.json({ error: error.message }, { status: 500 })
  return NextResponse.json({ orders: data })
}

export async function POST(request: Request) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })

  const body = await request.json()
  const { items, notes } = body

  if (!items || !Array.isArray(items) || items.length === 0) {
    return NextResponse.json({ error: 'No items provided' }, { status: 400 })
  }

  // Calculate totals
  const subtotal = items.reduce((sum: number, item: any) => sum + item.price * item.quantity, 0)
  const tax = Math.round(subtotal * 0.05 * 100) / 100
  const total = subtotal + tax

  // Create order
  const { data: order, error: orderError } = await supabase
    .from('orders')
    .insert({
      customer_id: user.id,
      status: 'pending',
      subtotal,
      tax,
      total,
      notes: notes || null,
    })
    .select()
    .single()

  if (orderError) return NextResponse.json({ error: orderError.message }, { status: 500 })

  // Create order items
  const orderItems = items.map((item: any) => ({
    order_id: order.id,
    menu_item_id: item.id,
    name: item.name,
    price: item.price,
    quantity: item.quantity,
  }))

  const { error: itemsError } = await supabase.from('order_items').insert(orderItems)
  if (itemsError) return NextResponse.json({ error: itemsError.message }, { status: 500 })

  // Log to audit
  await supabase.from('audit_logs').insert({
    user_id: user.id,
    action: 'create',
    table_name: 'orders',
    record_id: order.id,
    new_data: { order_number: order.order_number, total },
  })

  return NextResponse.json({ order }, { status: 201 })
}
`;

// ─────────────────────────────────────────
// FILE: src/app/api/reviews/route.ts
// ─────────────────────────────────────────
export const reviewsApiCode = `
import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET() {
  const supabase = await createClient()

  const { data, error } = await supabase
    .from('reviews')
    .select(\`
      *,
      customers!inner (
        profiles!inner (full_name, avatar_url)
      )
    \`)
    .eq('is_published', true)
    .order('created_at', { ascending: false })
    .limit(20)

  if (error) return NextResponse.json({ error: error.message }, { status: 500 })
  return NextResponse.json({ reviews: data })
}

export async function POST(request: Request) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })

  // Validate it's a customer
  const { data: profile } = await supabase.from('profiles').select('role').eq('id', user.id).single()
  if (profile?.role !== 'customer') {
    return NextResponse.json({ error: 'Only customers can submit reviews' }, { status: 403 })
  }

  const body = await request.json()
  const { rating_overall, rating_food, rating_service, rating_ambience, rating_cleanliness, review_text, order_id } = body

  // Validate ratings
  const ratings = [rating_overall, rating_food, rating_service, rating_ambience, rating_cleanliness]
  if (ratings.some(r => r < 1 || r > 5)) {
    return NextResponse.json({ error: 'Ratings must be between 1 and 5' }, { status: 400 })
  }

  const { data: review, error } = await supabase
    .from('reviews')
    .insert({
      customer_id: user.id,
      order_id: order_id || null,
      rating_overall,
      rating_food,
      rating_service,
      rating_ambience,
      rating_cleanliness,
      review_text: review_text?.trim() || null,
      points_awarded: 20,
    })
    .select()
    .single()

  if (error) return NextResponse.json({ error: error.message }, { status: 500 })
  return NextResponse.json({ review }, { status: 201 })
}
`;

// ─────────────────────────────────────────
// FILE: src/app/api/analytics/route.ts
// ─────────────────────────────────────────
export const analyticsApiCode = `
import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(request: Request) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })

  const { data: profile } = await supabase.from('profiles').select('role').eq('id', user.id).single()
  if (!['owner', 'staff'].includes(profile?.role || '')) {
    return NextResponse.json({ error: 'Access denied' }, { status: 403 })
  }

  const { searchParams } = new URL(request.url)
  const range = searchParams.get('range') || 'week'

  const today = new Date()
  let startDate: Date

  if (range === 'day') startDate = new Date(today.setHours(0,0,0,0))
  else if (range === 'week') startDate = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
  else if (range === 'month') startDate = new Date(today.getFullYear(), today.getMonth(), 1)
  else startDate = new Date(today.getFullYear(), 0, 1)

  // Total revenue
  const { data: revenueData } = await supabase
    .from('orders')
    .select('total, created_at')
    .gte('created_at', startDate.toISOString())
    .eq('status', 'completed')

  const totalRevenue = revenueData?.reduce((s, o) => s + o.total, 0) || 0
  const totalOrders = revenueData?.length || 0
  const avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0

  // Top items
  const { data: topItems } = await supabase
    .from('order_items')
    .select('name, quantity, menu_item_id')
    .gte('created_at', startDate.toISOString())

  // Customer count
  const { count: customerCount } = await supabase
    .from('customers')
    .select('*', { count: 'exact', head: true })

  // Average rating
  const { data: ratingData } = await supabase
    .from('reviews')
    .select('rating_overall')
    .gte('created_at', startDate.toISOString())

  const avgRating = ratingData && ratingData.length > 0
    ? ratingData.reduce((s, r) => s + r.rating_overall, 0) / ratingData.length
    : 0

  return NextResponse.json({
    totalRevenue,
    totalOrders,
    avgOrderValue: Math.round(avgOrderValue),
    customerCount: customerCount || 0,
    avgRating: Math.round(avgRating * 10) / 10,
    topItems: topItems?.slice(0, 5) || [],
  })
}
`;

// ─────────────────────────────────────────
// FILE: src/app/api/notifications/route.ts
// ─────────────────────────────────────────
export const notificationsApiCode = `
import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })

  const { data, error } = await supabase
    .from('notifications')
    .select('*')
    .eq('user_id', user.id)
    .order('created_at', { ascending: false })
    .limit(20)

  if (error) return NextResponse.json({ error: error.message }, { status: 500 })
  return NextResponse.json({ notifications: data })
}

export async function PATCH(request: Request) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })

  const { id } = await request.json()

  const { error } = await supabase
    .from('notifications')
    .update({ is_read: true })
    .eq('id', id)
    .eq('user_id', user.id)

  if (error) return NextResponse.json({ error: error.message }, { status: 500 })
  return NextResponse.json({ success: true })
}
`;

// ─────────────────────────────────────────
// FILE: src/hooks/useAuth.ts
// ─────────────────────────────────────────
export const useAuthCode = `
'use client'
import { useEffect, useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import type { User } from '@supabase/supabase-js'
import type { UserRole } from '@/types/database'

export function useAuth() {
  const [user, setUser] = useState<User | null>(null)
  const [role, setRole] = useState<UserRole | null>(null)
  const [loading, setLoading] = useState(true)
  const supabase = createClient()

  useEffect(() => {
    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
      setUser(session?.user ?? null)

      if (session?.user) {
        const { data } = await supabase
          .from('profiles')
          .select('role')
          .eq('id', session.user.id)
          .single()
        setRole(data?.role ?? null)
      } else {
        setRole(null)
      }
      setLoading(false)
    })

    return () => subscription.unsubscribe()
  }, [])

  const signOut = async () => {
    await supabase.auth.signOut()
    setUser(null)
    setRole(null)
  }

  return { user, role, loading, signOut }
}
`;

// ─────────────────────────────────────────
// FILE: src/hooks/useRealtime.ts
// ─────────────────────────────────────────
export const useRealtimeCode = `
'use client'
import { useEffect } from 'react'
import { createClient } from '@/lib/supabase/client'

export function useRealtimeOrders(onUpdate: (order: any) => void) {
  const supabase = createClient()

  useEffect(() => {
    const channel = supabase
      .channel('orders-realtime')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'orders' },
        (payload) => onUpdate(payload.new)
      )
      .subscribe()

    return () => { supabase.removeChannel(channel) }
  }, [])
}

export function useRealtimeNotifications(userId: string, onNotif: (n: any) => void) {
  const supabase = createClient()

  useEffect(() => {
    const channel = supabase
      .channel('notifications-' + userId)
      .on(
        'postgres_changes',
        { event: 'INSERT', schema: 'public', table: 'notifications', filter: \`user_id=eq.\${userId}\` },
        (payload) => onNotif(payload.new)
      )
      .subscribe()

    return () => { supabase.removeChannel(channel) }
  }, [userId])
}
`;

// ─────────────────────────────────────────
// FILE: tailwind.config.ts
// ─────────────────────────────────────────
export const tailwindConfig = `
import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        green: {
          400: '#4ADE80',
          500: '#22C55E',
          600: '#16A34A',
        },
        gold: '#F59E0B',
        cafe: {
          bg: '#0A0F0A',
          card: '#111811',
          card2: '#162016',
          border: 'rgba(255,255,255,0.07)',
        },
      },
      fontFamily: {
        sans: ['DM Sans', 'sans-serif'],
        display: ['Playfair Display', 'serif'],
        mono: ['DM Mono', 'monospace'],
      },
      borderRadius: {
        'xl2': '20px',
        '2xl': '16px',
      },
    },
  },
  plugins: [],
}
export default config
`;

console.log("All Next.js source files documented.");
