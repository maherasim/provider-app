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
import 'package:nb_utils/nb_utils.dart';
import '../../components/chat_gpt_loder.dart';
import '../../models/multi_language_request_model.dart';
import '../../models/static_data_model.dart';

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
      title: 'Hybrid',
      key: VISIT_OPTION_HYBRID,
    ),
    VisitTypeData(
        isEnabled: false,
        title: languages.onSiteVisit,
        key: VISIT_OPTION_ON_SITE),
    if (appConfigurationStore.digitalServiceStatus)
      VisitTypeData(
          isEnabled: false,
          title: languages.onlineRemoteService,
          key: VISIT_OPTION_ONLINE),
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
      countryId = widget.data!.countryId.validate();
      stateId = widget.data!.stateId.validate();
      cityId = widget.data!.cityId.validate();
      minBookingCont.text = widget.data!.minimumBookings.validate();
      cancellationPolicyCont.text = widget.data!.cancellationPolicy.validate();
      tempAttachments = widget.data!.attchments.validate();
      imageFiles = widget.data!.attchments
          .validate()
          .map((e) => File(e.url.toString()))
          .toList();
      serviceNameCont.text =
          widget.data?.translations?[DEFAULT_LANGUAGE]?.name.validate() ?? "";
      priceCont.text = widget.data!.price.toString().validate();
      discountCont.text = widget.data!.discount.toString().validate();
      descriptionCont.text = widget.data?.translations?[DEFAULT_LANGUAGE]?.description.validate() ?? "";
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
      if (widget.data!.advancePaymentAmount != null) {
        prePayAmountController.text =
            widget.data!.advancePaymentAmount.validate().toString();
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
    }

   
    await getCountryStateCityData();
    setState(() {});
    await timeSlotStore.timeSlotForProvider();
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

      if (value.any((element) => element.id == stateId)) {
        selectedState =
            value.firstWhere((element) => element.id == stateId);
      }
      setState(() {});
    }).catchError((e) {
      toast('$e', print: true);
    });
    appStore.setLoading(false);
  }

  Future<void> getCity(int stateId) async {
    appStore.setLoading(true);

    await getUpdatedCityList(stateId).then((value) async {
      cityList.clear();
      cityList.addAll(value);

      if (value.any((element) => element.id == cityId)) {
        selectedCity =
            value.firstWhere((element) => element.id == cityId);
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
      AddServiceKey.providerId: appStore.userId.validate(),
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
      AddServiceKey.cancellationPolicy: countryId.toString(),
      AddServiceKey.minBooking: minBookingCont.text.validate(),
      AddServiceKey.cancellationPolicy: cancellationPolicyCont.text.validate(),
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
      await addServiceMultiPart(
        value: req,
        serviceAddressList: serviceAddressList,
        imageFile: imageFiles
            .where((element) => !element.path.contains('http'))
            .toList(),
      );
    } catch (e) {
      toast(e.toString());
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
    final bool isAdmin = false;
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
                      value: selectedState,
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
                  value: selectedCity,
                  dropdownColor: context.cardColor,
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
                      hint: languages.advancePayAmountPer,
                      fillColor: context.scaffoldBackgroundColor,
                      counterText: '',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (s) {
                      if (s!.isEmpty) return errorThisFieldRequired;

                      if (s.toInt() <= 0 || s.toInt() >= 100)
                        return languages.valueConditionMessage;
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
        color: context.primaryColor,
        backWidget: BackWidget(),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              8.height,
              MultiLanguageWidget(onTap: (LanguageDataModel code) {
                log("langaugeCode ==> ${code.languageCode}");
                checkValidation(isSave: false, code: code);
              }),
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
                builder: (_) => AppButton(
                  margin: EdgeInsets.only(bottom: 12),
                  text: languages.btnSave,
                  height: 40,
                  color: appStore.isLoading
                      ? primaryColor.withValues(alpha: 0.5)
                      : primaryColor,
                  textStyle: boldTextStyle(color: white),
                  width: context.width() - context.navigationBarHeight,
                  onTap: appStore.isLoading
                      ? () {}
                      : () {
                          checkValidation(isSave: true);
                        },
                ),
              ).paddingOnly(left: 16.0, right: 16.0),
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
