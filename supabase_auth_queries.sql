-- ============================================
-- SUPABASE SQL QUERIES UNTUK AUTHENTICATION
-- ============================================

-- 1. CREATE TABLE PROFILES
-- Tabel ini menyimpan informasi profil user
-- Terhubung dengan auth.users melalui foreign key
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT NOT NULL,
  full_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. ENABLE ROW LEVEL SECURITY (RLS)
-- Aktifkan RLS untuk keamanan data
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 3. CREATE POLICIES
-- Policy untuk SELECT: User hanya bisa melihat profil mereka sendiri
CREATE POLICY "Users can view their own profile"
  ON public.profiles
  FOR SELECT
  USING (auth.uid() = id);

-- Policy untuk INSERT: User bisa membuat profil mereka sendiri
CREATE POLICY "Users can insert their own profile"
  ON public.profiles
  FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Policy untuk UPDATE: User hanya bisa update profil mereka sendiri
CREATE POLICY "Users can update their own profile"
  ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Policy untuk DELETE: User bisa menghapus profil mereka sendiri
CREATE POLICY "Users can delete their own profile"
  ON public.profiles
  FOR DELETE
  USING (auth.uid() = id);

-- 4. UPDATE CAFES TABLE
-- Tambahkan kolom user_id ke tabel cafes yang sudah ada
-- Ini akan menghubungkan setiap cafe dengan user yang membuatnya
ALTER TABLE public.cafes 
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- Tambahkan kolom address jika belum ada (untuk menyimpan alamat cafe)
ALTER TABLE public.cafes 
ADD COLUMN IF NOT EXISTS address TEXT;

-- 5. UPDATE CAFES TABLE RLS
-- Aktifkan RLS untuk tabel cafes
ALTER TABLE public.cafes ENABLE ROW LEVEL SECURITY;

-- Policy untuk SELECT: User bisa melihat semua cafe (public)
-- Atau bisa diubah menjadi hanya cafe milik user sendiri
CREATE POLICY "Users can view all cafes"
  ON public.cafes
  FOR SELECT
  USING (true); -- Semua user bisa lihat semua cafe

-- Alternatif: Jika ingin user hanya bisa lihat cafe milik mereka sendiri
-- CREATE POLICY "Users can view their own cafes"
--   ON public.cafes
--   FOR SELECT
--   USING (auth.uid() = user_id);

-- Policy untuk INSERT: User hanya bisa menambah cafe dengan user_id mereka sendiri
CREATE POLICY "Users can insert their own cafes"
  ON public.cafes
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy untuk UPDATE: User hanya bisa update cafe milik mereka sendiri
CREATE POLICY "Users can update their own cafes"
  ON public.cafes
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy untuk DELETE: User hanya bisa delete cafe milik mereka sendiri
CREATE POLICY "Users can delete their own cafes"
  ON public.cafes
  FOR DELETE
  USING (auth.uid() = user_id);

-- 6. CREATE FUNCTION: Auto update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. CREATE TRIGGER: Auto update updated_at pada profiles
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- 8. CREATE INDEX untuk performa
CREATE INDEX IF NOT EXISTS idx_cafes_user_id ON public.cafes(user_id);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);

-- ============================================
-- CATATAN PENTING:
-- ============================================
-- 1. Jalankan query ini di Supabase SQL Editor
-- 2. Authentication sudah otomatis dihandle oleh Supabase Auth
-- 3. Pastikan Email Auth sudah diaktifkan di Supabase Dashboard
--    (Authentication > Providers > Email)
-- 4. Untuk testing, bisa disable email confirmation di:
--    Authentication > Settings > Email Auth > 
--    Uncheck "Enable email confirmations"
-- 5. Setelah menjalankan query ini, update cafe_service.dart
--    untuk menambahkan user_id saat insert cafe

-- ============================================
-- QUERY UNTUK TESTING (OPTIONAL)
-- ============================================

-- Lihat semua profiles
-- SELECT * FROM public.profiles;

-- Lihat semua cafes dengan info user
-- SELECT c.*, p.full_name, p.email 
-- FROM public.cafes c
-- LEFT JOIN public.profiles p ON c.user_id = p.id;

-- Hapus semua data (untuk reset testing)
-- DELETE FROM public.cafes;
-- DELETE FROM public.profiles;
