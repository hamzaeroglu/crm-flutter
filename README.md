[🇹🇷 Türkçe](#proje-özeti) | [🇬🇧 English](#project-overview)

---

# CRM (Müşteri İlişkileri Yönetimi)

## Proje Özeti
Bu proje, küçük ve orta ölçekli ekiplerin müşteri ilişkilerini, kullanıcı yetkilerini ve denetim süreçlerini yönetebilmesi için geliştirilmiş, gerçek zamanlı bir mobil/web uygulamasıdır. Projenin temel amacı, ölçeklenebilir bir veri mimarisi ve güvenli bir yetki yönetim sistemi (RBAC) üzerine kurulu, performanslı bir arayüz sunmaktır.

## Teknik Öne Çıkanlar

### 1. Rol Tabanlı Erişim Kontrolü (RBAC) ve Güvenlik
Uygulama güvenliği sadece ön yüzde değil, veritabanı seviyesinde sağlanmıştır.
- **Firestore Security Rules:** `request.auth` ve `get()` fonksiyonları kullanılarak yazılan kurallar ile, kullanıcıların (Viewer, Agent, Admin) sadece kendi yetki seviyelerindeki verilere erişmesi garanti altına alınmıştır.
- **Backend-Enforced Security:** Admin yetkisi gerektiren işlemler (Örn: Veri silme) sunucu tarafında doğrulanır.

### 2. Gerçek Zamanlı Veri Senkronizasyonu
- **Stream Mimarisi:** Kullanıcı listeleri ve müşteri verileri `Stream<QuerySnapshot>` yapısı ile yönetilmektedir. Bu sayede, çoklu kullanıcı ortamında yapılan değişiklikler (Örn: Bir kullanıcının rolünün değişmesi veya silinmesi) anlık olarak tüm bağlı istemcilere yansıtılır ve "hayalet kayıt" (ghost record) sorunlarının önüne geçilir.

### 3. Duyarlı (Responsive) Arayüz Mimarisi
- **Adaptif Layout:** Tek bir kod tabanı üzerinden hem masaüstü hem de mobil deneyim sunulmuştur.
- **LayoutBuilder Entegrasyonu:** `Sidebar` bileşeni, ekran genişliğindeki değişimlere (resize) anlık tepki vererek animasyonlu ve "snap" efektli bir geçiş (collapse/expand) sağlar; bu sayede `RenderFlex` taşma hataları engellenmiştir.

### 4. Temiz Mimari ve State Management
- **Provider Pattern:** Uygulama durumu; Auth, Data ve UI state'leri olmak üzere modüler `ChangeNotifier` sınıflarına ayrılmıştır. İş mantığı (Business Logic) arayüzden soyutlanmıştır.

## Kullanılan Teknolojiler
- **Framework:** Flutter (Dart)
- **Backend-as-a-Service:** Firebase (Authentication, Cloud Firestore)
- **State Management:** Provider
- **UI:** Material Design, Google Fonts

## Bu Proje Neyi Gösteriyor?
- **Full-Stack Entegrasyon:** Ön yüz ile bulut tabanlı bir arka ucun (Auth + DB) güvenli ve verimli entegrasyonu.
- **Güvenlik Bilinci:** Yetkilendirmenin sadece UI'da değil, veritabanı kuralları seviyesinde kurgulanması.
- **Kompleks State Yönetimi:** Asenkron veri akışlarının (Stream) ve global uygulama durumunun efektif yönetimi.
- **Duyarlı Tasarım Yetkinliği:** Farklı ekran çözünürlüklerine uyum sağlayan esnek widget mimarisi kurma becerisi.

---

<br>
<br>

# Project Overview

This project is a real-time CRM application designed for teams to manage customer relationships, user roles, and audit processes efficiently. The core objective was to build a performant interface on top of a scalable data architecture and a secure Role-Based Access Control (RBAC) system.

## Technical Highlights

### 1. Role-Based Access Control (RBAC) & Security
Security is implemented significantly at the database level, ensuring data integrity beyond UI restrictions.
- **Firestore Security Rules:** Custom security rules utilizing `request.auth` and `get()` functions ensure users (Viewer, Agent, Admin) can only access data permitted by their specific roles.
- **Backend-Enforced Security:** Critical actions (e.g., deletion) are validated server-side to prevent unauthorized access.

### 2. Real-Time Data Synchronization
- **Stream Architecture:** User and customer data management utilizes `Stream<QuerySnapshot>`. This ensures changes in a multi-user environment (e.g., role updates or user deletions) are instantly propagated to all clients, effectively preventing stale data or "ghost record" issues.

### 3. Responsive UI Architecture
- **Adaptive Layout:** A single codebase delivers a seamless experience across both desktop and mobile form factors.
- **LayoutBuilder Integration:** The custom `Sidebar` component dynamically adapts to viewport constraint changes using `LayoutBuilder`, proving a robust implementation that handles animation states and prevents layout overflows (RenderFlex errors).

### 4. Clean Architecture & State Management
- **Provider Pattern:** Application state is decoupled into modular `ChangeNotifier` providers (Auth, Data, UI). Business logic is strictly separated from the presentation layer.

## Tech Stack
- **Framework:** Flutter (Dart)
- **Backend-as-a-Service:** Firebase (Authentication, Cloud Firestore)
- **State Management:** Provider
- **UI:** Material Design, Google Fonts

## Key Competencies Demonstrated
- **Full-Stack Integration:** Secure and efficient integration of a mobile frontend with cloud-native backend services.
- **Security First Mindset:** Implementing authorization strictly at the database rule level rather than relying solely on client-side logic.
- **Complex State Management:** Handling asynchronous data streams and global application state effectively.
- **Responsive Design Proficiency:** Designing flexible widget hierarchies that adapt gracefully to varying screen constraints.
