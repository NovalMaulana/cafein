# 🔧 TROUBLESHOOTING: Email Address Invalid Error

## ❌ Error yang Muncul
```
AuthApiException(message: Email address "noval@gmail.com" is invalid, statusCode: 400, code: email_address_invalid)
```

---

## 🎯 Solusi Cepat

### **Opsi 1: Cek Email Validation di Supabase (RECOMMENDED)**

1. **Buka Supabase Dashboard**
   - Pergi ke: https://app.supabase.com
   - Pilih project **nongki**

2. **Pergi ke Authentication Settings**
   - Klik **Authentication** di sidebar
   - Klik **Settings**
   - Scroll ke bagian **Email Auth**

3. **Disable Email Validation yang Ketat**
   - Cari setting **"Email validation"** atau **"Email provider"**
   - Pastikan setting berikut:
     - ✅ **Enable email confirmations**: OFF (untuk testing)
     - ✅ **Enable email provider**: ON
     - ✅ **Minimum password length**: 6 (default)

4. **Cek SMTP Settings (Jika ada)**
   - Jika ada custom SMTP, pastikan sudah dikonfigurasi dengan benar
   - Untuk testing, gunakan **default Supabase email provider**

5. **Save Changes**
   - Klik **Save** di bagian bawah
   - Tunggu beberapa detik untuk perubahan diterapkan

---

### **Opsi 2: Gunakan Email yang Berbeda**

Beberapa email domain mungkin diblokir. Coba gunakan:
- ✅ Gmail: `test@gmail.com`
- ✅ Outlook: `test@outlook.com`
- ✅ Yahoo: `test@yahoo.com`
- ✅ Email domain lain yang valid

**PENTING:** Pastikan email yang digunakan adalah **email yang benar-benar ada** jika email confirmation diaktifkan.

---

### **Opsi 3: Cek Rate Limiting**

1. Buka **Supabase Dashboard** → **Authentication** → **Rate Limits**
2. Pastikan tidak ada rate limiting yang terlalu ketat
3. Untuk development, bisa set rate limit lebih tinggi

---

### **Opsi 4: Gunakan Test Email dari Supabase**

Supabase menyediakan test email untuk development:

1. Buka **Authentication** → **Users**
2. Klik **Add User** (manual)
3. Buat user test dengan email apapun
4. Gunakan kredensial tersebut untuk login

---

## 🔍 Debug Steps

### **1. Cek Console Log**

Setelah update code terbaru, cek console log di Flutter:
```
Attempting to register with email: noval@gmail.com
SignUp response: <user_id> atau error
Auth error: <error message>
```

### **2. Test dengan Email Sederhana**

Coba register dengan email yang sangat sederhana:
- Email: `test@test.com`
- Password: `123456`
- Nama: `Test User`

### **3. Cek Supabase Logs**

1. Buka **Supabase Dashboard**
2. Pergi ke **Logs** → **Auth Logs**
3. Lihat error detail yang muncul saat register

---

## 🛠️ Kemungkinan Penyebab

### **1. Email Confirmation Masih Aktif**
- **Solusi**: Disable di Authentication → Settings → Email Auth

### **2. SMTP Configuration Error**
- **Solusi**: Gunakan default Supabase email provider

### **3. Domain Blocklist**
- **Solusi**: Gunakan email domain yang berbeda

### **4. Rate Limiting**
- **Solusi**: Tunggu beberapa menit atau reset rate limit

### **5. Supabase Project Issue**
- **Solusi**: Restart project atau buat project baru

---

## ✅ Verifikasi Setting Supabase

Jalankan query ini di **SQL Editor** untuk cek konfigurasi:

```sql
-- Cek auth config
SELECT * FROM auth.config;

-- Cek users yang sudah ada
SELECT id, email, created_at, confirmed_at 
FROM auth.users;
```

---

## 🔄 Alternatif: Bypass Email Validation (Development Only)

Jika masih error, bisa buat user manual di Supabase:

### **Cara 1: Via Dashboard**
1. **Authentication** → **Users** → **Add User**
2. Isi:
   - Email: `noval@gmail.com`
   - Password: `password123`
   - Auto Confirm User: ✅ **YES**
3. Klik **Create User**
4. Login di app dengan kredensial tersebut

### **Cara 2: Via SQL**
```sql
-- Insert user manual (HATI-HATI: Hanya untuk development!)
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  confirmation_token,
  recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'noval@gmail.com',
  crypt('password123', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  '',
  ''
);
```

**CATATAN:** Cara ini **TIDAK RECOMMENDED** untuk production!

---

## 📞 Jika Masih Error

### **Cek Hal Berikut:**

1. ✅ Supabase project masih aktif?
2. ✅ API keys masih valid?
3. ✅ Internet connection stabil?
4. ✅ Supabase service tidak down? (cek https://status.supabase.com)

### **Coba Restart:**

1. Stop Flutter app (`Ctrl + C` di terminal)
2. Restart Supabase project (Dashboard → Settings → Restart)
3. Run Flutter app lagi: `flutter run -d edge`

### **Buat Project Baru (Last Resort):**

Jika semua cara di atas gagal:
1. Buat project Supabase baru
2. Copy URL dan anon key yang baru
3. Update di `lib/main.dart`
4. Jalankan SQL queries lagi

---

## 🎯 Quick Fix Checklist

- [ ] Disable email confirmations di Supabase
- [ ] Pastikan Email provider enabled
- [ ] Coba email yang berbeda (test@gmail.com)
- [ ] Cek Supabase logs untuk error detail
- [ ] Restart Flutter app (hot reload tidak cukup)
- [ ] Cek console log untuk debug messages
- [ ] Buat user manual via Dashboard jika perlu

---

## 📝 Update Code

Code sudah diupdate dengan:
- ✅ Email trimming & lowercase normalization
- ✅ Better error handling
- ✅ Debug logging
- ✅ Specific error messages

Silakan **hot restart** app Flutter Anda dan coba lagi!

---

**Jika masih ada masalah, share screenshot dari:**
1. Console log Flutter
2. Supabase Auth Logs
3. Supabase Authentication Settings page
