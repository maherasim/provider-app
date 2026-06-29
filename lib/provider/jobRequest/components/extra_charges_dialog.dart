import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/extra_charges_model.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/models/post_job_detail_response.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class ExtraChargesDialog extends StatefulWidget {
  final JobRequestDetailResponse data;
  final List<ExtraChargesModel>? existingCharges;

  ExtraChargesDialog({required this.data, this.existingCharges});

  @override
  _ExtraChargesDialogState createState() => _ExtraChargesDialogState();
}

class _ExtraChargesDialogState extends State<ExtraChargesDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<ExtraChargeRow> chargeRows = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    // Initialize with existing charges or create one empty row
    if (widget.existingCharges != null && widget.existingCharges!.isNotEmpty) {
      chargeRows = widget.existingCharges!.map((charge) => ExtraChargeRow.fromModel(charge)).toList();
    } else {
      chargeRows = [ExtraChargeRow()];
    }
    setState(() {});
  }

  void addRow() {
    setState(() {
      chargeRows.add(ExtraChargeRow());
    });
  }

  void removeRow(int index) {
    if (chargeRows.length > 1) {
      setState(() {
        chargeRows.removeAt(index);
      });
    }
  }

  void _handleSubmitClick() async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      
      appStore.setLoading(true);

      List<ExtraChargesModel> charges = chargeRows.map((row) => row.toModel()).toList();
      
      List<Map<String, dynamic>> chargesData = charges.map((charge) =>  {
        "title": charge.title,
        "amount": charge.price,
        "quantity": charge.qty
      }).toList();

      Map<String, dynamic> request = {
        "items": chargesData,
      };

      try {
        await addExtraCharges(widget.data.id.validate(),request).then((res) async {
          appStore.setLoading(false);

          toast(res.message.validate());
          finish(context, true);
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString(), print: true);
        });
      } catch (e) {
        appStore.setLoading(false);
        toast(e.toString());
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget _gradientText(Widget text) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return kAppPrimaryGradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
      },
      blendMode: BlendMode.srcIn,
      child: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      height: context.height() * 0.45,
      color: Colors.transparent,
      child: Stack(
        children: [
          Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(languages.addExtraCharges, style: boldTextStyle(size: 14)).paddingSymmetric(horizontal: 16, vertical: 8),
                // Scrollable Content
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: chargeRows.length,
                    itemBuilder: (context, index) {
                      return _buildChargeRow(index);
                    },
                  ),
                ),
                // Add more button
                Container(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: addRow,
                    icon: _gradientText(Icon(Icons.add, size: 16)),
                    label: _gradientText(Text(languages.addMore, style: secondaryTextStyle(size: 12))),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: gradientRed,
                      side: BorderSide(color: gradientRed),
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ).paddingSymmetric(horizontal: 16,vertical: 4),
                // Info text
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 12, color: context.iconColor),
                    4.width,
                    Expanded(
                      child: Text(
                        languages.extraChargesWillBeIncludedInFinalInvoice,
                        style: secondaryTextStyle(size: 10),
                      ),
                    ),
                  ],
                ).paddingSymmetric(vertical: 4,horizontal: 16),
                
                // Fixed Footer with Action buttons
                Row(
                  children: [
                    AppButton(
                      onTap: () {
                        finish(context);
                      },
                      shapeBorder: RoundedRectangleBorder(borderRadius: radius()),
                      color: context.scaffoldBackgroundColor,
                      text: languages.lblCancel,
                      textColor: context.iconColor,
                    ).expand(),
                    8.width,
                    DecoratedBox(
                      decoration: BoxDecoration(gradient: kAppPrimaryGradient, borderRadius: radius(8)),
                      child: AppButton(
                        onTap: _handleSubmitClick,
                        color: Color(0x00000000),
                        text: languages.save,
                        textStyle: boldTextStyle(color: white, size: 14),
                        elevation: 0,
                      ),
                    ).expand(),
                  ],
                ).paddingSymmetric(vertical: 4,horizontal: 16),
              ],
            ),
          ),
          Observer(builder: (context) {
            return LoaderWidget().visible(appStore.isLoading);
          })
        ],
      ).center(),
    );
  }

  Widget _buildChargeRow(int index) {
    final row = chargeRows[index];
    
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(10),
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: context.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        children: [
          // Row header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _gradientText(
                Text(
                  '${languages.charge} ${index + 1}',
                  style: boldTextStyle(size: 11),
                ),
              ),
              if (chargeRows.length > 1)
                IconButton(
                  onPressed: () => removeRow(index),
                  icon: Icon(Icons.close, size: 18, color: Colors.red),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                ),
            ],
          ),
          8.height,
          AppTextField(
            textFieldType: TextFieldType.NAME,
            controller: row.titleController,
            autoFocus: index == 0 && row.titleController.text.isEmpty,
            validator: (s) {
              if (s!.isEmpty) return languages.hintRequired;
              return null;
            },
            decoration: inputDecoration(context).copyWith(
              fillColor: context.cardColor,
              filled: true,
              hintText: languages.title,
              hintStyle: secondaryTextStyle(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),

          8.height,
          // Form fields
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  textFieldType: TextFieldType.OTHER,
                  controller: row.amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (s) {
                    if (s!.isEmpty) return languages.hintRequired;
                    if ((double.tryParse(s) ?? 0) <= 0) return languages.priceAmountValidationMessage;
                    return null;
                  },
                  decoration: inputDecoration(context).copyWith(
                    fillColor: context.cardColor,
                    filled: true,
                    hintText: languages.price,
                    hintStyle: secondaryTextStyle(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              8.width,
              Expanded(
                child: AppTextField(
                  textFieldType: TextFieldType.OTHER,
                  controller: row.qtyController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (s) {
                    if (s!.isEmpty) return languages.hintRequired;
                    if ((double.tryParse(s) ?? 0) <= 0) return languages.quantityMustBeAtLeast1;
                    return null;
                  },
                  decoration: inputDecoration(context).copyWith(
                    fillColor: context.cardColor,
                    filled: true,
                    hintText: languages.quantity,
                    hintStyle: secondaryTextStyle(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ExtraChargeRow {
  TextEditingController titleController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController qtyController = TextEditingController();

  ExtraChargeRow({String? title, String? amount, String? qty}) {
    if (title != null) titleController.text = title;
    if (amount != null) amountController.text = amount;
    if (qty != null) qtyController.text = qty;
  }

  ExtraChargeRow.fromModel(ExtraChargesModel model) {
    titleController.text = model.title ?? '';
    amountController.text = model.price?.toString() ?? '';
    qtyController.text = model.qty?.toString() ?? '1';
  }

  ExtraChargesModel toModel() {
    return ExtraChargesModel(
      title: titleController.text.trim(),
      price: double.tryParse(amountController.text) ?? 0.0,
      qty: double.tryParse(qtyController.text) ?? 1.0,
    );
  }

  void dispose() {
    titleController.dispose();
    amountController.dispose();
    qtyController.dispose();
  }
}
