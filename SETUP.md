# Database Setup

Run these SQL files **in order** in your Supabase SQL Editor.

## Order of Execution

```
1. supabase-schema.sql    ← Run first (creates tables, triggers, seed data)
2. rls-policies.sql       ← Run second (Row Level Security policies)
3. fix-signup-rls.sql     ← Run third (fixes customer signup trigger bug)
```

## After Running SQL — Create Owner Account

1. Supabase Dashboard → Authentication → Users → Add User
2. Enter your email and a strong password → click Create
3. Copy the UUID shown in the users list
4. Run this in SQL Editor:

```sql
UPDATE profiles
SET role = 'owner', full_name = 'Your Name'
WHERE id = 'PASTE-UUID-HERE';
```

## Adding Staff Members

Staff cannot self-register as staff (security by design).
After a staff member creates a normal customer account, run:

```sql
UPDATE profiles
SET role = 'staff'
WHERE id = (SELECT id FROM auth.users WHERE email = 'staff@example.com');

INSERT INTO staff (id, staff_role)
SELECT id, 'Cashier'
FROM profiles
WHERE id = (SELECT id FROM auth.users WHERE email = 'staff@example.com');
```

## Seed Data Included

`supabase-schema.sql` includes seed data for:
- 12 menu items (pizzas, burgers, mocktails, desserts)
- 6 default offers
