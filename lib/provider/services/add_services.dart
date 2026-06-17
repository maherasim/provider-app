import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/custom_image_picker.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/attachment_model.dart';
import 'package:handyman_provider_flutter/models/city_list_response.dart';
import 'package:handyman_provider_flutter/models/country_list_response.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/models/state_list_response.dart';
import 'package:handyman_provider_flutter/models/visit_type_model.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/services/components/category_sub_cat_drop_down.dart';
import 'package:handyman_provider_flutter/provider/services/components/service_address_component.dart';
import 'package:handyman_provider_flutter/provider/timeSlots/my_time_slots_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/chat_gpt_loder.dart';
import '../../models/multi_language_request_model.dart';
import '../../models/static_data_model.dart';
import '../../models/user_data.dart';
import '../../provider/jobRequest/models/post_job_data.dart';

class AddServices extends StatefulWidget {
  final ServiceData? data;

  AddServices({this.data});

  @override
  State<AddServices> createState() => _AddServicesState();
}

class _AddServicesState extends State<AddServices> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  UniqueKey uniqueKey = UniqueKey();
  UniqueKey formWidgetKey = UniqueKey();

  /// TextEditingController
  TextEditingController serviceNameCont = TextEditingController();
  TextEditingController priceCont = TextEditingController();
  TextEditingController discountCont = TextEditingController();
  TextEditingController descriptionCont = TextEditingController();
  TextEditingController durationContDay = TextEditingController();
  TextEditingController durationContHr = TextEditingController();
  TextEditingController durationContMin = TextEditingController();
  TextEditingController prePayAmountController = TextEditingController();
  TextEditingController hoursCont = TextEditingController();
  TextEditingController miutesCont = TextEditingController();
  TextEditingController countryTaxCont = TextEditingController();
  TextEditingController minBookingCont = TextEditingController();
  TextEditingController cancellationPolicyCont = TextEditingController();

  /// FocusNode
  FocusNode serviceNameFocus = FocusNode();
  FocusNode priceFocus = FocusNode();
  FocusNode discountFocus = FocusNode();
  FocusNode descriptionFocus = FocusNode();
  FocusNode durationDayFocus = FocusNode();
  FocusNode durationHrFocus = FocusNode();
  FocusNode durationMinFocus = FocusNode();
  FocusNode prePayAmountFocus = FocusNode();
  FocusNode countryTaxFocus = FocusNode();
  FocusNode minBookingFocus = FocusNode();
  FocusNode cancellationPolicyFocus = FocusNode();

  FocusNode hoursFocus = FocusNode();
  FocusNode minutesFocus = FocusNode();

  String serviceType = SERVICE_TYPE_FIXED;
  String serviceStatus = ACTIVE;
  int? categoryId = -1;
  int? subCategoryId = -1;

  TimeOfDay? currentTime;

  bool isUpdate = false;
  bool isFeature = false;
  bool isTimeSlotAvailable = false;
  bool isAdvancePayment = false;
  bool isDigitalService = false;
  bool isAdvancePaymentAllowedBySystem =
      appConfigurationStore.isAdvancePaymentAllowed;
  bool isOnSiteVisit = true;
  bool isOnlineOrRemoteService = false;
  List<File> imageFiles = [];
  List<Attachments> tempAttachments = [];

  VisitTypeData? selectedVisitType;
  List<VisitTypeData> visitTypeData = [
    VisitTypeData(
        isEnabled: false,
        title: languages.onSiteVisit,
        key: VISIT_OPTION_ON_SITE),
    if (appConfigurationStore.digitalServiceStatus)
      VisitTypeData(
          isEnabled: false,
          title: languages.onlineRemoteService,
          key: VISIT_OPTION_ONLINE),
    VisitTypeData(
      isEnabled: false,
      title: languages.lblHybrid,
      key: VISIT_OPTION_HYBRID,
    ),
  ];

  List<StaticDataModel> typeStaticData = [
    StaticDataModel(key: SERVICE_TYPE_FIXED, value: languages.lblFixed),
    StaticDataModel(key: SERVICE_TYPE_HOURLY, value: languages.lblHourly),
    StaticDataModel(key: SERVICE_TYPE_DAILY, value: languages.lblDaily),
  ];

  List<StaticDataModel> statusListStaticData = [
    StaticDataModel(key: ACTIVE, value: languages.active),
    StaticDataModel(key: INACTIVE, value: languages.inactive),
  ];

  StaticDataModel? serviceStatusModel;

  CountryListResponse? selectedCountry;
  StateListResponse? selectedState;
  CityListResponse? selectedCity;

  int countryId = 0;
  int stateId = 0;
  int cityId = 0;

  List<CountryListResponse> countryList = [];
  List<StateListResponse> stateList = [];
  List<CityListResponse> cityList = [];

  List<int> serviceAddressList = [];
  Map<String, MultiLanguageRequest> translations = {};
  MultiLanguageRequest enTranslations = MultiLanguageRequest();

  // New fields for documentation requirements
  int? selectedProviderId;
  List<UserData> providerList = [];
  RemoteWorkLevel? selectedRemoteWorkLevel = RemoteWorkLevel.onsite0;
  CareerLevel? selectedCareerLevel = CareerLevel.notSpecified;
  TravelRequirement? selectedTravelRequired = TravelRequirement.no;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    isUpdate = widget.data != null;
    selectedVisitType = visitTypeData.first;
    appStore.setSelectedLanguage(languageList().first);
    if (isUpdate) {
      // Log the data being loaded for debugging
      print('🔵 LOADING SERVICE DATA FOR EDITING:');
      print('   countryId from data: ${widget.data!.countryId}');
      print('   stateId from data: ${widget.data!.stateId}');
      print('   cityId from data: ${widget.data!.cityId}');
      print('   name from data: ${widget.data!.name}');
      print('   description from data: ${widget.data!.description}');
      print('   advancePaymentAmount from data: ${widget.data!.advancePaymentAmount}');
      print('   translations: ${widget.data!.translations?.keys.toList()}');
      
      countryId = widget.data!.countryId.validate();
      // Ensure stateId and cityId are properly set (not 0 if they have values)
      final loadedStateId = widget.data!.stateId;
      final loadedCityId = widget.data!.cityId;
      stateId = (loadedStateId != null && loadedStateId != 0) ? loadedStateId : 0;
      cityId = (loadedCityId != null && loadedCityId != 0) ? loadedCityId : 0;
      
      print('🔵 SETTING IDs: countryId=$countryId, stateId=$stateId, cityId=$cityId');
      minBookingCont.text = widget.data!.minimumBookings.validate();
      cancellationPolicyCont.text = widget.data!.cancellationPolicy.validate();
      tempAttachments = widget.data!.attchments.validate();
      imageFiles = widget.data!.attchments
          .validate()
          .map((e) => File(e.url.toString()))
          .toList();
      // Load name - check translations first, then direct field
      String serviceName = widget.data?.translations?[DEFAULT_LANGUAGE]?.name.validate() ?? "";
      if (serviceName.isEmpty) {
        serviceName = widget.data?.name.validate() ?? "";
      }
      serviceNameCont.text = serviceName;
      
      priceCont.text = widget.data!.price.toString().validate();
      discountCont.text = widget.data!.discount.toString().validate();
      
      // Load description - check translations first, then direct field
      String serviceDescription = widget.data?.translations?[DEFAULT_LANGUAGE]?.description.validate() ?? "";
      if (serviceDescription.isEmpty) {
        serviceDescription = widget.data?.description.validate() ?? "";
      }
      descriptionCont.text = serviceDescription;
      categoryId = widget.data!.categoryId.validate();
      subCategoryId = widget.data!.subCategoryId.validate();
      isFeature = widget.data!.isFeatured.validate() == 1 ? true : false;
      serviceType = widget.data!.type.validate();
      setHourByServiceType();
      serviceStatus = widget.data!.status.validate() == 1 ? ACTIVE : INACTIVE;
      if (serviceStatus == ACTIVE) {
        serviceStatusModel = statusListStaticData.first;
      } else {
        serviceStatusModel = statusListStaticData[1];
      }
      isTimeSlotAvailable = widget.data!.isSlot.validate() == 1 ? true : false;
      //isAdvancePaymentAllowedBySystem = widget.data!.isAdvancePaymentSetting;
      isAdvancePayment = widget.data!.isAdvancePayment;
      
      // Fetch advance_payment_percentage directly from API and display as integer (e.g., "70" instead of "70.00%")
      if (widget.data!.advancePaymentPercentage != null) {
        // Convert to integer to remove decimals (e.g., 70.00 -> 70)
        int percentageInt = widget.data!.advancePaymentPercentage!.toInt();
        prePayAmountController.text = percentageInt.toString();
        print('🔵 ADVANCE PAYMENT: Displaying percentage=$percentageInt (cleaned from ${widget.data!.advancePaymentPercentage})');
      } else if (widget.data!.advancePaymentAmount != null) {
        // Fallback to amount if percentage is not available
        prePayAmountController.text = widget.data!.advancePaymentAmount!.toString();
        print('🔵 ADVANCE PAYMENT: Fetched amount=${widget.data!.advancePaymentAmount} from API');
      }
      if (widget.data?.translations?.isNotEmpty ?? false) {
        translations = await widget.data!.translations!;
        enTranslations = await translations[DEFAULT_LANGUAGE]!;
      }

      timeSlotStore.initializeSlots(
          value: widget.data!.providerSlotData.validate());

      selectedVisitType = visitTypeData.firstWhere(
          (element) => element.key == widget.data!.visitType.validate(),
          orElse: () => visitTypeData.first);

      // Load new fields from existing data if available
      selectedProviderId = widget.data!.providerId;
      
      // Load remote work level
      if (widget.data!.remoteWorkLevel != null) {
        try {
          selectedRemoteWorkLevel = RemoteWorkLevel.values.firstWhere(
            (e) => e.backendValue == widget.data!.remoteWorkLevel,
            orElse: () => RemoteWorkLevel.onsite0,
          );
        } catch (e) {
          selectedRemoteWorkLevel = RemoteWorkLevel.onsite0;
        }
      }
      
      // Load career level
      if (widget.data!.careerLevel != null) {
        try {
          selectedCareerLevel = CareerLevel.values.firstWhere(
            (e) => e.backendValue == widget.data!.careerLevel,
            orElse: () => CareerLevel.notSpecified,
          );
        } catch (e) {
          selectedCareerLevel = CareerLevel.notSpecified;
        }
      }
      
      // Load travel required
      if (widget.data!.travelRequired != null) {
        try {
          selectedTravelRequired = TravelRequirement.values.firstWhere(
            (e) => e.backendValue == widget.data!.travelRequired,
            orElse: () => TravelRequirement.no,
          );
        } catch (e) {
          selectedTravelRequired = TravelRequirement.no;
        }
      }
    }

    // Load provider list if user is admin
    if (_isAdminUser()) {
      await loadProviderList();
    }
   
    await getCountryStateCityData();
    setState(() {});
    await timeSlotStore.timeSlotForProvider();
  }

  bool _isAdminUser() {
    final userType = appStore.userType.toLowerCase();
    return userType == 'admin' || userType == 'demo_admin';
  }

  Future<void> loadProviderList() async {
    appStore.setLoading(true);
    try {
      await getProviderList(
        page: 1,
        keyword: '',
        status: '',
        list: providerList,
        lastPageCallback: (isLast) {},
      );
      if (isUpdate && selectedProviderId != null) {
        // Find and set selected provider
        final provider = providerList.firstWhere(
          (p) => p.id == selectedProviderId,
          orElse: () => providerList.isNotEmpty ? providerList.first : UserData(),
        );
        if (provider.id != null) {
          selectedProviderId = provider.id;
        }
      }
    } catch (e) {
      toast('$e', print: true);
    }
    appStore.setLoading(false);
    setState(() {});
  }

  getCountryStateCityData() async {
    if (countryId != 0) {
      await getCountry();
      await getStates(countryId);
      if (stateId != 0) {
        await getCity(stateId);
      }
      setState(() {});
    } else {
      await getCountry();
    }
  }

  Future<void> getCountry() async {
    appStore.setLoading(true);
    await getUpdatedCountryList().then((value) async {
      countryList.clear();
      countryList.addAll(value);

      if (value.any((element) => element.id == countryId)) {
        selectedCountry = value.firstWhere((element) => element.id == countryId);
        countryTaxCont.text = selectedCountry?.name ?? '';
      }
      setState(() {});
    }).catchError((e) {
      toast('$e', print: true);
    });
    appStore.setLoading(false);
  }

  Future<void> getStates(int countryId) async {
    appStore.setLoading(true);
    await getUpdatedStateList(countryId).then((value) async {
      stateList.clear();
      stateList.addAll(value);

      if (stateId != 0 && stateId != null) {
        final stateIdInt = _toInt(stateId);
        StateListResponse? matchingState;
        for (var e in value) {
          if (_toInt(e.id) == stateIdInt) {
            matchingState = e;
            break;
          }
        }
        if (matchingState != null) selectedState = matchingState;
      }
      setState(() {});
    }).catchError((e) {
      toast('$e', print: true);
    });
    appStore.setLoading(false);
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  Future<void> getCity(int stateIdParam) async {
    appStore.setLoading(true);

    await getUpdatedCityList(stateIdParam).then((value) async {
      cityList.clear();
      cityList.addAll(value);

      if (cityId != 0 && cityId != null) {
        final cityIdInt = _toInt(cityId);
        CityListResponse? matchingCity;
        for (var e in value) {
          if (_toInt(e.id) == cityIdInt) {
            matchingCity = e;
            break;
          }
        }
        if (matchingCity != null) selectedCity = matchingCity;
      }
      setState(() {});
    }).catchError((e) {
      toast('$e', print: true);
    });
    appStore.setLoading(false);
  }

  

//region Add Service
  Future<void> checkValidation(
      {required bool isSave, LanguageDataModel? code}) async {
    if ((!isUpdate && imageFiles.isEmpty) || (isUpdate && imageFiles.isEmpty)) {
      toast(languages.pleaseSelectImages);
      return;
    }

    if ((!isUpdate && serviceAddressList.validate().isEmpty) ||
        (isUpdate && serviceAddressList.validate().isEmpty)) {
      toast(languages.pleaseSelectServiceAddresses);
      return;
    }

    // Validate required fields per documentation
    if (stateId == 0) {
      toast(languages.selectState);
      return;
    }

    if (cityId == 0) {
      toast(languages.selectCity);
      return;
    }

    if (selectedRemoteWorkLevel == null) {
      toast(languages.lblPleaseSelectRemoteWorkLevel);
      return;
    }

    if (selectedCareerLevel == null) {
      toast(languages.lblPleaseSelectCareerLevel);
      return;
    }

    if (selectedTravelRequired == null) {
      toast(languages.lblPleaseSelectTravelRequired);
      return;
    }

    if (_isAdminUser() && selectedProviderId == null) {
      toast(languages.lblPleaseSelectProvider);
      return;
    }

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);
      updateTranslation();

      if (!isSave) {
        appStore.setSelectedLanguage(code!);
        disposeAllTextFieldsController();
        getTranslation();
        await checkValidationLanguage();
        setState(() => formWidgetKey = UniqueKey());
      } else {
        await removeEnTranslations();
        final req = _buildServiceRequest();
        await _submitService(req);
      }
    }
  }

