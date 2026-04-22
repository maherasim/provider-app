import 'dart:convert';
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/custom_image_picker.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/city_list_response.dart';
import 'package:handyman_provider_flutter/models/country_list_response.dart';
import 'package:handyman_provider_flutter/models/service_address_response.dart';
import 'package:handyman_provider_flutter/models/state_list_response.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/models/user_type_response.dart';
import 'package:handyman_provider_flutter/networks/network_utils.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:nb_utils/nb_utils.dart';

import '../provider/earning/handyman_payout_list_screen.dart';
import 'add_reasons_component.dart';

class HandymanAddUpdateScreen extends StatefulWidget {
  final String? userType;
  final UserData? data;
  final Function? onUpdate;

  HandymanAddUpdateScreen({this.userType, this.data, this.onUpdate});

  @override
  HandymanAddUpdateScreenState createState() => HandymanAddUpdateScreenState();
}

class HandymanAddUpdateScreenState extends State<HandymanAddUpdateScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController fNameCont = TextEditingController();
  TextEditingController lNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController userNameCont = TextEditingController();
  TextEditingController mobileCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController cPasswordCont = TextEditingController();
  TextEditingController designationCont = TextEditingController();
  TextEditingController addressCont = TextEditingController();
  TextEditingController educationCont = TextEditingController();
  // New fields from documentation
  TextEditingController companyNameCont = TextEditingController();
  TextEditingController vatNumberCont = TextEditingController();
  TextEditingController aboutMeCont = TextEditingController();
  TextEditingController skillsCont = TextEditingController();
  TextEditingController certificationCont = TextEditingController();
  TextEditingController mobilityCont = TextEditingController();
  TextEditingController experienceCont = TextEditingController();
  TextEditingController handymanCommissionCont = TextEditingController();

  FocusNode fNameFocus = FocusNode();
  FocusNode lNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode addressFocus = FocusNode();
  FocusNode cPasswordFocus = FocusNode();
  FocusNode designationFocus = FocusNode();
  FocusNode educationFocus = FocusNode();
  FocusNode companyNameFocus = FocusNode();
  FocusNode vatNumberFocus = FocusNode();
  FocusNode aboutMeFocus = FocusNode();
  FocusNode skillsFocus = FocusNode();
  FocusNode certificationFocus = FocusNode();
  FocusNode mobilityFocus = FocusNode();
  FocusNode experienceFocus = FocusNode();
  FocusNode handymanCommissionFocus = FocusNode();

  ValueNotifier _valueNotifier = ValueNotifier(true);

  Country selectedCountry = defaultCountry();

  // Languages - changed to multi-select dropdown
  final List<String> languageOptions = ['English', 'French', 'Chinese', 'Urdu', 'Spanish', 'German'];
  List<String> selectedLanguages = [];
  
  // Skills, Certification, Mobility - changed to text inputs (keeping lists for backward compatibility during migration)
  final List<String> skills = [];
  final List<String> experiences = [];
  final List<String> availabilityList = [
    'full_time', // Changed to match documentation
    'part_time',
  ];
  String selectedAvailability = 'full_time';
  final List<String> mobilityList = [];
  final List<String> certifications = [];
  
  // Profile image
  File? profileImageFile;
  
  // Country/State/City dropdowns
  List<CountryListResponse> countryList = [];
  List<StateListResponse> stateList = [];
  List<CityListResponse> cityList = [];
  CountryListResponse? selectedCountryData;
  StateListResponse? selectedState;
  CityListResponse? selectedCity;
  int? countryId;
  int? stateId;
  int? cityId;
  
  // Provider dropdown (for admin)
  List<UserData> providerList = [];
  UserData? selectedProvider;
  int? providerId;
  
  // Status dropdown
  String selectedStatus = '1'; // 1 = Active, 0 = Inactive

  List<AddressResponse> serviceAddressList = [];
  AddressResponse? selectedServiceAddress;

  List<UserTypeData> commissionList = [
    UserTypeData(name: languages.lblSelectCommission, id: -1)
  ];
  UserTypeData? selectedHandymanCommission;

  int? serviceAddressId;
  int? commissionId;

  bool isUpdate = false;

  @override
  void initState() {
    super.initState();

    if (widget.data != null) {
      isUpdate = true;
      fNameCont.text = widget.data!.firstName.validate();
      lNameCont.text = widget.data!.lastName.validate();
      emailCont.text = widget.data!.email.validate();
      userNameCont.text = widget.data!.username.validate();
      mobileCont.text =
          widget.data!.contactNumber?.split("-").last.validate() ?? "";
      serviceAddressId = widget.data!.serviceAddressId.validate();
      commissionId = widget.data!.handymanCommissionId.validate();
      designationCont.text = widget.data!.designation.validate();
      addressCont.text = parseHtmlString(widget.data!.address.validate());
      
      // Initialize new fields
      companyNameCont.text = widget.data!.companyName.validate();
      vatNumberCont.text = widget.data!.vatNumber.validate();
      
      // Handle skills - might be JSON array or plain text
      if (widget.data!.skills != null && widget.data!.skills!.isNotEmpty) {
        try {
          if (widget.data!.skills!.isJson()) {
            // If it's JSON, try to parse and join
            List<String> skillsList = widget.data!.skillsArray;
            skillsCont.text = skillsList.join(', ');
          } else {
            skillsCont.text = widget.data!.skills.validate();
          }
        } catch (e) {
          skillsCont.text = widget.data!.skills.validate();
        }
      }
      
      experienceCont.text = parseHtmlString(widget.data!.experience.validate());
      mobilityCont.text = widget.data!.mobility.validate();
      certificationCont.text = widget.data!.certification.validate();
      aboutMeCont.text = parseHtmlString(widget.data!.aboutMe.validate());
      educationCont.text = parseHtmlString(widget.data!.education.validate()); // Use education field directly
      
      // Initialize availability - normalize the value to match dropdown items
      if (widget.data!.availability != null) {
        String availabilityValue = widget.data!.availability.validate().toLowerCase();
        // Normalize: convert "Full-time", "full-time", "full_time" to "full_time"
        // and "Part-time", "part-time", "part_time" to "part_time"
        if (availabilityValue.contains('full') || availabilityValue == 'full_time') {
          selectedAvailability = 'full_time';
        } else if (availabilityValue.contains('part') || availabilityValue == 'part_time') {
          selectedAvailability = 'part_time';
        } else {
          // Default to full_time if value doesn't match
          selectedAvailability = 'full_time';
        }
      } else if (widget.data!.isHandymanAvailable != null) {
        selectedAvailability = widget.data!.isHandymanAvailable == true ? 'full_time' : 'part_time';
      }
      
      // Initialize status
      selectedStatus = widget.data!.status == 1 ? '1' : '0';
      
      // Initialize languages - check both languagesArray and knownLanguagesArray
      if (widget.data!.languagesArray != null && widget.data!.languagesArray!.isNotEmpty) {
        selectedLanguages = List<String>.from(widget.data!.languagesArray!);
      } else if (widget.data!.knownLanguages != null && widget.data!.knownLanguages!.isNotEmpty) {
        try {
          selectedLanguages = widget.data!.knownLanguagesArray;
        } catch (e) {
          selectedLanguages = [];
        }
      }
      
      // Initialize handyman commission
      if (widget.data!.handymanCommission != null) {
        handymanCommissionCont.text = widget.data!.handymanCommission.toString();
      }
      
      // Initialize country, state, city
      countryId = widget.data!.countryId;
      stateId = widget.data!.stateId;
      cityId = widget.data!.cityId;
      
      // Initialize provider (if admin)
      if (_isAdminUser() && widget.data!.providerId != null) {
        providerId = widget.data!.providerId;
      }
      
      // Initialize country code from contact number
      String? phoneCodeFromContact = "";
      if (widget.data!.contactNumber != null && widget.data!.contactNumber!.contains("-")) {
        phoneCodeFromContact = widget.data!.contactNumber!.split("-").first.trim();
      }
      
      selectedCountry = Country(
        phoneCode: phoneCodeFromContact.isNotEmpty ? phoneCodeFromContact : defaultCountry().phoneCode,
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
    }

    init();
    afterBuildCreated(() {
      appStore.setLoading(true);
    });
  }

  Future<void> init() async {
    getAddressList();
    getCommissionList();
    getCountryList();
    if (_isAdminUser()) {
      loadProviderList();
    }
  }
  
  bool _isAdminUser() {
    return appStore.userType == 'admin' || appStore.userType == 'demo_admin';
  }
  
  Future<void> getCountryList() async {
    appStore.setLoading(true);
    await getUpdatedCountryList().then((value) {
      countryList = value;
      if (widget.data != null && widget.data!.countryId != null) {
        selectedCountryData = value.firstWhere(
          (e) => e.id == widget.data!.countryId,
          orElse: () => value.first,
        );
        countryId = selectedCountryData?.id;
        if (countryId != null) {
          getStates(countryId!);
        }
      }
      setState(() {});
    }).catchError((e) {
      toast(e.toString());
    });
    appStore.setLoading(false);
  }
  
  Future<void> getStates(int countryId) async {
    appStore.setLoading(true);
    await getUpdatedStateList(countryId).then((value) {
      stateList = value;
      if (widget.data != null && widget.data!.stateId != null) {
        if (value.isNotEmpty) {
          selectedState = value.firstWhere(
            (e) => e.id == widget.data!.stateId,
            orElse: () => value.first,
          );
        }
        stateId = selectedState?.id;
        if (stateId != null) {
          getCity(stateId!);
        }
      }
      setState(() {});
    }).catchError((e) {
      toast(e.toString());
    });
    appStore.setLoading(false);
  }
  
  Future<void> getCity(int stateId) async {
    appStore.setLoading(true);
    await getUpdatedCityList(stateId).then((value) {
      cityList = value;
      if (widget.data != null && widget.data!.cityId != null) {
        if (value.isNotEmpty) {
          selectedCity = value.firstWhere(
            (e) => e.id == widget.data!.cityId,
            orElse: () => value.first,
          );
        }
        cityId = selectedCity?.id;
      }
      setState(() {});
    }).catchError((e) {
      toast(e.toString());
    });
    appStore.setLoading(false);
  }
  
  Future<void> loadProviderList() async {
    appStore.setLoading(true);
    List<UserData> tempList = [];
    await getProviderList(
      perPage: 100,
      page: 1,
      keyword: '',
      status: '',
      list: tempList,
    ).then((value) {
      providerList = tempList;
      if (widget.data != null && widget.data!.providerId != null) {
        selectedProvider = providerList.firstWhere(
          (e) => e.id == widget.data!.providerId,
          orElse: () => providerList.isNotEmpty ? providerList.first : UserData(),
        );
        providerId = selectedProvider?.id;
      }
      setState(() {});
    }).catchError((e) {
      toast(e.toString());
    });
    appStore.setLoading(false);
  }

  Future<void> getAddressList() async {
    getAddresses(providerId: appStore.userId).then((value) {
      appStore.setLoading(false);
      serviceAddressList.addAll(value.addressResponse!);

      serviceAddressList.forEach((e) {
        if (e.id == serviceAddressId) {
          selectedServiceAddress = e;
        }
      });
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> getCommissionList() async {
    getCommissionType(type: USER_TYPE_HANDYMAN, providerId: appStore.userId)
        .then((value) {
      appStore.setLoading(false);
      commissionList.addAll(value.userTypeData!);

      commissionList.forEach((e) {
        if (e.id == commissionId) {
          selectedHandymanCommission = e;
        }
      });
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      commissionList = [
        UserTypeData(name: languages.lblSelectCommission, id: -1)
      ];
      log(e.toString());
    });
  }

  // Build mobile number with phone code and number
  String buildMobileNumber() {
    String phoneCode = selectedCountry.phoneCode.validate().trim();
    String phoneNumber = mobileCont.text.trim();
    
    // If phone code is empty, try to get it from the original data
    if (phoneCode.isEmpty && isUpdate && widget.data != null) {
      String? originalContact = widget.data!.contactNumber;
      if (originalContact != null && originalContact.contains('-')) {
        phoneCode = originalContact.split('-').first.trim();
      }
    }
    
    // If still empty, use default country code
    if (phoneCode.isEmpty) {
      phoneCode = defaultCountry().phoneCode;
    }
    
    // Remove any non-digit characters from phone number (except if it already has country code)
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Ensure phone number is not empty
    if (phoneNumber.isEmpty) {
      throw Exception('Phone number cannot be empty');
    }
    
    // Return in format: phoneCode-phoneNumber
    return '$phoneCode-$phoneNumber';
  }

  /// Register the Handyman
  Future<void> register() async {
    if (formKey.currentState!.validate()) {
      // Commission selection is now optional - user can use manual handyman_commission field instead
      formKey.currentState!.save();
      hideKeyboard(context);
      String? type = widget.userType;
      
      // Use multipart request ONLY if profile image file is present
      // Otherwise use regular JSON request (backend accepts profile_image_url in JSON)
      log('Checking profileImageFile: ${profileImageFile != null}, isUpdate: $isUpdate');
      if (profileImageFile != null) {
        log('Using multipart request with image file');
        await registerWithImage(type);
      } else {
        log('Using regular JSON request ${isUpdate ? '(update without new image)' : '(new handyman)'}');
        var request = {
          if (isUpdate) CommonKeys.id: widget.data!.id,
          UserKeys.firstName: fNameCont.text,
          UserKeys.lastName: lNameCont.text,
          UserKeys.userName: userNameCont.text,
          UserKeys.userType: type,
          UserKeys.providerId: _isAdminUser() && providerId != null ? providerId : appStore.userId,
          UserKeys.status: selectedStatus,
          UserKeys.contactNumber: buildMobileNumber().validate(),
          UserKeys.designation: designationCont.text.validate(),
          if (serviceAddressId != null && serviceAddressId != -1)
            UserKeys.serviceAddressId: serviceAddressId.validate(),
          UserKeys.email: emailCont.text,
          UserKeys.address: addressCont.text,
          if (selectedHandymanCommission != null && selectedHandymanCommission!.id != -1)
            UserKeys.handymanTypeId: selectedHandymanCommission?.id,
          if (!isUpdate) UserKeys.password: passwordCont.text,
          // Include existing profile image URL when updating without new image
          if (isUpdate && widget.data != null && widget.data!.profileImage.validate().isNotEmpty)
            'profile_image_url': widget.data!.profileImage.validate(),
          // New fields from documentation
          'company_name': companyNameCont.text.trim(),
          'vat_number': vatNumberCont.text.trim(),
          if (skillsCont.text.trim().isNotEmpty) 'skills': skillsCont.text.trim(),
          if (educationCont.text.trim().isNotEmpty) 'education': educationCont.text.trim(),
          if (certificationCont.text.trim().isNotEmpty) 'certification': certificationCont.text.trim(),
          if (mobilityCont.text.trim().isNotEmpty) 'mobility': mobilityCont.text.trim(),
          if (experienceCont.text.trim().isNotEmpty) 'experience': experienceCont.text.trim(),
          if (aboutMeCont.text.trim().isNotEmpty) 'about_me': aboutMeCont.text.trim(),
          if (selectedAvailability.isNotEmpty) 'availability': selectedAvailability,
          if (selectedLanguages.isNotEmpty) 'languages': jsonEncode(selectedLanguages),
          if (selectedLanguages.isNotEmpty) 'known_languages': jsonEncode(selectedLanguages),
          if (handymanCommissionCont.text.isNotEmpty)
            'handyman_commission': handymanCommissionCont.text.validate(),
          if (countryId != null) CommonKeys.countryId: countryId,
          if (stateId != null) CommonKeys.stateId: stateId,
          if (cityId != null) CommonKeys.cityId: cityId,
        };
        appStore.setLoading(true);
        
        // Debug: Log the request
        log('Handyman Request: ${jsonEncode(request)}');
        
        if (isUpdate) {
          await updateProfile(request).then((res) async {
            appStore.setLoading(false);
            toast(res.message.validate());
            finish(context, widget.onUpdate!.call());
          }).catchError((e) {
            appStore.setLoading(false);
            log('Update Profile Error: $e');
            toast(e.toString());
          });
        } else {
          await registerUser(request).then((res) async {
            appStore.setLoading(false);
            toast(res.message.validate());
            finish(context, widget.onUpdate!.call());
          }).catchError((e) {
            appStore.setLoading(false);
            log('Register User Error: $e');
            toast(e.toString());
          });
        }
      }
    }
  }
  
  Future<void> registerWithImage(String? type) async {
    MultipartRequest multiPartRequest = await getMultiPartRequest(isUpdate ? 'update-profile' : 'register');
    
    log('Creating multipart request for ${isUpdate ? 'update-profile' : 'register'}');
    log('profileImageFile is null: ${profileImageFile == null}');
    
    multiPartRequest.fields[UserKeys.firstName] = fNameCont.text;
    multiPartRequest.fields[UserKeys.lastName] = lNameCont.text;
    multiPartRequest.fields[UserKeys.userName] = userNameCont.text;
    multiPartRequest.fields[UserKeys.userType] = type.validate();
    multiPartRequest.fields[UserKeys.providerId] = (_isAdminUser() && providerId != null ? providerId : appStore.userId).toString();
    multiPartRequest.fields[UserKeys.status] = selectedStatus;
    multiPartRequest.fields[UserKeys.contactNumber] = buildMobileNumber().validate();
    multiPartRequest.fields[UserKeys.designation] = designationCont.text.validate();
    if (serviceAddressId != null && serviceAddressId != -1)
      multiPartRequest.fields[UserKeys.serviceAddressId] = serviceAddressId.toString();
    multiPartRequest.fields[UserKeys.email] = emailCont.text;
    multiPartRequest.fields[UserKeys.address] = addressCont.text.validate();
    if (selectedHandymanCommission != null && selectedHandymanCommission!.id != -1)
      multiPartRequest.fields[UserKeys.handymanTypeId] = selectedHandymanCommission!.id.toString();
    if (!isUpdate) multiPartRequest.fields[UserKeys.password] = passwordCont.text;
    if (isUpdate) multiPartRequest.fields[CommonKeys.id] = widget.data!.id.toString();
    
    // New fields from documentation
    multiPartRequest.fields['company_name'] = companyNameCont.text.trim();
    multiPartRequest.fields['vat_number'] = vatNumberCont.text.trim();
    if (skillsCont.text.trim().isNotEmpty) multiPartRequest.fields['skills'] = skillsCont.text.trim();
    if (educationCont.text.trim().isNotEmpty) multiPartRequest.fields['education'] = educationCont.text.trim();
    if (certificationCont.text.trim().isNotEmpty) multiPartRequest.fields['certification'] = certificationCont.text.trim();
    if (mobilityCont.text.trim().isNotEmpty) multiPartRequest.fields['mobility'] = mobilityCont.text.trim();
    if (experienceCont.text.trim().isNotEmpty) multiPartRequest.fields['experience'] = experienceCont.text.trim();
    if (aboutMeCont.text.trim().isNotEmpty) multiPartRequest.fields['about_me'] = aboutMeCont.text.trim();
    if (selectedAvailability.isNotEmpty) multiPartRequest.fields['availability'] = selectedAvailability;
    if (selectedLanguages.isNotEmpty) {
      multiPartRequest.fields['languages'] = jsonEncode(selectedLanguages);
      multiPartRequest.fields['known_languages'] = jsonEncode(selectedLanguages);
    }
    if (handymanCommissionCont.text.isNotEmpty)
      multiPartRequest.fields['handyman_commission'] = handymanCommissionCont.text.validate();
    if (countryId != null) multiPartRequest.fields[CommonKeys.countryId] = countryId.toString();
    if (stateId != null) multiPartRequest.fields[CommonKeys.stateId] = stateId.toString();
    if (cityId != null) multiPartRequest.fields[CommonKeys.cityId] = cityId.toString();
    
    // Always add profile_image field, even if null (backend expects it)
    // But only add file if profileImageFile is not null and is a valid local file
    if (profileImageFile != null) {
      try {
        // Verify it's a local file, not a network URL
        if (profileImageFile!.path.contains('http://') || profileImageFile!.path.contains('https://')) {
          log('Error: profileImageFile is a network URL, not a local file: ${profileImageFile!.path}');
          toast('Please select a new image file');
          appStore.setLoading(false);
          return;
        }
        
        // Verify file exists
        if (!await profileImageFile!.exists()) {
          log('Error: profile image file does not exist: ${profileImageFile!.path}');
          toast('Selected file does not exist');
          appStore.setLoading(false);
          return;
        }
        
        // Get file info before adding
        int fileSize = await profileImageFile!.length();
        String fileName = profileImageFile!.path.split('/').last;
        String fileExtension = fileName.split('.').last.toLowerCase();
        log('Adding profile image file: ${profileImageFile!.path}');
        log('File size: $fileSize bytes, File name: $fileName, Extension: $fileExtension');
        
        // Determine content type based on file extension (allow all image types)
        String? contentType;
        switch (fileExtension) {
          case 'jpg':
          case 'jpeg':
            contentType = 'image/jpeg';
            break;
          case 'png':
            contentType = 'image/png';
            break;
          case 'gif':
            contentType = 'image/gif';
            break;
          case 'webp':
            contentType = 'image/webp';
            break;
          case 'bmp':
            contentType = 'image/bmp';
            break;
          case 'svg':
            contentType = 'image/svg+xml';
            break;
          case 'tiff':
          case 'tif':
            contentType = 'image/tiff';
            break;
          case 'ico':
            contentType = 'image/x-icon';
            break;
          case 'heic':
          case 'heif':
            contentType = 'image/heic';
            break;
          default:
            // Default to image/jpeg for unknown extensions, or let it be auto-detected
            contentType = null; // Let multipart auto-detect
            log('Unknown image extension: $fileExtension, using auto-detect');
        }
        
        // Create multipart file - allow all image types
        MultipartFile multipartFile = await MultipartFile.fromPath(
          'profile_image',
          profileImageFile!.path,
          filename: fileName,
          contentType: contentType != null ? MediaType.parse(contentType) : null,
        );
        
        log('MultipartFile created - field: ${multipartFile.field}, filename: ${multipartFile.filename}, length: ${multipartFile.length}, contentType: ${multipartFile.contentType}');
        
        multiPartRequest.files.add(multipartFile);
        log('Profile image file added successfully. Files count: ${multiPartRequest.files.length}');
      } catch (e) {
        log('Error adding profile image: $e');
        toast('Error adding profile image: $e');
        appStore.setLoading(false);
        return;
      }
    } else {
      log('Warning: profileImageFile is null - no image will be uploaded');
      // Don't add empty file - backend will skip image update if not present
    }
    
    // Build headers but remove Content-Type (multipart will set it automatically)
    Map<String, String> headers = buildHeaderTokens();
    headers.remove('Content-Type'); // Let multipart set this automatically
    multiPartRequest.headers.addAll(headers);
    
    // Debug: Log all files being sent
    log('Total multipart files: ${multiPartRequest.files.length}');
    if (multiPartRequest.files.isNotEmpty) {
      for (var file in multiPartRequest.files) {
        log('Multipart file - field: ${file.field}, filename: ${file.filename ?? 'no filename'}, length: ${file.length}, contentType: ${file.contentType}');
      }
    } else {
      log('No files in multipart request');
    }
    
    // Log complete payload structure
    log('=== MULTIPART REQUEST PAYLOAD ===');
    log('URL: ${multiPartRequest.url}');
    log('Method: ${multiPartRequest.method}');
    log('Headers: ${multiPartRequest.headers}');
    log('Fields (${multiPartRequest.fields.length}):');
    multiPartRequest.fields.forEach((key, value) {
      log('  $key: ${value.length > 100 ? value.substring(0, 100) + "..." : value}');
    });
    log('Files (${multiPartRequest.files.length}):');
    for (var file in multiPartRequest.files) {
      log('  ${file.field}: ${file.filename ?? 'no filename'} (length: ${file.length}, contentType: ${file.contentType})');
    }
    log('=== END PAYLOAD ===');
    
    // Verify file is actually added before sending
    if (profileImageFile != null && multiPartRequest.files.isEmpty) {
      log('ERROR: profileImageFile is set but no files in multipart request!');
      toast('Error: Image file not added to request');
      appStore.setLoading(false);
      return;
    }
    
    appStore.setLoading(true);
    
    await sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        appStore.setLoading(false);
        if (data != null) {
          if ((data as String).isJson()) {
            var res = jsonDecode(data);
            toast(res['message']?.toString() ?? 'Success');
            finish(context, widget.onUpdate!.call());
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

  /// Remove the Handyman
  Future<void> removeHandyman(int? id) async {
    appStore.setLoading(true);
    await deleteHandyman(id.validate()).then((value) {
      appStore.setLoading(false);

      finish(context, widget.onUpdate!.call());

      toast(languages.lblTrashHandyman, print: true);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  /// Restore the Handyman
  Future<void> restoreHandymanData() async {
    appStore.setLoading(true);
    var req = {
      CommonKeys.id: widget.data!.id,
      'type': RESTORE,
    };

    await restoreHandyman(req).then((value) {
      appStore.setLoading(false);
      toast(value.message);
      finish(context, widget.onUpdate!.call());
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  /// ForceFully Delete the Handyman
  Future<void> forceDeleteHandymanData() async {
    appStore.setLoading(true);
    var req = {
      CommonKeys.id: widget.data!.id,
      'type': FORCE_DELETE,
    };

    await restoreHandyman(req).then((value) {
      appStore.setLoading(false);
      toast(value.message);
      finish(context, widget.onUpdate!.call());
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.cardColor,
        appBar: AppBar(
          title: Text(
            isUpdate ? languages.lblUpdate : languages.lblAddHandyman,
            style: boldTextStyle(color: white, size: APP_BAR_TEXT_SIZE),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: BackWidget(color: white),
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: kAppPrimaryGradient)),
          actions: [
            IconButton(
              onPressed: () {
                if (widget.data != null) {
                  HandymanPayoutListScreen(user: widget.data!).launch(context);
                }
              },
              icon: Icon(Icons.payments_outlined, size: 24, color: white),
              tooltip: languages.handymanPayoutList,
            ).visible(isUpdate),
            if (isUpdate && rolesAndPermissionStore.handymanDelete)
              PopupMenuButton(
                icon: Icon(Icons.more_vert, size: 24, color: white),
                onSelected: (selection) async {
                  if (selection == 1) {
                    showConfirmDialogCustom(
                      context,
                      dialogType: DialogType.DELETE,
                      title: languages.lblDoYouWantToDelete,
                      positiveText: languages.lblDelete,
                      negativeText: languages.lblCancel,
                      onAccept: (_) {
                        ifNotTester(context, () {
                          removeHandyman(widget.data!.id.validate());
                        });
                      },
                    );
                  } else if (selection == 2) {
                    showConfirmDialogCustom(
                      context,
                      dialogType: DialogType.DELETE,
                      title: languages.lblDoYouWantToRestore,
                      positiveText: languages.lblRestore,
                      negativeText: languages.lblCancel,
                      onAccept: (_) {
                        ifNotTester(context, () {
                          restoreHandymanData();
                        });
                      },
                    );
                  } else if (selection == 3) {
                    showConfirmDialogCustom(
                      context,
                      dialogType: DialogType.DELETE,
                      title: languages.lblDoYouWantToDeleteForcefully,
                      positiveText: languages.lblDelete,
                      negativeText: languages.lblCancel,
                      onAccept: (_) {
                        ifNotTester(context, () {
                          forceDeleteHandymanData();
                        });
                      },
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text(languages.lblDelete),
                    value: 1,
                    enabled: widget.data!.deletedAt == null,
                    textStyle: boldTextStyle(
                        color: widget.data!.deletedAt == null
                            ? textPrimaryColorGlobal
                            : null),
                  ),
                  PopupMenuItem(
                    child: Text(languages.lblRestore),
                    value: 2,
                    textStyle: boldTextStyle(
                        color: widget.data!.deletedAt != null
                            ? textPrimaryColorGlobal
                            : null),
                    enabled: widget.data!.deletedAt != null,
                  ),
                  PopupMenuItem(
                    child: Text(languages.lblForceDelete),
                    textStyle: boldTextStyle(),
                    value: 3,
                    enabled: widget.data!.deletedAt != null,
                  ),
                ],
              ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(languages.lblProfile, style: boldTextStyle(size: 16)),
                    12.height,
                    // Profile Image Preview and Upload
                    // Show existing image only when no new file is selected
                    if (isUpdate && widget.data!.profileImage.validate().isNotEmpty && profileImageFile == null)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CachedImageWidget(
                            url: widget.data!.profileImage.validate(value: profile),
                            height: 100,
                            width: 100,
                            circle: true,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    // Show preview of newly selected image
                    if (profileImageFile != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.file(
                          profileImageFile!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ).center(),
                    if ((isUpdate && widget.data!.profileImage.validate().isNotEmpty && profileImageFile == null) || profileImageFile != null) 16.height,
                    // Profile Image Picker - only pass local file path, not network URL
                    CustomImagePicker(
                      selectedImages: profileImageFile != null ? [profileImageFile!.path] : null,
                      onFileSelected: (List<File> files) async {
                        if (files.isNotEmpty) {
                          File selectedFile = files.first;
                          // Check if it's a valid local file (not a network URL)
                          if (selectedFile.path.contains('http://') || selectedFile.path.contains('https://')) {
                            log('Warning: Selected file is a network URL, not a local file: ${selectedFile.path}');
                            toast('Please select a new image from gallery or camera');
                            return;
                          }
                          // Check if file exists
                          bool fileExists = await selectedFile.exists();
                          if (!fileExists) {
                            log('Error: Selected file does not exist: ${selectedFile.path}');
                            toast('Selected file does not exist');
                            return;
                          }
                          profileImageFile = selectedFile;
                          log('Profile image file set successfully: ${profileImageFile!.path}, exists: ${await profileImageFile!.exists()}');
                          setState(() {});
                        } else {
                          log('Warning: onFileSelected called with empty files list');
                        }
                      },
                      onRemoveClick: (String value) {
                        profileImageFile = null;
                        setState(() {});
                      },
                      isMultipleImages: false,
                    ),
                    30.height,
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      controller: fNameCont,
                      focus: fNameFocus,
                      enabled: true,
                      nextFocus: lNameFocus,
                      decoration: inputDecoration(
                        context,
                        hint: languages.hintFirstNameTxt,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                      suffix: profile.iconImage(size: 10).paddingAll(14),
                    ),
                    16.height,
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      controller: lNameCont,
                      focus: lNameFocus,
                      enabled: true,
                      nextFocus: userNameFocus,
                      decoration: inputDecoration(
                        context,
                        hint: languages.hintLastNameTxt,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                      suffix: profile.iconImage(size: 10).paddingAll(14),
                    ),
                    16.height,
                    AppTextField(
                      textFieldType: TextFieldType.USERNAME,
                      controller: userNameCont,
                      focus: userNameFocus,
                      nextFocus: emailFocus,
                      enabled: true,
                      decoration: inputDecoration(
                        context,
                        hint: languages.hintUserNameTxt,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                      suffix: profile.iconImage(size: 10).paddingAll(14),
                    ),
                    16.height,
                    AppTextField(
                      textFieldType: TextFieldType.EMAIL_ENHANCED,
                      controller: emailCont,
                      focus: emailFocus,
                      nextFocus: mobileFocus,
                      enabled: true,
                      decoration: inputDecoration(
                        context,
                        hint: languages.hintEmailAddressTxt,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                      suffix: ic_message.iconImage(size: 10).paddingAll(14),
                    ),
                    16.height,
                    Divider(),
                    12.height,
                    Text(languages.lblCompanyInformation, style: boldTextStyle(size: 16)),
                    12.height,
                    // Company Name - Optional
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      controller: companyNameCont,
                      focus: companyNameFocus,
                      nextFocus: vatNumberFocus,
                      enabled: true,
                      isValidationRequired: false,
                      decoration: inputDecoration(
                        context,
                        hint: languages.lblCompanyNameHint,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                    ),
                    16.height,
                    // VAT number — optional (company / professional / skills are all optional here)
                    Text(languages.lblVatNumberHint, style: secondaryTextStyle()),
                    8.height,
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      controller: vatNumberCont,
                      focus: vatNumberFocus,
                      nextFocus: skillsFocus,
                      enabled: true,
                      isValidationRequired: false,
                      decoration: inputDecoration(
                        context,
                        hint: languages.lblVatNumberHint,
                        fillColor: context.scaffoldBackgroundColor,
                        prefixIcon: Icon(
                          Icons.receipt_long_outlined,
                          size: 20,
                          color: context.iconColor,
                        ),
                      ),
                    ),
                    16.height,
                    Divider(),
                    12.height,
                    Text(languages.lblProfessionalDetails, style: boldTextStyle(size: 16)),
                    12.height,
                    // Skills - Text Input (Optional)
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      controller: skillsCont,
                      focus: skillsFocus,
                      nextFocus: experienceFocus,
                      enabled: true,
                      isValidationRequired: false,
                      decoration: inputDecoration(
                        context,
                        hint: languages.lblSkillsHint,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                    ),
                    16.height,
                    // Experience - Textarea (Optional)
                    AppTextField(
                      textFieldType: TextFieldType.MULTILINE,
                      controller: experienceCont,
                      focus: experienceFocus,
                      nextFocus: mobilityFocus,
                      enabled: true,
                      isValidationRequired: false,
                      minLines: 2,
                      maxLines: 5,
                      decoration: inputDecoration(
                        context,
                        hint: languages.lblExperienceHint,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                    ),
                    16.height,
                    // Mobility - Text Input (Optional)
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      controller: mobilityCont,
                      focus: mobilityFocus,
                      nextFocus: certificationFocus,
                      enabled: true,
                      isValidationRequired: false,
                      decoration: inputDecoration(
                        context,
                        hint: languages.lblMobilityShortHint,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                    ),
                    16.height,
                    // Certification - Text Input (Optional)
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      controller: certificationCont,
                      focus: certificationFocus,
                      nextFocus: mobileFocus,
                      enabled: true,
                      isValidationRequired: false,
                      decoration: inputDecoration(
                        context,
                        hint: languages.lblCertificationShortHint,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                    ),
                    16.height,
                    Divider(),
                    12.height,
                    Text(languages.lblContactAndAddress, style: boldTextStyle(size: 16)),
                    12.height,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 48.0,
                          decoration: BoxDecoration(
                            color: context.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Center(
                            child: ValueListenableBuilder(
                              valueListenable: _valueNotifier,
                              builder: (context, value, child) => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "+${selectedCountry.phoneCode}",
                                    style: primaryTextStyle(size: 12),
                                  ).paddingOnly(left: 8),
                                  Icon(Icons.arrow_drop_down)
                                ],
                              ),
                            ),
                          ),
                        )
                            .onTap(
                              () => changeCountry(),
                            )
                            .paddingOnly(right: 10.0),
                        Expanded(
                          child: AppTextField(
                            textFieldType: TextFieldType.PHONE,
                            controller: mobileCont,
                            focus: mobileFocus,
                            nextFocus: designationFocus,
                            enabled: true,
                            decoration: inputDecoration(
                              context,
                              hint: languages.hintContactNumberTxt,
                              fillColor: context.scaffoldBackgroundColor,
                            ),
                            suffix:
                                calling.iconImage(size: 10).paddingAll(14),
                            validator: (mobileCont) {
                              if (mobileCont!.isEmpty)
                                return languages.lblPleaseEnterMobileNumber;
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    16.height,
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      controller: designationCont,
                      isValidationRequired: false,
                      enabled: true, // Always enabled
                      focus: designationFocus,
                      nextFocus: addressFocus,
                      decoration: inputDecoration(
                        context,
                        hint: languages.lblDesignation,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                    ),
                    16.height,
                    Divider(),
                    12.height,
                    Text(languages.commission, style: boldTextStyle(size: 16)),
                    12.height,
                    // Handyman Commission - Number input (1-85)
                    AppTextField(
                      textFieldType: TextFieldType.PHONE,
                      controller: handymanCommissionCont,
                      focus: handymanCommissionFocus,
                      nextFocus: companyNameFocus,
                      enabled: true,
                      isValidationRequired: false,
                      decoration: inputDecoration(
                        context,
                        hint: languages.lblHandymanCommissionHint,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          double? commission = double.tryParse(value);
                          if (commission == null) {
                            return 'Please enter a valid number';
                          }
                          if (commission < 1 || commission > 99) {
                            return 'Commission must be between 1 and 99';
                          }
                        }
                        return null;
                      },
                    ),
                    16.height,
                    Divider(),
                    12.height,
                    Text(languages.lblLocationSection, style: boldTextStyle(size: 16)),
                    12.height,
                    DropdownButtonFormField<AddressResponse>(
                        decoration: inputDecoration(
                          context,
                          hint:  '${languages.lblService} ${languages.lblAddress}',
                          fillColor: context.scaffoldBackgroundColor,
                        ),
                        isExpanded: true,
                        dropdownColor: context.cardColor,
                        value: selectedServiceAddress != null
                            ? selectedServiceAddress
                            : null,
                        items: serviceAddressList.map((data) {
                          return DropdownMenuItem<AddressResponse>(
                            value: data,
                            child: Text(
                              data.address.validate(),
                              style: primaryTextStyle(),
                            ),
                          );
                        }).toList(),
                        onChanged: (AddressResponse? value) async {
                          selectedServiceAddress = value;
                          serviceAddressId =
                              selectedServiceAddress!.id.validate();
                          setState(() {});
                        },
                      ).visible(serviceAddressList.isNotEmpty),
                    16.height,
                    // Provider dropdown (for admin only)
                    if (_isAdminUser())
                      DropdownButtonFormField<UserData>(
                          decoration: inputDecoration(
                            context,
                            hint: languages.lblSelectProviderHint,
                            fillColor: context.scaffoldBackgroundColor,
                          ),
                          isExpanded: true,
                          dropdownColor: context.cardColor,
                          value: selectedProvider,
                          items: providerList.map((data) {
                            return DropdownMenuItem<UserData>(
                              value: data,
                              child: Text(
                                data.displayName ?? '${data.firstName} ${data.lastName}',
                                style: primaryTextStyle(),
                              ),
                            );
                          }).toList(),
                          onChanged: (UserData? value) {
                            selectedProvider = value;
                            providerId = selectedProvider?.id;
                            setState(() {});
                          },
                        ).visible(providerList.isNotEmpty),
                    if (_isAdminUser()) 16.height,
                    // Country dropdown - Required
                    DropdownButtonFormField<CountryListResponse>(
                      decoration: inputDecoration(
                        context,
                        hint: languages.selectCountry,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                      isExpanded: true,
                      menuMaxHeight: 300,
                      value: selectedCountryData,
                      dropdownColor: context.cardColor,
                      items: countryList.map((e) {
                        return DropdownMenuItem<CountryListResponse>(
                          value: e,
                          child: Text(
                            e.name ?? '',
                            style: primaryTextStyle(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (CountryListResponse? value) {
                        selectedCountryData = value;
                        countryId = value?.id;
                        selectedState = null;
                        selectedCity = null;
                        stateList.clear();
                        cityList.clear();
                        setState(() {});
                        if (countryId != null) {
                          getStates(countryId!);
                        }
                      },
                    ).visible(countryList.isNotEmpty),
                    16.height.visible(countryList.isNotEmpty),
                    // State dropdown - Required
                    if (stateList.isNotEmpty)
                      DropdownButtonFormField<StateListResponse>(
                        decoration: inputDecoration(
                          context,
                          hint: languages.selectState,
                          fillColor: context.scaffoldBackgroundColor,
                        ),
                        isExpanded: true,
                        menuMaxHeight: 300,
                        value: selectedState,
                        dropdownColor: context.cardColor,
                        items: stateList.map((e) {
                          return DropdownMenuItem<StateListResponse>(
                            value: e,
                            child: Text(
                              e.name ?? '',
                              style: primaryTextStyle(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (StateListResponse? value) {
                          selectedState = value;
                          stateId = value?.id;
                          selectedCity = null;
                          cityList.clear();
                          setState(() {});
                          if (stateId != null) {
                            getCity(stateId!);
                          }
                        },
                      ),
                    16.height.visible(stateList.isNotEmpty),
                    // City dropdown - Required
                    if (cityList.isNotEmpty)
                      DropdownButtonFormField<CityListResponse>(
                        decoration: inputDecoration(
                          context,
                          hint: languages.selectCity,
                          fillColor: context.scaffoldBackgroundColor,
                        ),
                        isExpanded: true,
                        menuMaxHeight: 300,
                        value: selectedCity,
                        dropdownColor: context.cardColor,
                        items: cityList.map((e) {
                          return DropdownMenuItem<CityListResponse>(
                            value: e,
                            child: Text(
                              e.name ?? '',
                              style: primaryTextStyle(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (CityListResponse? value) {
                          selectedCity = value;
                          cityId = value?.id;
                          setState(() {});
                        },
                      ),
                    16.height.visible(cityList.isNotEmpty),
                    AppTextField(
                      textFieldType: TextFieldType.MULTILINE,
                      controller: addressCont,
                      isValidationRequired: false,
                      enabled: true, // Always enabled
                      focus: addressFocus,
                      nextFocus: passwordFocus,
                      decoration: inputDecoration(
                        context,
                        hint: languages.lblAddress,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                    ),
                    16.height.visible(!isUpdate),
                    AppTextField(
                      textFieldType: TextFieldType.PASSWORD,
                      controller: passwordCont,
                      focus: passwordFocus,
                      enabled: true,
                      obscureText: true,
                      decoration: inputDecoration(
                        context,
                        hint: languages.hintPassword,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                      isValidationRequired: true,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return languages.hintRequired;
                        } else if (val.length < 8 || val.length > 12) {
                          return languages.passwordLengthShouldBe;
                        }
                        return null;
                      },
                      onFieldSubmitted: (s) {
                        ifNotTester(context, () {
                          register();
                        });
                      },
                    ).visible(!isUpdate),
                    16.height,
                    if (isUpdate)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${widget.data!.displayName} ${languages.lblRegistered} ${DateTime.parse(widget.data!.createdAt!).timeAgo}\n${formatBookingDate(widget.data!.createdAt!)}',
                              style: secondaryTextStyle()),
                          if (widget.data!.emailVerifiedAt
                              .validate()
                              .isNotEmpty)
                            TextIcon(
                              text: '${languages.lblEmailIsVerified}',
                              textStyle: primaryTextStyle(color: Colors.green),
                              prefix: Container(
                                child: Icon(Icons.check,
                                    color: Colors.white, size: 14),
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green),
                              ),
                            ).paddingTop(8),
                        ],
                      ),
                    // Availability dropdown - full_time/part_time
                    DropdownButtonFormField<String>(
                      decoration: inputDecoration(
                        context,
                        hint: languages.lblAvailableStatus,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                      dropdownColor: context.cardColor,
                      value: selectedAvailability,
                      items: availabilityList.map((data) {
                        String displayText = data == 'full_time' ? 'Full-time' : 'Part-time';
                        return DropdownMenuItem<String>(
                          value: data,
                          child: Text(displayText, style: primaryTextStyle()),
                        );
                      }).toList(),
                      onChanged: (String? value) async {
                        selectedAvailability = value.validate();
                        setState(() {});
                      },
                    ),
                    16.height,
                    // Status dropdown - Active/Inactive
                    DropdownButtonFormField<String>(
                      decoration: inputDecoration(
                        context,
                        hint: languages.lblStatus,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                      dropdownColor: context.cardColor,
                      value: selectedStatus,
                      items: [
                        DropdownMenuItem<String>(
                          value: '1',
                          child: Text(languages.active, style: primaryTextStyle()),
                        ),
                        DropdownMenuItem<String>(
                          value: '0',
                          child: Text(languages.inactive, style: primaryTextStyle()),
                        ),
                      ],
                      onChanged: (String? value) {
                        selectedStatus = value.validate();
                        setState(() {});
                      },
                    ),
                    16.height,
                    Divider(),
                    12.height,
                    Text(languages.lblLanguagesSection, style: boldTextStyle(size: 16)),
                    8.height,
                    Text(languages.knownLanguages, style: secondaryTextStyle()),
                    8.height,
                    // Languages - Multi-select dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: context.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.dividerColor),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: languageOptions.map((lang) {
                          bool isSelected = selectedLanguages.contains(lang);
                          return FilterChip(
                            label: Text(lang),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                selectedLanguages.add(lang);
                              } else {
                                selectedLanguages.remove(lang);
                              }
                              setState(() {});
                            },
                            selectedColor: gradientBlue.withOpacity(0.2),
                            checkmarkColor: gradientBlue,
                          );
                        }).toList(),
                      ).paddingAll(12),
                    ),
                    16.height,
                    // Keep old language list display for backward compatibility
                    Wrap(
                      children: selectedLanguages.map((e) {
                        return Stack(
                          children: [
                            Container(
                              decoration: boxDecorationWithRoundedCorners(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                                backgroundColor: appStore.isDarkMode
                                    ? cardDarkColor
                                    : gradientBlue.withValues(alpha: 0.1),
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
                                selectedLanguages.remove(e);
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

                        if (res != null && !selectedLanguages.contains(res.trim())) {
                          selectedLanguages.add(res.trim());
                          setState(() {});
                        }
                      },
                      child: Text(languages.lblAddLanguage,
                          style: primaryTextStyle(color: gradientBlue)),
                    ),
                    Divider(),
                    12.height,
                    Text(languages.lblEducationAndBio, style: boldTextStyle(size: 16)),
                    12.height,
                    // Education - Text Input (Optional)
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      controller: educationCont,
                      focus: educationFocus,
                      nextFocus: aboutMeFocus,
                      enabled: true,
                      isValidationRequired: false,
                      decoration: inputDecoration(
                        context,
                        hint: languages.lblEducationHint,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                    ),
                    16.height,
                    // About Me - Textarea (Optional)
                    AppTextField(
                      textFieldType: TextFieldType.MULTILINE,
                      controller: aboutMeCont,
                      focus: aboutMeFocus,
                      enabled: true,
                      isValidationRequired: false,
                      minLines: 2,
                      maxLines: 5,
                      decoration: inputDecoration(
                        context,
                        hint: languages.lblAboutMeHint,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                    ),
                    16.height,
                    24.height,
                    Observer(
                      builder: (context) => DecoratedBox(
                        decoration: BoxDecoration(gradient: kAppPrimaryGradient, borderRadius: radius(8)),
                        child: AppButton(
                          text: languages.btnSave,
                          height: 40,
                          color: Colors.transparent,
                          elevation: 0,
                          textColor: white,
                          width: context.width() - context.navigationBarHeight,
                          onTap: appStore.isLoading
                              ? null
                              : () {
                                  ifNotTester(context, () {
                                    register();
                                  });
                                },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Observer(
                builder: (_) =>
                    LoaderWidget().center().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }

  // Change country code function...
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
        selectedCountry = country;
        _valueNotifier.value = !_valueNotifier.value;
      },
    );
  }
}
