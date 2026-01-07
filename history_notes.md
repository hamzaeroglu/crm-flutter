# Nedede kaldık
_Exported on 1/1/2026 at 17:39:13 GMT+3 from Cursor (2.2.44)_

---

**User**

nedede kaldık

---

**Cursor**

Şu anda lib/presentation/pages/customer_page.dart dosyasını inceliyoruz ve 78. satırdasınız. Kodun tamamı, müşteri listesini gösteren ve ekleme/düzenleme/silme işlemlerini sağlayan bir Flutter sayfası (CustomerPage) içeriyor.

En son, müşteri listesinin ListView.builder ile ekrana basıldığı ve her müşteri için CustomerListTile widget'ının kullanıldığı bölümdeyiz. 78. satır, CustomerListTile widget'ının kapandığı satır:

```dart
                              );
```

Yani, müşteri kartlarının listelendiği ve her birinin düzenlenip silinebildiği kısmın tam ortasındayız. Buradan devam etmek veya başka bir dosya/özellik üzerinde çalışmak isterseniz, ne yapmak istediğinizi belirtmeniz yeterli!

```dart
                              );
```

---

**User**

şimdiye kadar neler yaptık, projemiz neydi genel bir taslak sun

---

**Cursor**

Şu ana kadarki durum ve proje taslağı:

- Proje: Flutter tabanlı basit bir CRM uygulaması. Katmanlı yapı: `core` (constants/utils/services), `data` (models/datasources/repositories), `domain` (entities/usecases), `presentation` (pages/widgets), giriş `main.dart`.
- Uygulama akışı: `CustomerPage` ana dashboard; toplam müşteri sayısı kartı, yeni müşteri ekleme kartı, kategori/favori/etiket filtreleri, arama çubuğu, filtrelenmiş müşteri listesi.
- Listede her müşteri için `CustomerListTile` kullanılıyor; detay sayfasına gitme, favori toggle, düzenleme (AddCustomerPage ile varolan müşteri dolduruluyor), silme (onay diyaloğu + snackbar) işlemleri hazır.
- Tema: AppBar üzerinden ThemeMode (system/light/dark) seçilebiliyor; `ThemeProvider` ile yönetiliyor.
- Son odaklandığımız dosya: `lib/presentation/pages/customer_detail_page.dart` (cursor 188). Öncesinde `customer_page.dart` üzerinde müşteri listeleme/filtreleme/aksiyonlar tamamlanmıştı.

Genel taslak (hedeflenen özellikler):
- Müşteri yönetimi: listeleme, arama, kategori/etiket filtreleri, favoriler, ekle/düzenle/sil.
- Müşteri detay: detay bilgileri, muhtemelen notlar/etkinlikler (dosyada ilerliyoruz).
- Tema desteği: açık/koyu/sistem.
- Katmanlı mimari: entity/usecase -> repository -> provider + UI.

Devam için öneri:
- `customer_detail_page.dart` içinde eksik kalan detay/aksiyonları kontrol edip tamamlamak.
- Test etmek: filtreler, arama, favori toggle, silme akışı.
- Gerekirse dummy veri/datasource entegrasyonu ve hata durumları için snackbar/toast akışları.

---

**User**

güzel, program şu an çalışmıyor ve alınan hata bu: Launching lib\main.dart on ASUS I003DD in debug mode...
Running Gradle task 'assembleDebug'...
lib/presentation/providers/customer_provider.dart:89:8: Error: A value of type 'List<CustomerModel>' can't be returned from a function with return type 'List<Customer>'.
 - 'List' is from 'dart:core'.
 - 'CustomerModel' is from 'package:crm/data/models/customer_model.dart' ('lib/data/models/customer_model.dart').
 - 'Customer' is from 'package:crm/presentation/domain/entities/customer.dart' ('lib/presentation/domain/entities/customer.dart').
    }).toList();
       ^
Target kernel_snapshot_program failed: Exception


FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:compileFlutterBuildDebug'.
> Process 'command 'C:\flutter\bin\flutter.bat'' finished with non-zero exit value 1

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 3s
Error: Gradle task assembleDebug failed with exit code 1


---

**Cursor**

```dart
import 'package:flutter/material.dart';
import '../../data/models/customer_model.dart';
import '../../data/repo/customer_repository.dart';
import '../../presentation/domain/entities/customer.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerRepository repository;

  List<CustomerModel> _customers = [];
  List<CustomerModel> get customers => _customers;

  List<Customer> get customerEntities => _customers.map(_mapToEntity).toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  CustomerCategory? _selectedCategory;
  CustomerCategory? get selectedCategory => _selectedCategory;
  set selectedCategory(CustomerCategory? value) {
    _selectedCategory = value;
    notifyListeners();
  }

  bool _showOnlyFavorites = false;
  bool get showOnlyFavorites => _showOnlyFavorites;
  set showOnlyFavorites(bool value) {
    _showOnlyFavorites = value;
    notifyListeners();
  }

  String _selectedTag = '';
  String get selectedTag => _selectedTag;
  set selectedTag(String value) {
    _selectedTag = value;
    notifyListeners();
  }

  List<String> get allTags {
    final allTags = <String>{};
    for (final customer in _customers) {
      if (customer.tags != null) {
        allTags.addAll(customer.tags);
      }
    }
    return allTags.toList()..sort();
  }

  List<Customer> get filteredCustomers {
    final filtered = _customers.where((customer) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = customer.name.toLowerCase().contains(query);
        final matchesEmail = customer.email.toLowerCase().contains(query);
        final matchesPhone = customer.phone.toLowerCase().contains(query);
        final matchesNotes = customer.notes != null && 
            customer.notes.any((note) => note.toLowerCase().contains(query));
        final matchesTags = customer.tags != null && 
            customer.tags.any((tag) => tag.toLowerCase().contains(query));
        
        if (!matchesName && !matchesEmail && !matchesPhone && !matchesNotes && !matchesTags) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != null && customer.category != _selectedCategory) {
        return false;
      }

      // Favorite filter
      if (_showOnlyFavorites && !customer.isFavorite) {
        return false;
      }

      // Tag filter
      if (_selectedTag.isNotEmpty && (customer.tags == null || !customer.tags.contains(_selectedTag))) {
        return false;
      }

      return true;
    }).toList();

    return filtered.map(_mapToEntity).toList();
  }

  CustomerProvider(this.repository);

  Customer _mapToEntity(CustomerModel model) {
    return Customer(
      id: model.id,
      name: model.name,
      email: model.email,
      phone: model.phone,
      category: model.category,
      isFavorite: model.isFavorite,
      notes: model.notes,
      tags: model.tags,
    );
  }

  Future<void> fetchCustomers() async {
    _isLoading = true;
    notifyListeners();
    _customers = await repository.getCustomers();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCustomer(CustomerModel customer) async {
    try {
      await repository.addCustomer(customer);
      await fetchCustomers();
    } catch (e) {
      throw Exception('Müşteri eklenemedi: $e');
    }
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await repository.updateCustomer(customer);
      await fetchCustomers();
    } catch (e) {
      throw Exception('Müşteri güncellenemedi: $e');
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await repository.deleteCustomer(id);
      await fetchCustomers();
    } catch (e) {
      throw Exception('Müşteri silinemedi: $e');
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == id);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedCustomer = customer.copyWith(isFavorite: !customer.isFavorite);
        await repository.updateCustomer(updatedCustomer);
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Favori durumu güncellenemedi: $e');
    }
  }

  Future<void> updateCustomerCategory(String id, CustomerCategory category) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == id);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedCustomer = customer.copyWith(category: category);
        await repository.updateCustomer(updatedCustomer);
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Kategori güncellenemedi: $e');
    }
  }

  Future<void> addNote(String customerId, String note) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == customerId);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedNotes = [...customer.notes, note];
        final updatedCustomer = customer.copyWith(notes: updatedNotes);
        await repository.updateCustomer(updatedCustomer);
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Not eklenemedi: $e');
    }
  }

  Future<void> removeNote(String customerId, int noteIndex) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == customerId);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedNotes = List<String>.from(customer.notes);
        updatedNotes.removeAt(noteIndex);
        final updatedCustomer = customer.copyWith(notes: updatedNotes);
        await repository.updateCustomer(updatedCustomer);
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Not silinemedi: $e');
    }
  }

  Future<void> addTag(String customerId, String tag) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == customerId);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        if (!customer.tags.contains(tag)) {
          final updatedTags = [...customer.tags, tag];
          final updatedCustomer = customer.copyWith(tags: updatedTags);
          await repository.updateCustomer(updatedCustomer);
          await fetchCustomers();
        }
      }
    } catch (e) {
      throw Exception('Etiket eklenemedi: $e');
    }
  }

  Future<void> removeTag(String customerId, String tag) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == customerId);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedTags = List<String>.from(customer.tags);
        updatedTags.remove(tag);
        final updatedCustomer = customer.copyWith(tags: updatedTags);
        await repository.updateCustomer(updatedCustomer);
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Etiket silinemedi: $e');
    }
  }
} 
```

`customer_provider.dart` içinde `filteredCustomers` artık `CustomerModel` yerine `Customer` döndürüyor. Filtrelenmiş modelleri önce toplayıp `_mapToEntity` ile entity’ye çeviren bir yardımcı eklendi; `customerEntities` de aynı yöntemi kullanıyor. Bu, build sırasında oluşan `List<CustomerModel> -> List<Customer>` dönüşüm hatasını giderir.

Çalıştırmak için: `flutter run` veya IDE’den yeniden derleyip deneyebilirsin.

---

**User**

sırada ne var?

---

**Cursor**

Önerilen sıradaki adımlar:
- Uygulamayı derleyip çalıştır: `flutter run` (hata temizlendi mi kontrol et).
- `customer_detail_page.dart` akışını gözden geçir: not/etiket ekleme-silme butonları, kategori/favori güncelleme çağrıları provider’la uyumlu mı?
- Veri katmanını kontrol et: `CustomerRepository` get/add/update/delete metotları `CustomerModel` ile tam uyumlu ve async hataları düzgün ele alıyor mu?
- Filtre/arama/favori akışını cihazda deneyip UI/UX geri bildirimlerini topla.

Hazırsan önce derlemeyi deneyelim; sorun kalmadıysa detay sayfasındaki eksikleri tamamlayabiliriz.

---

**User**

güncel planımı anlatayım, ona göre devam edelim. Öncelikle programın teknik işlevsel kısımlarını tamamlamak ve hepsini eksiksiz çalışır hale getirmek istiyorum (Tüm özelliklerin ihtiyaçları karşılaması, yeni özellik tavsiyen varsa onları da eklemek). Daha sonra program için yetkilendirmeler yapmak istiyorum veri güvenliğini ve veri kullanım hiyerarşisini sağlamak için. Veri güvenliğini iyileştirecek uygulamalar yapmak istiyorum. En son da bir tasarım giydirmek istiyorum.

---

**Cursor**

Planı adım adım kuralım; önce teknik işlevsellik, sonra güvenlik/yetkilendirme, en son tasarım. Önerim:

**0) Mevcut durumu hızlı doğrula**
- `flutter run` ile derleme/çalıştır, crash veya eksik akış var mı bak.
- Temel veri akışlarını elle test: listeleme, arama, filtre (kategori/etiket/favori), ekle/güncelle/sil, favori toggle, detayda not/etiket ekle-sil.

**1) Çekirdek işlevler (eksiksiz çalışma)**
- `CustomerRepository` ve datasources: get/add/update/delete tümü `CustomerModel` ile tutarlı mı, hata durumlarını doğru fırlatıyor mu? Gerekirse mock/local JSON/SQLite/backend entegrasyonunu netleştir.
- `customer_detail_page.dart`: kategori değiştirme, favori toggle, not/etiket ekle-sil butonları provider çağrılarına bağlı mı? UI boş durumları (notes/tags) düzgün mü?
- Validasyon: müşteri ekle/güncelle formu (isim/email/telefon) doğrulamaları, boş veya hatalı giriş için uyarı/snackbar.
- Hata yönetimi: repository hatalarında kullanıcıya anlamlı mesaj/snackbar; loading göstergeleri (isLoading) doğru tetikleniyor mu?

**2) Ekleyebileceğimiz faydalı özellikler (işlevsellik)**
- Toplu filtre reset butonu.
- Sıralama seçenekleri (isim A-Z, oluşturulma tarihi varsa).
- Basit pagination veya lazy load (gerekiyorsa).
- Arama geçmişi veya son kullanılan etiketler (isteğe bağlı).

**3) Yetkilendirme ve veri güvenliği**
- Auth seçimi: basit JWT/OAuth2 ya da Firebase Auth; rol tabanlı yetki (admin/agent/read-only).
- Müşteri verisi erişim kuralları: yalnızca yetkili roller silme/düzenleme yapabilsin; okuma/yazma ayrımı.
- Güvenli depolama: token için secure storage; hassas configleri .env/.json (git-ignore) içinde.
- Ağ güvenliği: HTTPS zorunlu, hata mesajlarında hassas veri sızdırmama; retry/backoff için interceptors (e.g. Dio).
- Denetim izi (audit log): basitçe lokal log veya backend’e event gönderimi (isteğe bağlı).
- Rate limiting / brute-force önlemleri (backend tarafı varsa).

**4) Tasarım/giydirme**
- Tema sistemi: mevcut light/dark + renk paleti iyileştirme, tipografi ve spacing tutarlılığı.
- Bileşen kütüphanesi: Card/ListTile/Chip’leri tutarlı border radius/padding ile yeniden kullanmak.
- Boş/yükleniyor durumları için ilüstrasyon veya ikon.
- Responsiveness: web/tablet/telefon için maxWidth ve grid düzenleri.

**Önerilen sıradaki adım**
- Önce “1) Çekirdek işlevler”i bitirelim. Bunun için `customer_detail_page.dart` ve `CustomerRepository`yi kontrol edip eksik çağrıları bağlayalım; ardından derleme/test. Onay verirsen hemen `customer_detail_page.dart` ve repository/datasource’ları inceleyip eksikleri tamamlayayım.

---

**User**

onay veriyorum bu güzel planlamayı hayata adım adım geçirelim

---

**Cursor**

```dart
import 'package:flutter/material.dart';
import '../../data/models/customer_model.dart';
import '../../data/repo/customer_repository.dart';
import '../../presentation/domain/entities/customer.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerRepository repository;

  List<CustomerModel> _customers = [];
  List<CustomerModel> get customers => _customers;

  List<Customer> get customerEntities => _customers.map(_mapToEntity).toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  CustomerCategory? _selectedCategory;
  CustomerCategory? get selectedCategory => _selectedCategory;
  set selectedCategory(CustomerCategory? value) {
    _selectedCategory = value;
    notifyListeners();
  }

  bool _showOnlyFavorites = false;
  bool get showOnlyFavorites => _showOnlyFavorites;
  set showOnlyFavorites(bool value) {
    _showOnlyFavorites = value;
    notifyListeners();
  }

  String _selectedTag = '';
  String get selectedTag => _selectedTag;
  set selectedTag(String value) {
    _selectedTag = value;
    notifyListeners();
  }

  List<String> get allTags {
    final allTags = <String>{};
    for (final customer in _customers) {
      if (customer.tags != null) {
        allTags.addAll(customer.tags);
      }
    }
    return allTags.toList()..sort();
  }

  List<Customer> get filteredCustomers {
    final filtered = _customers.where((customer) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = customer.name.toLowerCase().contains(query);
        final matchesEmail = customer.email.toLowerCase().contains(query);
        final matchesPhone = customer.phone.toLowerCase().contains(query);
        final matchesNotes = customer.notes != null && 
            customer.notes.any((note) => note.toLowerCase().contains(query));
        final matchesTags = customer.tags != null && 
            customer.tags.any((tag) => tag.toLowerCase().contains(query));
        
        if (!matchesName && !matchesEmail && !matchesPhone && !matchesNotes && !matchesTags) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != null && customer.category != _selectedCategory) {
        return false;
      }

      // Favorite filter
      if (_showOnlyFavorites && !customer.isFavorite) {
        return false;
      }

      // Tag filter
      if (_selectedTag.isNotEmpty && (customer.tags == null || !customer.tags.contains(_selectedTag))) {
        return false;
      }

      return true;
    }).toList();

    return filtered.map(_mapToEntity).toList();
  }

  CustomerProvider(this.repository);

  Customer? findById(String id) {
    final model = _customers.where((c) => c.id == id).cast<CustomerModel?>().firstWhere(
          (c) => c != null,
          orElse: () => null,
        );
    if (model == null) return null;
    return _mapToEntity(model);
  }

  Customer _mapToEntity(CustomerModel model) {
    return Customer(
      id: model.id,
      name: model.name,
      email: model.email,
      phone: model.phone,
      category: model.category,
      isFavorite: model.isFavorite,
      notes: model.notes,
      tags: model.tags,
    );
  }

  Future<void> fetchCustomers() async {
    _isLoading = true;
    notifyListeners();
    _customers = await repository.getCustomers();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCustomer(CustomerModel customer) async {
    try {
      await repository.addCustomer(customer);
      await fetchCustomers();
    } catch (e) {
      throw Exception('Müşteri eklenemedi: $e');
    }
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await repository.updateCustomer(customer);
      await fetchCustomers();
    } catch (e) {
      throw Exception('Müşteri güncellenemedi: $e');
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await repository.deleteCustomer(id);
      await fetchCustomers();
    } catch (e) {
      throw Exception('Müşteri silinemedi: $e');
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == id);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedCustomer = customer.copyWith(isFavorite: !customer.isFavorite);
        await repository.updateCustomer(updatedCustomer);
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Favori durumu güncellenemedi: $e');
    }
  }

  Future<void> updateCustomerCategory(String id, CustomerCategory category) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == id);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedCustomer = customer.copyWith(category: category);
        await repository.updateCustomer(updatedCustomer);
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Kategori güncellenemedi: $e');
    }
  }

  Future<void> addNote(String customerId, String note) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == customerId);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedNotes = [...customer.notes, note];
        final updatedCustomer = customer.copyWith(notes: updatedNotes);
        await repository.updateCustomer(updatedCustomer);
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Not eklenemedi: $e');
    }
  }

  Future<void> removeNote(String customerId, int noteIndex) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == customerId);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedNotes = List<String>.from(customer.notes);
        updatedNotes.removeAt(noteIndex);
        final updatedCustomer = customer.copyWith(notes: updatedNotes);
        await repository.updateCustomer(updatedCustomer);
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Not silinemedi: $e');
    }
  }

  Future<void> addTag(String customerId, String tag) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == customerId);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        if (!customer.tags.contains(tag)) {
          final updatedTags = [...customer.tags, tag];
          final updatedCustomer = customer.copyWith(tags: updatedTags);
          await repository.updateCustomer(updatedCustomer);
          await fetchCustomers();
        }
      }
    } catch (e) {
      throw Exception('Etiket eklenemedi: $e');
    }
  }

  Future<void> removeTag(String customerId, String tag) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == customerId);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedTags = List<String>.from(customer.tags);
        updatedTags.remove(tag);
        final updatedCustomer = customer.copyWith(tags: updatedTags);
        await repository.updateCustomer(updatedCustomer);
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Etiket silinemedi: $e');
    }
  }
} 
```