//endregion

//region remove en translations
  removeEnTranslations() {
    if (translations.containsKey(DEFAULT_LANGUAGE)) {
      translations.remove(DEFAULT_LANGUAGE);
    }
  }
//endregion

//region service request
  Map<String, dynamic> _buildServiceRequest() {
    final req = {
      AddServiceKey.name: enTranslations.name.validate(),
      AddServiceKey.providerId: _isAdminUser() && selectedProviderId != null 
          ? selectedProviderId!.validate() 
          : appStore.userId.validate(),
      AddServiceKey.categoryId: categoryId,
      AddServiceKey.type: serviceType.validate(),
      AddServiceKey.price: priceCont.text,
      AddServiceKey.discountPrice: discountCont.text,
      AddServiceKey.description: enTranslations.description.validate(),
      AddServiceKey.isFeatured: isFeature ? '1' : '0',
      AddServiceKey.isSlot: isTimeSlotAvailable ? '1' : '0',
      AddServiceKey.status: serviceStatus.validate() == ACTIVE ? '1' : '0',
      AddServiceKey.duration: "${currentTime!.hour}:${currentTime!.minute}",
      AddServiceKey.visitType: selectedVisitType!.key,
      AdvancePaymentKey.isEnableAdvancePayment: isAdvancePayment ? 1 : 0,
      CommonKeys.countryId: countryId.toString(),
      CommonKeys.stateId: stateId.toString(),
      CommonKeys.cityId: cityId.toString(),
      AddServiceKey.countryTax: countryId.toString(),
      AddServiceKey.cancellationPolicy: cancellationPolicyCont.text.validate(),
      AddServiceKey.minBooking: minBookingCont.text.validate(),
      AddServiceKey.remoteWorkLevel: selectedRemoteWorkLevel!.backendValue,
      AddServiceKey.careerLevel: selectedCareerLevel!.backendValue,
      AddServiceKey.travelRequired: selectedTravelRequired!.backendValue,
    };

    if (subCategoryId != -1) {
      req.putIfAbsent(AddServiceKey.subCategoryId, () => subCategoryId);
    }

    if (translations.isNotEmpty) {
      req.putIfAbsent(
          AddServiceKey.translations, () => jsonEncode(translations));
    }

    if (isUpdate) {
      req.putIfAbsent(AddServiceKey.id, () => widget.data!.id.validate());
    }
    if (isAdvancePaymentAllowedBySystem && isAdvancePayment) {
      req.putIfAbsent(AdvancePaymentKey.advancePaymentAmount,
          () => prePayAmountController.text.validate().toDouble());
    }

    return req;
  }

  //endregion

