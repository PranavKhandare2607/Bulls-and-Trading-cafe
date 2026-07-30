-- ═══════════════════════════════════════════════════════════════
-- BULL'S & TRADING CAFE — ROW LEVEL SECURITY POLICIES
-- Production-Ready · Enterprise-Grade Security
-- ═══════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════
-- ENABLE RLS ON ALL TABLES
-- ═══════════════════════════════════════════
ALTER TABLE profiles              ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers             ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_items            ENABLE ROW LEVEL SECURITY;
ALTER TABLE offers                ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders                ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items           ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews               ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications         ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs            ENABLE ROW LEVEL SECURITY;
ALTER TABLE loyalty_transactions  ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_analytics       ENABLE ROW LEVEL SECURITY;

-- ═══════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════
-- Get current user's role
CREATE OR REPLACE FUNCTION get_user_role()
RETURNS user_role AS $$
  SELECT role FROM profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Check if current user is owner
CREATE OR REPLACE FUNCTION is_owner()
RETURNS BOOLEAN AS $$
  SELECT get_user_role() = 'owner';
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Check if current user is staff or owner
CREATE OR REPLACE FUNCTION is_staff_or_owner()
RETURNS BOOLEAN AS $$
  SELECT get_user_role() IN ('owner', 'staff');
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- ═══════════════════════════════════════════
-- PROFILES POLICIES
-- ═══════════════════════════════════════════
-- Users can view their own profile
CREATE POLICY "profiles_select_own"
  ON profiles FOR SELECT
  USING (id = auth.uid());

-- Owner can view all profiles
CREATE POLICY "profiles_select_owner"
  ON profiles FOR SELECT
  USING (is_owner());

-- Staff can view all profiles (for order management)
CREATE POLICY "profiles_select_staff"
  ON profiles FOR SELECT
  USING (is_staff_or_owner());

-- Users can update their own profile
CREATE POLICY "profiles_update_own"
  ON profiles FOR UPDATE
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- Owner can update any profile
CREATE POLICY "profiles_update_owner"
  ON profiles FOR UPDATE
  USING (is_owner());

-- System can insert profiles (via trigger)
CREATE POLICY "profiles_insert_system"
  ON profiles FOR INSERT
  WITH CHECK (id = auth.uid() OR is_owner());

-- Only owner can delete profiles
CREATE POLICY "profiles_delete_owner"
  ON profiles FOR DELETE
  USING (is_owner());

-- ═══════════════════════════════════════════
-- CUSTOMERS POLICIES
-- ═══════════════════════════════════════════
-- Customers can view only their own record
CREATE POLICY "customers_select_own"
  ON customers FOR SELECT
  USING (id = auth.uid());

-- Owner and staff can view all customers
CREATE POLICY "customers_select_staff"
  ON customers FOR SELECT
  USING (is_staff_or_owner());

-- Customers can update their own record
CREATE POLICY "customers_update_own"
  ON customers FOR UPDATE
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- Owner can update any customer
CREATE POLICY "customers_update_owner"
  ON customers FOR UPDATE
  USING (is_owner());

-- System inserts customer records (via trigger)
CREATE POLICY "customers_insert_system"
  ON customers FOR INSERT
  WITH CHECK (id = auth.uid() OR is_owner());

-- ═══════════════════════════════════════════
-- STAFF POLICIES
-- ═══════════════════════════════════════════
-- Staff can view their own record
CREATE POLICY "staff_select_own"
  ON staff FOR SELECT
  USING (id = auth.uid());

-- Owner can view all staff
CREATE POLICY "staff_select_owner"
  ON staff FOR SELECT
  USING (is_owner());

-- Only owner can manage staff
CREATE POLICY "staff_insert_owner"
  ON staff FOR INSERT
  WITH CHECK (is_owner());

CREATE POLICY "staff_update_owner"
  ON staff FOR UPDATE
  USING (is_owner());

CREATE POLICY "staff_delete_owner"
  ON staff FOR DELETE
  USING (is_owner());

-- ═══════════════════════════════════════════
-- MENU ITEMS POLICIES
-- ═══════════════════════════════════════════
-- Everyone (including anonymous) can view available menu items
CREATE POLICY "menu_select_public"
  ON menu_items FOR SELECT
  USING (is_available = TRUE OR is_staff_or_owner());

-- Only owner can modify menu
CREATE POLICY "menu_insert_owner"
  ON menu_items FOR INSERT
  WITH CHECK (is_owner());

CREATE POLICY "menu_update_owner"
  ON menu_items FOR UPDATE
  USING (is_owner());

CREATE POLICY "menu_delete_owner"
  ON menu_items FOR DELETE
  USING (is_owner());

-- ═══════════════════════════════════════════
-- OFFERS POLICIES
-- ═══════════════════════════════════════════
-- Everyone can view active offers
CREATE POLICY "offers_select_public"
  ON offers FOR SELECT
  USING (is_active = TRUE OR is_owner());

-- Only owner can manage offers
CREATE POLICY "offers_insert_owner"
  ON offers FOR INSERT
  WITH CHECK (is_owner());

CREATE POLICY "offers_update_owner"
  ON offers FOR UPDATE
  USING (is_owner());

