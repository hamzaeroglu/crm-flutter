[🇹🇷 Türkçe](#-crm-müşteri-ilişkileri-yönetimi-uygulaması) | [🇬🇧 English](#-crm-customer-relationship-management-application)

---

# 🇹🇷 CRM (Müşteri İlişkileri Yönetimi) Uygulaması

**Flutter** ve **Firebase** ile geliştirilmiş profesyonel, güvenli ve modern bir CRM uygulaması. Öne çıkan özellikler arasında gerçek zamanlı iş birliği, rol tabanlı erişim kontrolü (RBAC) ve duyarlı denetim kaydı sistemi bulunur.

![Project Banner](screenshots/dashboard_desktop.png)

## 🚀 Öne Çıkan Özellikler

### 🔐 Güvenlik ve Erişim Kontrolü
- **Rol Tabanlı Erişim Kontrolü (RBAC):**
  - **Admin:** Tam yetki (Kullanıcı yönetimi, denetim kayıtları, veri silme).
  - **Agent:** Müşteri ve potansiyel müşteri yönetimi (Okuma/Yazma).
  - **Viewer:** Sadece görüntüleme yetkisi.
- **Güvenli Kimlik Doğrulama:** E-posta doğrulama zorunluluğu olan Firebase Auth entegrasyonu.
- **Denetim Kayıtları (Audit Logs):** Kritik işlemlerin (Giriş, rol değişimi, silme) kapsamlı takibi (Sadece Adminler görebilir).

### 👥 Müşteri Yönetimi
- **Gerçek Zamanlı Güncellemeler:** Cloud Firestore ile anlık senkronizasyon.
- **Filtreleme ve Arama:** İsim, kategori veya etiketlere göre gelişmiş arama.
- **Dinamik Kategoriler:** Müşterileri Aktif, Potansiyel, VIP veya Pasif olarak görsel indikatörlerle sınıflandırma.

### 🎨 Modern Arayüz ve Kullanıcı Deneyimi
- **Duyarlı Tasarım (Responsive):** Masaüstü (Yan Menü) ve Mobil (Çekmece Menü) görünümlerine tam uyumlu yerleşim.
- **Katlanabilir Yan Menü:** Ekran alanını verimli kullanan akıllı navigasyon.
- **Premium Estetik:** *Glassmorphism* dokunuşları ve *Outfit* yazı tipi ile temiz bir arayüz.
- **İnteraktif Bileşenler:** Animasyonlu KPI kartları ve akıcı geçişler.

## 🛠️ Teknoloji Yığını

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Auth, Firestore)
- **Durum Yönetimi (State Management):** Provider
- **Tipografi:** Google Fonts (Outfit)
- **İkonlar:** Material Design Rounded

## 📸 Ekran Görüntüleri

| Dashboard (Masaüstü) | Mobil Navigasyon |
|:---:|:---:|
| ![Dashboard](screenshots/dashboard_desktop.png) | ![Mobil Menü](screenshots/mobile_menu.png) |

| Kullanıcı Yönetimi | Müşteri Detayı |
|:---:|:---:|
| ![Kullanıcı Yönetimi](screenshots/user_management.png) | ![Müşteri Detayı](screenshots/customer_detail.png) |

## 🏗️ Mimari

Proje, aşağıdaki katmanlara ayrılmış temiz bir mimari (clean architecture) izler:
- **Presentation (Sunum) Katmanı:** Widget'lar, Sayfalar ve Provider'lar.
- **Domain/Data (Veri) Katmanı:** Repository'ler ve Servisler.
- **Core (Çekirdek):** Yardımcı araçlar, Sabitler ve Temalar.

## 🚦 Kurulum

1. **Repoyu klonlayın:**
   ```bash
   git clone https://github.com/kullaniciadiniz/crm-app.git
   ```
2. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```
3. **Uygulamayı çalıştırın:**
   ```bash
   flutter run
   ```

---

<br>
<br>

# 🇬🇧 CRM (Customer Relationship Management) Application

A professional, secure, and modern CRM application built with **Flutter** and **Firebase**. Key features include real-time collaboration, role-based access control (RBAC), and a responsive audit logging system.

![Project Banner](screenshots/dashboard_desktop.png)

## 🚀 Key Features

### 🔐 Security & Access Control
- **Role-Based Access Control (RBAC):**
  - **Admin:** Full access (Manage users, view audit logs, delete records).
  - **Agent:** Manage customers and leads (Read/Write).
  - **Viewer:** Read-only access to customer data.
- **Secure Authentication:** Firebase Auth integration with email verification enforcement.
- **Audit Logging:** Comprehensive tracking of critical actions (User logins, role changes, deletions) visible only to Admins.

### 👥 Customer Management
- **Real-time Updates:** Instant synchronization with Cloud Firestore.
- **Filtering & Search:** Advanced search capabilities by name, category, or tags.
- **Dynamic Categories:** Categorize customers as Active, Potential, VIP, or Inactive with visual indicators.

### 🎨 Modern UI/UX
- **Responsive Design:** Fully responsive layout adapting to Desktop (Sidebar) and Mobile (Drawer) views.
- **Collapsible Sidebar:** Smart navigation that maximizes screen real estate.
- **Premium Aesthetics:** Clean interface using *Glassmorphism* elements and the *Outfit* typeface.
- **Interactive Widgets:** Animated KPI cards and smooth transitions.

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Auth, Firestore)
- **State Management:** Provider
- **Typography:** Google Fonts (Outfit)
- **Icons:** Material Design Rounded

## 📸 Screenshots

| Dashboard (Desktop) | Mobile Navigation |
|:---:|:---:|
| ![Dashboard](screenshots/dashboard_desktop.png) | ![Mobile Menu](screenshots/mobile_menu.png) |

| User Management | Customer Detail |
|:---:|:---:|
| ![User Management](screenshots/user_management.png) | ![Customer Detail](screenshots/customer_detail.png) |

## 🏗️ Architecture

The project follows a clean architecture pattern separating:
- **Presentation Layer:** Widgets, Pages, and Providers.
- **Domain/Data Layer:** Repositories and Services.
- **Core:** Utilities, Constants, and Themes.

## 🚦 Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/crm-app.git
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Run the app:**
   ```bash
   flutter run
   ```

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
