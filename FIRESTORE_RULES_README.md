# Firestore Security Rules Kurulumu

## Endpoint'in İşlevi

`firebase_options.dart` dosyasındaki endpoint'ler, Firebase servislerine (Auth, Firestore, vb.) bağlanmak için gerekli yapılandırma bilgilerini içerir:
- **API Key**: Firebase servislerine erişim anahtarı
- **Project ID**: Projenin benzersiz kimliği
- **Auth Domain**: Authentication için domain
- **Storage Bucket**: Dosya depolama alanı

Bu bilgiler sayesinde uygulama Firebase servislerine doğru projeye bağlanır.

## Firestore Security Rules Kurulumu

### 1. Firebase Console'a Git
- [Firebase Console](https://console.firebase.google.com/) → Projeni seç
- Sol menüden **Firestore Database** → **Rules** sekmesine git

### 2. Kuralları Yapıştır
`firestore.rules` dosyasındaki kuralları kopyalayıp Firebase Console'daki Rules editörüne yapıştır.

### 3. Yayınla
**Publish** butonuna tıkla.

## Kuralların Açıklaması

### Users Koleksiyonu
- **Okuma**: Kullanıcılar sadece kendi verilerini okuyabilir, Admin herkesi görebilir
- **Oluşturma**: Kullanıcılar sadece kendi verilerini oluşturabilir
- **Güncelleme**: Kullanıcılar kendi verilerini güncelleyebilir, Admin herkesi güncelleyebilir
- **Silme**: Sadece Admin yapabilir

### Customers Koleksiyonu
- **Okuma**: Tüm authenticated kullanıcılar (viewer dahil) okuyabilir
- **Oluşturma**: Admin ve Agent yapabilir
- **Güncelleme**: Admin ve Agent yapabilir
- **Silme**: Sadece Admin yapabilir

## Test Etme

Kuralları yayınladıktan sonra:
1. Uygulamayı çalıştır
2. Farklı rollerle (admin, agent, viewer) giriş yap
3. Her rolün yetkilerini test et

## Önemli Notlar

⚠️ **Geliştirme aşamasında** test için kuralları geçici olarak gevşetebilirsin:
```
allow read, write: if request.auth != null;
```

⚠️ **Production'da** mutlaka yukarıdaki kuralları kullan!