//region Service APi Call
  Future<void> _submitService(Map<String, dynamic> req) async {
    try {
      // Filter to only real local files (existing images are File(url) and are skipped)
      List<File> validImageFiles = [];
      log('Processing ${imageFiles.length} image files for upload');

      for (var file in imageFiles) {
        final filePath = file.path.trim();
        log('Checking file: path="$filePath", exists=${await file.exists()}');

        if (file.path.contains('http')) {
          log('Skipping network image (existing): ${file.path}');
          continue; // Existing images - not uploaded again
        }

        // Validate path - check for empty, root path, or invalid paths
        if (filePath.isEmpty ||
            filePath == '/' ||
            filePath == '\\' ||
            filePath.length <= 1 ||
            filePath == Platform.pathSeparator) {
          log('Skipping invalid file path: "$filePath"');
          continue;
        }

        // Ensure path contains directory separators (not just a single character)
        if (!filePath.contains(Platform.pathSeparator) && filePath.length < 3) {
          log('Skipping invalid file path (no directory separator): "$filePath"');
          continue;
        }

        // Check if file exists
        try {
          final exists = await file.exists();
          if (exists) {
            // Verify file is readable and has content
            final stat = await file.stat();
            if (stat.size == 0) {
              log('File is empty, skipping: ${file.path}');
              continue;
            }

            // Double-check path is still valid
            final currentPath = file.path.trim();
            if (currentPath.isEmpty || currentPath == '/' || currentPath == '\\') {
              log('File path became invalid after check, skipping: "$currentPath"');
              continue;
            }

            log('File is valid: ${file.path}, size: ${stat.size} bytes');
            validImageFiles.add(file);
          } else {
            log('File does not exist: ${file.path}');
          }
        } catch (e) {
          log('Error checking file existence: ${file.path}, error: $e');
        }
      }

      log('Valid image files count: ${validImageFiles.length}');

      // When editing: allow submit with no new files if we have existing attachments (they stay on server)
      final bool hasExistingImages = tempAttachments.validate().isNotEmpty;
      if (validImageFiles.isEmpty) {
        if (!isUpdate) {
          toast(languages.lblPleaseSelectValidImages);
          return;
        }
        if (isUpdate && !hasExistingImages) {
          toast(languages.lblPleaseSelectValidImages);
          return;
        }
        // isUpdate && hasExistingImages → proceed with empty validImageFiles (keep existing only)
      }

      await addServiceMultiPart(
        value: req,
        serviceAddressList: serviceAddressList,
        imageFile: validImageFiles,
      );
    } catch (e) {
      log('Error in _submitService: $e');
      String errorMessage = e.toString();
      // Provide user-friendly error message for file upload errors
      if (errorMessage.contains("File `/` does not exist") || 
          errorMessage.contains("FileDoesNotExist") ||
          errorMessage.contains("does not exist")) {
        errorMessage = 'Image upload failed. Please try selecting the image again.';
      }
      toast(errorMessage);
    }
  }

