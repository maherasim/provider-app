import 'package:mobx/mobx.dart';

part 'filter_store.g.dart';

class FilterStore = FilterStoreBase with _$FilterStore;

abstract class FilterStoreBase with Store {
  @observable
  List<int> serviceId = ObservableList();

  @observable
  List<int> customerId = ObservableList();

  @observable
  List<int> providerId = ObservableList();

  @observable
  List<int> handymanId = ObservableList();

  @observable
  List<String> bookingStatus = ObservableList();

  @observable
  List<String> paymentStatus = ObservableList();

  @observable
  List<String> paymentType = ObservableList();

  @observable
  String startDate = '';

  @observable
  String endDate = '';

  @action
  void setStartDate(String val) {
    startDate = val;
  }

  @action
  void setEndDate(String val) {
    endDate = val;
  }

  @action
  Future<void> addToServiceList({required int serId}) async {
    serviceId.add(serId);
  }

  @action
  Future<void> removeFromServiceList({required int serId}) async {
    serviceId.removeWhere((element) => element == serId);
  }

  @action
  Future<void> addToCustomerList({required int cusId}) async {
    customerId.add(cusId);
  }

  @action
  Future<void> removeFromCustomerList({required int cusId}) async {
    customerId.removeWhere((element) => element == cusId);
  }

  @action
  Future<void> addToProviderList({required int prodId}) async {
    providerId.add(prodId);
  }

  @action
  Future<void> removeFromProviderList({required int prodId}) async {
    providerId.removeWhere((element) => element == prodId);
  }

  @action
  Future<void> addToHandymanList({required int handyId}) async {
    handymanId.add(handyId);
  }

  @action
  Future<void> removeFromHandymanList({required int handyId}) async {
    handymanId.removeWhere((element) => element == handyId);
  }

  @action
  Future<void> addToBookingStatusList({required String bookingStatusList}) async {
    bookingStatus.add(bookingStatusList);
  }

  @action
  Future<void> removeFromBookingStatusList({required String bookingStatusList}) async {
    bookingStatus.removeWhere((element) => element == bookingStatusList);
  }

  @action
  Future<void> addToPaymentStatusList({required String paymentStatusList}) async {
    paymentStatus.add(paymentStatusList);
  }

  @action
  Future<void> removeFromPaymentStatusList({required String paymentStatusList}) async {
    paymentStatus.removeWhere((element) => element == paymentStatusList);
  }

  @action
  Future<void> addToPaymentTypeList({required String paymentTypeList}) async {
    paymentType.add(paymentTypeList);
  }

  @action
  Future<void> removeFromPaymentTypeList({required String paymentTypeList}) async {
    paymentType.removeWhere((element) => element == paymentTypeList);
  }

  @action
  Future<void> clearFilters() async {
    customerId.clear();
    serviceId.clear();
    providerId.clear();
    handymanId.clear();
    bookingStatus.clear();
    paymentType.clear();
    paymentStatus.clear();
    startDate = '';
    endDate = '';
  }
}
