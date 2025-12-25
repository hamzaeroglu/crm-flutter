# Firestore Security Rules Test Rehberi

## Yöntem 1: Firebase Console Rules Simulator (Önerilen)

### Adımlar:

1. **Firebase Console'a Git**
   - [Firebase Console](https://console.firebase.google.com/) → Projeni seç
   - **Firestore Database** → **Rules** sekmesi

2. **Rules Simulator'ü Aç**
   - Rules editörünün sağ üstünde **"Rules playground"** veya **"Simulator"** butonuna tıkla

3. **Test Senaryoları**

#### Test 1: Viewer Rolü - Okuma İzni
```
Type: get
Location: /customers/{customerId}
Authentication: Authenticated
User ID: test-viewer-user-id
Custom Claims: {role: "viewer"}
```
**Beklenen Sonuç:** ✅ Allow (Viewer okuyabilir)

#### Test 2: Viewer Rolü - Yazma İzni (Reddedilmeli)
```
Type: create
Location: /customers/{customerId}
Authentication: Authenticated
User ID: test-viewer-user-id
Custom Claims: {role: "viewer"}
Data: {name: "Test", email: "test@test.com"}
```
**Beklenen Sonuç:** ❌ Deny (Viewer yazamaz)

#### Test 3: Agent Rolü - Oluşturma İzni
```
Type: create
Location: /customers/{customerId}
Authentication: Authenticated
User ID: test-agent-user-id
Custom Claims: {role: "agent"}
Data: {name: "Test", email: "test@test.com"}
```
**Beklenen Sonuç:** ✅ Allow (Agent oluşturabilir)

#### Test 4: Agent Rolü - Silme İzni (Reddedilmeli)
```
Type: delete
Location: /customers/{customerId}
Authentication: Authenticated
User ID: test-agent-user-id
Custom Claims: {role: "agent"}
```
**Beklenen Sonuç:** ❌ Deny (Agent silemez, sadece Admin)

#### Test 5: Admin Rolü - Silme İzni
```
Type: delete
Location: /customers/{customerId}
Authentication: Authenticated
User ID: test-admin-user-id
Custom Claims: {role: "admin"}
```
**Beklenen Sonuç:** ✅ Allow (Admin silebilir)

#### Test 6: Unauthenticated - Erişim (Reddedilmeli)
```
Type: get
Location: /customers/{customerId}
Authentication: Unauthenticated
```
**Beklenen Sonuç:** ❌ Deny (Giriş yapmamış kullanıcı erişemez)

## Yöntem 2: Uygulamada Pratik Test

### Test Senaryoları:

1. **Viewer Rolü ile Test**
   - Viewer hesabıyla giriş yap
   - ✅ Müşteri listesini görebilmeli
   - ✅ Müşteri detayını görebilmeli
   - ❌ "Yeni Müşteri" butonu görünmemeli
   - ❌ Düzenle/Sil butonları görünmemeli
   - ❌ Not/Etiket ekleme butonları görünmemeli

2. **Agent Rolü ile Test**
   - Agent hesabıyla giriş yap
   - ✅ Müşteri listesini görebilmeli
   - ✅ "Yeni Müşteri" butonu görünmeli
   - ✅ Düzenle butonu görünmeli
   - ✅ Not/Etiket ekleme butonları görünmeli
   - ❌ Sil butonu görünmemeli

3. **Admin Rolü ile Test**
   - Admin hesabıyla giriş yap
   - ✅ Tüm butonlar görünmeli
   - ✅ Sil butonu görünmeli
   - ✅ Tüm işlemleri yapabilmeli

## Yöntem 3: Test Kullanıcıları Oluşturma

### Firebase Console'da:

1. **Authentication** → **Users** → **Add user**
2. Test kullanıcıları oluştur:
   - `viewer@test.com` (password: test123)
   - `agent@test.com` (password: test123)
   - `admin@test.com` (password: test123)

3. **Firestore** → **users** koleksiyonunda her kullanıcı için doküman oluştur:
   ```json
   {
     "email": "viewer@test.com",
     "role": "viewer",
     "createdAt": "2024-01-01T00:00:00Z"
   }
   ```
   ```json
   {
     "email": "agent@test.com",
     "role": "agent",
     "createdAt": "2024-01-01T00:00:00Z"
   }
   ```
   ```json
   {
     "email": "admin@test.com",
     "role": "admin",
     "createdAt": "2024-01-01T00:00:00Z"
   }
   ```

## Yöntem 4: Console'da Manuel Test

Firebase Console → Firestore Database → Data sekmesinden:
- Farklı rollerle giriş yapıp veri ekleme/silme işlemlerini dene
- Hata mesajlarını kontrol et

## Hata Ayıklama İpuçları

1. **Rules Simulator'de hata alırsan:**
   - `getUserRole()` fonksiyonu çalışmıyor olabilir
   - Kullanıcı dokümanı (`users/{userId}`) Firestore'da var mı kontrol et
   - Rol değeri tam olarak `"admin"`, `"agent"`, `"viewer"` olmalı (büyük/küçük harf duyarlı)

2. **Uygulamada hata alırsan:**
   - Console'da hata mesajını kontrol et
   - `AuthProvider`'da rol yükleme işlemini kontrol et
   - Firestore'da `users` koleksiyonunda kullanıcı dokümanı var mı bak

3. **Yaygın Hatalar:**
   - `Permission denied`: Kural izin vermiyor
   - `Missing or insufficient permissions`: Kullanıcı dokümanı yok veya rol yanlış
   - `Document not found`: `users/{userId}` dokümanı eksik

## Test Checklist

- [ ] Viewer okuyabilir ama yazamaz
- [ ] Agent okuyup yazabilir ama silemez
- [ ] Admin tüm işlemleri yapabilir
- [ ] Unauthenticated kullanıcı hiçbir şey yapamaz
- [ ] Kullanıcılar sadece kendi `users` dokümanlarını görebilir
- [ ] Admin tüm `users` dokümanlarını görebilir

