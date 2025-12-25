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