CREATE POLICY "offers_delete_owner"
  ON offers FOR DELETE
  USING (is_owner());

-- ═══════════════════════════════════════════
-- ORDERS POLICIES
-- ═══════════════════════════════════════════
-- Customers can view their own orders
CREATE POLICY "orders_select_own"
  ON orders FOR SELECT
  USING (customer_id = auth.uid());

-- Staff and owner can view all orders
CREATE POLICY "orders_select_staff"
  ON orders FOR SELECT
  USING (is_staff_or_owner());

-- Customers can create orders
CREATE POLICY "orders_insert_customer"
  ON orders FOR INSERT
  WITH CHECK (customer_id = auth.uid() OR is_staff_or_owner());

-- Staff and owner can update orders (change status)
CREATE POLICY "orders_update_staff"
  ON orders FOR UPDATE
  USING (is_staff_or_owner());

-- Only owner can delete orders
CREATE POLICY "orders_delete_owner"
  ON orders FOR DELETE
  USING (is_owner());

-- ═══════════════════════════════════════════
-- ORDER ITEMS POLICIES
-- ═══════════════════════════════════════════
-- Customers can view items in their own orders
CREATE POLICY "order_items_select_own"
  ON order_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM orders
      WHERE orders.id = order_items.order_id
      AND orders.customer_id = auth.uid()
    )
  );

-- Staff/owner can view all order items
CREATE POLICY "order_items_select_staff"
  ON order_items FOR SELECT
  USING (is_staff_or_owner());

-- Insertable by authenticated users (linked to order)
CREATE POLICY "order_items_insert"
  ON order_items FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM orders
      WHERE orders.id = order_items.order_id
      AND (orders.customer_id = auth.uid() OR is_staff_or_owner())
    )
  );

-- Only staff/owner can update order items
CREATE POLICY "order_items_update_staff"
  ON order_items FOR UPDATE
  USING (is_staff_or_owner());

-- ═══════════════════════════════════════════
-- REVIEWS POLICIES
-- ═══════════════════════════════════════════
-- Everyone can read published reviews
CREATE POLICY "reviews_select_public"
  ON reviews FOR SELECT
  USING (is_published = TRUE OR customer_id = auth.uid() OR is_owner());

-- Only logged-in customers can submit reviews
CREATE POLICY "reviews_insert_customer"
  ON reviews FOR INSERT
  WITH CHECK (
    customer_id = auth.uid()
    AND get_user_role() = 'customer'
  );

-- Customers can update their own reviews
CREATE POLICY "reviews_update_own"
  ON reviews FOR UPDATE
  USING (customer_id = auth.uid())
  WITH CHECK (customer_id = auth.uid());

-- Owner can update reviews (for replies, moderation)
CREATE POLICY "reviews_update_owner"
  ON reviews FOR UPDATE
  USING (is_owner());

-- Owner can delete inappropriate reviews
CREATE POLICY "reviews_delete_owner"
  ON reviews FOR DELETE
  USING (is_owner());

-- ═══════════════════════════════════════════
-- NOTIFICATIONS POLICIES
-- ═══════════════════════════════════════════
-- Users can only see their own notifications
CREATE POLICY "notif_select_own"
  ON notifications FOR SELECT
  USING (user_id = auth.uid());

-- System can insert notifications (via functions)
CREATE POLICY "notif_insert_system"
  ON notifications FOR INSERT
  WITH CHECK (is_owner() OR is_staff_or_owner());

-- Users can mark their own as read
CREATE POLICY "notif_update_own"
  ON notifications FOR UPDATE
  USING (user_id = auth.uid());

-- ═══════════════════════════════════════════
-- AUDIT LOGS POLICIES
-- ═══════════════════════════════════════════
-- Only owner can view audit logs
CREATE POLICY "audit_select_owner"
  ON audit_logs FOR SELECT
  USING (is_owner());

-- System inserts audit logs
CREATE POLICY "audit_insert_system"
  ON audit_logs FOR INSERT
  WITH CHECK (TRUE);  -- Allow all inserts; controlled via service role

-- ═══════════════════════════════════════════
-- LOYALTY TRANSACTIONS POLICIES
-- ═══════════════════════════════════════════
-- Customers see their own transactions
CREATE POLICY "loyalty_select_own"
  ON loyalty_transactions FOR SELECT
  USING (customer_id = auth.uid());

-- Owner can see all
CREATE POLICY "loyalty_select_owner"
  ON loyalty_transactions FOR SELECT
  USING (is_owner());

-- System inserts (via triggers)
CREATE POLICY "loyalty_insert_system"
  ON loyalty_transactions FOR INSERT
  WITH CHECK (customer_id = auth.uid() OR is_staff_or_owner());

-- ═══════════════════════════════════════════
-- DAILY ANALYTICS POLICIES
-- ═══════════════════════════════════════════
-- Only owner and staff can view analytics
CREATE POLICY "analytics_select_staff"
  ON daily_analytics FOR SELECT
  USING (is_staff_or_owner());

-- Only system/owner can write analytics
CREATE POLICY "analytics_insert_owner"
  ON daily_analytics FOR INSERT
  WITH CHECK (is_owner());

CREATE POLICY "analytics_update_owner"
  ON daily_analytics FOR UPDATE
  USING (is_owner());