//endregion

//region Update Translation
  void updateTranslation() {
    appStore.setLoading(true);
    final languageCode = appStore.selectedLanguage.languageCode.validate();
    if (serviceNameCont.text.isEmpty && descriptionCont.text.isEmpty) {
      translations.remove(languageCode);
    } else {
      if (languageCode != DEFAULT_LANGUAGE) {
        translations[languageCode] = translations[languageCode]?.copyWith(
              name: serviceNameCont.text.validate(),
              description: descriptionCont.text.validate(),
            ) ??
            MultiLanguageRequest(
              name: serviceNameCont.text.validate(),
              description: descriptionCont.text.validate(),
            );
      } else {
        enTranslations = enTranslations.copyWith(
          name: serviceNameCont.text.validate(),
          description: descriptionCont.text.validate(),
        );
      }
    }
    appStore.setLoading(false);
  }

//endregion

//region Get Translation Details
  void getTranslation() {
    final languageCode = appStore.selectedLanguage.languageCode;
    if (languageCode == DEFAULT_LANGUAGE) {
      serviceNameCont.text = enTranslations.name.validate();
      descriptionCont.text = enTranslations.description.validate();
    } else {
      final translation = translations[languageCode] ?? MultiLanguageRequest();
      serviceNameCont.text = translation.name.validate();
      descriptionCont.text = translation.description.validate();
    }
    setState(() {});
  }

//endregion

//region Dispose All TextControllers
  void disposeAllTextFieldsController() {
    serviceNameCont.clear();
    descriptionCont.clear();
    setState(() {});
  }

//endregion

//region language wise validation
  bool checkValidationLanguage() {
    log("langauge Code ==> ${appStore.selectedLanguage.languageCode}");
    if (appStore.selectedLanguage.languageCode == DEFAULT_LANGUAGE) {
      return true;
    } else {
      return false;
    }
  }
//endregion

