import '../models/customer_model.dart';

class CustomerDataSource {
  final List<CustomerModel> _customers = [];

  List<CustomerModel> getAllCustomers() => _customers;

  void addCustomer(CustomerModel customer) {
    _customers.add(customer);
  }
} 