import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/customer_model.dart';

class CustomerFirestoreService {
  final CollectionReference _customerCollection =
      FirebaseFirestore.instance.collection('customers');

  Future<List<CustomerModel>> getCustomers() async {
    final snapshot = await _customerCollection.get();
    return snapshot.docs
        .map((doc) => CustomerModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addCustomer(CustomerModel customer) async {
    await _customerCollection.doc(customer.id).set(customer.toJson());
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    await _customerCollection.doc(customer.id).update(customer.toJson());
  }

  Future<void> deleteCustomer(String id) async {
    await _customerCollection.doc(id).delete();
  }
} 