import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/base_scaffold_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/networks/network_utils.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/bank_list_response.dart';
import '../../models/base_response.dart';
import '../../models/static_data_model.dart';

class AddBankScreen extends StatefulWidget {
  final BankHistory? data;

  const AddBankScreen({super.key, this.data});

  @override
  State<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController bankNameCont = TextEditingController();
  TextEditingController branchNameCont = TextEditingController();
  TextEditingController accNumberCont = TextEditingController();
  TextEditingController accountHolderCont = TextEditingController();
  TextEditingController bicNumberCont = TextEditingController();
  TextEditingController ibanNoCont = TextEditingController();
  TextEditingController contactNumberCont = TextEditingController();
  TextEditingController aadharCardNumberCont = TextEditingController();
  TextEditingController panNumberCont = TextEditingController();
  TextEditingController stripeAccountCont = TextEditingController();

  FocusNode bankNameFocus = FocusNode();
  FocusNode branchNameFocus = FocusNode();
  FocusNode accNumberFocus = FocusNode();
  FocusNode accountHolderFocus = FocusNode();
  FocusNode bicNumberFocus = FocusNode();
  FocusNode ibanNoFocus = FocusNode();
  FocusNode contactNumberFocus = FocusNode();
  FocusNode aadharCardNumberFocus = FocusNode();
  FocusNode panNumberFocus = FocusNode();
  FocusNode stripeAccountFocus = FocusNode();