```dart
import 'package:flutter/material.dart';
import '../../data/models/customer_model.dart';
import '../../data/repo/customer_repository.dart';
import '../../presentation/domain/entities/customer.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerRepository repository;

  List<CustomerModel> _customers = [];
  List<CustomerModel> get customers => _customers;

  List<Customer> get customerEntities => _customers.map(_mapToEntity).toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  CustomerCategory? _selectedCategory;
  CustomerCategory? get selectedCategory => _selectedCategory;
  set selectedCategory(CustomerCategory? value) {
    _selectedCategory = value;
    notifyListeners();
  }

  bool _showOnlyFavorites = false;
  bool get showOnlyFavorites => _showOnlyFavorites;
  set showOnlyFavorites(bool value) {
    _showOnlyFavorites = value;
    notifyListeners();
  }

  String _selectedTag = '';
  String get selectedTag => _selectedTag;
  set selectedTag(String value) {
    _selectedTag = value;
    notifyListeners();
  }

  List<String> get allTags {
    final allTags = <String>{};
    for (final customer in _customers) {
      if (customer.tags != null) {
        allTags.addAll(customer.tags);
      }
    }
    return allTags.toList()..sort();
  }

  List<Customer> get filteredCustomers {
    final filtered = _customers.where((customer) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = customer.name.toLowerCase().contains(query);
        final matchesEmail = customer.email.toLowerCase().contains(query);
        final matchesPhone = customer.phone.toLowerCase().contains(query);
        final matchesNotes = customer.notes != null && 
            customer.notes.any((note) => note.toLowerCase().contains(query));
        final matchesTags = customer.tags != null && 
            customer.tags.any((tag) => tag.toLowerCase().contains(query));
        
        if (!matchesName && !matchesEmail && !matchesPhone && !matchesNotes && !matchesTags) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != null && customer.category != _selectedCategory) {
        return false;
      }

      // Favorite filter
      if (_showOnlyFavorites && !customer.isFavorite) {
        return false;
      }

      // Tag filter
      if (_selectedTag.isNotEmpty && (customer.tags == null || !customer.tags.contains(_selectedTag))) {
        return false;
      }

      return true;
    }).toList();

    return filtered.map(_mapToEntity).toList();
  }

  CustomerProvider(this.repository);

  Customer? findById(String id) {
    final model = _customers.where((c) => c.id == id);
    if (model.isEmpty) return null;
    return _mapToEntity(model.first);
  }

  Customer _mapToEntity(CustomerModel model) {
    return Customer(
      id: model.id,
      name: model.name,
      email: model.email,
      phone: model.phone,
      category: model.category,
      isFavorite: model.isFavorite,
      notes: model.notes,
      tags: model.tags,
    );
  }

  Future<void> fetchCustomers() async {
    _isLoading = true;
    notifyListeners();
    _customers = await repository.getCustomers();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCustomer(CustomerModel customer) async {
    try {
      await repository.addCustomer(customer);
      await fetchCustomers();
    } catch (e) {
      throw Exception('Müşteri eklenemedi: $e');
    }
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await repository.updateCustomer(customer);
      await fetchCustomers();
    } catch (e) {
      throw Exception('Müşteri güncellenemedi: $e');
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await repository.deleteCustomer(id);
      await fetchCustomers();
    } catch (e) {
      throw Exception('Müşteri silinemedi: $e');
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == id);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedCustomer = customer.copyWith(isFavorite: !customer.isFavorite);
        await repository.updateCustomer(updatedCustomer);
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Favori durumu güncellenemedi: $e');
    }
  }

  Future<void> updateCustomerCategory(String id, CustomerCategory category) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == id);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedCustomer = customer.copyWith(category: category);
        await repository.updateCustomer(updatedCustomer);
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Kategori güncellenemedi: $e');
    }
  }

  Future<void> addNote(String customerId, String note) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == customerId);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedNotes = [...customer.notes, note];
        final updatedCustomer = customer.copyWith(notes: updatedNotes);
        await repository.updateCustomer(updatedCustomer);
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Not eklenemedi: $e');
    }
  }

  Future<void> removeNote(String customerId, int noteIndex) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == customerId);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedNotes = List<String>.from(customer.notes);
        updatedNotes.removeAt(noteIndex);
        final updatedCustomer = customer.copyWith(notes: updatedNotes);
        await repository.updateCustomer(updatedCustomer);
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Not silinemedi: $e');
    }
  }

  Future<void> addTag(String customerId, String tag) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == customerId);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        if (!customer.tags.contains(tag)) {
          final updatedTags = [...customer.tags, tag];
          final updatedCustomer = customer.copyWith(tags: updatedTags);
          await repository.updateCustomer(updatedCustomer);
          await fetchCustomers();
        }
      }
    } catch (e) {
      throw Exception('Etiket eklenemedi: $e');
    }
  }

  Future<void> removeTag(String customerId, String tag) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == customerId);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedTags = List<String>.from(customer.tags);
        updatedTags.remove(tag);
        final updatedCustomer = customer.copyWith(tags: updatedTags);
        await repository.updateCustomer(updatedCustomer);
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Etiket silinemedi: $e');
    }
  }
} 
```

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../domain/entities/customer.dart';
import '../providers/customer_provider.dart';

