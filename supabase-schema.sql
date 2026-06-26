-- ═══════════════════════════════════════════════════════════════
-- BULL'S & TRADING CAFE — SUPABASE POSTGRESQL SCHEMA
-- Production-Ready · Row Level Security · Full Relationships
-- ═══════════════════════════════════════════════════════════════

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ═══════════════════════════════════════════
-- 1. ENUM TYPES
-- ═══════════════════════════════════════════
CREATE TYPE user_role AS ENUM ('owner', 'staff', 'customer');
CREATE TYPE order_status AS ENUM ('pending', 'preparing', 'ready', 'completed', 'cancelled');
CREATE TYPE item_category AS ENUM ('pizza', 'burger', 'mocktail', 'dessert', 'other');
CREATE TYPE audit_action AS ENUM ('login', 'logout', 'create', 'update', 'delete', 'view');

-- ═══════════════════════════════════════════
-- 2. PROFILES TABLE (extends Supabase Auth users)
-- ═══════════════════════════════════════════
CREATE TABLE profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role          user_role NOT NULL DEFAULT 'customer',
  full_name     TEXT NOT NULL,
  phone         TEXT,
  avatar_url    TEXT,
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ═══════════════════════════════════════════
-- 3. CUSTOMERS TABLE
-- ═══════════════════════════════════════════
CREATE TABLE customers (
  id              UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  loyalty_points  INTEGER NOT NULL DEFAULT 50,
  birthday        DATE,
  instagram_handle TEXT,
  total_orders    INTEGER NOT NULL DEFAULT 0,
  total_spent     NUMERIC(10,2) NOT NULL DEFAULT 0,
  last_visit      TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ═══════════════════════════════════════════
-- 4. STAFF TABLE
-- ═══════════════════════════════════════════
CREATE TABLE staff (
  id              UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  staff_role      TEXT NOT NULL DEFAULT 'Staff',  -- e.g. Head Chef, Cashier
  orders_today    INTEGER NOT NULL DEFAULT 0,
  hire_date       DATE NOT NULL DEFAULT CURRENT_DATE,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_by      UUID REFERENCES profiles(id),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ═══════════════════════════════════════════
-- 5. MENU ITEMS TABLE
-- ═══════════════════════════════════════════
CREATE TABLE menu_items (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name          TEXT NOT NULL,
  description   TEXT,
  category      item_category NOT NULL,
  price         NUMERIC(8,2) NOT NULL CHECK (price >= 0),
  emoji         TEXT DEFAULT '🍽️',
  image_url     TEXT,
  is_available  BOOLEAN NOT NULL DEFAULT TRUE,
  is_featured   BOOLEAN NOT NULL DEFAULT FALSE,
  sort_order    INTEGER NOT NULL DEFAULT 0,
  created_by    UUID REFERENCES profiles(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ═══════════════════════════════════════════
-- 6. OFFERS TABLE
-- ═══════════════════════════════════════════
CREATE TABLE offers (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title           TEXT NOT NULL,
  description     TEXT,
  emoji           TEXT DEFAULT '🔥',
  offer_price     NUMERIC(8,2) NOT NULL CHECK (offer_price >= 0),
  original_price  NUMERIC(8,2) NOT NULL CHECK (original_price >= 0),
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  valid_from      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  valid_until     TIMESTAMPTZ,
  created_by      UUID REFERENCES profiles(id),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ═══════════════════════════════════════════
-- 7. ORDERS TABLE
-- ═══════════════════════════════════════════
CREATE TABLE orders (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_number    TEXT UNIQUE NOT NULL,  -- e.g. ORD-101
  customer_id     UUID REFERENCES profiles(id),
  staff_id        UUID REFERENCES profiles(id),
  status          order_status NOT NULL DEFAULT 'pending',
  subtotal        NUMERIC(10,2) NOT NULL DEFAULT 0,
  tax             NUMERIC(10,2) NOT NULL DEFAULT 0,
  discount        NUMERIC(10,2) NOT NULL DEFAULT 0,
  total           NUMERIC(10,2) NOT NULL DEFAULT 0,
  notes           TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ═══════════════════════════════════════════
-- 8. ORDER ITEMS TABLE
-- ═══════════════════════════════════════════
CREATE TABLE order_items (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id      UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  menu_item_id  UUID NOT NULL REFERENCES menu_items(id),
  name          TEXT NOT NULL,  -- snapshot at time of order
  price         NUMERIC(8,2) NOT NULL,
  quantity      INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
  subtotal      NUMERIC(10,2) GENERATED ALWAYS AS (price * quantity) STORED,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ═══════════════════════════════════════════
-- 9. REVIEWS TABLE
-- ═══════════════════════════════════════════
CREATE TABLE reviews (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id       UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  order_id          UUID REFERENCES orders(id),
  rating_overall    SMALLINT NOT NULL CHECK (rating_overall BETWEEN 1 AND 5),
  rating_food       SMALLINT NOT NULL CHECK (rating_food BETWEEN 1 AND 5),
  rating_service    SMALLINT NOT NULL CHECK (rating_service BETWEEN 1 AND 5),
  rating_ambience   SMALLINT NOT NULL CHECK (rating_ambience BETWEEN 1 AND 5),
  rating_cleanliness SMALLINT NOT NULL CHECK (rating_cleanliness BETWEEN 1 AND 5),
  review_text       TEXT,
  owner_reply       TEXT,
  reply_at          TIMESTAMPTZ,
  is_published      BOOLEAN NOT NULL DEFAULT TRUE,
  points_awarded    INTEGER NOT NULL DEFAULT 20,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ═══════════════════════════════════════════
-- 10. NOTIFICATIONS TABLE
-- ═══════════════════════════════════════════
CREATE TABLE notifications (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  body        TEXT,
  type        TEXT NOT NULL DEFAULT 'info', -- info, success, warning, alert
  is_read     BOOLEAN NOT NULL DEFAULT FALSE,
  data        JSONB,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ═══════════════════════════════════════════
-- 11. AUDIT LOGS TABLE
-- ═══════════════════════════════════════════
CREATE TABLE audit_logs (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID REFERENCES profiles(id),
  action      audit_action NOT NULL,
  table_name  TEXT,
  record_id   UUID,
  old_data    JSONB,
  new_data    JSONB,
  ip_address  TEXT,
  user_agent  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ═══════════════════════════════════════════
-- 12. ANALYTICS / DAILY SNAPSHOTS TABLE
-- ═══════════════════════════════════════════
CREATE TABLE daily_analytics (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  date            DATE UNIQUE NOT NULL DEFAULT CURRENT_DATE,
  total_orders    INTEGER NOT NULL DEFAULT 0,
  total_revenue   NUMERIC(12,2) NOT NULL DEFAULT 0,
  total_customers INTEGER NOT NULL DEFAULT 0,
  new_customers   INTEGER NOT NULL DEFAULT 0,
  avg_order_value NUMERIC(8,2),
  top_item_id     UUID REFERENCES menu_items(id),
  top_item_qty    INTEGER,
  pizza_revenue   NUMERIC(10,2) NOT NULL DEFAULT 0,
  burger_revenue  NUMERIC(10,2) NOT NULL DEFAULT 0,
  mocktail_revenue NUMERIC(10,2) NOT NULL DEFAULT 0,
  dessert_revenue NUMERIC(10,2) NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ═══════════════════════════════════════════
-- 13. LOYALTY TRANSACTIONS TABLE
-- ═══════════════════════════════════════════
CREATE TABLE loyalty_transactions (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id   UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  points        INTEGER NOT NULL,  -- positive = earned, negative = redeemed
  reason        TEXT NOT NULL,     -- 'review', 'referral', 'redemption', 'signup'
  reference_id  UUID,              -- order_id or review_id
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ═══════════════════════════════════════════
-- INDEXES FOR PERFORMANCE
-- ═══════════════════════════════════════════
CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_is_active ON profiles(is_active);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_staff_id ON orders(staff_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_menu_item_id ON order_items(menu_item_id);
CREATE INDEX idx_reviews_customer_id ON reviews(customer_id);
CREATE INDEX idx_reviews_created_at ON reviews(created_at DESC);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);
CREATE INDEX idx_menu_items_category ON menu_items(category);
CREATE INDEX idx_menu_items_is_available ON menu_items(is_available);
CREATE INDEX idx_loyalty_customer_id ON loyalty_transactions(customer_id);
CREATE INDEX idx_daily_analytics_date ON daily_analytics(date DESC);

-- ═══════════════════════════════════════════
-- AUTO-UPDATE updated_at TRIGGER
-- ═══════════════════════════════════════════
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_menu_items_updated_at BEFORE UPDATE ON menu_items FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_offers_updated_at BEFORE UPDATE ON offers FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_reviews_updated_at BEFORE UPDATE ON reviews FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ═══════════════════════════════════════════
-- ORDER NUMBER GENERATOR
-- ═══════════════════════════════════════════
CREATE SEQUENCE order_number_seq START 101;

CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
  NEW.order_number = 'ORD-' || LPAD(nextval('order_number_seq')::TEXT, 4, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_order_number
  BEFORE INSERT ON orders
  FOR EACH ROW
  WHEN (NEW.order_number IS NULL OR NEW.order_number = '')
  EXECUTE FUNCTION generate_order_number();

-- ═══════════════════════════════════════════
-- AUTO-CREATE PROFILE ON SIGNUP
-- ═══════════════════════════════════════════
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, role, full_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'role', 'customer')::user_role,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email)
  );

  -- If customer, also create customer record
  IF COALESCE(NEW.raw_user_meta_data->>'role', 'customer') = 'customer' THEN
    INSERT INTO customers (id) VALUES (NEW.id);
    -- Award signup points
    INSERT INTO loyalty_transactions (customer_id, points, reason)
    VALUES (NEW.id, 50, 'signup');
  END IF;

  -- If staff, create staff record
  IF NEW.raw_user_meta_data->>'role' = 'staff' THEN
    INSERT INTO staff (id, staff_role, created_by)
    VALUES (
      NEW.id,
      COALESCE(NEW.raw_user_meta_data->>'staff_role', 'Staff'),
      (NEW.raw_user_meta_data->>'created_by')::UUID
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_new_user
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- ═══════════════════════════════════════════
-- UPDATE CUSTOMER STATS ON ORDER COMPLETE
-- ═══════════════════════════════════════════
CREATE OR REPLACE FUNCTION update_customer_stats()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'completed' AND OLD.status != 'completed' AND NEW.customer_id IS NOT NULL THEN
    UPDATE customers
    SET
      total_orders = total_orders + 1,
      total_spent  = total_spent + NEW.total,
      last_visit   = NOW()
    WHERE id = NEW.customer_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_customer_stats
  AFTER UPDATE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION update_customer_stats();

-- ═══════════════════════════════════════════
-- AWARD LOYALTY POINTS ON REVIEW
-- ═══════════════════════════════════════════
CREATE OR REPLACE FUNCTION award_review_points()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE customers
  SET loyalty_points = loyalty_points + NEW.points_awarded
  WHERE id = NEW.customer_id;

  INSERT INTO loyalty_transactions (customer_id, points, reason, reference_id)
  VALUES (NEW.customer_id, NEW.points_awarded, 'review', NEW.id);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_review_points
  AFTER INSERT ON reviews
  FOR EACH ROW
  EXECUTE FUNCTION award_review_points();

-- ═══════════════════════════════════════════
-- OWNER NOTIFICATION ON NEW REVIEW
-- ═══════════════════════════════════════════
CREATE OR REPLACE FUNCTION notify_owner_review()
RETURNS TRIGGER AS $$
DECLARE owner_id UUID;
BEGIN
  SELECT id INTO owner_id FROM profiles WHERE role = 'owner' LIMIT 1;
  IF owner_id IS NOT NULL THEN
    INSERT INTO notifications (user_id, title, body, type, data)
    VALUES (
      owner_id,
      '⭐ New Review Submitted',
      'A customer left a ' || NEW.rating_overall || '-star review',
      'info',
      jsonb_build_object('review_id', NEW.id, 'rating', NEW.rating_overall)
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_notify_review
  AFTER INSERT ON reviews
  FOR EACH ROW
  EXECUTE FUNCTION notify_owner_review();

-- ═══════════════════════════════════════════
-- SEED DATA — MENU ITEMS
-- ═══════════════════════════════════════════
INSERT INTO menu_items (name, description, category, price, emoji, is_available, is_featured) VALUES
  ('Classic Margherita',  'Fresh tomato sauce, mozzarella, fragrant basil',           'pizza',    119, '🍕', TRUE, TRUE),
  ('Paneer Tikka Pizza',  'Spiced paneer, capsicum, onion & tangy sauce',             'pizza',    129, '🍕', TRUE, FALSE),
  ('Veg Supreme Pizza',   'Loaded veggies, olives, corn & generous cheese pull',      'pizza',    139, '🍕', TRUE, FALSE),
  ('Crispy Veg Burger',   'Golden patty, fresh lettuce, tomato & house sauce',        'burger',   119, '🍔', TRUE, TRUE),
  ('Spicy Chicken Burger','Juicy chicken, jalapeños, crispy slaw & chipotle mayo',    'burger',   139, '🍗', TRUE, FALSE),
  ('Double Stack Burger', 'Two patties, double cheese, caramelised onions',           'burger',   159, '🍔', TRUE, FALSE),
  ('Green Mojito',        'Fresh mint, lime, sugar cane, ice',                        'mocktail', 79,  '🍹', TRUE, FALSE),
  ('Berry Blast',         'Mixed berries, citrus, soda & sweetness',                  'mocktail', 89,  '🥤', TRUE, FALSE),
  ('Cold Coffee',         'Creamy, strong & perfectly chilled',                       'mocktail', 79,  '☕', TRUE, TRUE),
  ('Choco Lava Cake',     'Warm chocolate cake with molten centre',                   'dessert',  59,  '🍫', TRUE, TRUE),
  ('Vanilla Sundae',      'Ice cream, chocolate drizzle & crunch topping',            'dessert',  69,  '🍦', TRUE, FALSE),
  ('Brownie Delight',     'Fudgy brownie served warm with vanilla ice cream',         'dessert',  79,  '🍫', TRUE, FALSE);

-- ═══════════════════════════════════════════
-- SEED DATA — OFFERS
-- ═══════════════════════════════════════════
INSERT INTO offers (title, description, emoji, offer_price, original_price, is_active) VALUES
  ('2 Pizzas Combo',       'Any 2 pizzas at a special price',        '🍕', 119, 238, TRUE),
  ('2 Veg Burgers',        'Great value burger deal',                 '🍔', 119, 238, TRUE),
  ('2 Non-Veg Burgers',    'Chicken burger power combo',              '🍗', 139, 278, TRUE),
  ('Fresh Mocktail',       'Any mocktail at an amazing price',        '🍹', 79,  89,  TRUE),
  ('Choco Lava Cake',      'Indulgent dessert at the best price',     '🍫', 59,  69,  TRUE),
  ('Buy 20 Burgers Deal',  'Buy 20 burgers, get 4 cold coffees FREE', '🔥', 2780, 3096, TRUE);
