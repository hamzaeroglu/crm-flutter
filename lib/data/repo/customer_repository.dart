import '../models/customer_model.dart';
import '../../core/services/customer_firestore_service.dart';

abstract class CustomerRepository {
  Future<List<CustomerModel>> getCustomers();
  Future<void> addCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String id);
}

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerFirestoreService firestoreService;

  CustomerRepositoryImpl(this.firestoreService);

  @override
  Future<List<CustomerModel>> getCustomers() {
    return firestoreService.getCustomers();
  }

  @override
  Future<void> addCustomer(CustomerModel customer) {
    return firestoreService.addCustomer(customer);
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) {
    return firestoreService.updateCustomer(customer);
  }

  @override
  Future<void> deleteCustomer(String id) {
    return firestoreService.deleteCustomer(id);
  }
} 