  Future<void> update() async {
    MultipartRequest multiPartRequest = await getMultiPartRequest('save-bank');

    // Only include id for update, omit for create
    if (isUpdate && widget.data != null) {
      multiPartRequest.fields['id'] = widget.data!.id.toString();
    }

    // Use logged-in user id so bank is stored under correct account (not providerId from token)
    final int loggedInUserId = appStore.userId.validate();
    multiPartRequest.fields['user_id'] = loggedInUserId.toString();
    multiPartRequest.fields['provider_id'] = loggedInUserId.toString();

    // Required fields
    multiPartRequest.fields['bank_name'] = bankNameCont.text.trim();
    multiPartRequest.fields['branch_name'] = branchNameCont.text.trim();
    multiPartRequest.fields['account_no'] = accNumberCont.text.trim();
    multiPartRequest.fields['status'] = getStatusValue().toString();

    // Optional fields (only include if not empty)
    if (accountHolderCont.text.trim().isNotEmpty) {
      multiPartRequest.fields['account_holder'] = accountHolderCont.text.trim();
    }
    if (contactNumberCont.text.trim().isNotEmpty) {
      multiPartRequest.fields['mobile_no'] = contactNumberCont.text.trim();
    }
    if (ibanNoCont.text.trim().isNotEmpty) {
      multiPartRequest.fields['iban_no'] = ibanNoCont.text.trim();
    }
    if (bicNumberCont.text.trim().isNotEmpty) {
      multiPartRequest.fields['bic_number'] = bicNumberCont.text.trim();
    }
    if (aadharCardNumberCont.text.trim().isNotEmpty) {
      multiPartRequest.fields['aadhar_no'] = aadharCardNumberCont.text.trim();
    }
    if (panNumberCont.text.trim().isNotEmpty) {
      multiPartRequest.fields['pan_no'] = panNumberCont.text.trim();
    }
    if (stripeAccountCont.text.trim().isNotEmpty) {
      multiPartRequest.fields['stripe_account'] = stripeAccountCont.text.trim();
    }

    // is_default defaults to 0 if not provided
    multiPartRequest.fields['is_default'] =
        widget.data?.isDefault.toString() ?? "0";

    // File upload handling (if needed in future)
    // multiPartRequest.fields['attachment_count'] = '0';
    // multiPartRequest.files.add(MultipartFile('bank_attachment_0', fileStream, fileLength, filename: fileName));

    print(multiPartRequest.fields);

    multiPartRequest.headers.addAll(buildHeaderTokens());

    appStore.setLoading(true);

    sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        appStore.setLoading(false);
        if (data != null) {
          print(data);
          if ((data as String).isJson()) {
            BaseResponseModel res =
                BaseResponseModel.fromJson(jsonDecode(data));
            finish(context, [true, bankNameCont.text]);
            if (res.status ?? false) {}
            snackBar(context, title: res.message!);
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

  String bankStatus = 'ACTIVE';
  int getStatusValue() {
    if (bankStatus == 'ACTIVE') {
      return 1;
    } else {
      return 0;
    }
  }

  bool isUpdate = true;

  List<StaticDataModel> statusListStaticData = [
    StaticDataModel(key: ACTIVE, value: languages.active),
    StaticDataModel(key: INACTIVE, value: languages.inactive),
  ];
  StaticDataModel? blogStatusModel;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    isUpdate = widget.data != null;

    // Clear all controllers first
    bankNameCont.clear();
    branchNameCont.clear();
    accNumberCont.clear();
    accountHolderCont.clear();
    ibanNoCont.clear();
    bicNumberCont.clear();
    contactNumberCont.clear();
    aadharCardNumberCont.clear();
    panNumberCont.clear();
    stripeAccountCont.clear();

    if (isUpdate && widget.data != null) {
      log('Loading bank data for editing - ID: ${widget.data!.id}');
      log('Raw data - Account Holder: "${widget.data!.accountHolder}", IBAN: "${widget.data!.ibanNo}", BIC: "${widget.data!.bicNumber}"');

      bankNameCont.text = widget.data!.bankName.validate();
      branchNameCont.text = widget.data!.branchName.validate();
      accNumberCont.text = widget.data!.accountNo.validate();

      // Handle account holder - ensure null values don't show as "null"
      String accountHolder = widget.data!.accountHolder.validate();
      accountHolderCont.text =
          (accountHolder.isEmpty || accountHolder.toLowerCase() == "null")
              ? ""
              : accountHolder;

      // Handle IBAN - ensure null values don't show as "null"
      String ibanNo = widget.data!.ibanNo.validate();
      ibanNoCont.text =
          (ibanNo.isEmpty || ibanNo.toLowerCase() == "null") ? "" : ibanNo;

      // Handle BIC - ensure null values don't show as "null"
      String bicNumber = widget.data!.bicNumber.validate();
      bicNumberCont.text =
          (bicNumber.isEmpty || bicNumber.toLowerCase() == "null")
              ? ""
              : bicNumber;

      contactNumberCont.text = widget.data!.mobileNo.validate();
      aadharCardNumberCont.text = widget.data!.aadharNo.validate();
      panNumberCont.text = widget.data!.panNo.validate();

      // Handle stripe account - ensure null values don't show as "null"
      String stripeAccount = widget.data!.stripeAccount.validate();
      stripeAccountCont.text =
          (stripeAccount.isEmpty || stripeAccount.toLowerCase() == "null")
              ? ""
              : stripeAccount;

      log('After setting - Account Holder: "${accountHolderCont.text}", IBAN: "${ibanNoCont.text}", BIC: "${bicNumberCont.text}"');
      log('Status: ${widget.data!.status}');

      // Set status dropdown based on bank status (1 = ACTIVE, 0 = INACTIVE)
      bankStatus = widget.data!.status == 1 ? ACTIVE : INACTIVE;
      blogStatusModel = statusListStaticData.firstWhere(
        (item) => item.key == bankStatus,
        orElse: () => statusListStaticData.first,
      );
    } else {
      // For new bank, set default status
      bankStatus = ACTIVE;
      blogStatusModel = statusListStaticData.first;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: languages.addBank,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              return await update();
            },
            child: Form(
              key: formKey,
              child: AnimatedScrollView(
                padding: EdgeInsets.all(16),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: bankNameCont,
                    focus: bankNameFocus,
                    nextFocus: branchNameFocus,
                    decoration:
                        inputDecoration(context, hint: languages.bankName),
                    suffix: ic_piggy_bank.iconImage(size: 10).paddingAll(14),
                    isValidationRequired: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return errorThisFieldRequired;
                      }
                      return null;
                    },
                  ),
                  16.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: branchNameCont,
                    focus: branchNameFocus,
                    nextFocus: accNumberFocus,
                    decoration: inputDecoration(context,
                        hint: languages.fullNameOnBankAccount),
                    suffix: ic_piggy_bank.iconImage(size: 10).paddingAll(14),
                    isValidationRequired: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return errorThisFieldRequired;
                      }
                      return null;
                    },
                  ),
                  16.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: accNumberCont,
                    focus: accNumberFocus,
                    nextFocus: accountHolderFocus,
                    decoration: inputDecoration(context,
                        hint: languages.accountNumber, counter: false),
                    suffix: ic_password
                        .iconImage(size: 10, fit: BoxFit.contain)
                        .paddingAll(14),
                    isValidationRequired: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return errorThisFieldRequired;
                      }
                      return null;
                    },
                  ),
                  16.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: accountHolderCont,
                    focus: accountHolderFocus,
                    nextFocus: contactNumberFocus,
                    decoration: inputDecoration(context,
                        hint: languages.lblAccountHolderNameHint, counter: false),
                    suffix: profile.iconImage(size: 10).paddingAll(14),
                    isValidationRequired: false,
                  ),
                  16.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: contactNumberCont,
                    focus: contactNumberFocus,
                    nextFocus: ibanNoFocus,
                    decoration: inputDecoration(context,
                        hint: languages.lblMobileNumberHint, counter: false),
                    suffix: profile.iconImage(size: 10).paddingAll(14),
                    isValidationRequired: false,
                  ),
                  16.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: ibanNoCont,
                    focus: ibanNoFocus,
                    nextFocus: bicNumberFocus,
                    decoration: inputDecoration(context,
                        hint: languages.lblIbanNumberHint, counter: false),
                    suffix: profile.iconImage(size: 10).paddingAll(14),
                    isValidationRequired: false,
                  ),
                  16.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: bicNumberCont,
                    focus: bicNumberFocus,
                    nextFocus: aadharCardNumberFocus,
                    decoration: inputDecoration(context,
                        hint: languages.bicSwiftCode, counter: false),
                    suffix: profile.iconImage(size: 10).paddingAll(14),
                    isValidationRequired: false,
                  ),
                  16.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: aadharCardNumberCont,
                    focus: aadharCardNumberFocus,
                    nextFocus: panNumberFocus,
                    decoration: inputDecoration(context,
                        hint: languages.aadharNumber, counter: false),
                    suffix: profile.iconImage(size: 10).paddingAll(14),
                    isValidationRequired: false,
                  ),
                  16.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: panNumberCont,
                    focus: panNumberFocus,
                    nextFocus: stripeAccountFocus,
                    decoration: inputDecoration(context,
                        hint: languages.panNumber, counter: false),
                    suffix: profile.iconImage(size: 10).paddingAll(14),
                    isValidationRequired: false,
                  ),
                  16.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: stripeAccountCont,
                    focus: stripeAccountFocus,
                    decoration: inputDecoration(context,
                        hint: languages.lblStripeAccountHint, counter: false),
                    suffix: profile.iconImage(size: 10).paddingAll(14),
                    isValidationRequired: false,
                  ),
                  16.height,
                  DropdownButtonFormField<StaticDataModel>(
                    isExpanded: true,
                    dropdownColor: context.cardColor,
                    initialValue: blogStatusModel != null
                        ? blogStatusModel
                        : statusListStaticData.first,
                    items: statusListStaticData.map((StaticDataModel data) {
                      return DropdownMenuItem<StaticDataModel>(
                        value: data,
                        child: Text(data.value.validate(),
                            style: primaryTextStyle()),
                      );
                    }).toList(),
                    decoration:
                        inputDecoration(context, hint: languages.lblStatus),
                    onChanged: (StaticDataModel? value) async {
                      bankStatus = value!.key.validate();
                      setState(() {});
                    },
                    validator: (value) {
                      if (value == null) return errorThisFieldRequired;
                      return null;
                    },
                  ),
                  100.height,
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16 + MediaQuery.of(context).padding.bottom,
            left: 16,
            right: 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  gradient: kAppPrimaryGradient, borderRadius: radius(8)),
              child: AppButton(
                text: languages.btnSave,
                color: Colors.transparent,
                elevation: 0,
                textStyle: boldTextStyle(color: white),
                width: context.width(),
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    hideKeyboard(context);
                    update();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
