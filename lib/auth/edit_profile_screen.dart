import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/city_list_response.dart';
import 'package:handyman_provider_flutter/models/country_list_response.dart';
import 'package:handyman_provider_flutter/models/service_address_response.dart';
import 'package:handyman_provider_flutter/models/state_list_response.dart';
import 'package:handyman_provider_flutter/networks/network_utils.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/language_options.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/add_reasons_component.dart';
import '../components/chat_gpt_loder.dart';
import '../models/user_update_response.dart';
import '../provider/jobRequest/models/post_job_data.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  File? imageFile;
  XFile? pickedFile;

  List<CountryListResponse> countryList = [];
  List<StateListResponse> stateList = [];
  List<CityListResponse> cityList = [];
  // Converted to simple text fields - keeping lists for backward compatibility during migration
  List<String> knownLanguages = [];
  List<String> mobility = [];
  List<String> experiences = [];
  List<String> certification = [];
  List<String> whyChooseMeReasons = [];
  List<String> skills = [];

  /// Selected language values for Known Languages multi-select (e.g. ['english', 'german']).
  List<String> selectedLanguages = [];

  /// Code → display name from [getSpokenLanguages], falling back to [kLanguageOptions] until loaded.
  Map<String, String> spokenLanguageOptions =
      Map<String, String>.from(kLanguageOptions);

  List<AddressResponse> serviceAddressList = [];
  AddressResponse? selectedAddress;

  CountryListResponse? selectedCountry;
  StateListResponse? selectedState;
  CityListResponse? selectedCity;

  CountryListResponse? selectedTaxCountry;
  int taxCountryId = 0;

  /// Blade: `''`, `full_time`, `part_time`
  static const Map<String, String> _profileAvailabilityOptions = {
    '': '—',
    'full_time': 'Full time',
    'part_time': 'Part time',
  };

  String selectedAvailability = 'full_time';

  /// Account status: `1` active, `0` inactive (`profile_form` + validation).
  int profileAccountStatus = 1;

  CareerLevel? selectedCareerLevel = CareerLevel.notSpecified;
  ProfileEducationLevel? selectedEducation = ProfileEducationLevel.unspecified;
  YearsOfExperience? selectedYearsOfExperience = YearsOfExperience.unspecified;

  TextEditingController fNameCont = TextEditingController();
  TextEditingController lNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController userNameCont = TextEditingController();
  TextEditingController mobileCont = TextEditingController();
  TextEditingController addressCont = TextEditingController();
  TextEditingController designationCont = TextEditingController();
  TextEditingController knownLangCont = TextEditingController();
  TextEditingController skillsCont = TextEditingController();
  TextEditingController aboutMeCont = TextEditingController();
  TextEditingController aboutDescriptionCont = TextEditingController();
  TextEditingController whyChooseMeCont = TextEditingController();
  TextEditingController cNameCont = TextEditingController();
  TextEditingController vatNumCont = TextEditingController();
  TextEditingController experienceCont = TextEditingController();
  TextEditingController mobilityCont = TextEditingController();
  TextEditingController certificationCont = TextEditingController();

  FocusNode fNameFocus = FocusNode();
  FocusNode lNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();
  FocusNode designationFocus = FocusNode();
  FocusNode knownLangFocus = FocusNode();
  FocusNode addressFocus = FocusNode();
  FocusNode skillsFocus = FocusNode();
  FocusNode aboutMeFocus = FocusNode();
  FocusNode aboutDescriptionFocus = FocusNode();
  FocusNode whyChooseMeFocus = FocusNode();
  FocusNode cNameFocus = FocusNode();
  FocusNode vatNumFocus = FocusNode();
  FocusNode experienceFocus = FocusNode();
  FocusNode mobilityFocus = FocusNode();
  FocusNode certificationFocus = FocusNode();

  ValueNotifier _valueNotifier = ValueNotifier(true);

  Country selectedCountryPicker = defaultCountry();

  int countryId = 0;
  int stateId = 0;
  int cityId = 0;
  int? serviceAddressId;

  bool isEmailVerified = getBoolAsync(IS_EMAIL_VERIFIED);

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    afterBuildCreated(() {
      setStatusBarColor(context.primaryColor);
      appStore.setLoading(true);
    });

    if (isUserTypeHandyman) await getAddressList();

    countryId = getIntAsync(COUNTRY_ID);
    stateId = getIntAsync(STATE_ID);
    cityId = getIntAsync(CITY_ID);
    fNameCont.text = appStore.userFirstName;
    lNameCont.text = appStore.userLastName;
    emailCont.text = appStore.userEmail;
    userNameCont.text = appStore.userName;
    mobileCont.text = appStore.userContactNumber.split("-").last.toString();
    countryId = appStore.countryId;
    stateId = appStore.stateId;
    cityId = appStore.cityId;
    addressCont.text = appStore.address;
    serviceAddressId = appStore.serviceAddressId;
    designationCont.text = appStore.designation;
    selectedCountryPicker = Country(
      phoneCode: appStore.userContactNumber.split("-").first.isEmpty
          ? "+91"
          : appStore.userContactNumber.split("-").first.toString(),
      countryCode: "",
      e164Sc: 0,
      geographic: true,
      level: 0,
      name: "",
      example: "",
      displayName: "",
      displayNameNoCountryCode: "",
      e164Key: "",
    );
    await _loadSpokenLanguageOptions();
    userDetailAPI();

    if (getIntAsync(COUNTRY_ID) != 0) {
      await getCountry();
      await getStates(getIntAsync(COUNTRY_ID));
      if (getIntAsync(STATE_ID) != 0) {
        await getCity(getIntAsync(STATE_ID));
      }

      setState(() {});
    } else {
      await getCountry();
    }
  }

  Future<void> _loadSpokenLanguageOptions() async {
    spokenLanguageOptions = Map<String, String>.from(kLanguageOptions);
    try {
      final res = await getSpokenLanguages();
      if (res.options.isNotEmpty) {
        spokenLanguageOptions = Map<String, String>.from(res.options);
      }
    } catch (e) {
      log(e.toString());
    }
    if (mounted) setState(() {});
  }

  /// Normalize API string to language code (key in [spokenLanguageOptions]).
  String _languageStringToValue(String s) {
    if (s.isEmpty) return '';
    String normalized = s.toLowerCase().trim();
    String withUnderscore = normalized.replaceAll(' ', '_');
    if (spokenLanguageOptions.containsKey(normalized)) return normalized;
    if (spokenLanguageOptions.containsKey(withUnderscore))
      return withUnderscore;
    for (var e in spokenLanguageOptions.entries) {
      if (e.value.toLowerCase() == s.toLowerCase()) return e.key;
    }
    return withUnderscore.isNotEmpty ? withUnderscore : normalized;
  }

  void _parsePlainLanguageString(String knownLanguagesStr) {
    List<String> parts = knownLanguagesStr
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    for (String part in parts) {
      String value = _languageStringToValue(part);
      if (value.isNotEmpty && !selectedLanguages.contains(value)) {
        selectedLanguages.add(value);
      }
    }
  }

  // Helper function to safely convert API values to string (handles both String and List)
  String _safeStringFromValue(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is List) {
      return value.map((e) => e.toString()).join(', ');
    }
    return value.toString();
  }

  Future<void> userDetailAPI() async {
    await getUserDetail(appStore.userId).then((value) async {
      isEmailVerified = value.data!.isEmailVerified.validate().getBoolInt();
      await setValue(IS_EMAIL_VERIFIED, isEmailVerified);

      // Load known languages - multi-select values (backend may send JSON array or plain string)
      String? knownLanguagesStr = value.data!.knownLanguages;
      selectedLanguages = [];
      if (knownLanguagesStr != null && knownLanguagesStr.isNotEmpty) {
        if (knownLanguagesStr.isJson()) {
          try {
            Iterable it = jsonDecode(knownLanguagesStr);
            for (var e in it) {
              String s = e.toString().trim();
              if (s.isEmpty) continue;
              String value = _languageStringToValue(s);
              if (value.isNotEmpty && !selectedLanguages.contains(value)) {
                selectedLanguages.add(value);
              }
            }
          } catch (_) {
            _parsePlainLanguageString(knownLanguagesStr);
          }
        } else {
          _parsePlainLanguageString(knownLanguagesStr);
        }
      }
      selectedLanguages
          .removeWhere((k) => !spokenLanguageOptions.containsKey(k));
      knownLanguages = List<String>.from(selectedLanguages);

      // Load skills - handle JSON string (from model) or plain string
      String? skillsStr = value.data!.skills;
      if (skillsStr != null && skillsStr.isNotEmpty) {
        if (skillsStr.isJson()) {
          try {
            Iterable it = jsonDecode(skillsStr);
            skillsCont.text = it.map((e) => e.toString()).join(', ');
          } catch (e) {
            skillsCont.text = skillsStr;
          }
        } else {
          skillsCont.text = skillsStr;
        }
      }

      // Load experience, mobility, certification as strings
      experienceCont.text = _safeStringFromValue(value.data!.experience);
      mobilityCont.text = _safeStringFromValue(value.data!.mobility);
      certificationCont.text = _safeStringFromValue(value.data!.certification);

      // Load career level, education, years of experience (dropdowns)
      if (value.data!.careerLevel != null &&
          value.data!.careerLevel!.isNotEmpty) {
        try {
          selectedCareerLevel = CareerLevel.values.firstWhere(
            (e) => e.backendValue == value.data!.careerLevel,
            orElse: () => CareerLevel.notSpecified,
          );
        } catch (_) {
          selectedCareerLevel = CareerLevel.notSpecified;
        }
      }
      String eduRaw = value.data!.education.validate();
      if (eduRaw == 'not_specified') eduRaw = '';
      if (eduRaw.isNotEmpty) {
        try {
          selectedEducation = ProfileEducationLevel.values.firstWhere(
            (e) => e.backendValue == eduRaw,
            orElse: () => ProfileEducationLevel.unspecified,
          );
        } catch (_) {
          selectedEducation = ProfileEducationLevel.unspecified;
        }
      } else {
        selectedEducation = ProfileEducationLevel.unspecified;
      }

      String yoeRaw = value.data!.yearsOfExperience.validate();
      if (yoeRaw.isNotEmpty) {
        try {
          selectedYearsOfExperience = YearsOfExperience.values.firstWhere(
            (e) => e.backendValue == yoeRaw,
            orElse: () => YearsOfExperience.unspecified,
          );
        } catch (_) {
          selectedYearsOfExperience = YearsOfExperience.unspecified;
        }
      } else {
        selectedYearsOfExperience = YearsOfExperience.unspecified;
      }

      final av = value.data!.availability
          .validate()
          .trim()
          .toLowerCase()
          .replaceAll(' ', '_');
      if (av == 'full_time' || av == 'part_time') {
        selectedAvailability = av;
      } else if (av == 'hybrid') {
        selectedAvailability = 'full_time';
      } else {
        selectedAvailability = '';
      }

      profileAccountStatus = value.data!.status == 0 ? 0 : 1;

      aboutMeCont.text = value.data!.aboutMe.validate();
      if (aboutMeCont.text.isEmpty) {
        aboutMeCont.text = value.data!.description.validate();
      }
      aboutDescriptionCont.text = value.data!.aboutDescription.validate();
      addressCont.text = value.data!.address.validate();

      taxCountryId = value.data!.taxCountryId ?? countryId;
      if (countryList.isNotEmpty && taxCountryId > 0) {
        selectedTaxCountry =
            countryList.where((e) => e.id == taxCountryId).firstOrNull;
      }

      // Load company name and VAT number
      cNameCont.text = _safeStringFromValue(value.data!.companyName);
      vatNumCont.text = _safeStringFromValue(value.data!.vatNumber);

      // Load why choose me - handle JSON object, direct string, or List
      if (value.data != null) {
        whyChooseMeReasons.clear();
        dynamic whyChooseMeData = value.data!.whyChooseMe;

        // First try the parsed object
        if (value.data!.whyChooseMeObj.reason.isNotEmpty) {
          whyChooseMeReasons.addAll(value.data!.whyChooseMeObj.reason);
        }
        if (value.data!.whyChooseMeObj.title.isNotEmpty) {
          whyChooseMeCont.text = value.data!.whyChooseMeObj.title;
        } else if (whyChooseMeData != null) {
          // Handle direct string (plain text)
          if (whyChooseMeData is String && whyChooseMeData.isNotEmpty) {
            // Check if it's JSON
            if (whyChooseMeData.isJson()) {
              try {
                Map<String, dynamic> whyChooseMeJson =
                    jsonDecode(whyChooseMeData);
                if (whyChooseMeJson['title'] != null) {
                  whyChooseMeCont.text = whyChooseMeJson['title'].toString();
                }
                if (whyChooseMeJson['reason'] != null &&
                    whyChooseMeJson['reason'] is List) {
                  whyChooseMeReasons.clear();
                  whyChooseMeReasons.addAll((whyChooseMeJson['reason'] as List)
                      .map((e) => e.toString())
                      .toList());
                }
                if (whyChooseMeJson['about_description'] != null &&
                    aboutDescriptionCont.text.isEmpty) {
                  aboutDescriptionCont.text =
                      whyChooseMeJson['about_description'].toString();
                }
              } catch (e) {
                // If JSON parsing fails, treat as plain text
                whyChooseMeCont.text = whyChooseMeData;
              }
            } else {
              // Plain text string
              whyChooseMeCont.text = whyChooseMeData;
            }
          }
        }
      }

      if (!mounted) return;
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  Future<void> getAddressList() async {
    await getAddresses(providerId: appStore.providerId).then((value) {
      serviceAddressList.addAll(value.addressResponse!);

      if (value.addressResponse
          .validate()
          .any((element) => element.id == getIntAsync(SERVICE_ADDRESS_ID))) {
        selectedAddress = value.addressResponse!.firstWhere(
            (element) => element.id == getIntAsync(SERVICE_ADDRESS_ID));
      }
      if (!mounted) return;
      setState(() {});
    }).catchError((e) {
      toast(e.toString(), print: true);
    });
    appStore.setLoading(false);
  }

  Future<void> getCountry() async {
    appStore.setLoading(true);
    await getCountryList().then((value) async {
      countryList.clear();
      countryList.addAll(value);

      if (value.any((element) => element.id == getIntAsync(COUNTRY_ID))) {
        selectedCountry = value
            .firstWhere((element) => element.id == getIntAsync(COUNTRY_ID));
        if (selectedTaxCountry == null) {
          selectedTaxCountry = selectedCountry;
          taxCountryId = selectedCountry?.id ?? getIntAsync(COUNTRY_ID);
        } else if (taxCountryId > 0 && value.any((e) => e.id == taxCountryId)) {
          selectedTaxCountry = value.firstWhere((e) => e.id == taxCountryId);
        }
      }
      if (!mounted) return;
      setState(() {});
    }).catchError((e) {
      toast('$e', print: true);
    });
    appStore.setLoading(false);
  }

  Future<void> getStates(int countryId) async {
    appStore.setLoading(true);
    await getStateList({'country_id': countryId}).then((value) async {
      stateList.clear();
      stateList.addAll(value);

      if (value.any((element) => element.id == getIntAsync(STATE_ID))) {
        selectedState =
            value.firstWhere((element) => element.id == getIntAsync(STATE_ID));
      }
      if (!mounted) return;
      setState(() {});
    }).catchError((e) {
      toast('$e', print: true);
    });
    appStore.setLoading(false);
  }

  Future<void> getCity(int stateId) async {
    appStore.setLoading(true);

    await getCityList({'state_id': stateId}).then((value) async {
      cityList.clear();
      cityList.addAll(value);

      if (value.any((element) => element.id == getIntAsync(CITY_ID))) {
        selectedCity =
            value.firstWhere((element) => element.id == getIntAsync(CITY_ID));
      }
      if (!mounted) return;
      setState(() {});
    }).catchError((e) {
      toast('$e', print: true);
    });
    appStore.setLoading(false);
  }

  Future<void> update() async {
    if (selectedLanguages.isEmpty) {
      toast(languages.pleaseAddKnownLanguage);
      return;
    }

    MultipartRequest multiPartRequest =
        await getMultiPartRequest('update-profile');
    multiPartRequest.fields['profile'] = 'profile';
    multiPartRequest.fields[UserKeys.id] = appStore.userId.toString();
    multiPartRequest.fields[UserKeys.firstName] = fNameCont.text;
    multiPartRequest.fields[UserKeys.lastName] = lNameCont.text;
    multiPartRequest.fields[UserKeys.userName] = userNameCont.text;
    multiPartRequest.fields[UserKeys.userType] = getStringAsync(USER_TYPE);
    multiPartRequest.fields[UserKeys.contactNumber] = mobileCont.text.isEmpty
        ? ''
        : selectedCountryPicker.phoneCode + "-" + mobileCont.text;
    multiPartRequest.fields[UserKeys.email] = emailCont.text;
    multiPartRequest.fields[CommonKeys.countryId] = countryId.toString();
    multiPartRequest.fields[CommonKeys.stateId] = stateId.toString();
    multiPartRequest.fields[CommonKeys.cityId] = cityId.toString();
    multiPartRequest.fields['tax_country_id'] = taxCountryId.toString();
    multiPartRequest.fields[CommonKeys.address] = addressCont.text.validate();
    if (isUserTypeProvider) {
      multiPartRequest.fields[UserKeys.designation] =
          designationCont.text.validate();
    }
    multiPartRequest.fields['company_name'] = cNameCont.text.trim();
    multiPartRequest.fields['vat_number'] = vatNumCont.text.trim();
    multiPartRequest.fields[UserKeys.knownLanguages] =
        jsonEncode(selectedLanguages);
    for (var i = 0; i < selectedLanguages.length; i++) {
      multiPartRequest.fields['languages[$i]'] = selectedLanguages[i];
    }

    if (skillsCont.text.trim().isNotEmpty) {
      multiPartRequest.fields[UserKeys.skills] = skillsCont.text.trim();
    }

    if (experienceCont.text.trim().isNotEmpty) {
      multiPartRequest.fields['experience'] = experienceCont.text.trim();
    }
    if (mobilityCont.text.trim().isNotEmpty) {
      multiPartRequest.fields['mobility'] = mobilityCont.text.trim();
    }
    if (certificationCont.text.trim().isNotEmpty) {
      multiPartRequest.fields['certification'] = certificationCont.text.trim();
    }
    multiPartRequest.fields['education'] = selectedEducation?.backendValue ??
        ProfileEducationLevel.unspecified.backendValue;
    multiPartRequest.fields['career_level'] =
        selectedCareerLevel?.backendValue ??
            CareerLevel.notSpecified.backendValue;
    multiPartRequest.fields['years_of_experience'] =
        selectedYearsOfExperience?.backendValue ??
            YearsOfExperience.unspecified.backendValue;
    multiPartRequest.fields['availability'] = selectedAvailability;
    multiPartRequest.fields[UserKeys.status] = profileAccountStatus.toString();

    multiPartRequest.fields['about_me'] = aboutMeCont.text.trim();
    multiPartRequest.fields[UserKeys.description] = aboutMeCont.text.validate();

    if (isUserTypeProvider) {
      multiPartRequest.fields[UserKeys.whyChooseTitle] =
          whyChooseMeCont.text.trim();
      multiPartRequest.fields['about_description'] =
          aboutDescriptionCont.text.trim();
      for (var i = 0; i < whyChooseMeReasons.length; i++) {
        multiPartRequest.fields['reason[$i]'] = whyChooseMeReasons[i];
      }
    }

    multiPartRequest.fields[UserKeys.displayName] =
        '${fNameCont.text.validate() + " " + lNameCont.text.validate()}';

    if (isUserTypeHandyman && serviceAddressId != null)
      multiPartRequest.fields[UserKeys.serviceAddressId] =
          serviceAddressId == 0 ? '' : serviceAddressId.toString();
    if (imageFile != null) {
      multiPartRequest.files.add(
          await MultipartFile.fromPath(UserKeys.profileImage, imageFile!.path));
    }

    multiPartRequest.headers.addAll(buildHeaderTokens());

    appStore.setLoading(true);

    sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        appStore.setLoading(false);
        if (!mounted) return;
        if (data != null) {
          if ((data as String).isJson()) {
            UserUpdateResponse res =
                UserUpdateResponse.fromJson(jsonDecode(data));

            if (FirebaseAuth.instance.currentUser != null) {
              userService.updateDocument({
                'profile_image': res.data!.profileImage.validate(),
                'updated_at': Timestamp.now().toDate().toString(),
              }, FirebaseAuth.instance.currentUser!.uid);
            }
            saveUserData(res.data!);
            toast(res.message.validate().capitalizeFirstLetter());
            if (mounted) finish(context);
          }
        }
      },
      onError: (error) {
        toast(error.toString(), print: true);
        appStore.setLoading(false);
      },
    ).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  Future<void> verifyEmail() async {
    appStore.setLoading(true);

    await verifyUserEmail(emailCont.text).then((value) async {
      isEmailVerified = value.isEmailVerified.validate().getBoolInt();

      toast(value.message);

      await setValue(IS_EMAIL_VERIFIED, isEmailVerified);
      if (!mounted) return;
      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      isEmailVerified = false;

      appStore.setLoading(false);

      toast(e.toString());
      if (mounted) setState(() {});
    });
  }

  void _getFromGallery() async {
    pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxWidth: 1800, maxHeight: 1800);
    if (pickedFile != null) {
      _showSelectionDialog(context);
    }
  }

  _getFromCamera() async {
    pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxWidth: 1800, maxHeight: 1800);
    if (pickedFile != null) {
      _showSelectionDialog(context);
    }
  }

  Future<void> _showSelectionDialog(BuildContext context) {
    return showConfirmDialogCustom(
      context,
      title: languages.confirmationRequestTxt,
      positiveText: languages.lblOk,
      negativeText: languages.lblNo,
      primaryColor: context.primaryColor,
      onAccept: (BuildContext context) async {
        imageFile = File(pickedFile!.path);
        if (mounted) setState(() {});
      },
      onCancel: (BuildContext context) {
        imageFile = null;
      },
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: context.cardColor,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SettingItemWidget(
              title: languages.lblGallery,
              leading: Icon(Icons.image, color: context.iconColor),
              onTap: () async {
                _getFromGallery();
                finish(context);
              },
            ),
            SettingItemWidget(
              title: languages.camera,
              leading: Icon(Icons.camera, color: context.iconColor),
              onTap: () {
                _getFromCamera();
                finish(context);
              },
            ),
          ],
        ).paddingAll(16.0);
      },
    );
  }

  void _showLanguageMultiSelect(BuildContext context) {
    List<String> tempSelected = List<String>.from(selectedLanguages);
    TextEditingController searchCont = TextEditingController();
    ValueNotifier<String> searchNotifier = ValueNotifier('');
    showModalBottomSheet<List<String>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardColor,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.3,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) => Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: searchCont,
                            textFieldType: TextFieldType.OTHER,
                            decoration: inputDecoration(context,
                                hint: languages.lblSearchLanguagesHint),
                            onChanged: (v) {
                              searchNotifier.value = v;
                            },
                          ),
                        ),
                        8.width,
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx)
                                .pop(List<String>.from(tempSelected));
                          },
                          child: Text(languages.done,
                              style: boldTextStyle(color: primaryColor)),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  Expanded(
                    child: ValueListenableBuilder<String>(
                      valueListenable: searchNotifier,
                      builder: (_, query, __) {
                        String q = query.toLowerCase().trim();
                        var entries = spokenLanguageOptions.entries
                            .where((e) =>
                                e.key.contains(q) ||
                                e.value.toLowerCase().contains(q))
                            .toList();
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: entries.length,
                          itemBuilder: (_, i) {
                            String value = entries[i].key;
                            String label = entries[i].value;
                            bool checked = tempSelected.contains(value);
                            return CheckboxListTile(
                              value: checked,
                              onChanged: (v) {
                                if (v == true) {
                                  if (!tempSelected.contains(value))
                                    tempSelected.add(value);
                                } else {
                                  tempSelected.remove(value);
                                }
                                setModalState(() {});
                              },
                              title: Text(label,
                                  style: primaryTextStyle(size: 14)),
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: primaryColor,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((List<String>? result) {
      final selected = result != null ? List<String>.from(result) : null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        searchCont.dispose();
        searchNotifier.dispose();
        if (selected != null && mounted) {
          selectedLanguages = selected;
          setState(() {});
        }
      });
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(languages.editProfile,
                style: boldTextStyle(color: white, size: APP_BAR_TEXT_SIZE)),
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: BackWidget(),
            flexibleSpace: Container(
                decoration: const BoxDecoration(gradient: kAppPrimaryGradient)),
          ),
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  return await userDetailAPI();
                },
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(languages.lblProfilePhoto, style: secondaryTextStyle()),
                        4.height,
                        Align(
                          child: Stack(
                            children: [
                              Container(
                                decoration: boxDecorationDefault(
                                  border: Border.all(
                                    color: context.scaffoldBackgroundColor,
                                    width: 4,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: imageFile != null
                                    ? Image.file(imageFile!,
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.cover)
                                        .cornerRadiusWithClipRRect(45)
                                    : Observer(
                                        builder: (_) => CachedImageWidget(
                                          url: appStore.userProfileImage,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          radius: 64,
                                        ),
                                      ),
                              ),
                              Positioned(
                                bottom: 4,
                                right: 2,
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: boxDecorationWithRoundedCorners(
                                    boxShape: BoxShape.circle,
                                    backgroundColor: primaryColor,
                                    border: Border.all(color: Colors.white),
                                  ),
                                  child: Icon(AntDesign.camera,
                                          color: Colors.white, size: 16)
                                      .paddingAll(4.0),
                                ).onTap(() async {
                                  _showBottomSheet(context);
                                }),
                              )
                            ],
                          ),
                        ),
                        16.height,
                        AppTextField(
                          textFieldType: TextFieldType.NAME,
                          controller: fNameCont,
                          focus: fNameFocus,
                          nextFocus: lNameFocus,
                          decoration: inputDecoration(context,
                              hint: languages.hintFirstNameTxt),
                          suffix: profile.iconImage(size: 10).paddingAll(14),
                        ),
                        16.height,
                        AppTextField(
                          textFieldType: TextFieldType.NAME,
                          controller: lNameCont,
                          focus: lNameFocus,
                          nextFocus: userNameFocus,
                          decoration: inputDecoration(context,
                              hint: languages.hintLastNameTxt),
                          suffix: profile.iconImage(size: 10).paddingAll(14),
                        ),
                        16.height,
                        Text(languages.knownLanguages,
                            style: secondaryTextStyle()),
                        8.height,
                        InkWell(
                          onTap: () => _showLanguageMultiSelect(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: context.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.dividerColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.language,
                                        size: 20, color: context.iconColor),
                                    8.width,
                                    Text(
                                      selectedLanguages.isEmpty
                                          ? 'Select languages'
                                          : '${selectedLanguages.length} selected',
                                      style: selectedLanguages.isEmpty
                                          ? secondaryTextStyle()
                                          : primaryTextStyle(size: 14),
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_drop_down,
                                        color: context.iconColor),
                                  ],
                                ),
                                if (selectedLanguages.isNotEmpty) ...[
                                  8.height,
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: selectedLanguages.map((value) {
                                      String label =
                                          spokenLanguageOptions[value] ?? value;
                                      return Chip(
                                        label: Text(label,
                                            style: primaryTextStyle(size: 12)),
                                        deleteIcon: Icon(Icons.close,
                                            size: 16, color: context.iconColor),
                                        onDeleted: () {
                                          selectedLanguages.remove(value);
                                          setState(() {});
                                        },
                                        backgroundColor:
                                            context.scaffoldBackgroundColor,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        16.height,
                        AppTextField(
                          textFieldType: TextFieldType.NAME,
                          controller: userNameCont,
                          focus: userNameFocus,
                          nextFocus: emailFocus,
                          enabled: false,
                          decoration: inputDecoration(context,
                              hint: languages.hintUserNameTxt),
                          suffix: profile.iconImage(size: 10).paddingAll(14),
                        ),
                        16.height,
                        Row(
                          children: [
                            DropdownButtonFormField<CountryListResponse>(
                              decoration: inputDecoration(context,
                                  hint: languages.selectCountry),
                              isExpanded: true,
                              menuMaxHeight: 300,
                              initialValue: selectedCountry,
                              dropdownColor: context.cardColor,
                              items: countryList.map((CountryListResponse e) {
                                return DropdownMenuItem<CountryListResponse>(
                                  value: e,
                                  child: Text(e.name!,
                                      style: primaryTextStyle(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (CountryListResponse? value) async {
                                countryId = value!.id!;
                                selectedCountry = value;
                                selectedTaxCountry = value;
                                taxCountryId = value.id!;
                                selectedState = null;
                                selectedCity = null;
                                setState(() {});

                                getStates(value.id!);
                              },
                            ).expand(),
                            8.width.visible(stateList.isNotEmpty),
                            if (stateList.isNotEmpty)
                              DropdownButtonFormField<StateListResponse>(
                                decoration: inputDecoration(context,
                                    hint: languages.selectState),
                                isExpanded: true,
                                dropdownColor: context.cardColor,
                                menuMaxHeight: 300,
                                initialValue: selectedState,
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
                        16.height,
                        DropdownButtonFormField<CountryListResponse>(
                          decoration: inputDecoration(context,
                              hint: 'Select Country tax'),
                          isExpanded: true,
                          menuMaxHeight: 300,
                          initialValue: selectedTaxCountry,
                          dropdownColor: context.cardColor,
                          items: countryList.map((CountryListResponse e) {
                            return DropdownMenuItem<CountryListResponse>(
                              value: e,
                              child: Text(e.name!,
                                  style: primaryTextStyle(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: null,
                        ),
                        16.height,
                        if (cityList.isNotEmpty)
                          Column(
                            children: [
                              DropdownButtonFormField<CityListResponse>(
                                decoration: inputDecoration(context),
                                hint: Text(languages.selectCity,
                                    style: primaryTextStyle()),
                                isExpanded: true,
                                menuMaxHeight: 400,
                                initialValue: selectedCity,
                                dropdownColor: context.cardColor,
                                items: cityList.map(
                                  (CityListResponse e) {
                                    return DropdownMenuItem<CityListResponse>(
                                      value: e,
                                      child: Text(e.name!,
                                          style: primaryTextStyle(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                    );
                                  },
                                ).toList(),
                                onChanged: (CityListResponse? value) async {
                                  selectedCity = value;
                                  cityId = value!.id!;

                                  setState(() {});
                                },
                              ),
                              16.height,
                            ],
                          ),
                        if (isUserTypeHandyman && serviceAddressList.isNotEmpty)
                          DropdownButtonFormField<AddressResponse>(
                            decoration: inputDecoration(context,
                                hint: languages.lblSelectAddress),
                            isExpanded: true,
                            initialValue: selectedAddress != null
                                ? selectedAddress
                                : null,
                            dropdownColor: context.cardColor,
                            items:
                                serviceAddressList.map((AddressResponse data) {
                              return DropdownMenuItem<AddressResponse>(
                                value: data,
                                child: Text(data.address.validate(),
                                    style: primaryTextStyle()),
                              );
                            }).toList(),
                            onChanged: (AddressResponse? value) async {
                              selectedAddress = value;
                              serviceAddressId = selectedAddress!.id.validate();
                              setState(() {});
                            },
                          ).paddingTop(16),
                        if (isUserTypeHandyman && serviceAddressList.isNotEmpty)
                          16.height,
                        AppTextField(
                          textFieldType: TextFieldType.EMAIL_ENHANCED,
                          controller: emailCont,
                          focus: emailFocus,
                          nextFocus: mobileFocus,
                          decoration: inputDecoration(context,
                              hint: languages.hintEmailAddressTxt),
                          suffix: ic_message.iconImage(size: 10).paddingAll(14),
                          onFieldSubmitted: (email) async {
                            if (emailCont.text.isNotEmpty) await verifyEmail();
                          },
                        ),
                        16.height,
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Wrap(
                            spacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                isEmailVerified.validate()
                                    ? languages.verified
                                    : languages.verifyEmail,
                                style: isEmailVerified.validate()
                                    ? secondaryTextStyle(color: Colors.green)
                                    : secondaryTextStyle(),
                              ),
                              if (!isEmailVerified.validate())
                                ic_pending.iconImage(
                                    color: Colors.amber, size: 14)
                              else
                                Icon(
                                  isEmailVerified.validate()
                                      ? Icons.check_circle
                                      : Icons.refresh,
                                  color: isEmailVerified.validate()
                                      ? Colors.green
                                      : Colors.grey,
                                  size: 16,
                                )
                            ],
                          ).paddingSymmetric(horizontal: 6).onTap(
                            () {
                              verifyEmail();
                            },
                            borderRadius: radius(),
                          ),
                        ).paddingSymmetric(vertical: 6),
                        10.height,
                        AppTextField(
                          textFieldType: TextFieldType.NAME,
                          controller: cNameCont,
                          focus: cNameFocus,
                          decoration:
                              inputDecoration(context, hint: 'Company Name'),
                        ),
                        16.height,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 48.0,
                              decoration: BoxDecoration(
                                color: context.cardColor,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Center(
                                child: ValueListenableBuilder(
                                  valueListenable: _valueNotifier,
                                  builder: (context, value, child) => Row(
                                    children: [
                                      Text(
                                        "+${selectedCountryPicker.phoneCode}",
                                        style: primaryTextStyle(size: 12),
                                      ).paddingOnly(left: 8),
                                      Icon(Icons.arrow_drop_down)
                                    ],
                                  ),
                                ),
                              ),
                            ).onTap(() => changeCountry()),
                            10.width,
                            AppTextField(
                              textFieldType: isAndroid
                                  ? TextFieldType.PHONE
                                  : TextFieldType.NAME,
                              controller: mobileCont,
                              focus: mobileFocus,
                              decoration: inputDecoration(context,
                                      hint: languages.hintContactNumberTxt)
                                  .copyWith(
                                hintStyle: secondaryTextStyle(),
                              ),
                              suffix:
                                  calling.iconImage(size: 10).paddingAll(14),
                              maxLength: 15,
                            ).expand(),
                          ],
                        ),
                        16.height,
                        DropdownButtonFormField<int>(
                          decoration:
                              inputDecoration(context, hint: 'Account status'),
                          isExpanded: true,
                          initialValue: profileAccountStatus,
                          dropdownColor: context.cardColor,
                          items: [
                            DropdownMenuItem(
                              value: 1,
                              child: Text(languages.active,
                                  style: primaryTextStyle(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            DropdownMenuItem(
                              value: 0,
                              child: Text(languages.inactive,
                                  style: primaryTextStyle(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                          onChanged: (int? value) async {
                            hideKeyboard(context);
                            profileAccountStatus = value ?? 1;
                            setState(() {});
                          },
                        ),
                        16.height,
                        AppTextField(
                          textFieldType: TextFieldType.NUMBER,
                          controller: vatNumCont,
                          focus: vatNumFocus,
                          nextFocus:
                              isUserTypeProvider ? designationFocus : null,
                          decoration:
                              inputDecoration(context, hint: 'VAT Number'),
                        ),
                        16.height,
                        if (isUserTypeProvider)
                          AppTextField(
                            textFieldType: TextFieldType.NAME,
                            controller: designationCont,
                            isValidationRequired: false,
                            focus: designationFocus,
                            decoration: inputDecoration(context,
                                hint: languages.lblDesignation),
                          ),
                        if (isUserTypeProvider) 16.height,
                        AppTextField(
                          textFieldType: TextFieldType.NAME,
                          controller: skillsCont,
                          focus: skillsFocus,
                          nextFocus: null,
                          decoration: inputDecoration(context,
                              hint: languages.essentialSkills +
                                  ' (comma-separated)'),
                          suffix: Icon(Icons.work,
                                  size: 18, color: context.iconColor)
                              .paddingAll(14),
                        ),
                        16.height,
                        DropdownButtonFormField<ProfileEducationLevel>(
                          decoration: inputDecoration(context,
                              hint: languages.lblEducationHint,
                              fillColor: context.scaffoldBackgroundColor),
                          isExpanded: true,
                          initialValue: selectedEducation,
                          dropdownColor: context.cardColor,
                          menuMaxHeight: 300,
                          items: ProfileEducationLevel.values
                              .map((ProfileEducationLevel level) {
                            return DropdownMenuItem<ProfileEducationLevel>(
                              value: level,
                              child: Text(
                                level.displayName,
                                style: primaryTextStyle(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (ProfileEducationLevel? value) {
                            selectedEducation = value;
                            setState(() {});
                          },
                        ),
                        16.height,
                        DropdownButtonFormField<CareerLevel>(
                          decoration: inputDecoration(context,
                              hint: languages.lblCareerLevelHint,
                              fillColor: context.scaffoldBackgroundColor),
                          isExpanded: true,
                          initialValue: selectedCareerLevel,
                          dropdownColor: context.cardColor,
                          menuMaxHeight: 300,
                          items: CareerLevel.values.map((CareerLevel level) {
                            return DropdownMenuItem<CareerLevel>(
                              value: level,
                              child: Text(
                                level.displayName,
                                style: primaryTextStyle(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (CareerLevel? value) {
                            selectedCareerLevel = value;
                            setState(() {});
                          },
                        ),
                        16.height,
                        DropdownButtonFormField<YearsOfExperience>(
                          decoration: inputDecoration(context,
                              hint: languages.lblYearsOfExperienceHint,
                              fillColor: context.scaffoldBackgroundColor),
                          isExpanded: true,
                          initialValue: selectedYearsOfExperience,
                          dropdownColor: context.cardColor,
                          menuMaxHeight: 300,
                          items: YearsOfExperience.values
                              .map((YearsOfExperience val) {
                            return DropdownMenuItem<YearsOfExperience>(
                              value: val,
                              child: Text(
                                val.displayName,
                                style: primaryTextStyle(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (YearsOfExperience? value) {
                            selectedYearsOfExperience = value;
                            setState(() {});
                          },
                        ),
                        16.height,
                        AppTextField(
                          textFieldType: TextFieldType.NAME,
                          controller: certificationCont,
                          focus: certificationFocus,
                          nextFocus: aboutMeFocus,
                          decoration: inputDecoration(context,
                              hint: 'Certification (comma-separated)'),
                          suffix: Icon(Icons.verified,
                                  size: 18, color: context.iconColor)
                              .paddingAll(14),
                        ),
                        16.height,
                        DropdownButtonFormField<String>(
                          decoration:
                              inputDecoration(context, hint: 'Availability'),
                          isExpanded: true,
                          initialValue: _profileAvailabilityOptions
                                  .containsKey(selectedAvailability)
                              ? selectedAvailability
                              : '',
                          dropdownColor: context.cardColor,
                          items: _profileAvailabilityOptions.entries.map((e) {
                            return DropdownMenuItem<String>(
                              value: e.key,
                              child: Text(
                                e.value,
                                style: primaryTextStyle(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) async {
                            hideKeyboard(context);
                            selectedAvailability = value ?? '';
                            setState(() {});
                          },
                        ),
                        16.height,
                        AppTextField(
                          textFieldType: TextFieldType.NAME,
                          controller: mobilityCont,
                          focus: mobilityFocus,
                          nextFocus: experienceFocus,
                          decoration: inputDecoration(context,
                              hint:
                                  'Mobility (e.g., Car, Bike, Public Transport)'),
                          suffix: Icon(Icons.directions_car,
                                  size: 18, color: context.iconColor)
                              .paddingAll(14),
                        ),
                        16.height,
                        AppTextField(
                          textFieldType: TextFieldType.MULTILINE,
                          controller: experienceCont,
                          focus: experienceFocus,
                          nextFocus: aboutMeFocus,
                          minLines: 3,
                          maxLines: 5,
                          decoration: inputDecoration(context,
                              hint:
                                  'Experience (describe your work experience)'),
                          suffix: Icon(Icons.business_center,
                                  size: 18, color: context.iconColor)
                              .paddingAll(14),
                        ),
                        16.height,
                        AppTextField(
                          controller: aboutMeCont,
                          textFieldType: TextFieldType.MULTILINE,
                          maxLines: 5,
                          minLines: 3,
                          focus: aboutMeFocus,
                          nextFocus: addressFocus,
                          enableChatGPT: appConfigurationStore.chatGPTStatus,
                          promptFieldInputDecorationChatGPT:
                              inputDecoration(context).copyWith(
                            hintText: languages.writeHere,
                            fillColor: context.scaffoldBackgroundColor,
                            filled: true,
                          ),
                          testWithoutKeyChatGPT:
                              appConfigurationStore.testWithoutKey,
                          loaderWidgetForChatGPT: const ChatGPTLoadingWidget(),
                          decoration:
                              inputDecoration(context, hint: languages.lblAboutMeHint),
                          isValidationRequired: false,
                        ),
                        16.height,
                        AppTextField(
                          controller: addressCont,
                          textFieldType: TextFieldType.MULTILINE,
                          maxLines: 5,
                          focus: addressFocus,
                          minLines: 3,
                          nextFocus:
                              isUserTypeProvider ? whyChooseMeFocus : null,
                          decoration: inputDecoration(context,
                              hint: languages.hintAddress),
                        ),
                        16.height,
                        if (isUserTypeProvider) ...[
                          AppTextField(
                            controller: whyChooseMeCont,
                            textFieldType: TextFieldType.NAME,
                            maxLines: 3,
                            focus: whyChooseMeFocus,
                            minLines: 2,
                            maxLength: 120,
                            nextFocus: aboutDescriptionFocus,
                            enableChatGPT: appConfigurationStore.chatGPTStatus,
                            promptFieldInputDecorationChatGPT:
                                inputDecoration(context).copyWith(
                              hintText: languages.writeHere,
                              fillColor: context.scaffoldBackgroundColor,
                              filled: true,
                            ),
                            testWithoutKeyChatGPT:
                                appConfigurationStore.testWithoutKey,
                            loaderWidgetForChatGPT:
                                const ChatGPTLoadingWidget(),
                            decoration: inputDecoration(context,
                                hint: languages.writeShortLineAbout),
                            isValidationRequired: false,
                          ),
                          16.height,
                          AppTextField(
                            controller: aboutDescriptionCont,
                            textFieldType: TextFieldType.MULTILINE,
                            maxLines: 8,
                            minLines: 4,
                            focus: aboutDescriptionFocus,
                            enableChatGPT: appConfigurationStore.chatGPTStatus,
                            promptFieldInputDecorationChatGPT:
                                inputDecoration(context).copyWith(
                              hintText: languages.writeHere,
                              fillColor: context.scaffoldBackgroundColor,
                              filled: true,
                            ),
                            testWithoutKeyChatGPT:
                                appConfigurationStore.testWithoutKey,
                            loaderWidgetForChatGPT:
                                const ChatGPTLoadingWidget(),
                            decoration: inputDecoration(context,
                                hint:
                                    'About description (why choose me — rich text)'),
                            isValidationRequired: false,
                          ),
                          16.height,
                          Text(languages.reasonsToChooseYour,
                              style: secondaryTextStyle()),
                          8.height,
                          Wrap(
                            children: whyChooseMeReasons.map((e) {
                              return Stack(
                                children: [
                                  Container(
                                    decoration: boxDecorationWithRoundedCorners(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(16)),
                                      backgroundColor: appStore.isDarkMode
                                          ? cardDarkColor
                                          : primaryColor.withValues(alpha: 0.1),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    margin: EdgeInsets.all(4),
                                    child: Text(e, style: primaryTextStyle()),
                                  ),
                                  Positioned(
                                    right: 1,
                                    child: Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ).onTap(() {
                                      whyChooseMeReasons.remove(e);
                                      setState(() {});
                                    }),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                          TextButton(
                            onPressed: () async {
                              String? res = await showInDialog(
                                context,
                                contentPadding: EdgeInsets.zero,
                                builder: (p0) {
                                  return AddReasonsComponent();
                                },
                              );

                              if (res != null) {
                                whyChooseMeReasons.add(res.trim());
                                setState(() {});
                              }
                            },
                            child: Text(languages.addReasons,
                                style: primaryTextStyle(
                                    color: context.primaryColor)),
                          ),
                        ],
                        28.height,
                        Observer(
                          builder: (context) => DecoratedBox(
                            decoration: BoxDecoration(
                                gradient: kAppPrimaryGradient,
                                borderRadius: radius(8)),
                            child: AppButton(
                              text: languages.saveChanges,
                              height: 40,
                              color: Colors.transparent,
                              elevation: 0,
                              textStyle: boldTextStyle(color: white),
                              width:
                                  context.width() - context.navigationBarHeight,
                              onTap: appStore.isLoading
                                  ? null
                                  : () {
                                      ifNotTester(context, () {
                                        update();
                                      });
                                    },
                            ),
                          ),
                        ),
                        24.height,
                      ],
                    ),
                  ),
                ),
              ),
              Observer(
                  builder: (_) =>
                      LoaderWidget().center().visible(appStore.isLoading)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> changeCountry() async {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        textStyle: secondaryTextStyle(color: textSecondaryColorGlobal),
        searchTextStyle: primaryTextStyle(),
        inputDecoration: InputDecoration(
          labelText: languages.search,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withValues(alpha: 0.2),
            ),
          ),
        ),
      ),
      showPhoneCode:
          true, // optional. Shows phone code before the country name.
      onSelect: (Country country) {
        selectedCountryPicker = country;
        _valueNotifier.value = !_valueNotifier.value;
      },
    );
  }
}
