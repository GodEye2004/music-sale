-- Enable Storage
-- NOTE: Storage is enabled by default in Supabase projects

-- 1. Create Buckets
-- Bucket for Audio Files (Beats)
INSERT INTO storage.buckets (id, name, public)
VALUES ('beats', 'beats', true)
ON CONFLICT (id) DO NOTHING;

-- Bucket for Cover Images
INSERT INTO storage.buckets (id, name, public)
VALUES ('covers', 'covers', true)
ON CONFLICT (id) DO NOTHING;

-- Bucket for Profile Pictures
INSERT INTO storage.buckets (id, name, public)
VALUES ('profiles', 'profiles', true)
ON CONFLICT (id) DO NOTHING;


-- 2. Set Up Security Policies (RLS)

-- BEATS BUCKET POLICIES
-- Anyone can view (download) beats
CREATE POLICY "Public View Beats"
ON storage.objects FOR SELECT
USING ( bucket_id = 'beats' );

-- Only authenticated users (Producers) can upload beats
CREATE POLICY "Authenticated Upload Beats"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'beats' AND
  auth.role() = 'authenticated'
);

-- Users can only update/delete their own files
CREATE POLICY "Owner Manage Beats"
ON storage.objects FOR ALL
USING (
  bucket_id = 'beats' AND
  auth.uid() = owner
);


-- COVERS BUCKET POLICIES
-- Anyone can view covers
CREATE POLICY "Public View Covers"
ON storage.objects FOR SELECT
USING ( bucket_id = 'covers' );

-- Authenticated upload
CREATE POLICY "Authenticated Upload Covers"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'covers' AND
  auth.role() = 'authenticated'
);

-- Owner manage
CREATE POLICY "Owner Manage Covers"
ON storage.objects FOR ALL
USING (
  bucket_id = 'covers' AND
  auth.uid() = owner
);


-- PROFILES BUCKET POLICIES
-- Anyone can view profiles
CREATE POLICY "Public View Profiles"
ON storage.objects FOR SELECT
USING ( bucket_id = 'profiles' );

-- Authenticated upload
CREATE POLICY "Authenticated Upload Profiles"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'profiles' AND
  auth.role() = 'authenticated'
);

-- Owner manage
CREATE POLICY "Owner Manage Profiles"
ON storage.objects FOR ALL
USING (
  bucket_id = 'profiles' AND
  auth.uid() = owner
);
