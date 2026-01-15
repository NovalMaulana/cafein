## 📋 QUERY

```sql
-- ============================================
-- 1. BUAT TABEL PROFILES
-- ============================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT NOT NULL,
  full_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 2. AKTIFKAN KEAMANAN (RLS)
-- ============================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cafes ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 3. ATURAN KEAMANAN PROFILES
-- ============================================
-- User bisa lihat profil sendiri
CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

-- User bisa buat profil sendiri
CREATE POLICY "Users can insert their own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- User bisa update profil sendiri
CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- User bisa hapus profil sendiri
CREATE POLICY "Users can delete their own profile"
  ON public.profiles FOR DELETE
  USING (auth.uid() = id);

-- ============================================
-- 4. UPDATE TABEL CAFES
-- ============================================
-- Tambah kolom user_id
ALTER TABLE public.cafes 
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- Tambah kolom address
ALTER TABLE public.cafes 
ADD COLUMN IF NOT EXISTS address TEXT;

-- ============================================
-- 5. ATURAN KEAMANAN CAFES
-- ============================================
-- Semua user bisa lihat semua cafe
CREATE POLICY "Users can view all cafes"
  ON public.cafes FOR SELECT
  USING (true);

-- User hanya bisa tambah cafe dengan user_id sendiri
CREATE POLICY "Users can insert their own cafes"
  ON public.cafes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- User hanya bisa update cafe milik sendiri
CREATE POLICY "Users can update their own cafes"
  ON public.cafes FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- User hanya bisa delete cafe milik sendiri
CREATE POLICY "Users can delete their own cafes"
  ON public.cafes FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- 6. FUNGSI AUTO UPDATE TIMESTAMP
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 7. TRIGGER AUTO UPDATE
-- ============================================
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- ============================================
-- 8. INDEX UNTUK PERFORMA
-- ============================================
CREATE INDEX IF NOT EXISTS idx_cafes_user_id ON public.cafes(user_id);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
```

---

## ✅ Verifikasi Setup

Setelah menjalankan query di atas, jalankan query ini untuk cek:

```sql
-- Cek tabel profiles sudah dibuat
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'profiles';

-- Cek tabel cafes sudah diupdate
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'cafes';

-- Cek RLS policies sudah aktif
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE tablename IN ('profiles', 'cafes');
```

**Expected Result:**
- Tabel `profiles` punya kolom: id, email, full_name, created_at, updated_at
- Tabel `cafes` punya kolom tambahan: user_id, address
- Ada 8 policies total (4 untuk profiles, 4 untuk cafes)

---

## 🔧 Setup Email Authentication

1. Di Supabase Dashboard, pergi ke **Authentication** → **Providers**
2. Pastikan **Email** sudah enabled (toggle ON)
3. **PENTING untuk Testing**: Disable email confirmation
   - Pergi ke **Authentication** → **Settings**
   - Scroll ke **Email Auth**
   - **Uncheck** "Enable email confirmations"
   - Klik **Save**

---

## 🧪 Test Query

### Lihat semua profiles
```sql
SELECT * FROM public.profiles;
```

### Lihat semua cafes dengan info user
```sql
SELECT 
  c.id,
  c.name,
  c.lat,
  c.lng,
  c.address,
  p.full_name as owner_name,
  p.email as owner_email
FROM public.cafes c
LEFT JOIN public.profiles p ON c.user_id = p.id;
```

### Reset data (HATI-HATI!)
```sql
-- Hapus semua cafe
DELETE FROM public.cafes;

-- Hapus semua profile
DELETE FROM public.profiles;
```
