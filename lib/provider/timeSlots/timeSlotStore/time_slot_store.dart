import 'package:handyman_provider_flutter/provider/timeSlots/models/slot_data.dart';
import 'package:handyman_provider_flutter/provider/timeSlots/services/time_slot_services.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

part 'time_slot_store.g.dart';

class TimeSlotStore = TimeSlotStoreBase with _$TimeSlotStore;

abstract class TimeSlotStoreBase with Store {
  @observable
  bool isLoading = false;

  @observable
  bool slotsForAllServices = false;

  @observable
  bool isTimeSlotAvailable = false;

  @observable
  List<SlotData> serviceSlotData = ObservableList();

  @action
  Future<void> addSlotData({required SlotData value}) async {
    serviceSlotData.add(value);
  }

  @action
  Future<void> initializeSlots({required List<SlotData> value}) async {
    serviceSlotData = value;
  }

  @action
  Future<void> timeSlotForProvider() async {
    List<SlotData> list = await getProviderTimeSlots();
    isTimeSlotAvailable = list.where((element) => element.slot.validate().isNotEmpty).isNotEmpty;
  }

  @action
  Future<void> removeSlotData({required SlotData value}) async {
    if (value.date != null) {
      serviceSlotData.removeWhere((element) => 
        element.date != null &&
        element.date!.year == value.date!.year &&
        element.date!.month == value.date!.month &&
        element.date!.day == value.date!.day
      );
    }
  }

  @action
  Future<void> setForAllServices({required bool value, bool isInitializing = false}) async {
    slotsForAllServices = value;

    if (isInitializing) setValue(FOR_ALL_SERVICES, value);
  }

  @action
  Future<void> clearSlotData() async {
    serviceSlotData.clear();
  }

  @action
  List<String> checkIsAvailable({required DateTime selectedDate}) {
    return serviceSlotData.firstWhere((element) => 
      element.date != null &&
      element.date!.year == selectedDate.year &&
      element.date!.month == selectedDate.month &&
      element.date!.day == selectedDate.day,
      orElse: () => SlotData(slot: [])
    ).slot.validate();
  }

  @action
  void setLoading(bool val) {
    isLoading = val;
  }
}