class CustomerDetailPage extends StatefulWidget {
  final Customer customer;
  const CustomerDetailPage({Key? key, required this.customer}) : super(key: key);

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  final _noteController = TextEditingController();
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi ver
      if (url.startsWith('mailto:')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-posta uygulaması bulunamadı')),
        );
      } else if (url.startsWith('tel:')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Telefon uygulaması bulunamadı')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        final customer = provider.findById(widget.customer.id) ?? widget.customer;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Müşteri Detayı'),
            actions: [
              IconButton(
                tooltip: customer.isFavorite ? 'Favoriden çıkar' : 'Favoriye ekle',
                icon: Icon(customer.isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () => provider.toggleFavorite(customer.id),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // Müşteri Bilgileri
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => _launchUrl('mailto:${customer.email}', context),
                              child: Row(
                                children: [
                                  const Icon(Icons.email, size: 20),
                                  const SizedBox(width: 8),
                                  Text(customer.email, style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () => _launchUrl('tel:${customer.phone}', context),
                              child: Row(
                                children: [
                                  const Icon(Icons.phone, size: 20),
                                  const SizedBox(width: 8),
                                  Text(customer.phone, style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(
                                    _getCategoryName(customer.category),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: _getCategoryColor(customer.category),
                                ),
                                DropdownButton<CustomerCategory>(
                                  value: customer.category,
                                  onChanged: (value) {
                                    if (value != null) {
                                      provider.updateCustomerCategory(customer.id, value);
                                    }
                                  },
                                  items: CustomerCategory.values
                                      .map(
                                        (cat) => DropdownMenuItem(
                                          value: cat,
                                          child: Text(_getCategoryName(cat)),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Etiketler
                    if (customer.tags.isNotEmpty) ...[
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Etiketler',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: customer.tags.map((tag) {
                                  return Chip(
                                    label: Text(tag),
                                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                    deleteIcon: const Icon(Icons.close, size: 16),
                                    onDeleted: () {
                                      provider.removeTag(customer.id, tag);
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    // Etiket Ekleme
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Yeni Etiket Ekle',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _tagController,
                                    decoration: const InputDecoration(
                                      hintText: 'Etiket adı',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_tagController.text.trim().isNotEmpty) {
                                      provider.addTag(
                                        customer.id,
                                        _tagController.text.trim(),
                                      );
                                      _tagController.clear();
                                    }
                                  },
                                  child: const Text('Ekle'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Notlar
                    if (customer.notes.isNotEmpty) ...[
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notlar',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              ...customer.notes.asMap().entries.map((entry) {
                                final index = entry.key;
                                final note = entry.value;
                                return Card(
                                  margin: const SizedBox(height: 8),
                                  child: ListTile(
                                    title: Text(note),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        provider.removeNote(customer.id, index);
                                      },
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                    // Not Ekleme
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Yeni Not Ekle',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _noteController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Notunuzu buraya yazın...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_noteController.text.trim().isNotEmpty) {
                                    provider.addNote(
                                      customer.id,
                                      _noteController.text.trim(),
                                    );
                                    _noteController.clear();
                                  }
                                },
                                child: const Text('Not Ekle'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return 'Aktif';
      case CustomerCategory.potential:
        return 'Potansiyel';
      case CustomerCategory.vip:
        return 'VIP';
      case CustomerCategory.inactive:
        return 'Pasif';
      default:
        return 'Bilinmiyor';
    }
  }

  Color _getCategoryColor(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return Colors.green;
      case CustomerCategory.potential:
        return Colors.orange;
      case CustomerCategory.vip:
        return Colors.purple;
      case CustomerCategory.inactive:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
```

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../domain/entities/customer.dart';
import '../providers/customer_provider.dart';

class CustomerDetailPage extends StatefulWidget {
  final Customer customer;
  const CustomerDetailPage({Key? key, required this.customer}) : super(key: key);

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  final _noteController = TextEditingController();
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi ver
      if (url.startsWith('mailto:')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-posta uygulaması bulunamadı')),
        );
      } else if (url.startsWith('tel:')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Telefon uygulaması bulunamadı')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        final customer = provider.findById(widget.customer.id) ?? widget.customer;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Müşteri Detayı'),
            actions: [
              IconButton(
                tooltip: customer.isFavorite ? 'Favoriden çıkar' : 'Favoriye ekle',
                icon: Icon(customer.isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () => provider.toggleFavorite(customer.id),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // Müşteri Bilgileri
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => _launchUrl('mailto:${customer.email}', context),
                              child: Row(
                                children: [
                                  const Icon(Icons.email, size: 20),
                                  const SizedBox(width: 8),
                                  Text(customer.email, style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () => _launchUrl('tel:${customer.phone}', context),
                              child: Row(
                                children: [
                                  const Icon(Icons.phone, size: 20),
                                  const SizedBox(width: 8),
                                  Text(customer.phone, style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(
                                    _getCategoryName(customer.category),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: _getCategoryColor(customer.category),
                                ),
                                DropdownButton<CustomerCategory>(
                                  value: customer.category,
                                  onChanged: (value) {
                                    if (value != null) {
                                      provider.updateCustomerCategory(customer.id, value);
                                    }
                                  },
                                  items: CustomerCategory.values
                                      .map(
                                        (cat) => DropdownMenuItem(
                                          value: cat,
                                          child: Text(_getCategoryName(cat)),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Etiketler
                    if (customer.tags.isNotEmpty) ...[
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Etiketler',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: customer.tags.map((tag) {
                                  return Chip(
                                    label: Text(tag),
                                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                    deleteIcon: const Icon(Icons.close, size: 16),
                                    onDeleted: () {
                                      provider.removeTag(customer.id, tag);
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    // Etiket Ekleme
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Yeni Etiket Ekle',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _tagController,
                                    decoration: const InputDecoration(
                                      hintText: 'Etiket adı',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_tagController.text.trim().isNotEmpty) {
                                      provider.addTag(
                                        customer.id,
                                        _tagController.text.trim(),
                                      );
                                      _tagController.clear();
                                    }
                                  },
                                  child: const Text('Ekle'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Notlar
                    if (customer.notes.isNotEmpty) ...[
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notlar',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              ...customer.notes.asMap().entries.map((entry) {
                                final index = entry.key;
                                final note = entry.value;
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    title: Text(note),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        provider.removeNote(customer.id, index);
                                      },
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                    // Not Ekleme
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Yeni Not Ekle',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _noteController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Notunuzu buraya yazın...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_noteController.text.trim().isNotEmpty) {
                                    provider.addNote(
                                      customer.id,
                                      _noteController.text.trim(),
                                    );
                                    _noteController.clear();
                                  }
                                },
                                child: const Text('Not Ekle'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return 'Aktif';
      case CustomerCategory.potential:
        return 'Potansiyel';
      case CustomerCategory.vip:
        return 'VIP';
      case CustomerCategory.inactive:
        return 'Pasif';
      default:
        return 'Bilinmiyor';
    }
  }

  Color _getCategoryColor(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return Colors.green;
      case CustomerCategory.potential:
        return Colors.orange;
      case CustomerCategory.vip:
        return Colors.purple;
      case CustomerCategory.inactive:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
```

Yaptıklarım:
- `customer_provider.dart`: `findById` eklendi; entity’ye çevirerek detay sayfasının güncel veriyi çekebilmesini sağlıyor.
- `customer_detail_page.dart`: Sayfa `Consumer<CustomerProvider>` ile güncel müşteri verisini dinliyor. Favori toggle AppBar’a taşındı. Kategori dropdown’ı eklendi ve `updateCustomerCategory` ile bağlı. Etiket/not listeleri null-safety temizlendi. Etiket/not ekleme-silme işlemleri provider çağrılarına bağlı.

Sonraki adımlar (çekirdek işlevler):
- Derleyip çalıştır: `flutter run` ile akışları test et (detayta kategori/favori/not/etiket güncellemeleri Firestore’a yansıyor mu? listeye geri dönünce güncelleniyor mu?).
- `CustomerRepository` ve Firestore servisinde hata yakalama ve kullanıcıya snackbar geri bildirimi ihtiyacını gözden geçir.
- Form validasyonları: müşteri ekle/güncelle sayfasında zorunlu alanlar ve format kontrolleri.
- İleride: güvenlik/yetkilendirme (auth + rol bazlı izinler), ardından tasarım/giydirme.

Hazırsan şimdi çalıştırıp akışları birlikte gözden geçirelim.

---

**User**

olur devam

---

**Cursor**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/customer_provider.dart';
import '../../data/models/customer_model.dart';
import '../domain/entities/customer.dart';

class AddCustomerPage extends StatefulWidget {
  final CustomerModel? customer;
  const AddCustomerPage({Key? key, this.customer}) : super(key: key);

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  CustomerCategory _selectedCategory = CustomerCategory.active;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!.name;
      _emailController.text = widget.customer!.email;
      _phoneController.text = widget.customer!.phone;
      _selectedCategory = widget.customer!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final isEdit = widget.customer != null;
      final customer = CustomerModel(
        id: isEdit ? widget.customer!.id : const Uuid().v4(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        category: _selectedCategory,
        isFavorite: isEdit ? widget.customer!.isFavorite : false,
        notes: widget.customer?.notes ?? const [],
        tags: widget.customer?.tags ?? const [],
      );
      try {
        if (isEdit) {
          await Provider.of<CustomerProvider>(context, listen: false).updateCustomer(customer);
        } else {
          await Provider.of<CustomerProvider>(context, listen: false).addCustomer(customer);
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEdit ? 'Müşteri güncellendi' : 'Müşteri eklendi')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return 'Aktif';
      case CustomerCategory.potential:
        return 'Potansiyel';
      case CustomerCategory.vip:
        return 'VIP';
      case CustomerCategory.inactive:
        return 'Pasif';
      default:
        return 'Bilinmiyor';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.customer != null ? 'Müşteri Düzenle' : 'Müşteri Ekle')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.customer != null ? 'Müşteri Düzenle' : 'Yeni Müşteri Ekle',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'İsim',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'İsim giriniz' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Email giriniz';
                          final emailRegex = RegExp(r'^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$');
                          if (!emailRegex.hasMatch(value.trim())) return 'Geçerli bir email giriniz';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Telefon',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Telefon giriniz';
                          final digits = value.replaceAll(RegExp(r'\\D'), '');
                          if (digits.length < 10) return 'Geçerli bir telefon giriniz';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<CustomerCategory>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          prefixIcon: const Icon(Icons.category_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                        items: CustomerCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(_getCategoryName(category)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveCustomer,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  widget.customer != null ? 'Güncelle' : 'Kaydet',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 
```

Çekirdek işlevler için yaptıklarım:
- `CustomerDetailPage`: Provider’ı dinleyerek güncel veriyi kullanıyor; AppBar’da favori toggle; kategori dropdown ile `updateCustomerCategory`; etiket/not ekle-sil provider çağrılarına bağlı ve null-safety düzeltildi.
- `CustomerProvider`: `findById` eklendi; entity/map uyumlu.
- `AddCustomerPage`: Güncellemede not/tag kaybı düzeltilip mevcut değerler korunuyor. Email ve telefon için basit regex/uzunluk validasyonu eklendi.

Sıradaki öneri (çekirdek işlevleri bitirmek için):
- Derle/test et: `flutter run` ile ekle/düzenle/sil/favori/kategori/etiket/not akışlarını Firestore’da doğrula, listeye dönüşte güncelleniyor mu bak.
- Hata geri bildirimi: Repository/Firestore çağrılarında yakalanan hataları kullanıcıya anlamlı gösteriyor muyuz? (gerekirse provider tarafında try/catch mesajlarını iyileştirelim).
- İsteğe bağlı küçük iyileştirme: Liste ekranında “filtreyi temizle” butonu; sıralama (isim A-Z).

Derlemeyi başlatıp sonuçları söyleyebilirsen, kalan eksikleri tamamlayalım; ardından yetkilendirme/güvenlik adımına geçeriz.

---

**User**

etiketler kısmını aşağıya açılarak genişleyen bir pencere şeklinde yapalım sürekli aktif olup ana ekranda yer kaybı yapmasın

---

**Cursor**

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../domain/entities/customer.dart';
import '../providers/customer_provider.dart';

class CustomerDetailPage extends StatefulWidget {
  final Customer customer;
  const CustomerDetailPage({Key? key, required this.customer}) : super(key: key);

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  final _noteController = TextEditingController();
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi ver
      if (url.startsWith('mailto:')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-posta uygulaması bulunamadı')),
        );
      } else if (url.startsWith('tel:')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Telefon uygulaması bulunamadı')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        final customer = provider.findById(widget.customer.id) ?? widget.customer;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Müşteri Detayı'),
            actions: [
              IconButton(
                tooltip: customer.isFavorite ? 'Favoriden çıkar' : 'Favoriye ekle',
                icon: Icon(customer.isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () => provider.toggleFavorite(customer.id),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // Müşteri Bilgileri
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => _launchUrl('mailto:${customer.email}', context),
                              child: Row(
                                children: [
                                  const Icon(Icons.email, size: 20),
                                  const SizedBox(width: 8),
                                  Text(customer.email, style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () => _launchUrl('tel:${customer.phone}', context),
                              child: Row(
                                children: [
                                  const Icon(Icons.phone, size: 20),
                                  const SizedBox(width: 8),
                                  Text(customer.phone, style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(
                                    _getCategoryName(customer.category),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: _getCategoryColor(customer.category),
                                ),
                                DropdownButton<CustomerCategory>(
                                  value: customer.category,
                                  onChanged: (value) {
                                    if (value != null) {
                                      provider.updateCustomerCategory(customer.id, value);
                                    }
                                  },
                                  items: CustomerCategory.values
                                      .map(
                                        (cat) => DropdownMenuItem(
                                          value: cat,
                                          child: Text(_getCategoryName(cat)),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Etiketler (açılır kart)
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(
                          'Etiketler (${customer.tags.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        childrenPadding: const EdgeInsets.all(16.0),
                        children: [
                          if (customer.tags.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: customer.tags.map((tag) {
                                return Chip(
                                  label: Text(tag),
                                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    provider.removeTag(customer.id, tag);
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _tagController,
                                  decoration: const InputDecoration(
                                    hintText: 'Etiket adı',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  if (_tagController.text.trim().isNotEmpty) {
                                    provider.addTag(
                                      customer.id,
                                      _tagController.text.trim(),
                                    );
                                    _tagController.clear();
                                  }
                                },
                                child: const Text('Ekle'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Notlar
                    if (customer.notes.isNotEmpty) ...[
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notlar',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              ...customer.notes.asMap().entries.map((entry) {
                                final index = entry.key;
                                final note = entry.value;
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    title: Text(note),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        provider.removeNote(customer.id, index);
                                      },
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                    // Not Ekleme
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Yeni Not Ekle',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _noteController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Notunuzu buraya yazın...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_noteController.text.trim().isNotEmpty) {
                                    provider.addNote(
                                      customer.id,
                                      _noteController.text.trim(),
                                    );
                                    _noteController.clear();
                                  }
                                },
                                child: const Text('Not Ekle'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return 'Aktif';
      case CustomerCategory.potential:
        return 'Potansiyel';
      case CustomerCategory.vip:
        return 'VIP';
      case CustomerCategory.inactive:
        return 'Pasif';
      default:
        return 'Bilinmiyor';
    }
  }

  Color _getCategoryColor(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return Colors.green;
      case CustomerCategory.potential:
        return Colors.orange;
      case CustomerCategory.vip:
        return Colors.purple;
      case CustomerCategory.inactive:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
```

Etiket alanını ana ekranda yer kaplamayacak şekilde açılır hâle getirdim:
- `customer_detail_page.dart`: Etiket listesi ve ekleme alanı tek bir `ExpansionTile` içinde. Başlıkta etiket sayısı görünüyor; kullanıcı açınca mevcut etiketler ve ekleme formu gösteriliyor, kapalıyken alan daralıyor.

Derleyip deneyebilirsin; başka bir düzenleme istersen söyle.

---

**User**

tamam, yine customer detail sayfasındaki yeninot ekle kısmını da aynı şekilde yapalım ve bunlar dışında dashboard sayfasındaki Etiketler bölümü, statü bölümü bunları da aynı şekilde açılır kapanır yapalım

---

**Cursor**

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../domain/entities/customer.dart';
import '../providers/customer_provider.dart';

class CustomerDetailPage extends StatefulWidget {
  final Customer customer;
  const CustomerDetailPage({Key? key, required this.customer}) : super(key: key);

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  final _noteController = TextEditingController();
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi ver
      if (url.startsWith('mailto:')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-posta uygulaması bulunamadı')),
        );
      } else if (url.startsWith('tel:')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Telefon uygulaması bulunamadı')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        final customer = provider.findById(widget.customer.id) ?? widget.customer;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Müşteri Detayı'),
            actions: [
              IconButton(
                tooltip: customer.isFavorite ? 'Favoriden çıkar' : 'Favoriye ekle',
                icon: Icon(customer.isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () => provider.toggleFavorite(customer.id),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // Müşteri Bilgileri
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => _launchUrl('mailto:${customer.email}', context),
                              child: Row(
                                children: [
                                  const Icon(Icons.email, size: 20),
                                  const SizedBox(width: 8),
                                  Text(customer.email, style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () => _launchUrl('tel:${customer.phone}', context),
                              child: Row(
                                children: [
                                  const Icon(Icons.phone, size: 20),
                                  const SizedBox(width: 8),
                                  Text(customer.phone, style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(
                                    _getCategoryName(customer.category),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: _getCategoryColor(customer.category),
                                ),
                                DropdownButton<CustomerCategory>(
                                  value: customer.category,
                                  onChanged: (value) {
                                    if (value != null) {
                                      provider.updateCustomerCategory(customer.id, value);
                                    }
                                  },
                                  items: CustomerCategory.values
                                      .map(
                                        (cat) => DropdownMenuItem(
                                          value: cat,
                                          child: Text(_getCategoryName(cat)),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Etiketler (açılır kart)
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(
                          'Etiketler (${customer.tags.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        childrenPadding: const EdgeInsets.all(16.0),
                        children: [
                          if (customer.tags.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: customer.tags.map((tag) {
                                return Chip(
                                  label: Text(tag),
                                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    provider.removeTag(customer.id, tag);
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _tagController,
                                  decoration: const InputDecoration(
                                    hintText: 'Etiket adı',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  if (_tagController.text.trim().isNotEmpty) {
                                    provider.addTag(
                                      customer.id,
                                      _tagController.text.trim(),
                                    );
                                    _tagController.clear();
                                  }
                                },
                                child: const Text('Ekle'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Notlar (açılır kart)
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(
                          'Notlar (${customer.notes.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        childrenPadding: const EdgeInsets.all(16.0),
                        children: [
                          if (customer.notes.isNotEmpty) ...[
                            ...customer.notes.asMap().entries.map((entry) {
                              final index = entry.key;
                              final note = entry.value;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(note),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      provider.removeNote(customer.id, index);
                                    },
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 12),
                          ],
                          TextField(
                            controller: _noteController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Notunuzu buraya yazın...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_noteController.text.trim().isNotEmpty) {
                                  provider.addNote(
                                    customer.id,
                                    _noteController.text.trim(),
                                  );
                                  _noteController.clear();
                                }
                              },
                              child: const Text('Not Ekle'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return 'Aktif';
      case CustomerCategory.potential:
        return 'Potansiyel';
      case CustomerCategory.vip:
        return 'VIP';
      case CustomerCategory.inactive:
        return 'Pasif';
      default:
        return 'Bilinmiyor';
    }
  }

  Color _getCategoryColor(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return Colors.green;
      case CustomerCategory.potential:
        return Colors.orange;
      case CustomerCategory.vip:
        return Colors.purple;
      case CustomerCategory.inactive:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
```

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/customer_list_tile.dart';
import '../providers/customer_provider.dart';
import '../providers/theme_provider.dart';
import '../domain/entities/customer.dart';
import 'add_customer_page.dart';
import 'customer_detail_page.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({Key? key}) : super(key: key);

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return 'Aktif';
      case CustomerCategory.potential:
        return 'Potansiyel';
      case CustomerCategory.vip:
        return 'VIP';
      case CustomerCategory.inactive:
        return 'Pasif';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM Dashboard'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.brightness_6),
            onSelected: (mode) => context.read<ThemeProvider>().setTheme(mode),
            itemBuilder: (context) {
              final themeMode = Provider.of<ThemeProvider>(context, listen: false).themeMode;
              return [
                CheckedPopupMenuItem(
                  value: ThemeMode.system,
                  checked: themeMode == ThemeMode.system,
                  child: const Text('Sistem'),
                ),
                CheckedPopupMenuItem(
                  value: ThemeMode.light,
                  checked: themeMode == ThemeMode.light,
                  child: const Text('Açık'),
                ),
                CheckedPopupMenuItem(
                  value: ThemeMode.dark,
                  checked: themeMode == ThemeMode.dark,
                  child: const Text('Koyu'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CustomScrollView(
                slivers: [
                  // Dashboard Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Toplam Müşteri',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${provider.customers.length}',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Card(
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const AddCustomerPage()),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        size: 32,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Yeni Müşteri',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Category/Favorite Filters (collapsible)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: ExpansionTile(
                          title: const Text('Durum & Favori Filtreleri'),
                          childrenPadding: const EdgeInsets.all(16.0),
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        FilterChip(
                                          label: const Text('Tümü'),
                                          selected: provider.selectedCategory == null,
                                          onSelected: (selected) {
                                            if (selected) provider.selectedCategory = null;
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        ...CustomerCategory.values.map((category) {
                                          final isSelected = provider.selectedCategory == category;
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: FilterChip(
                                              label: Text(_getCategoryName(category)),
                                              selected: isSelected,
                                              onSelected: (selected) {
                                                provider.selectedCategory = selected ? category : null;
                                              },
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                FilterChip(
                                  label: const Text('Favoriler'),
                                  selected: provider.showOnlyFavorites,
                                  onSelected: (selected) {
                                    provider.showOnlyFavorites = selected;
                                  },
                                  avatar: Icon(
                                    provider.showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Tag Filters (collapsible)
                  if (provider.allTags.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: ExpansionTile(
                            title: const Text('Etiket Filtreleri'),
                            childrenPadding: const EdgeInsets.all(16.0),
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    FilterChip(
                                      label: const Text('Tüm Etiketler'),
                                      selected: provider.selectedTag.isEmpty,
                                      onSelected: (selected) {
                                        if (selected) provider.selectedTag = '';
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    ...provider.allTags.map((tag) {
                                      final isSelected = provider.selectedTag == tag;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: FilterChip(
                                          label: Text(tag),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            provider.selectedTag = selected ? tag : '';
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Müşteri ara (isim, email, telefon)',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          ),
                          onChanged: (value) => provider.searchQuery = value,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Customer List
                  provider.isLoading
                      ? const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : provider.filteredCustomers.isEmpty
                          ? SliverToBoxAdapter(
                              child: Center(
                                child: Card(
                                  margin: const EdgeInsets.all(32.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 64,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Hiç müşteri yok',
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Sağ üstten yeni müşteri ekleyebilirsiniz',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                    child: Card(
                                      child: CustomerListTile(
                                        customer: provider.filteredCustomers[index],
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => CustomerDetailPage(
                                                customer: provider.filteredCustomers[index],
                                              ),
                                            ),
                                          );
                                        },
                                        onToggleFavorite: () async {
                                          try {
                                            await provider.toggleFavorite(provider.filteredCustomers[index].id);
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(e.toString())),
                                              );
                                            }
                                          }
                                        },
                                        onEdit: () {
                                          final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => AddCustomerPage(
                                                customer: provider.customers[originalIndex],
                                              ),
                                            ),
                                          );
                                        },
                                        onDelete: () async {
                                          final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Müşteri Sil'),
                                              content: const Text('Bu müşteriyi silmek istediğinize emin misiniz?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: const Text('İptal'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: const Text('Sil'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            try {
                                              await provider.deleteCustomer(provider.customers[originalIndex].id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Müşteri silindi')),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(e.toString())),
                                                );
                                              }
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                                childCount: provider.filteredCustomers.length,
                              ),
                            ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 
```

İstenen açılır yapılarını ekledim:
- `customer_detail_page.dart`: Notlar bölümü artık `ExpansionTile`; başlıkta not sayısı, açıldığında mevcut notlar ve ekleme formu birlikte geliyor.
- `customer_page.dart`: Durum/favori filtreleri ile etiket filtreleri ayrı `ExpansionTile` içinde; kapalıyken yer kaplamıyor, açıldığında mevcut chip’ler görünüyor.

Linter hatası yok. Derleyip deneyebilirsin; başka açılır-kapanır düzenleme ihtiyacı varsa söyle.

---

**User**

bunlar tamam planımız doğrultusunda devam edelim kaldığımız yerden

---

**Cursor**

Devam adımları (çekirdek işlevler → güvenlik → tasarım):

**Hemen doğrulama**
- `flutter run` ile akış testleri: liste/arama/filtre, favori toggle, kategori değiştirme, etiket-not ekle/sil; detaydan geri dönünce liste güncelleniyor mu?
- Firestore erişimi ve hatalar: offline/izin hatalarında kullanıcıya snackbar gösterimi yeterli mi?

**Çekirdek tamamlamak için öneriler**
- `CustomerFirestoreService` çağrılarına try/catch ekleyip okunabilir hata mesajları döndürme; provider snackbar metinlerini iyileştirme.
- Liste ekranına hızlı “filtreyi temizle” butonu (kategori/favori/etiket/sorgu reset).
- Sıralama seçeneği (isim A-Z/Z-A) isteğe bağlı.

**Sonraki faza hazırlık (güvenlik/yetkilendirme)**
- Auth seç: Firebase Auth veya JWT backend? Rol tanımı (admin/agent/read-only).
- Token saklama: secure storage; config’leri .env + gitignore.
- İzinler: silme/düzenleme sadece yetkili rollerde; UI’da butonları rol bazlı gizle/disable.

**Tasarım fazı (sonra)**
- Renk/typografi tutarlılığı, boş/yükleniyor durumları için küçük iyileştirmeler.

İstersen önce hızlı bir “filtreleri temizle” ekleyeyim ve Firestore hatalarını kullanıcı dostu hale getireyim; sonra auth/rol tasarımına geçelim. Tercihin?

---

**User**

Hemen doğrulama kısmında bahsettiklerini kontrol ettim sorunsuz görünüyor. çekirdek tamamlamak için önerilerini uygula

---

**Cursor**

```dart
import 'package:flutter/material.dart';
import '../../data/models/customer_model.dart';
import '../../data/repo/customer_repository.dart';
import '../../presentation/domain/entities/customer.dart';

enum SortOption { nameAsc, nameDesc }

class CustomerProvider extends ChangeNotifier {
  final CustomerRepository repository;

  List<CustomerModel> _customers = [];
  List<CustomerModel> get customers => _customers;

  List<Customer> get customerEntities => _customers.map(_mapToEntity).toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  CustomerCategory? _selectedCategory;
  CustomerCategory? get selectedCategory => _selectedCategory;
  set selectedCategory(CustomerCategory? value) {
    _selectedCategory = value;
    notifyListeners();
  }

  bool _showOnlyFavorites = false;
  bool get showOnlyFavorites => _showOnlyFavorites;
  set showOnlyFavorites(bool value) {
    _showOnlyFavorites = value;
    notifyListeners();
  }

  String _selectedTag = '';
  String get selectedTag => _selectedTag;
  set selectedTag(String value) {
    _selectedTag = value;
    notifyListeners();
  }

  List<String> get allTags {
    final allTags = <String>{};
    for (final customer in _customers) {
      if (customer.tags != null) {
        allTags.addAll(customer.tags);
      }
    }
    return allTags.toList()..sort();
  }

  List<Customer> get filteredCustomers {
    final filtered = _customers.where((customer) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = customer.name.toLowerCase().contains(query);
        final matchesEmail = customer.email.toLowerCase().contains(query);
        final matchesPhone = customer.phone.toLowerCase().contains(query);
        final matchesNotes = customer.notes != null && 
            customer.notes.any((note) => note.toLowerCase().contains(query));
        final matchesTags = customer.tags != null && 
            customer.tags.any((tag) => tag.toLowerCase().contains(query));
        
        if (!matchesName && !matchesEmail && !matchesPhone && !matchesNotes && !matchesTags) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != null && customer.category != _selectedCategory) {
        return false;
      }

      // Favorite filter
      if (_showOnlyFavorites && !customer.isFavorite) {
        return false;
      }

      // Tag filter
      if (_selectedTag.isNotEmpty && (customer.tags == null || !customer.tags.contains(_selectedTag))) {
        return false;
      }

      return true;
    }).toList();

    final entities = filtered.map(_mapToEntity).toList();

    entities.sort((a, b) {
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();
      switch (_sortOption) {
        case SortOption.nameAsc:
          return aName.compareTo(bName);
        case SortOption.nameDesc:
          return bName.compareTo(aName);
      }
    });

    return entities;
  }

  CustomerProvider(this.repository);

  // Sort option
  SortOption _sortOption = SortOption.nameAsc;
  SortOption get sortOption => _sortOption;
  set sortOption(SortOption value) {
    _sortOption = value;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _showOnlyFavorites = false;
    _selectedTag = '';
    notifyListeners();
  }

  Customer? findById(String id) {
    final model = _customers.where((c) => c.id == id);
    if (model.isEmpty) return null;
    return _mapToEntity(model.first);
  }

  Customer _mapToEntity(CustomerModel model) {
    return Customer(
      id: model.id,
      name: model.name,
      email: model.email,
      phone: model.phone,
      category: model.category,
      isFavorite: model.isFavorite,
      notes: model.notes,
      tags: model.tags,
    );
  }

  Future<void> fetchCustomers() async {
    _isLoading = true;
    notifyListeners();
    _customers = await repository.getCustomers();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCustomer(CustomerModel customer) async {
    try {
      await repository.addCustomer(customer);
      await fetchCustomers();
    } catch (e) {
      throw Exception('Müşteri eklenemedi: $e');
    }
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await repository.updateCustomer(customer);
      await fetchCustomers();
    } catch (e) {
      throw Exception('Müşteri güncellenemedi: $e');
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await repository.deleteCustomer(id);
      await fetchCustomers();
    } catch (e) {
      throw Exception('Müşteri silinemedi: $e');
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == id);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedCustomer = customer.copyWith(isFavorite: !customer.isFavorite);
        await repository.updateCustomer(updatedCustomer);
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Favori durumu güncellenemedi: $e');
    }
  }

  Future<void> updateCustomerCategory(String id, CustomerCategory category) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == id);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedCustomer = customer.copyWith(category: category);
        await repository.updateCustomer(updatedCustomer);
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Kategori güncellenemedi: $e');
    }
  }

  Future<void> addNote(String customerId, String note) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == customerId);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedNotes = [...customer.notes, note];
        final updatedCustomer = customer.copyWith(notes: updatedNotes);
        await repository.updateCustomer(updatedCustomer);
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Not eklenemedi: $e');
    }
  }

  Future<void> removeNote(String customerId, int noteIndex) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == customerId);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedNotes = List<String>.from(customer.notes);
        updatedNotes.removeAt(noteIndex);
        final updatedCustomer = customer.copyWith(notes: updatedNotes);
        await repository.updateCustomer(updatedCustomer);
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Not silinemedi: $e');
    }
  }

  Future<void> addTag(String customerId, String tag) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == customerId);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        if (!customer.tags.contains(tag)) {
          final updatedTags = [...customer.tags, tag];
          final updatedCustomer = customer.copyWith(tags: updatedTags);
          await repository.updateCustomer(updatedCustomer);
          await fetchCustomers();
        }
      }
    } catch (e) {
      throw Exception('Etiket eklenemedi: $e');
    }
  }

  Future<void> removeTag(String customerId, String tag) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == customerId);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedTags = List<String>.from(customer.tags);
        updatedTags.remove(tag);
        final updatedCustomer = customer.copyWith(tags: updatedTags);
        await repository.updateCustomer(updatedCustomer);
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Etiket silinemedi: $e');
    }
  }
} 
```

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/customer_list_tile.dart';
import '../providers/customer_provider.dart';
import '../providers/theme_provider.dart';
import '../domain/entities/customer.dart';
import 'add_customer_page.dart';
import 'customer_detail_page.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({Key? key}) : super(key: key);

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return 'Aktif';
      case CustomerCategory.potential:
        return 'Potansiyel';
      case CustomerCategory.vip:
        return 'VIP';
      case CustomerCategory.inactive:
        return 'Pasif';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM Dashboard'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.brightness_6),
            onSelected: (mode) => context.read<ThemeProvider>().setTheme(mode),
            itemBuilder: (context) {
              final themeMode = Provider.of<ThemeProvider>(context, listen: false).themeMode;
              return [
                CheckedPopupMenuItem(
                  value: ThemeMode.system,
                  checked: themeMode == ThemeMode.system,
                  child: const Text('Sistem'),
                ),
                CheckedPopupMenuItem(
                  value: ThemeMode.light,
                  checked: themeMode == ThemeMode.light,
                  child: const Text('Açık'),
                ),
                CheckedPopupMenuItem(
                  value: ThemeMode.dark,
                  checked: themeMode == ThemeMode.dark,
                  child: const Text('Koyu'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CustomScrollView(
                slivers: [
                  // Dashboard Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Toplam Müşteri',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${provider.customers.length}',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Card(
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const AddCustomerPage()),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        size: 32,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Yeni Müşteri',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Category/Favorite Filters (collapsible)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: ExpansionTile(
                          title: const Text('Durum & Favori Filtreleri'),
                          childrenPadding: const EdgeInsets.all(16.0),
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        FilterChip(
                                          label: const Text('Tümü'),
                                          selected: provider.selectedCategory == null,
                                          onSelected: (selected) {
                                            if (selected) provider.selectedCategory = null;
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        ...CustomerCategory.values.map((category) {
                                          final isSelected = provider.selectedCategory == category;
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: FilterChip(
                                              label: Text(_getCategoryName(category)),
                                              selected: isSelected,
                                              onSelected: (selected) {
                                                provider.selectedCategory = selected ? category : null;
                                              },
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                FilterChip(
                                  label: const Text('Favoriler'),
                                  selected: provider.showOnlyFavorites,
                                  onSelected: (selected) {
                                    provider.showOnlyFavorites = selected;
                                  },
                                  avatar: Icon(
                                    provider.showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Tag Filters (collapsible)
                  if (provider.allTags.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: ExpansionTile(
                            title: const Text('Etiket Filtreleri'),
                            childrenPadding: const EdgeInsets.all(16.0),
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    FilterChip(
                                      label: const Text('Tüm Etiketler'),
                                      selected: provider.selectedTag.isEmpty,
                                      onSelected: (selected) {
                                        if (selected) provider.selectedTag = '';
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    ...provider.allTags.map((tag) {
                                      final isSelected = provider.selectedTag == tag;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: FilterChip(
                                          label: Text(tag),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            provider.selectedTag = selected ? tag : '';
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Müşteri ara (isim, email, telefon)',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          ),
                          onChanged: (value) => provider.searchQuery = value,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Customer List
                  provider.isLoading
                      ? const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : provider.filteredCustomers.isEmpty
                          ? SliverToBoxAdapter(
                              child: Center(
                                child: Card(
                                  margin: const EdgeInsets.all(32.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 64,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Hiç müşteri yok',
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Sağ üstten yeni müşteri ekleyebilirsiniz',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                    child: Card(
                                      child: CustomerListTile(
                                        customer: provider.filteredCustomers[index],
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => CustomerDetailPage(
                                                customer: provider.filteredCustomers[index],
                                              ),
                                            ),
                                          );
                                        },
                                        onToggleFavorite: () async {
                                          try {
                                            await provider.toggleFavorite(provider.filteredCustomers[index].id);
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(e.toString())),
                                              );
                                            }
                                          }
                                        },
                                        onEdit: () {
                                          final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => AddCustomerPage(
                                                customer: provider.customers[originalIndex],
                                              ),
                                            ),
                                          );
                                        },
                                        onDelete: () async {
                                          final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Müşteri Sil'),
                                              content: const Text('Bu müşteriyi silmek istediğinize emin misiniz?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: const Text('İptal'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: const Text('Sil'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            try {
                                              await provider.deleteCustomer(provider.customers[originalIndex].id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Müşteri silindi')),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(e.toString())),
                                                );
                                              }
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                                childCount: provider.filteredCustomers.length,
                              ),
                            ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 
```

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/customer_list_tile.dart';
import '../providers/customer_provider.dart';
import '../providers/theme_provider.dart';
import '../domain/entities/customer.dart';
import 'add_customer_page.dart';
import 'customer_detail_page.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final _searchController = TextEditingController();

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return 'Aktif';
      case CustomerCategory.potential:
        return 'Potansiyel';
      case CustomerCategory.vip:
        return 'VIP';
      case CustomerCategory.inactive:
        return 'Pasif';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM Dashboard'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.brightness_6),
            onSelected: (mode) => context.read<ThemeProvider>().setTheme(mode),
            itemBuilder: (context) {
              final themeMode = Provider.of<ThemeProvider>(context, listen: false).themeMode;
              return [
                CheckedPopupMenuItem(
                  value: ThemeMode.system,
                  checked: themeMode == ThemeMode.system,
                  child: const Text('Sistem'),
                ),
                CheckedPopupMenuItem(
                  value: ThemeMode.light,
                  checked: themeMode == ThemeMode.light,
                  child: const Text('Açık'),
                ),
                CheckedPopupMenuItem(
                  value: ThemeMode.dark,
                  checked: themeMode == ThemeMode.dark,
                  child: const Text('Koyu'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CustomScrollView(
                slivers: [
                  // Dashboard Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Toplam Müşteri',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${provider.customers.length}',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Card(
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const AddCustomerPage()),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        size: 32,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Yeni Müşteri',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Category/Favorite Filters (collapsible)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: ExpansionTile(
                          title: const Text('Durum & Favori Filtreleri'),
                          childrenPadding: const EdgeInsets.all(16.0),
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        FilterChip(
                                          label: const Text('Tümü'),
                                          selected: provider.selectedCategory == null,
                                          onSelected: (selected) {
                                            if (selected) provider.selectedCategory = null;
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        ...CustomerCategory.values.map((category) {
                                          final isSelected = provider.selectedCategory == category;
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: FilterChip(
                                              label: Text(_getCategoryName(category)),
                                              selected: isSelected,
                                              onSelected: (selected) {
                                                provider.selectedCategory = selected ? category : null;
                                              },
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                FilterChip(
                                  label: const Text('Favoriler'),
                                  selected: provider.showOnlyFavorites,
                                  onSelected: (selected) {
                                    provider.showOnlyFavorites = selected;
                                  },
                                  avatar: Icon(
                                    provider.showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Tag Filters (collapsible)
                  if (provider.allTags.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: ExpansionTile(
                            title: const Text('Etiket Filtreleri'),
                            childrenPadding: const EdgeInsets.all(16.0),
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    FilterChip(
                                      label: const Text('Tüm Etiketler'),
                                      selected: provider.selectedTag.isEmpty,
                                      onSelected: (selected) {
                                        if (selected) provider.selectedTag = '';
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    ...provider.allTags.map((tag) {
                                      final isSelected = provider.selectedTag == tag;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: FilterChip(
                                          label: Text(tag),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            provider.selectedTag = selected ? tag : '';
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Müşteri ara (isim, email, telefon)',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          ),
                          onChanged: (value) => provider.searchQuery = value,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Customer List
                  provider.isLoading
                      ? const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : provider.filteredCustomers.isEmpty
                          ? SliverToBoxAdapter(
                              child: Center(
                                child: Card(
                                  margin: const EdgeInsets.all(32.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 64,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Hiç müşteri yok',
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Sağ üstten yeni müşteri ekleyebilirsiniz',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                    child: Card(
                                      child: CustomerListTile(
                                        customer: provider.filteredCustomers[index],
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => CustomerDetailPage(
                                                customer: provider.filteredCustomers[index],
                                              ),
                                            ),
                                          );
                                        },
                                        onToggleFavorite: () async {
                                          try {
                                            await provider.toggleFavorite(provider.filteredCustomers[index].id);
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(e.toString())),
                                              );
                                            }
                                          }
                                        },
                                        onEdit: () {
                                          final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => AddCustomerPage(
                                                customer: provider.customers[originalIndex],
                                              ),
                                            ),
                                          );
                                        },
                                        onDelete: () async {
                                          final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Müşteri Sil'),
                                              content: const Text('Bu müşteriyi silmek istediğinize emin misiniz?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: const Text('İptal'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: const Text('Sil'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            try {
                                              await provider.deleteCustomer(provider.customers[originalIndex].id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Müşteri silindi')),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(e.toString())),
                                                );
                                              }
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                                childCount: provider.filteredCustomers.length,
                              ),
                            ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 
```

```dart
*** Begin Patch
*** Update File: lib/presentation/pages/customer_page.dart
@@
-                  // Category/Favorite Filters (collapsible)
+                  // Category/Favorite Filters (collapsible)
                   SliverToBoxAdapter(
                     child: Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
                       child: Card(
                         child: ExpansionTile(
                           title: const Text('Durum & Favori Filtreleri'),
                           childrenPadding: const EdgeInsets.all(16.0),
                           children: [
+                            Row(
+                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
+                              children: [
+                                Text(
+                                  'Sıralama',
+                                  style: Theme.of(context).textTheme.titleSmall,
+                                ),
+                                DropdownButton<SortOption>(
+                                  value: provider.sortOption,
+                                  onChanged: (value) {
+                                    if (value != null) provider.sortOption = value;
+                                  },
+                                  items: const [
+                                    DropdownMenuItem(
+                                      value: SortOption.nameAsc,
+                                      child: Text('İsim A-Z'),
+                                    ),
+                                    DropdownMenuItem(
+                                      value: SortOption.nameDesc,
+                                      child: Text('İsim Z-A'),
+                                    ),
+                                  ],
+                                ),
+                              ],
+                            ),
+                            const SizedBox(height: 12),
                             Row(
                               children: [
                                 Expanded(
                                   child: SingleChildScrollView(
                                     scrollDirection: Axis.horizontal,
@@
                                   size: 18,
                                 ),
                               ),
                             ),
+                            const SizedBox(height: 12),
+                            Align(
+                              alignment: Alignment.centerLeft,
+                              child: OutlinedButton.icon(
+                                icon: const Icon(Icons.refresh),
+                                label: const Text('Filtreleri temizle'),
+                                onPressed: () {
+                                  provider.resetFilters();
+                                  _searchController.clear();
+                                },
+                              ),
+                            ),
                           ],
                         ),
                       ),
                     ),
                   ),
*** End Patch
```

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/customer_list_tile.dart';
import '../providers/customer_provider.dart';
import '../providers/theme_provider.dart';
import '../domain/entities/customer.dart';
import 'add_customer_page.dart';
import 'customer_detail_page.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final _searchController = TextEditingController();

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return 'Aktif';
      case CustomerCategory.potential:
        return 'Potansiyel';
      case CustomerCategory.vip:
        return 'VIP';
      case CustomerCategory.inactive:
        return 'Pasif';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM Dashboard'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.brightness_6),
            onSelected: (mode) => context.read<ThemeProvider>().setTheme(mode),
            itemBuilder: (context) {
              final themeMode = Provider.of<ThemeProvider>(context, listen: false).themeMode;
              return [
                CheckedPopupMenuItem(
                  value: ThemeMode.system,
                  checked: themeMode == ThemeMode.system,
                  child: const Text('Sistem'),
                ),
                CheckedPopupMenuItem(
                  value: ThemeMode.light,
                  checked: themeMode == ThemeMode.light,
                  child: const Text('Açık'),
                ),
                CheckedPopupMenuItem(
                  value: ThemeMode.dark,
                  checked: themeMode == ThemeMode.dark,
                  child: const Text('Koyu'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CustomScrollView(
                slivers: [
                  // Dashboard Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Toplam Müşteri',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${provider.customers.length}',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Card(
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const AddCustomerPage()),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        size: 32,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Yeni Müşteri',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Category/Favorite Filters (collapsible)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: ExpansionTile(
                          title: const Text('Durum & Favori Filtreleri'),
                          childrenPadding: const EdgeInsets.all(16.0),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sıralama',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                DropdownButton<SortOption>(
                                  value: provider.sortOption,
                                  onChanged: (value) {
                                    if (value != null) provider.sortOption = value;
                                  },
                                  items: const [
                                    DropdownMenuItem(
                                      value: SortOption.nameAsc,
                                      child: Text('İsim A-Z'),
                                    ),
                                    DropdownMenuItem(
                                      value: SortOption.nameDesc,
                                      child: Text('İsim Z-A'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        FilterChip(
                                          label: const Text('Tümü'),
                                          selected: provider.selectedCategory == null,
                                          onSelected: (selected) {
                                            if (selected) provider.selectedCategory = null;
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        ...CustomerCategory.values.map((category) {
                                          final isSelected = provider.selectedCategory == category;
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: FilterChip(
                                              label: Text(_getCategoryName(category)),
                                              selected: isSelected,
                                              onSelected: (selected) {
                                                provider.selectedCategory = selected ? category : null;
                                              },
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                FilterChip(
                                  label: const Text('Favoriler'),
                                  selected: provider.showOnlyFavorites,
                                  onSelected: (selected) {
                                    provider.showOnlyFavorites = selected;
                                  },
                                  avatar: Icon(
                                    provider.showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text('Filtreleri temizle'),
                                onPressed: () {
                                  provider.resetFilters();
                                  _searchController.clear();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Tag Filters (collapsible)
                  if (provider.allTags.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: ExpansionTile(
                            title: const Text('Etiket Filtreleri'),
                            childrenPadding: const EdgeInsets.all(16.0),
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    FilterChip(
                                      label: const Text('Tüm Etiketler'),
                                      selected: provider.selectedTag.isEmpty,
                                      onSelected: (selected) {
                                        if (selected) provider.selectedTag = '';
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    ...provider.allTags.map((tag) {
                                      final isSelected = provider.selectedTag == tag;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: FilterChip(
                                          label: Text(tag),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            provider.selectedTag = selected ? tag : '';
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Müşteri ara (isim, email, telefon)',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          ),
                          onChanged: (value) => provider.searchQuery = value,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Customer List
                  provider.isLoading
                      ? const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : provider.filteredCustomers.isEmpty
                          ? SliverToBoxAdapter(
                              child: Center(
                                child: Card(
                                  margin: const EdgeInsets.all(32.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 64,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Hiç müşteri yok',
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Sağ üstten yeni müşteri ekleyebilirsiniz',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                    child: Card(
                                      child: CustomerListTile(
                                        customer: provider.filteredCustomers[index],
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => CustomerDetailPage(
                                                customer: provider.filteredCustomers[index],
                                              ),
                                            ),
                                          );
                                        },
                                        onToggleFavorite: () async {
                                          try {
                                            await provider.toggleFavorite(provider.filteredCustomers[index].id);
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(e.toString())),
                                              );
                                            }
                                          }
                                        },
                                        onEdit: () {
                                          final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => AddCustomerPage(
                                                customer: provider.customers[originalIndex],
                                              ),
                                            ),
                                          );
                                        },
                                        onDelete: () async {
                                          final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Müşteri Sil'),
                                              content: const Text('Bu müşteriyi silmek istediğinize emin misiniz?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: const Text('İptal'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: const Text('Sil'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            try {
                                              await provider.deleteCustomer(provider.customers[originalIndex].id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Müşteri silindi')),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(e.toString())),
                                                );
                                              }
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                                childCount: provider.filteredCustomers.length,
                              ),
                            ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 
```

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/customer_list_tile.dart';
import '../providers/customer_provider.dart';
import '../providers/theme_provider.dart';
import '../domain/entities/customer.dart';
import 'add_customer_page.dart';
import 'customer_detail_page.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final _searchController = TextEditingController();

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return 'Aktif';
      case CustomerCategory.potential:
        return 'Potansiyel';
      case CustomerCategory.vip:
        return 'VIP';
      case CustomerCategory.inactive:
        return 'Pasif';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM Dashboard'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.brightness_6),
            onSelected: (mode) => context.read<ThemeProvider>().setTheme(mode),
            itemBuilder: (context) {
              final themeMode = Provider.of<ThemeProvider>(context, listen: false).themeMode;
              return [
                CheckedPopupMenuItem(
                  value: ThemeMode.system,
                  checked: themeMode == ThemeMode.system,
                  child: const Text('Sistem'),
                ),
                CheckedPopupMenuItem(
                  value: ThemeMode.light,
                  checked: themeMode == ThemeMode.light,
                  child: const Text('Açık'),
                ),
                CheckedPopupMenuItem(
                  value: ThemeMode.dark,
                  checked: themeMode == ThemeMode.dark,
                  child: const Text('Koyu'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CustomScrollView(
                slivers: [
                  // Dashboard Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Toplam Müşteri',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${provider.customers.length}',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Card(
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const AddCustomerPage()),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        size: 32,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Yeni Müşteri',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Category/Favorite Filters (collapsible)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: ExpansionTile(
                          title: const Text('Durum & Favori Filtreleri'),
                          childrenPadding: const EdgeInsets.all(16.0),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sıralama',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                DropdownButton<SortOption>(
                                  value: provider.sortOption,
                                  onChanged: (value) {
                                    if (value != null) provider.sortOption = value;
                                  },
                                  items: const [
                                    DropdownMenuItem(
                                      value: SortOption.nameAsc,
                                      child: Text('İsim A-Z'),
                                    ),
                                    DropdownMenuItem(
                                      value: SortOption.nameDesc,
                                      child: Text('İsim Z-A'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        FilterChip(
                                          label: const Text('Tümü'),
                                          selected: provider.selectedCategory == null,
                                          onSelected: (selected) {
                                            if (selected) provider.selectedCategory = null;
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        ...CustomerCategory.values.map((category) {
                                          final isSelected = provider.selectedCategory == category;
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: FilterChip(
                                              label: Text(_getCategoryName(category)),
                                              selected: isSelected,
                                              onSelected: (selected) {
                                                provider.selectedCategory = selected ? category : null;
                                              },
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                FilterChip(
                                  label: const Text('Favoriler'),
                                  selected: provider.showOnlyFavorites,
                                  onSelected: (selected) {
                                    provider.showOnlyFavorites = selected;
                                  },
                                  avatar: Icon(
                                    provider.showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text('Filtreleri temizle'),
                                onPressed: () {
                                  provider.resetFilters();
                                  _searchController.clear();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Tag Filters (collapsible)
                  if (provider.allTags.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: ExpansionTile(
                            title: const Text('Etiket Filtreleri'),
                            childrenPadding: const EdgeInsets.all(16.0),
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    FilterChip(
                                      label: const Text('Tüm Etiketler'),
                                      selected: provider.selectedTag.isEmpty,
                                      onSelected: (selected) {
                                        if (selected) provider.selectedTag = '';
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    ...provider.allTags.map((tag) {
                                      final isSelected = provider.selectedTag == tag;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: FilterChip(
                                          label: Text(tag),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            provider.selectedTag = selected ? tag : '';
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Müşteri ara (isim, email, telefon)',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          ),
                          onChanged: (value) => provider.searchQuery = value,
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Customer List
                  provider.isLoading
                      ? const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : provider.filteredCustomers.isEmpty
                          ? SliverToBoxAdapter(
                              child: Center(
                                child: Card(
                                  margin: const EdgeInsets.all(32.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 64,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Hiç müşteri yok',
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Sağ üstten yeni müşteri ekleyebilirsiniz',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                    child: Card(
                                      child: CustomerListTile(
                                        customer: provider.filteredCustomers[index],
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => CustomerDetailPage(
                                                customer: provider.filteredCustomers[index],
                                              ),
                                            ),
                                          );
                                        },
                                        onToggleFavorite: () async {
                                          try {
                                            await provider.toggleFavorite(provider.filteredCustomers[index].id);
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(e.toString())),
                                              );
                                            }
                                          }
                                        },
                                        onEdit: () {
                                          final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => AddCustomerPage(
                                                customer: provider.customers[originalIndex],
                                              ),
                                            ),
                                          );
                                        },
                                        onDelete: () async {
                                          final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Müşteri Sil'),
                                              content: const Text('Bu müşteriyi silmek istediğinize emin misiniz?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: const Text('İptal'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: const Text('Sil'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            try {
                                              await provider.deleteCustomer(provider.customers[originalIndex].id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Müşteri silindi')),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(e.toString())),
                                                );
                                              }
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                                childCount: provider.filteredCustomers.length,
                              ),
                            ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 
```

Çekirdek iyileştirmeleri uyguladım:

- Sıralama ve filtre reset:
  - `customer_provider.dart`: `SortOption` eklendi, filtrelenen liste isim A-Z / Z-A sıralanıyor. `resetFilters()` tüm filtre/arama durumu ve favori/etiket seçimini sıfırlıyor.
  - `customer_page.dart`: Sayfa `StatefulWidget` oldu, arama için controller eklendi. Durum/Favori kartına sıralama dropdown’ı ve “Filtreleri temizle” butonu eklendi; arama kutusu temizleniyor.

- Kullanıcı deneyimi:
  - Arama alanı controller’lı, dışarı tıklayınca klavye kapanıyor.
  - Filtre kartları kapalıyken yer kazandırmaya devam ediyor.

Sıradaki küçük öneri (istersen):
- Arama alanına temizle (X) ikonu eklemek.
- Firestore servis çağrılarına try/catch ekleyip anlamlı mesajlar döndürmek.

Derleyip kontrol et; başka bir ekleme istersen yapalım.

---

**User**

şimdilik bu kadar, projeyi github hesabıma eklemek istiyorum github desktop ile ve ilerledikçe güncelleyeceğim, bunu sen yapabiliyor musun manuel mi yapmalıyım?

---

**Cursor**

Ben doğrudan GitHub Desktop’ı veya hesabını kontrol edemem; repo’yu GitHub’a ekleme işini sen manuel yapmalısın. Ama adımları net biçimde verebilirim:

### 1) Yerel repo’yu hazırlama
- Proje klasörün zaten `C:\androidProjects\crm`.
- İstersen önce terminalden git başlat: 

```bash
cd C:\androidProjects\crm
git init
git add .
git commit -m "Initial CRM app"
```

(Bunu istersen GitHub Desktop da otomatik yapabilir.)

### 2) GitHub Desktop ile yeni repo oluşturma
1. GitHub Desktop’ı aç.
2. **File → Add Local Repository...** menüsüne gir.
3. Path olarak `C:\androidProjects\crm` klasörünü seç, **Add Repository** de.
4. Sağ üstte **Publish repository** butonuna tıkla.
5. Repo adını ve görünürlüğü (Private/Public) seç → **Publish Repository**.

### 3) İleride güncelleme
- Değişiklik yaptıkça:
  - GitHub Desktop’ta değişiklikleri seç → commit mesajı yaz → **Commit to main**.
  - Sonra **Push origin** butonuna basarak GitHub’a gönder.

İstersen `.gitignore` (örneğin build klasörleri, `.flutter-plugins`, vs.) için de sana özel bir içerik hazırlayabilirim.

```shellscript
cd C:\androidProjects\crm
git init
git add .
git commit -m "Initial CRM app"
```

---

**User**

açıklama olarak ne yazayım

---

**Cursor**

Kısa ve net bir commit mesajı yeterli. Bu değişiklikler için şunlardan birini kullanabilirsin:

- **Genel ve açıklayıcı:**
  - `Tam fonksiyonel CRM müşteri yönetimi ekranları`
  - `Müşteri listeleme, detay, not ve etiket yönetimi eklendi`

- Daha teknik:
  - `Customer provider, filtreler ve detay sayfası iyileştirmeleri`
  - `Müşteri detayında not/etiket ve dashboard filtre yapısı güncellendi`

İlk commit ise repo için:
- `Initial commit: Flutter CRM uygulaması başlangıç yapısı`

---

**User**

ilk özet ve ilk açıklama için neler yazayım

---

**Cursor**

İlk kez GitHub’a atarken 2 yere yazı yazıyorsun gibi düşünebiliriz:  
1) Repo’nun genel açıklaması (GitHub’daki Description / README)  
2) İlk commit’in “Summary” ve istersen “Description” kısmı

### 1) Repo açıklaması / README için öneri

**Kısa Description alanı (GitHub’daki tek satır):**

- `Flutter ile geliştirilmiş basit CRM uygulaması: müşteri takibi, not ve etiket yönetimi`
- veya daha kısa: `Flutter tabanlı müşteri yönetim (CRM) uygulaması`

**README’nin en başına koyabileceğin giriş:**

```markdown
## CRM Flutter Uygulaması

Bu proje, Flutter ile geliştirilmiş basit bir CRM (Customer Relationship Management) uygulamasıdır.  
Amaç, küçük ekipler ve bireysel kullanıcılar için:

- Müşteri listesini görüntüleme ve arama
- Kategori (aktif/potansiyel/VIP/pasif) ve favori filtreleri
- Müşteri detayında not ve etiket yönetimi
- Temel dashboard görünümü ile toplam müşteri sayısına hızlı erişim

Üzerinde yetkilendirme, veri güvenliği ve tasarım iyileştirmeleri yapılmaya devam edilecektir.
```

### 2) İlk commit “Summary” ve “Description” için öneri

**Summary (kısa başlık):**

- `Initial commit: Flutter CRM uygulaması temel yapısı`
- veya: `Müşteri listeleme ve detay ekranlarının ilk versiyonu`

**Description (isteğe bağlı daha uzun açıklama):**

```text
- Customer listesi, filtreler ve arama çubuğu eklendi.
- Müşteri detay sayfasında not ve etiket yönetimi gerçekleştirildi.
- CustomerProvider, Firestore repository ve temel mimari yapılandırıldı.
- Temel tema switch (açık/koyu/sistem) desteği eklendi.
```

İstersen bu metinleri senin stiline göre sadeleştirebilir veya İngilizce’ye çevirebilirim.

```markdown
## CRM Flutter Uygulaması

Bu proje, Flutter ile geliştirilmiş basit bir CRM (Customer Relationship Management) uygulamasıdır.  
Amaç, küçük ekipler ve bireysel kullanıcılar için:

- Müşteri listesini görüntüleme ve arama
- Kategori (aktif/potansiyel/VIP/pasif) ve favori filtreleri
- Müşteri detayında not ve etiket yönetimi
- Temel dashboard görünümü ile toplam müşteri sayısına hızlı erişim

Üzerinde yetkilendirme, veri güvenliği ve tasarım iyileştirmeleri yapılmaya devam edilecektir.
```

```plaintext
- Customer listesi, filtreler ve arama çubuğu eklendi.
- Müşteri detay sayfasında not ve etiket yönetimi gerçekleştirildi.
- CustomerProvider, Firestore repository ve temel mimari yapılandırıldı.
- Temel tema switch (açık/koyu/sistem) desteği eklendi.
```

---

**User**

en son ne eklemiştik

---

**Cursor**

En son eklediklerimiz:

**1. Açılır-kapanır bölümler (UI iyileştirmesi):**
- `customer_detail_page.dart`: Etiketler ve Notlar bölümleri `ExpansionTile` ile açılır-kapanır yapıldı
- `customer_page.dart`: Durum & Favori Filtreleri ve Etiket Filtreleri `ExpansionTile` ile açılır-kapanır yapıldı

**2. Çekirdek işlevler:**
- Sıralama: İsim A-Z / Z-A seçeneği eklendi (`SortOption` enum'ı ve `customer_provider.dart`'ta sıralama mantığı)
- Filtreleri temizle butonu: Tüm filtreleri ve arama sorgusunu sıfırlıyor
- Arama iyileştirmesi: Arama alanına controller eklendi, dışarı tıklayınca klavye kapanıyor
- Form validasyonu: `add_customer_page.dart`'ta email ve telefon için basit regex validasyonu eklendi

**3. Provider iyileştirmeleri:**
- `resetFilters()` metodu eklendi
- `filteredCustomers` getter'ı sıralama mantığını içeriyor

Özet: UI’da yer tasarrufu için açılır-kapanır bölümler ve sıralama/filtre temizleme gibi kullanıcı deneyimi iyileştirmeleri eklendi.

GitHub’a commit ederken bu özellikleri özetleyebilirsin.

---

**User**

devam edelim

---

**Cursor**

Çekirdek işlevleri tamamlayıp ardından güvenlik/yetkilendirme fazına geçiyoruz. Önce Firestore hata yönetimini iyileştiriyoruz:


Firestore hata yönetimini iyileştirip arama alanına temizle butonu ekliyoruz:


```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/customer_model.dart';

class CustomerFirestoreService {
  final CollectionReference _customerCollection =
      FirebaseFirestore.instance.collection('customers');

  Future<List<CustomerModel>> getCustomers() async {
    try {
      final snapshot = await _customerCollection.get();
      return snapshot.docs
          .map((doc) {
            try {
              return CustomerModel.fromJson(doc.data() as Map<String, dynamic>);
            } catch (e) {
              throw Exception('Müşteri verisi okunamadı: ${doc.id}');
            }
          })
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Veriler yüklenirken hata oluştu: ${e.message ?? "Bilinmeyen hata"}');
    } catch (e) {
      throw Exception('Veriler yüklenirken beklenmeyen bir hata oluştu');
    }
  }

  Future<void> addCustomer(CustomerModel customer) async {
    try {
      await _customerCollection.doc(customer.id).set(customer.toJson());
    } on FirebaseException catch (e) {
      throw Exception('Müşteri eklenirken hata oluştu: ${e.message ?? "Bilinmeyen hata"}');
    } catch (e) {
      throw Exception('Müşteri eklenirken beklenmeyen bir hata oluştu');
    }
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await _customerCollection.doc(customer.id).update(customer.toJson());
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw Exception('Müşteri bulunamadı');
      }
      throw Exception('Müşteri güncellenirken hata oluştu: ${e.message ?? "Bilinmeyen hata"}');
    } catch (e) {
      throw Exception('Müşteri güncellenirken beklenmeyen bir hata oluştu');
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _customerCollection.doc(id).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw Exception('Müşteri bulunamadı');
      }
      throw Exception('Müşteri silinirken hata oluştu: ${e.message ?? "Bilinmeyen hata"}');
    } catch (e) {
      throw Exception('Müşteri silinirken beklenmeyen bir hata oluştu');
    }
  }
} 
```

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/customer_list_tile.dart';
import '../providers/customer_provider.dart';
import '../providers/theme_provider.dart';
import '../domain/entities/customer.dart';
import 'add_customer_page.dart';
import 'customer_detail_page.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final _searchController = TextEditingController();

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return 'Aktif';
      case CustomerCategory.potential:
        return 'Potansiyel';
      case CustomerCategory.vip:
        return 'VIP';
      case CustomerCategory.inactive:
        return 'Pasif';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM Dashboard'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.brightness_6),
            onSelected: (mode) => context.read<ThemeProvider>().setTheme(mode),
            itemBuilder: (context) {
              final themeMode = Provider.of<ThemeProvider>(context, listen: false).themeMode;
              return [
                CheckedPopupMenuItem(
                  value: ThemeMode.system,
                  checked: themeMode == ThemeMode.system,
                  child: const Text('Sistem'),
                ),
                CheckedPopupMenuItem(
                  value: ThemeMode.light,
                  checked: themeMode == ThemeMode.light,
                  child: const Text('Açık'),
                ),
                CheckedPopupMenuItem(
                  value: ThemeMode.dark,
                  checked: themeMode == ThemeMode.dark,
                  child: const Text('Koyu'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CustomScrollView(
                slivers: [
                  // Dashboard Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Toplam Müşteri',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${provider.customers.length}',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Card(
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const AddCustomerPage()),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        size: 32,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Yeni Müşteri',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Category/Favorite Filters (collapsible)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: ExpansionTile(
                          title: const Text('Durum & Favori Filtreleri'),
                          childrenPadding: const EdgeInsets.all(16.0),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sıralama',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                DropdownButton<SortOption>(
                                  value: provider.sortOption,
                                  onChanged: (value) {
                                    if (value != null) provider.sortOption = value;
                                  },
                                  items: const [
                                    DropdownMenuItem(
                                      value: SortOption.nameAsc,
                                      child: Text('İsim A-Z'),
                                    ),
                                    DropdownMenuItem(
                                      value: SortOption.nameDesc,
                                      child: Text('İsim Z-A'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        FilterChip(
                                          label: const Text('Tümü'),
                                          selected: provider.selectedCategory == null,
                                          onSelected: (selected) {
                                            if (selected) provider.selectedCategory = null;
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        ...CustomerCategory.values.map((category) {
                                          final isSelected = provider.selectedCategory == category;
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: FilterChip(
                                              label: Text(_getCategoryName(category)),
                                              selected: isSelected,
                                              onSelected: (selected) {
                                                provider.selectedCategory = selected ? category : null;
                                              },
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                FilterChip(
                                  label: const Text('Favoriler'),
                                  selected: provider.showOnlyFavorites,
                                  onSelected: (selected) {
                                    provider.showOnlyFavorites = selected;
                                  },
                                  avatar: Icon(
                                    provider.showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text('Filtreleri temizle'),
                                onPressed: () {
                                  provider.resetFilters();
                                  _searchController.clear();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Tag Filters (collapsible)
                  if (provider.allTags.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: ExpansionTile(
                            title: const Text('Etiket Filtreleri'),
                            childrenPadding: const EdgeInsets.all(16.0),
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    FilterChip(
                                      label: const Text('Tüm Etiketler'),
                                      selected: provider.selectedTag.isEmpty,
                                      onSelected: (selected) {
                                        if (selected) provider.selectedTag = '';
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    ...provider.allTags.map((tag) {
                                      final isSelected = provider.selectedTag == tag;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: FilterChip(
                                          label: Text(tag),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            provider.selectedTag = selected ? tag : '';
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Müşteri ara (isim, email, telefon)',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      provider.searchQuery = '';
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          ),
                          onChanged: (value) {
                            provider.searchQuery = value;
                            setState(() {}); // suffixIcon'u güncellemek için
                          },
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Customer List
                  provider.isLoading
                      ? const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : provider.filteredCustomers.isEmpty
                          ? SliverToBoxAdapter(
                              child: Center(
                                child: Card(
                                  margin: const EdgeInsets.all(32.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 64,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Hiç müşteri yok',
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Sağ üstten yeni müşteri ekleyebilirsiniz',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                    child: Card(
                                      child: CustomerListTile(
                                        customer: provider.filteredCustomers[index],
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => CustomerDetailPage(
                                                customer: provider.filteredCustomers[index],
                                              ),
                                            ),
                                          );
                                        },
                                        onToggleFavorite: () async {
                                          try {
                                            await provider.toggleFavorite(provider.filteredCustomers[index].id);
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(e.toString())),
                                              );
                                            }
                                          }
                                        },
                                        onEdit: () {
                                          final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => AddCustomerPage(
                                                customer: provider.customers[originalIndex],
                                              ),
                                            ),
                                          );
                                        },
                                        onDelete: () async {
                                          final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Müşteri Sil'),
                                              content: const Text('Bu müşteriyi silmek istediğinize emin misiniz?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: const Text('İptal'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: const Text('Sil'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            try {
                                              await provider.deleteCustomer(provider.customers[originalIndex].id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Müşteri silindi')),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(e.toString())),
                                                );
                                              }
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                                childCount: provider.filteredCustomers.length,
                              ),
                            ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 
```

Çekirdek iyileştirmeler tamamlandı. Güvenlik/yetkilendirme fazına geçiyoruz. Önce mevcut yapıyı kontrol ediyoruz:


Yetkilendirme yok. Firebase Auth ve rol bazlı yetkilendirme ekliyoruz. Adım adım ilerliyoruz:


Güvenlik/yetkilendirme fazına geçiyoruz. Firebase Auth entegrasyonunu başlatıyoruz:


```yaml
name: crm
description: "A new Flutter project."
# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

# The following defines the version and build number for your application.
# A version number is three numbers separated by dots, like 1.2.43
# followed by an optional build number separated by a +.
# Both the version and the builder number may be overridden in flutter
# build by specifying --build-name and --build-number, respectively.
# In Android, build-name is used as versionName while build-number used as versionCode.
# Read more about Android versioning at https://developer.android.com/studio/publish/versioning
# In iOS, build-name is used as CFBundleShortVersionString while build-number is used as CFBundleVersion.
# Read more about iOS versioning at
# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
# In Windows, build-name is used as the major, minor, and patch parts
# of the product and file versions while build-number is used as the build suffix.
version: 1.0.0+1

environment:
  sdk: ^3.8.1

# Dependencies specify other packages that your package needs in order to work.
# To automatically upgrade your package dependencies to the latest versions
# consider running `flutter pub upgrade --major-versions`. Alternatively,
# dependencies can be manually updated by changing the version numbers below to
# the latest version available on pub.dev. To see which dependencies have newer
# versions available, run `flutter pub outdated`.
dependencies:
  firebase_core: ^2.32.0
  cloud_firestore: ^4.15.8
  firebase_auth: ^5.3.1
  provider: ^6.1.2
  uuid: ^4.3.3
  url_launcher: ^6.2.5
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter

  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
  # rules and activating additional ones.
  flutter_lints: ^5.0.0

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg

  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images

  # For details regarding adding assets from package dependencies, see
  # https://flutter.dev/to/asset-from-package

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts from package dependencies,
  # see https://flutter.dev/to/font-from-package

```

Auth provider ve login sayfasını oluşturuyoruz:


```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, agent, viewer }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  UserRole _userRole = UserRole.viewer;
  bool _isLoading = false;

  User? get user => _user;
  UserRole get userRole => _userRole;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserRole(user.uid);
      } else {
        _userRole = UserRole.viewer;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final roleString = doc.data()?['role'] as String? ?? 'viewer';
        _userRole = _roleFromString(roleString);
      } else {
        // İlk girişte varsayılan rol viewer
        _userRole = UserRole.viewer;
        await _firestore.collection('users').doc(uid).set({
          'role': 'viewer',
          'email': _user?.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      notifyListeners();
    } catch (e) {
      _userRole = UserRole.viewer;
      notifyListeners();
    }
  }

  UserRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'agent':
        return UserRole.agent;
      default:
        return UserRole.viewer;
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Giriş yapılırken bir hata oluştu: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Kullanıcı bilgilerini Firestore'a kaydet
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'email': email,
          'name': name,
          'role': 'viewer', // Varsayılan rol
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Kayıt olurken bir hata oluştu: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      _userRole = UserRole.viewer;
      notifyListeners();
    } catch (e) {
      throw Exception('Çıkış yapılırken bir hata oluştu: $e');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı';
      case 'wrong-password':
        return 'Hatalı şifre';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter olmalı';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi';
      case 'user-disabled':
        return 'Bu kullanıcı hesabı devre dışı bırakılmış';
      default:
        return 'Bir hata oluştu: ${e.message}';
    }
  }
}

```

```dart
import '../providers/auth_provider.dart';

class PermissionHelper {
  // Admin tüm işlemleri yapabilir
  static bool canCreateCustomer(UserRole role) {
    return role == UserRole.admin || role == UserRole.agent;
  }

  static bool canUpdateCustomer(UserRole role) {
    return role == UserRole.admin || role == UserRole.agent;
  }

  static bool canDeleteCustomer(UserRole role) {
    return role == UserRole.admin;
  }

  static bool canViewCustomers(UserRole role) {
    return true; // Tüm roller görebilir
  }

  static bool canManageNotes(UserRole role) {
    return role == UserRole.admin || role == UserRole.agent;
  }

  static bool canManageTags(UserRole role) {
    return role == UserRole.admin || role == UserRole.agent;
  }
}

```

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    try {
      if (_isLogin) {
        await authProvider.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await authProvider.registerWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
      }
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.business_center,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      _isLogin ? 'CRM Giriş' : 'Kayıt Ol',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'İsim',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'İsim giriniz' : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'E-posta',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'E-posta giriniz';
                        }
                        if (!value.contains('@')) {
                          return 'Geçerli bir e-posta adresi giriniz';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Şifre giriniz';
                        }
                        if (value.length < 6) {
                          return 'Şifre en az 6 karakter olmalı';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(
                                    _isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _formKey.currentState?.reset();
                        });
                      },
                      child: Text(
                        _isLogin
                            ? 'Hesabınız yok mu? Kayıt olun'
                            : 'Zaten hesabınız var mı? Giriş yapın',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

```

```dart
import '../../presentation/providers/auth_provider.dart';

class PermissionHelper {
  // Admin tüm işlemleri yapabilir
  static bool canCreateCustomer(UserRole role) {
    return role == UserRole.admin || role == UserRole.agent;
  }

  static bool canUpdateCustomer(UserRole role) {
    return role == UserRole.admin || role == UserRole.agent;
  }

  static bool canDeleteCustomer(UserRole role) {
    return role == UserRole.admin;
  }

  static bool canViewCustomers(UserRole role) {
    return true; // Tüm roller görebilir
  }

  static bool canManageNotes(UserRole role) {
    return role == UserRole.admin || role == UserRole.agent;
  }

  static bool canManageTags(UserRole role) {
    return role == UserRole.admin || role == UserRole.agent;
  }
}


```

main.dart'ı güncelleyip AuthProvider'ı ekliyoruz ve auth durumuna göre login/home sayfasını gösteriyoruz:


```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/customer_firestore_service.dart';
import 'data/repo/customer_repository.dart';
import 'presentation/providers/customer_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/pages/customer_page.dart';
import 'presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CustomerProvider(
            CustomerRepositoryImpl(CustomerFirestoreService()),
          )..fetchCustomers(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'CRM Project',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
            ),
            themeMode: themeProvider.themeMode,
            home: CustomerPage(),
          );
        },
      ),
    );
  }
}

```

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/customer_firestore_service.dart';
import 'data/repo/customer_repository.dart';
import 'presentation/providers/customer_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/pages/customer_page.dart';
import 'presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => CustomerProvider(
            CustomerRepositoryImpl(CustomerFirestoreService()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, _) {
          return MaterialApp(
            title: 'CRM Project',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
            ),
            themeMode: themeProvider.themeMode,
            routes: {
              '/login': (_) => const LoginPage(),
              '/home': (_) => const CustomerPage(),
            },
            home: authProvider.isAuthenticated
                ? const CustomerPage()
                : const LoginPage(),
          );
        },
      ),
    );
  }
}

```

CustomerPage'e logout butonu ekleyip, rol bazlı butonları göstermek için permission helper'ı kullanıyoruz:


CustomerPage'e logout butonu ekleyip, rol bazlı butonları permission helper ile kontrol ediyoruz:


```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/customer_list_tile.dart';
import '../providers/customer_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/permission_helper.dart';
import '../domain/entities/customer.dart';
import 'add_customer_page.dart';
import 'customer_detail_page.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final _searchController = TextEditingController();

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return 'Aktif';
      case CustomerCategory.potential:
        return 'Potansiyel';
      case CustomerCategory.vip:
        return 'VIP';
      case CustomerCategory.inactive:
        return 'Pasif';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM Dashboard'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.brightness_6),
            onSelected: (mode) => context.read<ThemeProvider>().setTheme(mode),
            itemBuilder: (context) {
              final themeMode = Provider.of<ThemeProvider>(context, listen: false).themeMode;
              return [
                CheckedPopupMenuItem(
                  value: ThemeMode.system,
                  checked: themeMode == ThemeMode.system,
                  child: const Text('Sistem'),
                ),
                CheckedPopupMenuItem(
                  value: ThemeMode.light,
                  checked: themeMode == ThemeMode.light,
                  child: const Text('Açık'),
                ),
                CheckedPopupMenuItem(
                  value: ThemeMode.dark,
                  checked: themeMode == ThemeMode.dark,
                  child: const Text('Koyu'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CustomScrollView(
                slivers: [
                  // Dashboard Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Toplam Müşteri',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${provider.customers.length}',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Card(
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const AddCustomerPage()),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        size: 32,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Yeni Müşteri',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Category/Favorite Filters (collapsible)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: ExpansionTile(
                          title: const Text('Durum & Favori Filtreleri'),
                          childrenPadding: const EdgeInsets.all(16.0),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sıralama',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                DropdownButton<SortOption>(
                                  value: provider.sortOption,
                                  onChanged: (value) {
                                    if (value != null) provider.sortOption = value;
                                  },
                                  items: const [
                                    DropdownMenuItem(
                                      value: SortOption.nameAsc,
                                      child: Text('İsim A-Z'),
                                    ),
                                    DropdownMenuItem(
                                      value: SortOption.nameDesc,
                                      child: Text('İsim Z-A'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        FilterChip(
                                          label: const Text('Tümü'),
                                          selected: provider.selectedCategory == null,
                                          onSelected: (selected) {
                                            if (selected) provider.selectedCategory = null;
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        ...CustomerCategory.values.map((category) {
                                          final isSelected = provider.selectedCategory == category;
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: FilterChip(
                                              label: Text(_getCategoryName(category)),
                                              selected: isSelected,
                                              onSelected: (selected) {
                                                provider.selectedCategory = selected ? category : null;
                                              },
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                FilterChip(
                                  label: const Text('Favoriler'),
                                  selected: provider.showOnlyFavorites,
                                  onSelected: (selected) {
                                    provider.showOnlyFavorites = selected;
                                  },
                                  avatar: Icon(
                                    provider.showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text('Filtreleri temizle'),
                                onPressed: () {
                                  provider.resetFilters();
                                  _searchController.clear();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Tag Filters (collapsible)
                  if (provider.allTags.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: ExpansionTile(
                            title: const Text('Etiket Filtreleri'),
                            childrenPadding: const EdgeInsets.all(16.0),
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    FilterChip(
                                      label: const Text('Tüm Etiketler'),
                                      selected: provider.selectedTag.isEmpty,
                                      onSelected: (selected) {
                                        if (selected) provider.selectedTag = '';
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    ...provider.allTags.map((tag) {
                                      final isSelected = provider.selectedTag == tag;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: FilterChip(
                                          label: Text(tag),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            provider.selectedTag = selected ? tag : '';
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Müşteri ara (isim, email, telefon)',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      provider.searchQuery = '';
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          ),
                          onChanged: (value) {
                            provider.searchQuery = value;
                            setState(() {}); // suffixIcon'u güncellemek için
                          },
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Customer List
                  provider.isLoading
                      ? const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : provider.filteredCustomers.isEmpty
                          ? SliverToBoxAdapter(
                              child: Center(
                                child: Card(
                                  margin: const EdgeInsets.all(32.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 64,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Hiç müşteri yok',
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Sağ üstten yeni müşteri ekleyebilirsiniz',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                    child: Card(
                                      child: CustomerListTile(
                                        customer: provider.filteredCustomers[index],
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => CustomerDetailPage(
                                                customer: provider.filteredCustomers[index],
                                              ),
                                            ),
                                          );
                                        },
                                        onToggleFavorite: () async {
                                          try {
                                            await provider.toggleFavorite(provider.filteredCustomers[index].id);
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(e.toString())),
                                              );
                                            }
                                          }
                                        },
                                        onEdit: () {
                                          final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => AddCustomerPage(
                                                customer: provider.customers[originalIndex],
                                              ),
                                            ),
                                          );
                                        },
                                        onDelete: () async {
                                          final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Müşteri Sil'),
                                              content: const Text('Bu müşteriyi silmek istediğinize emin misiniz?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: const Text('İptal'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: const Text('Sil'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            try {
                                              await provider.deleteCustomer(provider.customers[originalIndex].id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Müşteri silindi')),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(e.toString())),
                                                );
                                              }
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                                childCount: provider.filteredCustomers.length,
                              ),
                            ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 
```

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/customer_list_tile.dart';
import '../providers/customer_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/permission_helper.dart';
import '../domain/entities/customer.dart';
import 'add_customer_page.dart';
import 'customer_detail_page.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final _searchController = TextEditingController();

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return 'Aktif';
      case CustomerCategory.potential:
        return 'Potansiyel';
      case CustomerCategory.vip:
        return 'VIP';
      case CustomerCategory.inactive:
        return 'Pasif';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM Dashboard'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'logout') {
                    try {
                      await authProvider.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  }
                },
                itemBuilder: (context) {
                  final themeMode = Provider.of<ThemeProvider>(context, listen: false).themeMode;
                  return [
                    PopupMenuItem(
                      value: 'theme',
                      child: PopupMenuButton<ThemeMode>(
                        child: Row(
                          children: [
                            const Icon(Icons.brightness_6),
                            const SizedBox(width: 8),
                            const Text('Tema'),
                            const Spacer(),
                            Text(themeMode == ThemeMode.system
                                ? 'Sistem'
                                : themeMode == ThemeMode.light
                                    ? 'Açık'
                                    : 'Koyu'),
                          ],
                        ),
                        onSelected: (mode) => context.read<ThemeProvider>().setTheme(mode),
                        itemBuilder: (context) => [
                          CheckedPopupMenuItem(
                            value: ThemeMode.system,
                            checked: themeMode == ThemeMode.system,
                            child: const Text('Sistem'),
                          ),
                          CheckedPopupMenuItem(
                            value: ThemeMode.light,
                            checked: themeMode == ThemeMode.light,
                            child: const Text('Açık'),
                          ),
                          CheckedPopupMenuItem(
                            value: ThemeMode.dark,
                            checked: themeMode == ThemeMode.dark,
                            child: const Text('Koyu'),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: const Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('Çıkış Yap'),
                        ],
                      ),
                    ),
                  ];
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CustomScrollView(
                slivers: [
                  // Dashboard Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Toplam Müşteri',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${provider.customers.length}',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Card(
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const AddCustomerPage()),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        size: 32,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Yeni Müşteri',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Category/Favorite Filters (collapsible)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: ExpansionTile(
                          title: const Text('Durum & Favori Filtreleri'),
                          childrenPadding: const EdgeInsets.all(16.0),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sıralama',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                DropdownButton<SortOption>(
                                  value: provider.sortOption,
                                  onChanged: (value) {
                                    if (value != null) provider.sortOption = value;
                                  },
                                  items: const [
                                    DropdownMenuItem(
                                      value: SortOption.nameAsc,
                                      child: Text('İsim A-Z'),
                                    ),
                                    DropdownMenuItem(
                                      value: SortOption.nameDesc,
                                      child: Text('İsim Z-A'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        FilterChip(
                                          label: const Text('Tümü'),
                                          selected: provider.selectedCategory == null,
                                          onSelected: (selected) {
                                            if (selected) provider.selectedCategory = null;
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        ...CustomerCategory.values.map((category) {
                                          final isSelected = provider.selectedCategory == category;
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: FilterChip(
                                              label: Text(_getCategoryName(category)),
                                              selected: isSelected,
                                              onSelected: (selected) {
                                                provider.selectedCategory = selected ? category : null;
                                              },
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                FilterChip(
                                  label: const Text('Favoriler'),
                                  selected: provider.showOnlyFavorites,
                                  onSelected: (selected) {
                                    provider.showOnlyFavorites = selected;
                                  },
                                  avatar: Icon(
                                    provider.showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text('Filtreleri temizle'),
                                onPressed: () {
                                  provider.resetFilters();
                                  _searchController.clear();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Tag Filters (collapsible)
                  if (provider.allTags.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: ExpansionTile(
                            title: const Text('Etiket Filtreleri'),
                            childrenPadding: const EdgeInsets.all(16.0),
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    FilterChip(
                                      label: const Text('Tüm Etiketler'),
                                      selected: provider.selectedTag.isEmpty,
                                      onSelected: (selected) {
                                        if (selected) provider.selectedTag = '';
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    ...provider.allTags.map((tag) {
                                      final isSelected = provider.selectedTag == tag;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: FilterChip(
                                          label: Text(tag),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            provider.selectedTag = selected ? tag : '';
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Müşteri ara (isim, email, telefon)',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      provider.searchQuery = '';
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          ),
                          onChanged: (value) {
                            provider.searchQuery = value;
                            setState(() {}); // suffixIcon'u güncellemek için
                          },
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Customer List
                  provider.isLoading
                      ? const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : provider.filteredCustomers.isEmpty
                          ? SliverToBoxAdapter(
                              child: Center(
                                child: Card(
                                  margin: const EdgeInsets.all(32.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 64,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Hiç müşteri yok',
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Sağ üstten yeni müşteri ekleyebilirsiniz',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                    child: Card(
                                      child: CustomerListTile(
                                        customer: provider.filteredCustomers[index],
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => CustomerDetailPage(
                                                customer: provider.filteredCustomers[index],
                                              ),
                                            ),
                                          );
                                        },
                                        onToggleFavorite: () async {
                                          try {
                                            await provider.toggleFavorite(provider.filteredCustomers[index].id);
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(e.toString())),
                                              );
                                            }
                                          }
                                        },
                                        onEdit: () {
                                          final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => AddCustomerPage(
                                                customer: provider.customers[originalIndex],
                                              ),
                                            ),
                                          );
                                        },
                                        onDelete: () async {
                                          final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Müşteri Sil'),
                                              content: const Text('Bu müşteriyi silmek istediğinize emin misiniz?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: const Text('İptal'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: const Text('Sil'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            try {
                                              await provider.deleteCustomer(provider.customers[originalIndex].id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Müşteri silindi')),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(e.toString())),
                                                );
                                              }
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                                childCount: provider.filteredCustomers.length,
                              ),
                            ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 
```

Rol bazlı butonları ekleyip, CustomerProvider'ı sadece authenticated olduğunda çağırıyoruz:


```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/customer_list_tile.dart';
import '../providers/customer_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/permission_helper.dart';
import '../domain/entities/customer.dart';
import 'add_customer_page.dart';
import 'customer_detail_page.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final _searchController = TextEditingController();

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return 'Aktif';
      case CustomerCategory.potential:
        return 'Potansiyel';
      case CustomerCategory.vip:
        return 'VIP';
      case CustomerCategory.inactive:
        return 'Pasif';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM Dashboard'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'logout') {
                    try {
                      await authProvider.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  }
                },
                itemBuilder: (context) {
                  final themeMode = Provider.of<ThemeProvider>(context, listen: false).themeMode;
                  return [
                    PopupMenuItem(
                      value: 'theme',
                      child: PopupMenuButton<ThemeMode>(
                        child: Row(
                          children: [
                            const Icon(Icons.brightness_6),
                            const SizedBox(width: 8),
                            const Text('Tema'),
                            const Spacer(),
                            Text(themeMode == ThemeMode.system
                                ? 'Sistem'
                                : themeMode == ThemeMode.light
                                    ? 'Açık'
                                    : 'Koyu'),
                          ],
                        ),
                        onSelected: (mode) => context.read<ThemeProvider>().setTheme(mode),
                        itemBuilder: (context) => [
                          CheckedPopupMenuItem(
                            value: ThemeMode.system,
                            checked: themeMode == ThemeMode.system,
                            child: const Text('Sistem'),
                          ),
                          CheckedPopupMenuItem(
                            value: ThemeMode.light,
                            checked: themeMode == ThemeMode.light,
                            child: const Text('Açık'),
                          ),
                          CheckedPopupMenuItem(
                            value: ThemeMode.dark,
                            checked: themeMode == ThemeMode.dark,
                            child: const Text('Koyu'),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: const Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('Çıkış Yap'),
                        ],
                      ),
                    ),
                  ];
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CustomScrollView(
                slivers: [
                  // Dashboard Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Toplam Müşteri',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${provider.customers.length}',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              final canCreate = PermissionHelper.canCreateCustomer(authProvider.userRole);
                              if (!canCreate) return const SizedBox.shrink();
                              return Expanded(
                                child: Card(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const AddCustomerPage()),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.add_circle_outline,
                                            size: 32,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Yeni Müşteri',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Category/Favorite Filters (collapsible)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: ExpansionTile(
                          title: const Text('Durum & Favori Filtreleri'),
                          childrenPadding: const EdgeInsets.all(16.0),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sıralama',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                DropdownButton<SortOption>(
                                  value: provider.sortOption,
                                  onChanged: (value) {
                                    if (value != null) provider.sortOption = value;
                                  },
                                  items: const [
                                    DropdownMenuItem(
                                      value: SortOption.nameAsc,
                                      child: Text('İsim A-Z'),
                                    ),
                                    DropdownMenuItem(
                                      value: SortOption.nameDesc,
                                      child: Text('İsim Z-A'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        FilterChip(
                                          label: const Text('Tümü'),
                                          selected: provider.selectedCategory == null,
                                          onSelected: (selected) {
                                            if (selected) provider.selectedCategory = null;
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        ...CustomerCategory.values.map((category) {
                                          final isSelected = provider.selectedCategory == category;
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: FilterChip(
                                              label: Text(_getCategoryName(category)),
                                              selected: isSelected,
                                              onSelected: (selected) {
                                                provider.selectedCategory = selected ? category : null;
                                              },
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                FilterChip(
                                  label: const Text('Favoriler'),
                                  selected: provider.showOnlyFavorites,
                                  onSelected: (selected) {
                                    provider.showOnlyFavorites = selected;
                                  },
                                  avatar: Icon(
                                    provider.showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text('Filtreleri temizle'),
                                onPressed: () {
                                  provider.resetFilters();
                                  _searchController.clear();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Tag Filters (collapsible)
                  if (provider.allTags.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: ExpansionTile(
                            title: const Text('Etiket Filtreleri'),
                            childrenPadding: const EdgeInsets.all(16.0),
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    FilterChip(
                                      label: const Text('Tüm Etiketler'),
                                      selected: provider.selectedTag.isEmpty,
                                      onSelected: (selected) {
                                        if (selected) provider.selectedTag = '';
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    ...provider.allTags.map((tag) {
                                      final isSelected = provider.selectedTag == tag;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: FilterChip(
                                          label: Text(tag),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            provider.selectedTag = selected ? tag : '';
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Müşteri ara (isim, email, telefon)',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      provider.searchQuery = '';
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          ),
                          onChanged: (value) {
                            provider.searchQuery = value;
                            setState(() {}); // suffixIcon'u güncellemek için
                          },
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Customer List
                  provider.isLoading
                      ? const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : provider.filteredCustomers.isEmpty
                          ? SliverToBoxAdapter(
                              child: Center(
                                child: Card(
                                  margin: const EdgeInsets.all(32.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 64,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Hiç müşteri yok',
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Sağ üstten yeni müşteri ekleyebilirsiniz',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                    child: Card(
                                      child: CustomerListTile(
                                        customer: provider.filteredCustomers[index],
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => CustomerDetailPage(
                                                customer: provider.filteredCustomers[index],
                                              ),
                                            ),
                                          );
                                        },
                                        onToggleFavorite: () async {
                                          try {
                                            await provider.toggleFavorite(provider.filteredCustomers[index].id);
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(e.toString())),
                                              );
                                            }
                                          }
                                        },
                                        onEdit: () {
                                          final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => AddCustomerPage(
                                                customer: provider.customers[originalIndex],
                                              ),
                                            ),
                                          );
                                        },
                                        onDelete: () async {
                                          final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Müşteri Sil'),
                                              content: const Text('Bu müşteriyi silmek istediğinize emin misiniz?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: const Text('İptal'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: const Text('Sil'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            try {
                                              await provider.deleteCustomer(provider.customers[originalIndex].id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Müşteri silindi')),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(e.toString())),
                                                );
                                              }
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                                childCount: provider.filteredCustomers.length,
                              ),
                            ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 
```

CustomerListTile'daki edit/delete butonlarını rol bazlı gösteriyoruz ve main.dart'ı güncelliyoruz:


```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/customer_list_tile.dart';
import '../providers/customer_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/permission_helper.dart';
import '../domain/entities/customer.dart';
import 'add_customer_page.dart';
import 'customer_detail_page.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final _searchController = TextEditingController();

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return 'Aktif';
      case CustomerCategory.potential:
        return 'Potansiyel';
      case CustomerCategory.vip:
        return 'VIP';
      case CustomerCategory.inactive:
        return 'Pasif';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM Dashboard'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'logout') {
                    try {
                      await authProvider.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  }
                },
                itemBuilder: (context) {
                  final themeMode = Provider.of<ThemeProvider>(context, listen: false).themeMode;
                  return [
                    PopupMenuItem(
                      value: 'theme',
                      child: PopupMenuButton<ThemeMode>(
                        child: Row(
                          children: [
                            const Icon(Icons.brightness_6),
                            const SizedBox(width: 8),
                            const Text('Tema'),
                            const Spacer(),
                            Text(themeMode == ThemeMode.system
                                ? 'Sistem'
                                : themeMode == ThemeMode.light
                                    ? 'Açık'
                                    : 'Koyu'),
                          ],
                        ),
                        onSelected: (mode) => context.read<ThemeProvider>().setTheme(mode),
                        itemBuilder: (context) => [
                          CheckedPopupMenuItem(
                            value: ThemeMode.system,
                            checked: themeMode == ThemeMode.system,
                            child: const Text('Sistem'),
                          ),
                          CheckedPopupMenuItem(
                            value: ThemeMode.light,
                            checked: themeMode == ThemeMode.light,
                            child: const Text('Açık'),
                          ),
                          CheckedPopupMenuItem(
                            value: ThemeMode.dark,
                            checked: themeMode == ThemeMode.dark,
                            child: const Text('Koyu'),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: const Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('Çıkış Yap'),
                        ],
                      ),
                    ),
                  ];
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CustomScrollView(
                slivers: [
                  // Dashboard Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Toplam Müşteri',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${provider.customers.length}',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              final canCreate = PermissionHelper.canCreateCustomer(authProvider.userRole);
                              if (!canCreate) return const SizedBox.shrink();
                              return Expanded(
                                child: Card(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const AddCustomerPage()),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.add_circle_outline,
                                            size: 32,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Yeni Müşteri',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Category/Favorite Filters (collapsible)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: ExpansionTile(
                          title: const Text('Durum & Favori Filtreleri'),
                          childrenPadding: const EdgeInsets.all(16.0),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sıralama',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                DropdownButton<SortOption>(
                                  value: provider.sortOption,
                                  onChanged: (value) {
                                    if (value != null) provider.sortOption = value;
                                  },
                                  items: const [
                                    DropdownMenuItem(
                                      value: SortOption.nameAsc,
                                      child: Text('İsim A-Z'),
                                    ),
                                    DropdownMenuItem(
                                      value: SortOption.nameDesc,
                                      child: Text('İsim Z-A'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        FilterChip(
                                          label: const Text('Tümü'),
                                          selected: provider.selectedCategory == null,
                                          onSelected: (selected) {
                                            if (selected) provider.selectedCategory = null;
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        ...CustomerCategory.values.map((category) {
                                          final isSelected = provider.selectedCategory == category;
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: FilterChip(
                                              label: Text(_getCategoryName(category)),
                                              selected: isSelected,
                                              onSelected: (selected) {
                                                provider.selectedCategory = selected ? category : null;
                                              },
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                FilterChip(
                                  label: const Text('Favoriler'),
                                  selected: provider.showOnlyFavorites,
                                  onSelected: (selected) {
                                    provider.showOnlyFavorites = selected;
                                  },
                                  avatar: Icon(
                                    provider.showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text('Filtreleri temizle'),
                                onPressed: () {
                                  provider.resetFilters();
                                  _searchController.clear();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Tag Filters (collapsible)
                  if (provider.allTags.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: ExpansionTile(
                            title: const Text('Etiket Filtreleri'),
                            childrenPadding: const EdgeInsets.all(16.0),
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    FilterChip(
                                      label: const Text('Tüm Etiketler'),
                                      selected: provider.selectedTag.isEmpty,
                                      onSelected: (selected) {
                                        if (selected) provider.selectedTag = '';
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    ...provider.allTags.map((tag) {
                                      final isSelected = provider.selectedTag == tag;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: FilterChip(
                                          label: Text(tag),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            provider.selectedTag = selected ? tag : '';
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Müşteri ara (isim, email, telefon)',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      provider.searchQuery = '';
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          ),
                          onChanged: (value) {
                            provider.searchQuery = value;
                            setState(() {}); // suffixIcon'u güncellemek için
                          },
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Customer List
                  provider.isLoading
                      ? const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : provider.filteredCustomers.isEmpty
                          ? SliverToBoxAdapter(
                              child: Center(
                                child: Card(
                                  margin: const EdgeInsets.all(32.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 64,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Hiç müşteri yok',
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Sağ üstten yeni müşteri ekleyebilirsiniz',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                    child: Consumer<AuthProvider>(
                                      builder: (context, authProvider, _) {
                                        final canUpdate = PermissionHelper.canUpdateCustomer(authProvider.userRole);
                                        final canDelete = PermissionHelper.canDeleteCustomer(authProvider.userRole);
                                        return Card(
                                          child: CustomerListTile(
                                            customer: provider.filteredCustomers[index],
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => CustomerDetailPage(
                                                    customer: provider.filteredCustomers[index],
                                                  ),
                                                ),
                                              );
                                            },
                                            onToggleFavorite: () async {
                                              try {
                                                await provider.toggleFavorite(provider.filteredCustomers[index].id);
                                              } catch (e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text(e.toString())),
                                                  );
                                                }
                                              }
                                            },
                                            onEdit: canUpdate
                                                ? () {
                                                    final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) => AddCustomerPage(
                                                          customer: provider.customers[originalIndex],
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                : null,
                                            onDelete: canDelete
                                                ? () async {
                                                    final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                                    final confirm = await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        title: const Text('Müşteri Sil'),
                                                        content: const Text('Bu müşteriyi silmek istediğinize emin misiniz?'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.of(context).pop(false),
                                                            child: const Text('İptal'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () => Navigator.of(context).pop(true),
                                                            child: const Text('Sil'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    if (confirm == true) {
                                                      try {
                                                        await provider.deleteCustomer(provider.customers[originalIndex].id);
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(content: Text('Müşteri silindi')),
                                                          );
                                                        }
                                                      } catch (e) {
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text(e.toString())),
                                                          );
                                                        }
                                                      }
                                                    }
                                                  }
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                childCount: provider.filteredCustomers.length,
                              ),
                            ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 
```

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/customer_firestore_service.dart';
import 'data/repo/customer_repository.dart';
import 'presentation/providers/customer_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/pages/customer_page.dart';
import 'presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CustomerProvider>(
          create: (_) => CustomerProvider(
            CustomerRepositoryImpl(CustomerFirestoreService()),
          ),
          update: (_, authProvider, previous) {
            final provider = previous ?? CustomerProvider(
              CustomerRepositoryImpl(CustomerFirestoreService()),
            );
            if (authProvider.isAuthenticated && previous == null) {
              provider.fetchCustomers();
            }
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, _) {
          return MaterialApp(
            title: 'CRM Project',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
            ),
            themeMode: themeProvider.themeMode,
            routes: {
              '/login': (_) => const LoginPage(),
              '/home': (_) => const CustomerPage(),
            },
            home: authProvider.isAuthenticated
                ? const CustomerPage()
                : const LoginPage(),
          );
        },
      ),
    );
  }
}

```

CustomerDetailPage'deki not/etiket butonlarını rol bazlı gösteriyoruz:


```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../domain/entities/customer.dart';
import '../providers/customer_provider.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/permission_helper.dart';

class CustomerDetailPage extends StatefulWidget {
  final Customer customer;
  const CustomerDetailPage({Key? key, required this.customer}) : super(key: key);

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  final _noteController = TextEditingController();
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi ver
      if (url.startsWith('mailto:')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-posta uygulaması bulunamadı')),
        );
      } else if (url.startsWith('tel:')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Telefon uygulaması bulunamadı')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        final customer = provider.findById(widget.customer.id) ?? widget.customer;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Müşteri Detayı'),
            actions: [
              IconButton(
                tooltip: customer.isFavorite ? 'Favoriden çıkar' : 'Favoriye ekle',
                icon: Icon(customer.isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () => provider.toggleFavorite(customer.id),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // Müşteri Bilgileri
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => _launchUrl('mailto:${customer.email}', context),
                              child: Row(
                                children: [
                                  const Icon(Icons.email, size: 20),
                                  const SizedBox(width: 8),
                                  Text(customer.email, style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () => _launchUrl('tel:${customer.phone}', context),
                              child: Row(
                                children: [
                                  const Icon(Icons.phone, size: 20),
                                  const SizedBox(width: 8),
                                  Text(customer.phone, style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(
                                    _getCategoryName(customer.category),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: _getCategoryColor(customer.category),
                                ),
                                DropdownButton<CustomerCategory>(
                                  value: customer.category,
                                  onChanged: (value) {
                                    if (value != null) {
                                      provider.updateCustomerCategory(customer.id, value);
                                    }
                                  },
                                  items: CustomerCategory.values
                                      .map(
                                        (cat) => DropdownMenuItem(
                                          value: cat,
                                          child: Text(_getCategoryName(cat)),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Etiketler (açılır kart)
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(
                          'Etiketler (${customer.tags.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        childrenPadding: const EdgeInsets.all(16.0),
                        children: [
                          if (customer.tags.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: customer.tags.map((tag) {
                                return Chip(
                                  label: Text(tag),
                                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    provider.removeTag(customer.id, tag);
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _tagController,
                                  decoration: const InputDecoration(
                                    hintText: 'Etiket adı',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  if (_tagController.text.trim().isNotEmpty) {
                                    provider.addTag(
                                      customer.id,
                                      _tagController.text.trim(),
                                    );
                                    _tagController.clear();
                                  }
                                },
                                child: const Text('Ekle'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Notlar (açılır kart)
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(
                          'Notlar (${customer.notes.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        childrenPadding: const EdgeInsets.all(16.0),
                        children: [
                          if (customer.notes.isNotEmpty) ...[
                            ...customer.notes.asMap().entries.map((entry) {
                              final index = entry.key;
                              final note = entry.value;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(note),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      provider.removeNote(customer.id, index);
                                    },
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 12),
                          ],
                          TextField(
                            controller: _noteController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Notunuzu buraya yazın...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_noteController.text.trim().isNotEmpty) {
                                  provider.addNote(
                                    customer.id,
                                    _noteController.text.trim(),
                                  );
                                  _noteController.clear();
                                }
                              },
                              child: const Text('Not Ekle'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return 'Aktif';
      case CustomerCategory.potential:
        return 'Potansiyel';
      case CustomerCategory.vip:
        return 'VIP';
      case CustomerCategory.inactive:
        return 'Pasif';
      default:
        return 'Bilinmiyor';
    }
  }

  Color _getCategoryColor(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return Colors.green;
      case CustomerCategory.potential:
        return Colors.orange;
      case CustomerCategory.vip:
        return Colors.purple;
      case CustomerCategory.inactive:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
```

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../domain/entities/customer.dart';
import '../providers/customer_provider.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/permission_helper.dart';

class CustomerDetailPage extends StatefulWidget {
  final Customer customer;
  const CustomerDetailPage({Key? key, required this.customer}) : super(key: key);

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  final _noteController = TextEditingController();
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi ver
      if (url.startsWith('mailto:')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-posta uygulaması bulunamadı')),
        );
      } else if (url.startsWith('tel:')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Telefon uygulaması bulunamadı')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        final customer = provider.findById(widget.customer.id) ?? widget.customer;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Müşteri Detayı'),
            actions: [
              IconButton(
                tooltip: customer.isFavorite ? 'Favoriden çıkar' : 'Favoriye ekle',
                icon: Icon(customer.isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () => provider.toggleFavorite(customer.id),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // Müşteri Bilgileri
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => _launchUrl('mailto:${customer.email}', context),
                              child: Row(
                                children: [
                                  const Icon(Icons.email, size: 20),
                                  const SizedBox(width: 8),
                                  Text(customer.email, style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () => _launchUrl('tel:${customer.phone}', context),
                              child: Row(
                                children: [
                                  const Icon(Icons.phone, size: 20),
                                  const SizedBox(width: 8),
                                  Text(customer.phone, style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(
                                    _getCategoryName(customer.category),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: _getCategoryColor(customer.category),
                                ),
                                DropdownButton<CustomerCategory>(
                                  value: customer.category,
                                  onChanged: (value) {
                                    if (value != null) {
                                      provider.updateCustomerCategory(customer.id, value);
                                    }
                                  },
                                  items: CustomerCategory.values
                                      .map(
                                        (cat) => DropdownMenuItem(
                                          value: cat,
                                          child: Text(_getCategoryName(cat)),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Etiketler (açılır kart)
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(
                          'Etiketler (${customer.tags.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        childrenPadding: const EdgeInsets.all(16.0),
                        children: [
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              final canManageTags = PermissionHelper.canManageTags(authProvider.userRole);
                              return Column(
                                children: [
                                  if (customer.tags.isNotEmpty) ...[
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: customer.tags.map((tag) {
                                        return Chip(
                                          label: Text(tag),
                                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                          deleteIcon: canManageTags ? const Icon(Icons.close, size: 16) : null,
                                          onDeleted: canManageTags
                                              ? () {
                                                  provider.removeTag(customer.id, tag);
                                                }
                                              : null,
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  if (canManageTags) ...[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _tagController,
                                            decoration: const InputDecoration(
                                              hintText: 'Etiket adı',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            if (_tagController.text.trim().isNotEmpty) {
                                              provider.addTag(
                                                customer.id,
                                                _tagController.text.trim(),
                                              );
                                              _tagController.clear();
                                            }
                                          },
                                          child: const Text('Ekle'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Notlar (açılır kart)
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(
                          'Notlar (${customer.notes.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        childrenPadding: const EdgeInsets.all(16.0),
                        children: [
                          if (customer.notes.isNotEmpty) ...[
                            ...customer.notes.asMap().entries.map((entry) {
                              final index = entry.key;
                              final note = entry.value;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(note),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      provider.removeNote(customer.id, index);
                                    },
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 12),
                          ],
                          TextField(
                            controller: _noteController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Notunuzu buraya yazın...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_noteController.text.trim().isNotEmpty) {
                                  provider.addNote(
                                    customer.id,
                                    _noteController.text.trim(),
                                  );
                                  _noteController.clear();
                                }
                              },
                              child: const Text('Not Ekle'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return 'Aktif';
      case CustomerCategory.potential:
        return 'Potansiyel';
      case CustomerCategory.vip:
        return 'VIP';
      case CustomerCategory.inactive:
        return 'Pasif';
      default:
        return 'Bilinmiyor';
    }
  }

  Color _getCategoryColor(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return Colors.green;
      case CustomerCategory.potential:
        return Colors.orange;
      case CustomerCategory.vip:
        return Colors.purple;
      case CustomerCategory.inactive:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
```

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../domain/entities/customer.dart';
import '../providers/customer_provider.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/permission_helper.dart';

class CustomerDetailPage extends StatefulWidget {
  final Customer customer;
  const CustomerDetailPage({Key? key, required this.customer}) : super(key: key);

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  final _noteController = TextEditingController();
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi ver
      if (url.startsWith('mailto:')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-posta uygulaması bulunamadı')),
        );
      } else if (url.startsWith('tel:')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Telefon uygulaması bulunamadı')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        final customer = provider.findById(widget.customer.id) ?? widget.customer;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Müşteri Detayı'),
            actions: [
              IconButton(
                tooltip: customer.isFavorite ? 'Favoriden çıkar' : 'Favoriye ekle',
                icon: Icon(customer.isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () => provider.toggleFavorite(customer.id),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // Müşteri Bilgileri
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => _launchUrl('mailto:${customer.email}', context),
                              child: Row(
                                children: [
                                  const Icon(Icons.email, size: 20),
                                  const SizedBox(width: 8),
                                  Text(customer.email, style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () => _launchUrl('tel:${customer.phone}', context),
                              child: Row(
                                children: [
                                  const Icon(Icons.phone, size: 20),
                                  const SizedBox(width: 8),
                                  Text(customer.phone, style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(
                                    _getCategoryName(customer.category),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: _getCategoryColor(customer.category),
                                ),
                                DropdownButton<CustomerCategory>(
                                  value: customer.category,
                                  onChanged: (value) {
                                    if (value != null) {
                                      provider.updateCustomerCategory(customer.id, value);
                                    }
                                  },
                                  items: CustomerCategory.values
                                      .map(
                                        (cat) => DropdownMenuItem(
                                          value: cat,
                                          child: Text(_getCategoryName(cat)),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Etiketler (açılır kart)
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(
                          'Etiketler (${customer.tags.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        childrenPadding: const EdgeInsets.all(16.0),
                        children: [
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              final canManageTags = PermissionHelper.canManageTags(authProvider.userRole);
                              return Column(
                                children: [
                                  if (customer.tags.isNotEmpty) ...[
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: customer.tags.map((tag) {
                                        return Chip(
                                          label: Text(tag),
                                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                          deleteIcon: canManageTags ? const Icon(Icons.close, size: 16) : null,
                                          onDeleted: canManageTags
                                              ? () {
                                                  provider.removeTag(customer.id, tag);
                                                }
                                              : null,
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  if (canManageTags) ...[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _tagController,
                                            decoration: const InputDecoration(
                                              hintText: 'Etiket adı',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            if (_tagController.text.trim().isNotEmpty) {
                                              provider.addTag(
                                                customer.id,
                                                _tagController.text.trim(),
                                              );
                                              _tagController.clear();
                                            }
                                          },
                                          child: const Text('Ekle'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Notlar (açılır kart)
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(
                          'Notlar (${customer.notes.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        childrenPadding: const EdgeInsets.all(16.0),
                        children: [
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              final canManageNotes = PermissionHelper.canManageNotes(authProvider.userRole);
                              return Column(
                                children: [
                                  if (customer.notes.isNotEmpty) ...[
                                    ...customer.notes.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final note = entry.value;
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        child: ListTile(
                                          title: Text(note),
                                          trailing: canManageNotes
                                              ? IconButton(
                                                  icon: const Icon(Icons.delete),
                                                  onPressed: () {
                                                    provider.removeNote(customer.id, index);
                                                  },
                                                )
                                              : null,
                                        ),
                                      );
                                    }),
                                    const SizedBox(height: 12),
                                  ],
                                  if (canManageNotes) ...[
                                    TextField(
                                      controller: _noteController,
                                      maxLines: 3,
                                      decoration: const InputDecoration(
                                        hintText: 'Notunuzu buraya yazın...',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_noteController.text.trim().isNotEmpty) {
                                            provider.addNote(
                                              customer.id,
                                              _noteController.text.trim(),
                                            );
                                            _noteController.clear();
                                          }
                                        },
                                        child: const Text('Not Ekle'),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return 'Aktif';
      case CustomerCategory.potential:
        return 'Potansiyel';
      case CustomerCategory.vip:
        return 'VIP';
      case CustomerCategory.inactive:
        return 'Pasif';
      default:
        return 'Bilinmiyor';
    }
  }

  Color _getCategoryColor(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return Colors.green;
      case CustomerCategory.potential:
        return Colors.orange;
      case CustomerCategory.vip:
        return Colors.purple;
      case CustomerCategory.inactive:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
```

Firebase Auth entegrasyonu tamamlandı. Özet:

**Tamamlananlar:**
1. Firebase Auth entegrasyonu: `firebase_auth` paketi eklendi
2. AuthProvider: Login/logout/register işlemleri
3. Login sayfası: Email/şifre ile giriş ve kayıt
4. Rol sistemi: Admin, Agent, Viewer rolleri
5. Permission Helper: Rol bazlı izin kontrolü
6. UI güncellemeleri: Butonlar rol bazlı gösteriliyor
   - Yeni müşteri ekleme: Admin ve Agent
   - Müşteri düzenleme: Admin ve Agent
   - Müşteri silme: Sadece Admin
   - Not/Etiket yönetimi: Admin ve Agent

**Sıradaki:**
1. `flutter pub get` çalıştır (firebase_auth paketi için)
2. Firestore Security Rules güncelle (Firebase Console'dan)

Firestore Security Rules için örnek kurallar hazırlayabilirim. Devam edeyim mi?

---

**User**

sürüm sorunu var sanırım: C:\flutter\bin\flutter.bat --no-color pub upgrade
Resolving dependencies...
Because firebase_auth >=5.3.1 <5.3.2 depends on firebase_core ^3.6.0 and firebase_auth >=5.3.2 <5.3.3 depends on firebase_core ^3.7.0, firebase_auth >=5.3.1 <5.3.3 requires firebase_core ^3.6.0.
And because firebase_auth >=5.3.3 <5.3.4 depends on firebase_core ^3.8.0, firebase_auth >=5.3.1 <5.3.4 requires firebase_core ^3.6.0.
And because firebase_auth >=5.3.4 <5.4.0 depends on firebase_core ^3.8.1 and firebase_auth >=5.4.0 <5.4.1 depends on firebase_core ^3.10.0, firebase_auth >=5.3.1 <5.4.1 requires firebase_core ^3.6.0.
And because firebase_auth >=5.4.1 <5.4.2 depends on firebase_core ^3.10.1 and firebase_auth >=5.4.2 <5.5.0 depends on firebase_core ^3.11.0, firebase_auth >=5.3.1 <5.5.0 requires firebase_core ^3.6.0.
And because firebase_auth >=5.5.0 <5.5.1 depends on firebase_core ^3.12.0 and firebase_auth >=5.5.1 <5.5.2 depends on firebase_core ^3.12.1, firebase_auth >=5.3.1 <5.5.2 requires firebase_core ^3.6.0.
And because firebase_auth >=5.5.2 <5.5.4 depends on firebase_core ^3.13.0 and firebase_auth >=5.5.4 <5.6.0 depends on firebase_core ^3.13.1, firebase_auth >=5.3.1 <5.6.0 requires firebase_core ^3.6.0.
And because firebase_auth >=5.6.0 <5.6.1 depends on firebase_core ^3.14.0 and firebase_auth >=5.6.1 <5.6.2 depends on firebase_core ^3.15.0, firebase_auth >=5.3.1 <5.6.2 requires firebase_core ^3.6.0.
Because cloud_firestore >=4.10.0 <5.0.1 depends on firebase_core_platform_interface ^5.0.0 and firebase_auth >=5.6.2 <6.1.0 depends on firebase_core_platform_interface ^6.0.0, cloud_firestore >=4.10.0 <5.0.1 is incompatible with firebase_auth >=5.6.2 <6.1.0.
Thus, if cloud_firestore >=4.10.0 <5.0.1 and firebase_auth >=5.3.1 <6.1.0 then firebase_core ^3.6.0.
And because crm depends on firebase_core ^2.32.0, cloud_firestore >=4.10.0 <5.0.1 is incompatible with firebase_auth >=5.3.1 <6.1.0.
So, because crm depends on both cloud_firestore ^4.15.8 and firebase_auth ^5.3.1, version solving failed.


You can try the following suggestion to make the pubspec resolve:
* Consider downgrading your constraint on firebase_auth: flutter pub add firebase_auth:^4.16.0
Failed to update packages.
Process finished with exit code 1

---

**Cursor**

Sürüm uyumsuzluğu var. Firebase paketlerini uyumlu sürümlere güncelliyoruz:


Firebase paketlerini uyumlu sürümlere güncelliyoruz:


```yaml
name: crm
description: "A new Flutter project."
# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

# The following defines the version and build number for your application.
# A version number is three numbers separated by dots, like 1.2.43
# followed by an optional build number separated by a +.
# Both the version and the builder number may be overridden in flutter
# build by specifying --build-name and --build-number, respectively.
# In Android, build-name is used as versionName while build-number used as versionCode.
# Read more about Android versioning at https://developer.android.com/studio/publish/versioning
# In iOS, build-name is used as CFBundleShortVersionString while build-number is used as CFBundleVersion.
# Read more about iOS versioning at
# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
# In Windows, build-name is used as the major, minor, and patch parts
# of the product and file versions while build-number is used as the build suffix.
version: 1.0.0+1

environment:
  sdk: ^3.8.1

# Dependencies specify other packages that your package needs in order to work.
# To automatically upgrade your package dependencies to the latest versions
# consider running `flutter pub upgrade --major-versions`. Alternatively,
# dependencies can be manually updated by changing the version numbers below to
# the latest version available on pub.dev. To see which dependencies have newer
# versions available, run `flutter pub outdated`.
dependencies:
  firebase_core: ^3.15.0
  cloud_firestore: ^5.0.0
  firebase_auth: ^5.6.2
  provider: ^6.1.2
  uuid: ^4.3.3
  url_launcher: ^6.2.5
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter

  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
  # rules and activating additional ones.
  flutter_lints: ^5.0.0

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg

  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images

  # For details regarding adding assets from package dependencies, see
  # https://flutter.dev/to/asset-from-package

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts from package dependencies,
  # see https://flutter.dev/to/font-from-package

```

Paketler yüklendi. Firebase paketleri uyumlu sürümlere güncellendi:
- `firebase_core: ^3.15.0`
- `cloud_firestore: ^5.0.0`
- `firebase_auth: ^5.7.0`

Kodda değişiklik gerekmiyor; Firebase Core 3.x geriye uyumlu.

**Not:** Windows'ta symlink uyarısı var. Geliştirme için kritik değil; istersen Developer Mode'u açabilirsin.

Şimdi uygulamayı çalıştırabilirsin. Firebase Auth entegrasyonu hazır. İstersen Firestore Security Rules için örnek kurallar hazırlayabilirim. Devam edeyim mi?

---

**User**

bu hatayı da düzeltelim: Launching lib\main.dart on ASUS I003DD in debug mode...
Running Gradle task 'assembleDebug'...
C:\androidProjects\crm\android\app\src\debug\AndroidManifest.xml Error:
	uses-sdk:minSdkVersion 21 cannot be smaller than version 23 declared in library [com.google.firebase:firebase-auth:23.2.1] C:\Users\Administrator\.gradle\caches\8.12\transforms\2aa3f59f4db98380ad58aa36e6094b0d\transformed\jetified-firebase-auth-23.2.1\AndroidManifest.xml as the library might be using APIs not available in 21
	Suggestion: use a compatible library with a minSdk of at most 21,
		or increase this project's minSdk version to at least 23,
		or use tools:overrideLibrary="com.google.firebase.auth" to force usage (may lead to runtime failures)

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:processDebugMainManifest'.
> Manifest merger failed : uses-sdk:minSdkVersion 21 cannot be smaller than version 23 declared in library [com.google.firebase:firebase-auth:23.2.1] C:\Users\Administrator\.gradle\caches\8.12\transforms\2aa3f59f4db98380ad58aa36e6094b0d\transformed\jetified-firebase-auth-23.2.1\AndroidManifest.xml as the library might be using APIs not available in 21
  	Suggestion: use a compatible library with a minSdk of at most 21,
  		or increase this project's minSdk version to at least 23,
  		or use tools:overrideLibrary="com.google.firebase.auth" to force usage (may lead to runtime failures)

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 49s
Error: Gradle task assembleDebug failed with exit code 1


---

**Cursor**

Android minSdkVersion'ı 23'e yükseltiyoruz:


```plaintext
plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.crm"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.crm"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23  // Firebase Auth requires minimum SDK 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

```

Android `minSdkVersion` 23'e yükseltildi. Firebase Auth'un gereksinimini karşılıyor.

**Yapılan değişiklik:**
- `android/app/build.gradle.kts` dosyasında `minSdk = 23` olarak ayarlandı

Uygulamayı tekrar derleyip çalıştırabilirsin. Firebase Auth entegrasyonu hazır.

**Not:** minSdk 23, Android 6.0 (Marshmallow) ve üzerini destekler. Bu, modern Android cihazların çoğunu kapsar.

Derleme başarılı olursa, Firestore Security Rules için örnek kurallar hazırlayabilirim. Devam edeyim mi?

---

**User**

endpoint ekledin mi?

---

**Cursor**

Firebase Console'da Authentication'ı etkinleştirmek gerekiyor. Kod tarafında hazır; Firebase tarafında manuel adımlar var. Kontrol ediyorum:


```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/customer_firestore_service.dart';
import 'data/repo/customer_repository.dart';
import 'presentation/providers/customer_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/pages/customer_page.dart';
import 'presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CustomerProvider>(
          create: (_) => CustomerProvider(
            CustomerRepositoryImpl(CustomerFirestoreService()),
          ),
          update: (_, authProvider, previous) {
            final provider = previous ?? CustomerProvider(
              CustomerRepositoryImpl(CustomerFirestoreService()),
            );
            if (authProvider.isAuthenticated && previous == null) {
              provider.fetchCustomers();
            }
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, _) {
          return MaterialApp(
            title: 'CRM Project',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
            ),
            themeMode: themeProvider.themeMode,
            routes: {
              '/login': (_) => const LoginPage(),
              '/home': (_) => const CustomerPage(),
            },
            home: authProvider.isAuthenticated
                ? const CustomerPage()
                : const LoginPage(),
          );
        },
      ),
    );
  }
}

```

Firebase endpoint'lerini ekledim. `main.dart`'ta `firebase_options.dart` import edildi ve `Firebase.initializeApp()` çağrısı platforma özel seçeneklerle güncellendi.

**Yapılan değişiklik:**
- `firebase_options.dart` import edildi
- `Firebase.initializeApp()` çağrısı `DefaultFirebaseOptions.currentPlatform` ile güncellendi

**Firebase Console'da yapılması gerekenler (manuel):**
1. Firebase Console → Authentication → Sign-in method
2. Email/Password'u etkinleştir
3. Firestore Database → Rules sekmesinde güvenlik kurallarını güncelle

Firestore Security Rules için örnek kurallar hazırlayabilirim. İstersen paylaşayım.

---

**User**

örnek kurallar hazırla, bunun harici endpointin işlevini de çok kısa söyle

---

**Cursor**

Firestore Security Rules için örnek kurallar hazırlıyorum:


```plaintext
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function: Kullanıcı giriş yapmış mı?
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function: Kullanıcının rolünü al
    function getUserRole() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
    }
    
    // Helper function: Admin mi?
    function isAdmin() {
      return isAuthenticated() && getUserRole() == 'admin';
    }
    
    // Helper function: Admin veya Agent mi?
    function isAdminOrAgent() {
      return isAuthenticated() && (getUserRole() == 'admin' || getUserRole() == 'agent');
    }
    
    // Users koleksiyonu: Kullanıcılar sadece kendi verilerini okuyabilir, admin herkesi görebilir
    match /users/{userId} {
      allow read: if isAuthenticated() && (request.auth.uid == userId || isAdmin());
      allow create: if isAuthenticated() && request.auth.uid == userId;
      allow update: if isAuthenticated() && (request.auth.uid == userId || isAdmin());
      allow delete: if isAdmin();
    }
    
    // Customers koleksiyonu: Rol bazlı erişim
    match /customers/{customerId} {
      // Okuma: Tüm authenticated kullanıcılar okuyabilir
      allow read: if isAuthenticated();
      
      // Oluşturma: Admin ve Agent yapabilir
      allow create: if isAdminOrAgent();
      
      // Güncelleme: Admin ve Agent yapabilir
      allow update: if isAdminOrAgent();
      
      // Silme: Sadece Admin yapabilir
      allow delete: if isAdmin();
    }
    
    // Diğer tüm koleksiyonlar için varsayılan: Erişim yok
    match /{document=**} {
      allow read, write: if false;
    }
  }
}

```

```markdown
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

```

**Endpoint'in işlevi (kısa):**
`firebase_options.dart` içindeki endpoint'ler, uygulamanın Firebase servislerine (Auth, Firestore) hangi projeye bağlanacağını belirler. API Key, Project ID, Auth Domain gibi yapılandırma bilgilerini içerir.

**Firestore Security Rules hazır:**
1. `firestore.rules` — Firebase Console'a yapıştırılacak kurallar
2. `FIRESTORE_RULES_README.md` — Kurulum talimatları ve açıklamalar

**Kuralların özeti:**
- Customers: Tüm authenticated kullanıcılar okuyabilir; Admin/Agent ekleyip güncelleyebilir; sadece Admin silebilir
- Users: Kullanıcılar kendi verilerini yönetebilir; Admin herkesi yönetebilir

Firebase Console → Firestore Database → Rules sekmesine gidip `firestore.rules` dosyasındaki kuralları yapıştır ve yayınla.

---

**User**

kuralların testini nasıl yapıyoruz

---

**Cursor**

Firestore Security Rules'ı test etmek için iki yöntem:

1) Firebase Console Rules Simulator (hızlı test)


```markdown
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

```

Test rehberi hazır. Özet:

## Firestore Rules Test Yöntemleri

### 1. Firebase Console Rules Simulator (en hızlı)
- Firebase Console → Firestore Database → Rules → "Rules playground" / "Simulator"
- Senaryoları simüle et (get, create, update, delete)
- Farklı rollerle test et (admin, agent, viewer)

### 2. Uygulamada pratik test
- Farklı rollerle giriş yap
- Butonların görünürlüğünü kontrol et
- İşlemleri deneyip hata mesajlarını kontrol et

### 3. Test kullanıcıları oluştur
- Firebase Console → Authentication → Users → Add user
- Firestore → `users` koleksiyonunda rol bilgilerini ekle

**Hızlı test için:**
1. Firebase Console → Firestore → Rules → Simulator
2. Test senaryolarını çalıştır
3. Sonuçları kontrol et (✅ Allow / ❌ Deny)

Detaylı adımlar ve test senaryoları `FIRESTORE_RULES_TEST_GUIDE.md` dosyasında.

---

**User**

location olarak nereyi göstermeliyim

---

**Cursor**

Firestore Rules Simulator'de Location alanı için örnekler:

## Location Örnekleri

### Customers koleksiyonu için:

**Tek bir müşteri okuma:**
```
Location: /customers/abc123
```
(abc123 = gerçek bir customer ID)

**Yeni müşteri oluşturma:**
```
Location: /customers/new-customer-id
```
(new-customer-id = yeni oluşturulacak ID)

**Müşteri güncelleme:**
```
Location: /customers/abc123
```

**Müşteri silme:**
```
Location: /customers/abc123
```

### Users koleksiyonu için:

**Kendi kullanıcı bilgisini okuma:**
```
Location: /users/test-user-id
```
(test-user-id = Firebase Auth'daki user.uid)

**Kullanıcı oluşturma:**
```
Location: /users/test-user-id
```

## Pratik İpucu

Firestore'da gerçek bir ID görmek için:
1. Firebase Console → Firestore Database → Data
2. `customers` koleksiyonunu aç
3. Bir doküman seç → ID'yi kopyala
4. Simulator'de Location'a yapıştır: `/customers/[kopyaladığın-id]`

**Örnek:**
```
Location: /customers/customer-001
Location: /users/user-abc123
```

**Not:** Location her zaman `/koleksiyon/doküman-id` formatında olmalı. Wildcard kullanmak istersen `/customers/{customerId}` yazabilirsin, ama simulator'de genelde gerçek ID kullanmak daha iyi sonuç verir.

```plaintext
Location: /customers/abc123
```

```plaintext
Location: /customers/new-customer-id
```

```plaintext
Location: /customers/abc123
```

```plaintext
Location: /customers/abc123
```

```plaintext
Location: /users/test-user-id
```

```plaintext
Location: /users/test-user-id
```

```plaintext
Location: /customers/customer-001
Location: /users/user-abc123
```

---

**User**

ne diyor

---

**Cursor**

Ekranda görünen durum:

## Sorun: "Simulated write denied" (Yazma reddedildi)

**Neden reddedildi:**
- Sağ panelde `request.auth: null` görünüyor.
- Authenticated toggle açık olsa da, simulator'de kullanıcı kimliği belirtilmemiş.

**Çözüm:**
1. Sol panelde "Authenticated" toggle'ı kapatıp tekrar aç.
2. Ya da "User ID" alanını doldur (varsa).
3. Alternatif: Simulator'de "User ID" alanına gerçek bir kullanıcı ID'si gir:
   ```
   User ID: test-user-123
   ```

**Location için:**
- Şu an: `/customers/{customerld}` (muhtemelen typo)
- Olması gereken: `/customers/{customerId}` veya gerçek bir ID: `/customers/abc123`

**Test için doğru ayarlar:**
- **Location:** `/customers/test-customer-1` (gerçek bir ID)
- **Authenticated:** AÇIK
- **User ID:** Bir kullanıcı ID'si gir (örn: `test-user-123`)
- **Simulation type:** update
- **Data:** Güncelleme verilerini ekle

**Not:** `request.auth: null` olduğu sürece `isAuthenticated()` false döner ve kurallar reddeder. User ID'yi doldurduğunda `request.auth` dolu gelir ve test çalışır.

```plaintext
   User ID: test-user-123
```

---

**User**

son rules kodları nasıl güncel halini yaz

---

**Cursor**

Güvenli hale getiriyorum: `getUserRole()` için hata kontrolü ekliyorum.


```plaintext
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function: Kullanıcı giriş yapmış mı?
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function: Kullanıcının rolünü al (güvenli)
    function getUserRole() {
      return isAuthenticated() && 
             exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role != null
        ? get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role
        : 'viewer'; // Varsayılan rol
    }
    
    // Helper function: Admin mi?
    function isAdmin() {
      return isAuthenticated() && getUserRole() == 'admin';
    }
    
    // Helper function: Admin veya Agent mi?
    function isAdminOrAgent() {
      return isAuthenticated() && (getUserRole() == 'admin' || getUserRole() == 'agent');
    }
    
    // Users koleksiyonu: Kullanıcılar sadece kendi verilerini okuyabilir, admin herkesi görebilir
    match /users/{userId} {
      allow read: if isAuthenticated() && (request.auth.uid == userId || isAdmin());
      allow create: if isAuthenticated() && request.auth.uid == userId;
      allow update: if isAuthenticated() && (request.auth.uid == userId || isAdmin());
      allow delete: if isAdmin();
    }
    
    // Customers koleksiyonu: Rol bazlı erişim
    match /customers/{customerId} {
      // Okuma: Tüm authenticated kullanıcılar okuyabilir
      allow read: if isAuthenticated();
      
      // Oluşturma: Admin ve Agent yapabilir
      allow create: if isAdminOrAgent();
      
      // Güncelleme: Admin ve Agent yapabilir
      allow update: if isAdminOrAgent();
      
      // Silme: Sadece Admin yapabilir
      allow delete: if isAdmin();
    }
    
    // Diğer tüm koleksiyonlar için varsayılan: Erişim yok
    match /{document=**} {
      allow read, write: if false;
    }
  }
}


```

Güncel Firestore Security Rules:

```1:60:firestore.rules
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function: Kullanıcı giriş yapmış mı?
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function: Kullanıcının rolünü al (güvenli)
    function getUserRole() {
      return isAuthenticated() && 
             exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role != null
        ? get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role
        : 'viewer'; // Varsayılan rol
    }
    
    // Helper function: Admin mi?
    function isAdmin() {
      return isAuthenticated() && getUserRole() == 'admin';
    }
    
    // Helper function: Admin veya Agent mi?
    function isAdminOrAgent() {
      return isAuthenticated() && (getUserRole() == 'admin' || getUserRole() == 'agent');
    }
    
    // Users koleksiyonu: Kullanıcılar sadece kendi verilerini okuyabilir, admin herkesi görebilir
    match /users/{userId} {
      allow read: if isAuthenticated() && (request.auth.uid == userId || isAdmin());
      allow create: if isAuthenticated() && request.auth.uid == userId;
      allow update: if isAuthenticated() && (request.auth.uid == userId || isAdmin());
      allow delete: if isAdmin();
    }
    
    // Customers koleksiyonu: Rol bazlı erişim
    match /customers/{customerId} {
      // Okuma: Tüm authenticated kullanıcılar okuyabilir
      allow read: if isAuthenticated();
      
      // Oluşturma: Admin ve Agent yapabilir
      allow create: if isAdminOrAgent();
      
      // Güncelleme: Admin ve Agent yapabilir
      allow update: if isAdminOrAgent();
      
      // Silme: Sadece Admin yapabilir
      allow delete: if isAdmin();
    }
    
    // Diğer tüm koleksiyonlar için varsayılan: Erişim yok
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

**Yapılan iyileştirme:**
- `getUserRole()` güvenli hale getirildi: Kullanıcı dokümanı yoksa veya rol yoksa varsayılan olarak `'viewer'` döner; hata oluşmaz.

Bu kuralları Firebase Console → Firestore Database → Rules sekmesine yapıştırıp yayınlayabilirsin.

```plaintext
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function: Kullanıcı giriş yapmış mı?
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function: Kullanıcının rolünü al (güvenli)
    function getUserRole() {
      return isAuthenticated() && 
             exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role != null
        ? get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role
        : 'viewer'; // Varsayılan rol
    }
    
    // Helper function: Admin mi?
    function isAdmin() {
      return isAuthenticated() && getUserRole() == 'admin';
    }
    
    // Helper function: Admin veya Agent mi?
    function isAdminOrAgent() {
      return isAuthenticated() && (getUserRole() == 'admin' || getUserRole() == 'agent');
    }
    
    // Users koleksiyonu: Kullanıcılar sadece kendi verilerini okuyabilir, admin herkesi görebilir
    match /users/{userId} {
      allow read: if isAuthenticated() && (request.auth.uid == userId || isAdmin());
      allow create: if isAuthenticated() && request.auth.uid == userId;
      allow update: if isAuthenticated() && (request.auth.uid == userId || isAdmin());
      allow delete: if isAdmin();
    }
    
    // Customers koleksiyonu: Rol bazlı erişim
    match /customers/{customerId} {
      // Okuma: Tüm authenticated kullanıcılar okuyabilir
      allow read: if isAuthenticated();
      
      // Oluşturma: Admin ve Agent yapabilir
      allow create: if isAdminOrAgent();
      
      // Güncelleme: Admin ve Agent yapabilir
      allow update: if isAdminOrAgent();
      
      // Silme: Sadece Admin yapabilir
      allow delete: if isAdmin();
    }
    
    // Diğer tüm koleksiyonlar için varsayılan: Erişim yok
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

**User**

Error running simulation — Error: simulator.rules line [14], column [14]. Function not found error: Name: [exists].

---

**Cursor**

`exists()` fonksiyonu bazı Firestore Rules sürümlerinde sorun çıkarabiliyor. Daha uyumlu bir yaklaşıma geçiyoruz:


```plaintext
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function: Kullanıcı giriş yapmış mı?
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function: Kullanıcının rolünü al (güvenli)
    function getUserRole() {
      let userDoc = get(/databases/$(database)/documents/users/$(request.auth.uid));
      return userDoc != null && userDoc.data.role != null 
        ? userDoc.data.role 
        : 'viewer'; // Varsayılan rol
    }
    
    // Helper function: Admin mi?
    function isAdmin() {
      return isAuthenticated() && getUserRole() == 'admin';
    }
    
    // Helper function: Admin veya Agent mi?
    function isAdminOrAgent() {
      return isAuthenticated() && (getUserRole() == 'admin' || getUserRole() == 'agent');
    }
    
    // Users koleksiyonu: Kullanıcılar sadece kendi verilerini okuyabilir, admin herkesi görebilir
    match /users/{userId} {
      allow read: if isAuthenticated() && (request.auth.uid == userId || isAdmin());
      allow create: if isAuthenticated() && request.auth.uid == userId;
      allow update: if isAuthenticated() && (request.auth.uid == userId || isAdmin());
      allow delete: if isAdmin();
    }
    
    // Customers koleksiyonu: Rol bazlı erişim
    match /customers/{customerId} {
      // Okuma: Tüm authenticated kullanıcılar okuyabilir
      allow read: if isAuthenticated();
      
      // Oluşturma: Admin ve Agent yapabilir
      allow create: if isAdminOrAgent();
      
      // Güncelleme: Admin ve Agent yapabilir
      allow update: if isAdminOrAgent();
      
      // Silme: Sadece Admin yapabilir
      allow delete: if isAdmin();
    }
    
    // Diğer tüm koleksiyonlar için varsayılan: Erişim yok
    match /{document=**} {
      allow read, write: if false;
    }
  }
}


```

---

**User**

bu kurallar ne için gerekliydi kısaca

---

**Cursor**

## Firestore Security Rules'ın amacı

**Güvenlik:** Veritabanına kimlerin erişebileceğini ve ne yapabileceğini kontrol eder.

**Özet:**
1. Yetkisiz erişimi engeller: Giriş yapmayanlar veri göremez/değiştiremez.
2. Rol bazlı kontrol: Admin, Agent, Viewer rolleri farklı yetkilere sahip.
3. Veri koruması: Kullanıcılar sadece yetkili oldukları işlemleri yapabilir.

**Örnek:**
- Viewer: Sadece okuyabilir (müşteri listesi, detay)
- Agent: Okuyup yazabilir (müşteri ekle/düzenle), silemez
- Admin: Tüm işlemleri yapabilir (okuma, yazma, silme)

**Sonuç:** Kurallar olmadan herkes veritabanını değiştirebilir. Kurallar ile sadece yetkili kullanıcılar işlem yapabilir.

---

**User**

get ssimülasyonunda sorun olmuyor bunda neden oluyor benim hatam mı

---

**Cursor**

Sorun: `getUserRole()` içinde `isAuthenticated()` kontrolü yok. `request.auth` null olduğunda `request.auth.uid` null olur ve path bozulur. `getUserRole()` içine `isAuthenticated()` kontrolü ekliyoruz:


```plaintext
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function: Kullanıcı giriş yapmış mı?
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function: Kullanıcının rolünü al (güvenli)
    function getUserRole() {
      // Önce authentication kontrolü yap
      if (!isAuthenticated()) {
        return 'viewer'; // Giriş yapmamışsa varsayılan rol
      }
      let userDoc = get(/databases/$(database)/documents/users/$(request.auth.uid));
      return userDoc != null && userDoc.data.role != null 
        ? userDoc.data.role 
        : 'viewer'; // Varsayılan rol
    }
    
    // Helper function: Admin mi?
    function isAdmin() {
      return isAuthenticated() && getUserRole() == 'admin';
    }
    
    // Helper function: Admin veya Agent mi?
    function isAdminOrAgent() {
      return isAuthenticated() && (getUserRole() == 'admin' || getUserRole() == 'agent');
    }
    
    // Users koleksiyonu: Kullanıcılar sadece kendi verilerini okuyabilir, admin herkesi görebilir
    match /users/{userId} {
      allow read: if isAuthenticated() && (request.auth.uid == userId || isAdmin());
      allow create: if isAuthenticated() && request.auth.uid == userId;
      allow update: if isAuthenticated() && (request.auth.uid == userId || isAdmin());
      allow delete: if isAdmin();
    }
    
    // Customers koleksiyonu: Rol bazlı erişim
    match /customers/{customerId} {
      // Okuma: Tüm authenticated kullanıcılar okuyabilir
      allow read: if isAuthenticated();
      
      // Oluşturma: Admin ve Agent yapabilir
      allow create: if isAdminOrAgent();
      
      // Güncelleme: Admin ve Agent yapabilir
      allow update: if isAdminOrAgent();
      
      // Silme: Sadece Admin yapabilir
      allow delete: if isAdmin();
    }
    
    // Diğer tüm koleksiyonlar için varsayılan: Erişim yok
    match /{document=**} {
      allow read, write: if false;
    }
  }
}


```

Sorun: Simulator'de "Authenticated" açık ama "Firebase UID" boş. Bu yüzden `request.auth` null geliyor ve `getUserRole()` içinde `request.auth.uid` kullanıldığında path bozuluyor.

**Senin hatan değil** — bu simulator ayarı. Ama kodda da güvenlik kontrolü ekledim.

**Çözüm:**
1. Simulator'de: "Firebase UID" alanına bir ID gir (örn: `test-user-123`)
2. Kod tarafında: `getUserRole()` içine `isAuthenticated()` kontrolü eklendi

**Güncellenmiş kod:**
```12:17:firestore.rules
    // Helper function: Kullanıcının rolünü al (güvenli)
    function getUserRole() {
      // Önce authentication kontrolü yap
      if (!isAuthenticated()) {
        return 'viewer'; // Giriş yapmamışsa varsayılan rol
      }
      let userDoc = get(/databases/$(database)/documents/users/$(request.auth.uid));
      return userDoc != null && userDoc.data.role != null 
        ? userDoc.data.role 
        : 'viewer'; // Varsayılan rol
    }
```

**Simulator'de test için:**
- "Firebase UID" alanına bir ID gir (örn: `test-user-123`)
- "Authenticated" toggle'ı açık olsun
- Artık `request.auth` null olmayacak ve hata çözülecek

Bu değişiklikle kod daha güvenli; `request.auth` null olsa bile hata vermez.

```plaintext
    // Helper function: Kullanıcının rolünü al (güvenli)
    function getUserRole() {
      // Önce authentication kontrolü yap
      if (!isAuthenticated()) {
        return 'viewer'; // Giriş yapmamışsa varsayılan rol
      }
      let userDoc = get(/databases/$(database)/documents/users/$(request.auth.uid));
      return userDoc != null && userDoc.data.role != null 
        ? userDoc.data.role 
        : 'viewer'; // Varsayılan rol
    }
```

---

**User**

şimdi ne yapıyoruz örneğin admin girişi falan nasıl oluyor uygulama kullanışında ne farklılıklar oldu pratikte

