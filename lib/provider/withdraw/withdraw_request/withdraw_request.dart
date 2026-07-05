// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/bank_details/add_bank_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/extensions/num_extenstions.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/app_widgets.dart';
import '../../../components/back_widget.dart';
import '../../../components/price_widget.dart';
import '../../../components/success_dialog.dart';
import '../../../models/bank_list_response.dart';

class WithdrawRequest extends StatefulWidget {
  num availableBalance = 0;
  WithdrawRequest({super.key, required this.availableBalance});

  @override
  State<WithdrawRequest> createState() => _WithdrawRequestState();
}

bool isValidWithdrawAmount(String? value, num availableBalance) {
  if (value == null || value.trim().isEmpty) return false;

  final parsedAmount = num.tryParse(value.trim());
  return parsedAmount != null && parsedAmount > 0 && parsedAmount <= availableBalance;
}

class _WithdrawRequestState extends State<WithdrawRequest> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController amount = TextEditingController();
  TextEditingController chooseBank = TextEditingController();

  FocusNode amountFocus = FocusNode();
  FocusNode chooseBankFocus = FocusNode();

  Future<List<BankHistory>>? future;
  List<BankHistory> bankHistoryList = [];
  BankHistory? selectedBank;

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init("");
  }

  init(String bankName) async {
    appStore.setLoading(true);
    // Clear the list before fetching new data
    bankHistoryList.clear();
    setState(() {});
    
    log('Fetching bank list for userId: ${appStore.userId}');
    getBankListDetail(
      page: page,
      list: bankHistoryList,
      lastPageCallback: (b) {
        isLastPage = b;
      },
      userId: appStore.userId,
    ).then((value) {
      log('Bank list received: ${value.length} banks');
      setState(() {
        bankHistoryList = value;
      });
      
      if (bankHistoryList.isEmpty) {
        log('Warning: Bank list is empty!');
      }
      
      bankHistoryList.forEach((value) {
        if(bankName.isNotEmpty && bankName == value.bankName){
             setState(() {
            selectedBank = value;
          });
        }
        else if (value.isDefault == 1) {
          setState(() {
            selectedBank = value;
          });
        }
      });
    }).catchError((e) {
      toast(e.toString(), print: true);
      log('Error loading bank list: ${e.toString()}');
      log('Stack trace: ${StackTrace.current}');
    }).whenComplete(() {
      appStore.setLoading(false);
    });
  }

  withdrawMoney() {
    final parsedAmount = num.tryParse(amount.text.trim());
    if (parsedAmount == null || parsedAmount <= 0 || parsedAmount > widget.availableBalance.validate()) {
      toast('Please enter a valid amount', print: true);
      return;
    }

    appStore.setLoading(true);
    Map request = {
      "_token": appStore.token.validate(),
      "payment_method": "bank",
      "payment_gateway": "manual",
      "user_id": appStore.userId,
      "bank": selectedBank?.id,
      "amount": parsedAmount,
    };
    peoviderWithdrawMoney(request: request).then((value) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => SuccessDialog(
          title: languages.successful,
          description: languages.yourWithdrawalRequestHasBeenSuccessfullySubmitted,
          buttonText: languages.done,
        ),
      );
    }).catchError((e) {
      toast(e.toString());
    }).whenComplete(() {
      appStore.setLoading(false);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        languages.withdrawRequest,
        backWidget: BackWidget(),
        showBack: true,
        textColor: white,
        color: Colors.transparent,
        elevation: 0.0,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: kAppPrimaryGradient)),
      ),
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Available Balance Card
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: boxDecorationRoundedWithShadow(
                      16,
                      backgroundColor: context.cardColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              languages.availableBalance,
                              style: secondaryTextStyle(size: 14),
                            ),
                            8.height,
                            PriceWidget(
                              price: widget.availableBalance.validate(),
                              size: 24,
                              color: gradientBlue,
                              isBoldText: true,
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: kAppPrimaryGradient,
                          ),
                          child: Image.asset(
                            ic_un_fill_wallet,
                            height: 24,
                            width: 24,
                            color: white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  24.height,
                  // Enter Amount Section
                  Text(
                    languages.lblEnterAmount,
                    style: boldTextStyle(size: 16),
                  ),
                  12.height,
                  AppTextField(
                    textFieldType: TextFieldType.NUMBER,
                    controller: amount,
                    focus: amountFocus,
                    nextFocus: chooseBankFocus,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    decoration: inputDecoration(
                      context,
                      hint: languages.eg3000,
                      fillColor: context.cardColor,
                    ),
                    isValidationRequired: true,
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return errorThisFieldRequired;
                      }

                      final parsedAmount = num.tryParse(value!.trim());
                      if (parsedAmount == null || parsedAmount <= 0) {
                        return 'Please enter a valid amount';
                      } else if (parsedAmount > widget.availableBalance.validate()) {
                        return "${languages.pleaseAddLessThanOrEqualTo} ${widget.availableBalance.validate().toPriceFormat()}";
                      }
                      return null;
                    },
                  ),
                  24.height,
                  // Choose Bank Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        languages.chooseBank,
                        style: boldTextStyle(size: 16),
                      ),
                      TextButton(
                        onPressed: () {
                          AddBankScreen().launch(context).then((value) {
                            if (value.isNotEmpty) {
                              if (value[0]) {
                                init(value[1]);
                                setState(() {});
                              }
                            }
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 18, color: gradientBlue),
                            4.width,
                            ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return kAppPrimaryGradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
                              },
                              blendMode: BlendMode.srcIn,
                              child: Text(
                                languages.addBank,
                                style: boldTextStyle(size: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  12.height,
                  Observer(
                    builder: (_) => DropdownButtonFormField<BankHistory>(
                      decoration: inputDecoration(
                        context,
                        fillColor: context.cardColor,
                      ),
                      isExpanded: true,
                      menuMaxHeight: 300,
                      value: selectedBank,
                      hint: Text(
                        bankHistoryList.isEmpty 
                            ? languages.noDataFound 
                            : languages.egCentralNationalBank,
                        style: secondaryTextStyle(size: 14),
                      ),
                      icon: Icon(Icons.keyboard_arrow_down, color: context.iconColor),
                      dropdownColor: context.cardColor,
                      items: bankHistoryList.map((BankHistory e) {
                        return DropdownMenuItem<BankHistory>(
                          value: e,
                          child: Text(
                            e.bankName.validate(),
                            style: primaryTextStyle(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: bankHistoryList.isEmpty || appStore.isLoading 
                          ? null 
                          : (BankHistory? value) async {
                              selectedBank = value;
                              setState(() {});
                            },
                      validator: (value) {
                        if (value == null) return errorThisFieldRequired;
                        return null;
                      },
                    ),
                  ),
                  32.height,
                  // Withdraw Button
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: kAppPrimaryGradient,
                      borderRadius: radius(12),
                    ),
                    child: AppButton(
                      text: languages.withdraw,
                      height: 50,
                      color: Colors.transparent,
                      elevation: 0,
                      textStyle: boldTextStyle(color: white, size: 16),
                      width: context.width(),
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          hideKeyboard(context);
                          withdrawMoney();
                        }
                      },
                    ),
                  ),
                  16.height,
                ],
              ),
            ),
          ),
          Observer(builder: (_) => LoaderWidget().center().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}