//region Remove Attachment
  Future<void> removeAttachment({required int id}) async {
    appStore.setLoading(true);

    Map req = {
      CommonKeys.type: 'service_attachment',
      CommonKeys.id: id,
    };

    await deleteImage(req).then((value) {
      tempAttachments.validate().removeWhere((element) => element.id == id);
      setState(() {});

      uniqueKey = UniqueKey();

      appStore.setLoading(false);
      toast(value.message.validate(), print: true);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

//endregion

//region Build Widget
  Widget buildFormWidget() {
    final bool isAdmin = _isAdminUser();
    return Container(
      key: formWidgetKey,
      // padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            Column(
              spacing: 16,
              children: [
                AppTextField(
                  textFieldType: TextFieldType.NAME,
                  controller: serviceNameCont,
                  focus: serviceNameFocus,
                  nextFocus: priceFocus,
                  isValidationRequired: checkValidationLanguage(),
                  errorThisFieldRequired: languages.hintRequired,
                  decoration: inputDecoration(context,
                      hint: languages.hintServiceName,
                      fillColor: context.scaffoldBackgroundColor),
                ),
                CategorySubCatDropDown(
                  categoryId: categoryId == -1 ? null : categoryId,
                  subCategoryId: subCategoryId == -1 ? null : subCategoryId,
                  isCategoryValidate: true,
                  onCategorySelect: (int? val) {
                    categoryId = val!;
                    setState(() {});
                  },
                  onSubCategorySelect: (int? val) {
                    subCategoryId = val!;
                    setState(() {});
                  },
                ),
                Row(
                  children: [
                    DropdownButtonFormField<CountryListResponse>(
                      decoration: inputDecoration(
                        context, 
                        hint: languages.selectCountry,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                      isExpanded: true,
                      menuMaxHeight: 300,
                      value: selectedCountry,
                      dropdownColor: context.cardColor,
                      items: countryList.map((CountryListResponse e) {
                        return DropdownMenuItem<CountryListResponse>(
                          value: e,
                          child: Text(
                            e.name!,
                            style: primaryTextStyle(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (CountryListResponse? value) async {
                        countryId = value!.id!;
                        selectedCountry = value;
                        selectedState = null;
                        selectedCity = null;
                        countryTaxCont.text = selectedCountry?.name ?? '';
                        setState(() {});
                    
                        getStates(value.id!);
                      },
                    ).expand(),
                    8.width.visible(stateList.isNotEmpty),
                    if (stateList.isNotEmpty) DropdownButtonFormField<StateListResponse>(
                      decoration: inputDecoration(
                        context,
                        hint: languages.selectState,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                      isExpanded: true,
                      dropdownColor: context.cardColor,
                      menuMaxHeight: 300,
                      value: stateList.where((s) => s.id != null && s.id == stateId).firstOrNull ?? selectedState,
                      validator: (value) {
                        if (value == null) return errorThisFieldRequired;
                        return null;
                      },
                      items: stateList.map((StateListResponse e) {
                        return DropdownMenuItem<StateListResponse>(
                          value: e,
                          child: Text(e.name!,
                              style: primaryTextStyle(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (StateListResponse? value) async {
                        selectedCity = null;
                        selectedState = value;
                        stateId = value!.id!;
                        setState(() {});
                    
                        getCity(value.id!);
                      },
                    ).expand(),
                  ],
                ),
                if (cityList.isNotEmpty) DropdownButtonFormField<CityListResponse>(
                  decoration: inputDecoration(
                    context,
                    hint: languages.selectCity,
                    fillColor: context.scaffoldBackgroundColor,
                  ),
                  isExpanded: true,
                  menuMaxHeight: 400,
                  value: cityList.where((c) => c.id != null && c.id == cityId).firstOrNull ?? selectedCity,
                  dropdownColor: context.cardColor,
                  validator: (value) {
                    if (value == null) return errorThisFieldRequired;
                    return null;
                  },
                  items: cityList.map(
                    (CityListResponse e) {
                      return DropdownMenuItem<CityListResponse>(
                        value: e,
                        child: Text(
                          e.name!,
                          style: primaryTextStyle(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ).toList(),
                  onChanged: (CityListResponse? value) async {
                    selectedCity = value;
                    cityId = value!.id!;
                    setState(() {});
                  },
                ),
                // Provider dropdown (only for admin/demo_admin)
                if (_isAdminUser() && providerList.isNotEmpty) DropdownButtonFormField<UserData>(
                  decoration: inputDecoration(
                    context,
                    hint: languages.lblSelectProviderHint,
                    fillColor: context.scaffoldBackgroundColor,
                  ),
                  isExpanded: true,
                  menuMaxHeight: 300,
                  value: selectedProviderId != null
                      ? providerList.where((p) => p.id == selectedProviderId).isNotEmpty
                          ? providerList.firstWhere((p) => p.id == selectedProviderId)
                          : null
                      : null,
                  dropdownColor: context.cardColor,
                  validator: (value) {
                    if (value == null) return errorThisFieldRequired;
                    return null;
                  },
                  items: providerList.map((UserData e) {
                    return DropdownMenuItem<UserData>(
                      value: e,
                      child: Text(
                        '${e.firstName ?? ''} ${e.lastName ?? ''}'.trim().isEmpty
                            ? e.username ?? 'Provider ${e.id}'
                            : '${e.firstName ?? ''} ${e.lastName ?? ''}'.trim(),
                        style: primaryTextStyle(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (UserData? value) {
                    selectedProviderId = value?.id;
                    setState(() {});
                  },
                ),
                // Remote Work Level dropdown
                DropdownButtonFormField<RemoteWorkLevel>(
                  decoration: inputDecoration(
                    context,
                    hint: languages.lblRemoteWorkLevelHint,
                    fillColor: context.scaffoldBackgroundColor,
                  ),
                  isExpanded: true,
                  value: selectedRemoteWorkLevel,
                  dropdownColor: context.cardColor,
                  validator: (value) {
                    if (value == null) return errorThisFieldRequired;
                    return null;
                  },
                  items: RemoteWorkLevel.values.map((RemoteWorkLevel level) {
                    final label = switch (level) {
                      RemoteWorkLevel.onsite0 => languages.lblRemoteWorkOnsite100,
                      RemoteWorkLevel.remote25 => languages.lblRemoteWork25,
                      RemoteWorkLevel.remote50 => languages.lblRemoteWork50,
                      RemoteWorkLevel.remote75 => languages.lblRemoteWork75,
                      RemoteWorkLevel.remote100 => languages.lblRemoteWork100,
                    };
                    return DropdownMenuItem<RemoteWorkLevel>(
                      value: level,
                      child: Text(label, style: primaryTextStyle()),
                    );
                  }).toList(),
                  onChanged: (RemoteWorkLevel? value) {
                    selectedRemoteWorkLevel = value;
                    setState(() {});
                  },
                ),
                // Career Level dropdown
                DropdownButtonFormField<CareerLevel>(
                  decoration: inputDecoration(
                    context,
                    hint: languages.lblCareerLevelHint,
                    fillColor: context.scaffoldBackgroundColor,
                  ),
                  isExpanded: true,
                  value: selectedCareerLevel,
                  dropdownColor: context.cardColor,
                  validator: (value) {
                    if (value == null) return errorThisFieldRequired;
                    return null;
                  },
                  items: CareerLevel.values.map((CareerLevel level) {
                    final label = switch (level) {
                      CareerLevel.notSpecified => languages.lblCareerNotSpecified,
                      CareerLevel.entryLevel => languages.lblCareerEntryLevel,
                      CareerLevel.intermediateLevel => languages.lblCareerIntermediateLevel,
                      CareerLevel.experienced => languages.lblCareerExperienced,
                      CareerLevel.professional => languages.lblCareerProfessional,
                      CareerLevel.middleManagement => languages.lblCareerMiddleManagement,
                      CareerLevel.executiveManagement => languages.lblCareerExecutiveManagement,
                      CareerLevel.seniorManagement => languages.lblCareerSeniorManagement,
                      CareerLevel.director => languages.lblCareerDirector,
                      CareerLevel.technician => languages.lblCareerTechnician,
                      CareerLevel.leader => languages.lblCareerLeader,
                      CareerLevel.manager => languages.lblCareerManager,
                    };
                    return DropdownMenuItem<CareerLevel>(
                      value: level,
                      child: Text(label, style: primaryTextStyle()),
                    );
                  }).toList(),
                  onChanged: (CareerLevel? value) {
                    selectedCareerLevel = value;
                    setState(() {});
                  },
                ),
                // Travel Required dropdown
                DropdownButtonFormField<TravelRequirement>(
                  decoration: inputDecoration(
                    context,
                    hint: languages.lblTravelRequiredHint,
                    fillColor: context.scaffoldBackgroundColor,
                  ),
                  isExpanded: true,
                  value: selectedTravelRequired,
                  dropdownColor: context.cardColor,
                  validator: (value) {
                    if (value == null) return errorThisFieldRequired;
                    return null;
                  },
                  items: TravelRequirement.values.map((TravelRequirement req) {
                    final label = req == TravelRequirement.yes ? languages.lblYes : languages.lblNo;
                    return DropdownMenuItem<TravelRequirement>(
                      value: req,
                      child: Text(label, style: primaryTextStyle()),
                    );
                  }).toList(),
                  onChanged: (TravelRequirement? value) {
                    selectedTravelRequired = value;
                    setState(() {});
                  },
                ),
                ServiceAddressComponent(
                  selectedList: widget.data?.serviceAddressMapping
                      .validate()
                      .map((e) => e.providerAddressMapping != null
                          ? e.providerAddressMapping!.id.validate()
                          : 0)
                      .toList(),
                  onSelectedList: (val) {
                    serviceAddressList = val;
                  },
                ),
                Row(
                  children: [
                    DropdownButtonFormField<StaticDataModel>(
                      decoration: inputDecoration(context,
                          fillColor: context.scaffoldBackgroundColor,
                          hint: languages.lblType),
                      isExpanded: true,
                      value: serviceType.isNotEmpty ? getServiceType : null,
                      dropdownColor: context.cardColor,
                      items: typeStaticData.map((StaticDataModel data) {
                        return DropdownMenuItem<StaticDataModel>(
                          value: data,
                          child: Text(data.value.validate(),
                              style: primaryTextStyle()),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) return errorThisFieldRequired;
                        return null;
                      },
                      onChanged: (StaticDataModel? value) async {
                        serviceType = value!.key.validate();
                        setHourByServiceType();
                        setState(() {});
                      },
                    ).expand(),
                    16.width,
                    DropdownButtonFormField<StaticDataModel>(
                      isExpanded: true,
                      dropdownColor: context.cardColor,
                      value: serviceStatusModel != null
                          ? serviceStatusModel
                          : statusListStaticData.first,
                      items: statusListStaticData.map((StaticDataModel data) {
                        return DropdownMenuItem<StaticDataModel>(
                          value: data,
                          child: Text(data.value.validate(),
                              style: primaryTextStyle()),
                        );
                      }).toList(),
                      decoration: inputDecoration(context,
                          fillColor: context.scaffoldBackgroundColor,
                          hint: languages.lblStatus),
                      onChanged: (StaticDataModel? value) async {
                        serviceStatus = value!.key.validate();
                        setState(() {});
                      },
                      validator: (value) {
                        if (value == null) return errorThisFieldRequired;
                        return null;
                      },
                    ).expand(),
                  ],
                ),
                Row(
                  children: [
                    AppTextField(
                      textFieldType: TextFieldType.PHONE,
                      controller: priceCont,
                      focus: priceFocus,
                      nextFocus: discountFocus,
                      enabled: serviceType != SERVICE_TYPE_FREE,
                      errorThisFieldRequired: languages.hintRequired,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: inputDecoration(
                        context,
                        hint: languages.hintPrice,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                      validator: (s) {
                        if (s!.isEmpty) return errorThisFieldRequired;

                        if (s.toDouble() <= 0 &&
                            serviceType != SERVICE_TYPE_FREE)
                          return languages.priceAmountValidationMessage;
                        return null;
                      },
                    ).expand(),
                    16.width,
                    AppTextField(
                      textFieldType: TextFieldType.PHONE,
                      controller: discountCont,
                      focus: discountFocus,
                      nextFocus: durationHrFocus,
                      enabled: serviceType != SERVICE_TYPE_FREE,
                      decoration: inputDecoration(
                        context,
                        hint: languages.hintDiscount
                            .capitalizeFirstLetter()
                            .suffixText(value: ' (%)'),
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                      isValidationRequired: serviceType != SERVICE_TYPE_FREE,
                      validator: (s) {
                        int discount = int.tryParse(s.validate()).validate();
                        if ((discount < 0 || discount >= 100))
                          return languages.valueConditionMessage;
                        else
                          return null;
                      },
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                    ).expand(),
                  ],
                ),
                Row(
                  children: [
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      controller: countryTaxCont,
                      isValidationRequired: false,
                      enabled: false,
                      focus: countryTaxFocus,
                      nextFocus: minBookingFocus,
                      decoration: inputDecoration(
                        context,
                        hint: languages.lblCountryTax,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                    ).expand(),
                    16.width,
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      controller: minBookingCont,
                      isValidationRequired: false,
                      enabled: true,
                      focus: minBookingFocus,
                      nextFocus: priceFocus,
                      decoration: inputDecoration(
                        context,
                        hint: languages.lblMinBooking,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                    ).expand(),
                  ],
                ),
              ],
            ).paddingAll(16),
            AppTextField(
              textFieldType: TextFieldType.PHONE,
              controller: durationContHr,
              focus: durationHrFocus,
              nextFocus: durationMinFocus,
              maxLength: 3,
              enabled: serviceType == SERVICE_TYPE_FREE || serviceType == SERVICE_TYPE_FIXED,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              onChanged: (value) {
                currentTime = TimeOfDay(
                  hour: int.parse(value),
                  minute: 0,
                );
              },
              errorThisFieldRequired: languages.hintRequired,
              decoration: inputDecoration(
                context,
                labelStyle: secondaryTextStyle(size: 10),
                hint: languages.lblDurationHr,
                fillColor: context.scaffoldBackgroundColor,
                counterText: '',
              ),
            ).paddingSymmetric(horizontal: 16),
            // Row(
            //   spacing: 8,
            //   children: [
            //     Expanded(
            //       child: AppTextField(
            //         textFieldType: TextFieldType.PHONE,
            //         controller: durationContDay,
            //         focus: durationDayFocus,
            //         nextFocus: durationHrFocus,
            //         maxLength: 3,
            //         inputFormatters: <TextInputFormatter>[
            //           FilteringTextInputFormatter.digitsOnly
            //         ],
            //         onChanged: (value) {
            //           currentTime = TimeOfDay(
            //               hour: int.parse(value),
            //               minute: int.parse(durationContMin.text.isEmpty
            //                   ? "0"
            //                   : durationContMin.text.toString()));
            //         },
            //         errorThisFieldRequired: languages.hintRequired,
            //         decoration: inputDecoration(
            //           context,
            //           labelStyle: secondaryTextStyle(size: 10),
            //           hint: 'Duration: Days',
            //           fillColor: context.scaffoldBackgroundColor,
            //           counterText: '',
            //         ),
            //       ),
            //     ),
            //     Expanded(
            //       child: AppTextField(
            //         textFieldType: TextFieldType.PHONE,
            //         controller: durationContHr,
            //         focus: durationHrFocus,
            //         nextFocus: durationMinFocus,
            //         maxLength: 3,
            //         inputFormatters: <TextInputFormatter>[
            //           FilteringTextInputFormatter.digitsOnly
            //         ],
            //         onChanged: (value) {
            //           currentTime = TimeOfDay(
            //               hour: int.parse(value),
            //               minute: int.parse(durationContMin.text.isEmpty
            //                   ? "0"
            //                   : durationContMin.text.toString()));
            //         },
            //         errorThisFieldRequired: languages.hintRequired,
            //         decoration: inputDecoration(
            //           context,
            //           labelStyle: secondaryTextStyle(size: 10),
            //           hint: languages.lblDurationHr,
            //           fillColor: context.scaffoldBackgroundColor,
            //           counterText: '',
            //         ),
            //       ),
            //     ),
            //     Expanded(
            //       child: AppTextField(
            //         textFieldType: TextFieldType.PHONE,
            //         controller: durationContMin,
            //         focus: durationMinFocus,
            //         nextFocus: descriptionFocus,
            //         inputFormatters: <TextInputFormatter>[
            //           FilteringTextInputFormatter.digitsOnly
            //         ],
            //         maxLength: 2,
            //         onChanged: (value) {
            //           currentTime = TimeOfDay(
            //               hour: int.parse(durationContHr.text.isEmpty
            //                   ? "0"
            //                   : durationContHr.text.toString()),
            //               minute: int.parse(value));
            //         },
            //         isValidationRequired:
            //             appStore.selectedLanguage.languageCode ==
            //                 DEFAULT_LANGUAGE,
            //         errorThisFieldRequired: languages.hintRequired,
            //         decoration: inputDecoration(
            //           context,
            //           labelStyle: secondaryTextStyle(size: 10),
            //           hint: languages.lblDurationMin,
            //           fillColor: context.scaffoldBackgroundColor,
            //           counterText: '',
            //         ),
            //       ),
            //     ),
            //   ],
            // ).paddingSymmetric(horizontal: 6),
            Column(
              spacing: 16,
              children: [
                AppTextField(
                  textFieldType: TextFieldType.MULTILINE,
                  minLines: 5,
                  controller: descriptionCont,
                  focus: descriptionFocus,
                  nextFocus: cancellationPolicyFocus,
                  enableChatGPT: appConfigurationStore.chatGPTStatus,
                  promptFieldInputDecorationChatGPT:
                      inputDecoration(context).copyWith(
                    hintText: languages.writeHere,
                    fillColor: context.scaffoldBackgroundColor,
                    filled: true,
                  ),
                  testWithoutKeyChatGPT: appConfigurationStore.testWithoutKey,
                  loaderWidgetForChatGPT: const ChatGPTLoadingWidget(),
                  errorThisFieldRequired: languages.hintRequired,
                  isValidationRequired: checkValidationLanguage(),
                  decoration: inputDecoration(
                    context,
                    hint: languages.hintDescription,
                    fillColor: context.scaffoldBackgroundColor,
                  ),
                ),
                AppTextField(
                  textFieldType: TextFieldType.MULTILINE,
                  minLines: 5,
                  controller: cancellationPolicyCont,
                  focus: cancellationPolicyFocus,
                  enableChatGPT: appConfigurationStore.chatGPTStatus,
                  promptFieldInputDecorationChatGPT:
                  inputDecoration(context).copyWith(
                    hintText: languages.writeHere,
                    fillColor: context.scaffoldBackgroundColor,
                    filled: true,
                  ),
                  testWithoutKeyChatGPT: appConfigurationStore.testWithoutKey,
                  loaderWidgetForChatGPT: const ChatGPTLoadingWidget(),
                  errorThisFieldRequired: languages.hintRequired,
                  isValidationRequired: checkValidationLanguage(),
                  decoration: inputDecoration(
                    context,
                    hint: languages.lblCancellationPolicy,
                    fillColor: context.scaffoldBackgroundColor,
                  ),
                ),
                if (isAdmin) Container(
                    decoration: boxDecorationDefault(
                        color: context.scaffoldBackgroundColor,
                        borderRadius: radius()),
                    padding: EdgeInsets.only(left: 16, right: 4),
                    child: Theme(
                      data: ThemeData(
                        unselectedWidgetColor: appStore.isDarkMode
                            ? context.dividerColor
                            : context.iconColor,
                      ),
                      child: CheckboxListTile(
                        checkboxShape:
                            RoundedRectangleBorder(borderRadius: radius(4)),
                        autofocus: false,
                        activeColor: context.primaryColor,
                        checkColor: appStore.isDarkMode
                            ? context.iconColor
                            : context.cardColor,
                        value: isFeature,
                        contentPadding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: radius(),
                            side: BorderSide(color: primaryColor)),
                        title: Text(languages.hintSetAsFeature,
                            style: secondaryTextStyle()),
                        onChanged: (bool? v) {
                          isFeature = v.validate();
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                Container(
                  width: context.width(),
                  decoration: boxDecorationDefault(
                      color: context.scaffoldBackgroundColor,
                      borderRadius: radius()),
                  padding: EdgeInsets.only(left: 16, right: 4, top: 8),
                  child: Theme(
                    data: ThemeData(
                      unselectedWidgetColor: appStore.isDarkMode
                          ? context.dividerColor
                          : context.iconColor,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(languages.visitOption, style: boldTextStyle()),
                        8.height,
                        AnimatedWrap(
                          itemCount: visitTypeData.length,
                          listAnimationType: ListAnimationType.FadeIn,
                          fadeInConfiguration:
                              FadeInConfiguration(duration: 2.seconds),
                          spacing: 8,
                          runSpacing: 10,
                          itemBuilder: (context, index) {
                            VisitTypeData value = visitTypeData[index];

                            return Stack(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  child: Container(
                                    width: context.width() * 0.5 - 70,
                                    height: 60,
                                    padding: EdgeInsets.all(8),
                                    decoration: boxDecorationDefault(
                                      borderRadius: radius(8),
                                      color: appStore.isDarkMode
                                          ? cardDarkColor
                                          : cardLightColor,
                                      border: Border.all(color: primaryColor),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(value.title.validate(),
                                        style: primaryTextStyle(size: 12),
                                        textAlign: TextAlign.center),
                                  ).onTap(() {
                                    selectedVisitType = value;

                                    setState(() {});
                                  }),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: selectedVisitType == value
                                        ? EdgeInsets.all(2)
                                        : EdgeInsets.zero,
                                    decoration: boxDecorationDefault(
                                        color: context.primaryColor),
                                    child: selectedVisitType == value
                                        ? Icon(Icons.done,
                                            size: 16, color: Colors.white)
                                        : Offstage(),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        8.height,
                      ],
                    ),
                  ),
                ),
                if (appConfigurationStore.slotServiceStatus)
                  Container(
                    decoration: boxDecorationDefault(
                        color: context.scaffoldBackgroundColor,
                        borderRadius: radius()),
                    child: SettingItemWidget(
                      title: languages.timeSlotAvailable,
                      subTitle: languages.doesThisServicesContainsTimeslot,
                      trailing: Observer(builder: (context) {
                        return Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            activeTrackColor: primaryColor,
                            value: isTimeSlotAvailable,
                            onChanged: (v) async {
                              if (!v) {
                                isTimeSlotAvailable = v;
                                setState(() {});
                                return;
                              }
                              if (timeSlotStore.isTimeSlotAvailable) {
                                isTimeSlotAvailable = v;
                                setState(() {});
                              } else {
                                toast(languages
                                    .pleaseEnterTheDefaultTimeslotsFirst);
                                MyTimeSlotsScreen(isFromService: true)
                                    .launch(context)
                                    .then((value) {
                                  if (value != null) {
                                    if (value) {
                                      isTimeSlotAvailable = v;
                                      setState(() {});
                                    }
                                  }
                                });
                              }
                            },
                          ).visible(!timeSlotStore.isLoading,
                              defaultWidget: LoaderWidget(size: 26)),
                        );
                      }),
                    ),
                  ),
                if (isAdvancePaymentAllowedBySystem)
                  Container(
                    decoration: boxDecorationDefault(
                        color: context.scaffoldBackgroundColor,
                        borderRadius: radius()),
                    child: SettingItemWidget(
                      title: languages.enablePrePayment,
                      subTitle: languages.enablePrePaymentMessage,
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          activeTrackColor: primaryColor,
                          value: isAdvancePayment,
                          onChanged: (v) async {
                            isAdvancePayment = !isAdvancePayment;
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ),
                if (isAdvancePaymentAllowedBySystem && isAdvancePayment)
                  AppTextField(
                    textFieldType: TextFieldType.PHONE,
                    controller: prePayAmountController,
                    focus: prePayAmountFocus,
                    maxLength: 3,
                    errorThisFieldRequired: languages.hintRequired,
                    decoration: inputDecoration(
                      context,
                      hint: '${languages.advancePayAmountPer} (20-99)',
                      fillColor: context.scaffoldBackgroundColor,
                      counterText: '',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (s) {
                      if (s!.trim().isEmpty) return errorThisFieldRequired;
                      final v = int.tryParse(s.trim());
                      if (v == null) return languages.lblEnterValidNumber;
                      if (v < 20 || v > 99) return languages.lblAdvancePaymentRange;
                      return null;
                    },
                  ),
              ],
            ).paddingAll(16),
          ],
        ),
      ),
    );
  }

//endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setStatusBarColor(Colors.transparent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: appBarWidget(
        isUpdate ? languages.lblEditService : languages.hintAddService,
        textColor: white,
        color: Colors.transparent,
        elevation: 0.0,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: kAppPrimaryGradient)),
        backWidget: BackWidget(),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              8.height,
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      CustomImagePicker(
                        key: uniqueKey,
                        onRemoveClick: (value) {
                          if (tempAttachments.validate().isNotEmpty &&
                              imageFiles.isNotEmpty) {
                            showConfirmDialogCustom(
                              context,
                              dialogType: DialogType.DELETE,
                              positiveText: languages.lblDelete,
                              negativeText: languages.lblCancel,
                              onAccept: (p0) {
                                imageFiles.removeWhere(
                                    (element) => element.path == value);
                                if (value.startsWith('http')) {
                                  removeAttachment(
                                      id: tempAttachments
                                          .validate()
                                          .firstWhere(
                                              (element) => element.url == value)
                                          .id
                                          .validate());
                                }
                              },
                            );
                          } else {
                            showConfirmDialogCustom(
                              context,
                              dialogType: DialogType.DELETE,
                              positiveText: languages.lblDelete,
                              negativeText: languages.lblCancel,
                              onAccept: (p0) {
                                imageFiles.removeWhere(
                                    (element) => element.path == value);
                                if (isUpdate) {
                                  uniqueKey = UniqueKey();
                                }
                                setState(() {});
                              },
                            );
                          }
                        },
                        selectedImages: widget.data != null
                            ? imageFiles
                                .validate()
                                .map((e) => e.path.validate())
                                .toList()
                            : null,
                        onFileSelected: (List<File> files) async {
                          imageFiles = files;
                          setState(() {});
                        },
                      ),
                      buildFormWidget(),
                    ],
                  ).paddingOnly(left: 16.0, right: 16.0),
                ),
              ),
              Observer(
                builder: (_) => DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: appStore.isLoading
                        ? LinearGradient(
                            begin: kAppPrimaryGradient.begin,
                            end: kAppPrimaryGradient.end,
                            colors: kAppPrimaryGradientColors.map((c) => c.withValues(alpha: 0.5)).toList(),
                          )
                        : kAppPrimaryGradient,
                    borderRadius: radius(),
                  ),
                  child: AppButton(
                    margin: EdgeInsets.zero,
                    text: languages.lblPublish,
                    height: 40,
                    color: Colors.transparent,
                    textStyle: boldTextStyle(color: white),
                    width: context.width() - context.navigationBarHeight,
                    onTap: appStore.isLoading
                        ? () {}
                        : () {
                            checkValidation(isSave: true);
                          },
                  ),
                ),
              ).paddingSymmetric(horizontal: 16.0, vertical: 16.0),
            ],
          ),
          Observer(
              builder: (_) =>
                  LoaderWidget().center().visible(appStore.isLoading)),
        ],
      ),
    );
  }

  StaticDataModel get getServiceType => serviceType == SERVICE_TYPE_DAILY ? typeStaticData[2]
      : serviceType == SERVICE_TYPE_HOURLY ? typeStaticData[1]
      : typeStaticData[0];

  setHourByServiceType () {
    if(serviceType == SERVICE_TYPE_HOURLY) {
      durationContHr.text = '1';
      currentTime = TimeOfDay(
        hour: int.parse(durationContHr.text),
        minute: 0,
      );
    } else if(serviceType == SERVICE_TYPE_DAILY) {
      durationContHr.text = '8';
      currentTime = TimeOfDay(
        hour: int.parse(durationContHr.text),
        minute: 0,
      );
    } else {
      if(widget.data != null) {
        currentTime = TimeOfDay(
          hour: widget.data!.duration.validate().splitBefore(':').toInt(),
          minute: widget.data!.duration.validate().splitAfter(':').toInt(),
        );
        durationContHr.text = "${currentTime!.hour}";
        durationContMin.text = "${currentTime!.minute}";
      }else {
        durationContHr.text = '';
        currentTime = null;
      }
    }
  }
}
