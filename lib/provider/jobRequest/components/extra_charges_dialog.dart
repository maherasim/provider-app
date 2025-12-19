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
      height: context.height() * 0.8,
      color: Colors.transparent,
      child: Stack(
        children: [
          Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(languages.addExtraCharges, style: boldTextStyle(size: 18)).paddingAll(16),
                // Scrollable Content
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 16),
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
                    icon: _gradientText(Icon(Icons.add, size: 20)),
                    label: _gradientText(Text(languages.addMore)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: gradientRed,
                      side: BorderSide(color: gradientRed),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ).paddingSymmetric(horizontal: 16,vertical: 8),
                // Info text
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: context.iconColor),
                    8.width,
                    Expanded(
                      child: Text(
                        languages.extraChargesWillBeIncludedInFinalInvoice,
                        style: secondaryTextStyle(size: 12),
                      ),
                    ),
                  ],
                ).paddingSymmetric(vertical: 8,horizontal: 16),
                
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
                    16.width,
                    DecoratedBox(
                      decoration: BoxDecoration(gradient: kAppPrimaryGradient, borderRadius: radius(8)),
                      child: AppButton(
                        onTap: _handleSubmitClick,
                        color: Color(0x00000000),
                        text: languages.save,
                        textStyle: boldTextStyle(color: white),
                        elevation: 0,
                      ),
                    ).expand(),
                  ],
                ).paddingSymmetric(vertical: 8,horizontal: 16),
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
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: context.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
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
                  style: boldTextStyle(size: 14),
                ),
              ),
              if (chargeRows.length > 1)
                IconButton(
                  onPressed: () => removeRow(index),
                  icon: Icon(Icons.close, size: 20, color: Colors.red),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                ),
            ],
          ),
          16.height,
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
            ),
          ),

          16.height,
          // Form fields
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  textFieldType: TextFieldType.PHONE,
                  controller: row.amountController,
                  validator: (s) {
                    if (s!.isEmpty) return languages.hintRequired;
                    if (s.toDouble() <= 0) return languages.priceAmountValidationMessage;
                    return null;
                  },
                  decoration: inputDecoration(context).copyWith(
                    fillColor: context.cardColor,
                    filled: true,
                    hintText: languages.price,
                    hintStyle: secondaryTextStyle(),
                  ),
                ),
              ),
              12.width,
              Expanded(
                child: AppTextField(
                  textFieldType: TextFieldType.NUMBER,
                  controller: row.qtyController,
                  validator: (s) {
                    if (s!.isEmpty) return languages.hintRequired;
                    if (s.toInt() < 1) return languages.quantityMustBeAtLeast1;
                    return null;
                  },
                  decoration: inputDecoration(context).copyWith(
                    fillColor: context.cardColor,
                    filled: true,
                    hintText: languages.quantity,
                    hintStyle: secondaryTextStyle(),
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
      qty: int.tryParse(qtyController.text) ?? 1,
    );
  }

  void dispose() {
    titleController.dispose();
    amountController.dispose();
    qtyController.dispose();
  }
}
