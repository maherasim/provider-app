import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';

/// API reason values for [reportPostJob].
const List<String> kJobReportReasonValues = [
  'spam',
  'harassment',
  'inappropriate',
  'fraud',
  'other',
];

String jobReportReasonLabel(String value) {
  switch (value) {
    case 'spam':
      return languages.lblReportReasonSpam;
    case 'harassment':
      return languages.lblReportReasonHarassment;
    case 'inappropriate':
      return languages.lblReportReasonInappropriate;
    case 'fraud':
      return languages.lblReportReasonFraud;
    case 'other':
      return languages.lblReportReasonOther;
    default:
      return value;
  }
}

/// Report dialog for POST `/api/ugc/report-post-job`.
class JobReportDialog extends StatefulWidget {
  final int postJobId;

  const JobReportDialog({super.key, required this.postJobId});

  @override
  State<JobReportDialog> createState() => _JobReportDialogState();
}

class _JobReportDialogState extends State<JobReportDialog> {
  String _reason = kJobReportReasonValues.first;
  final TextEditingController _detailsCont = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _detailsCont.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _detailsCont.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final details = _detailsCont.text.trim();
      final res = await reportPostJob(
        postJobId: widget.postJobId,
        reason: _reason,
        details: details.isEmpty ? null : details,
      );
      if (mounted) {
        finish(context, true);
        toast(res.message.validate());
      }
    } catch (e) {
      if (mounted) toast(e.toString(), print: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final len = _detailsCont.text.length;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: radius(16)),
      backgroundColor: context.cardColor,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: context.height() * 0.88,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                languages.lblReportJobTitle,
                style: boldTextStyle(size: 18),
              ),
              8.height,
              Text(
                languages.lblSelectReportReason,
                style: secondaryTextStyle(size: 13),
              ),
              8.height,
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _reason,
                dropdownColor: context.cardColor,
                menuMaxHeight: 280,
                decoration: inputDecoration(
                  context,
                  hint: languages.lblSelectReportReason,
                  fillColor: context.scaffoldBackgroundColor,
                ),
                items: kJobReportReasonValues
                    .map(
                      (v) => DropdownMenuItem<String>(
                        value: v,
                        child: Text(
                          jobReportReasonLabel(v),
                          style: primaryTextStyle(size: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _submitting
                    ? null
                    : (val) {
                        if (val != null) setState(() => _reason = val);
                      },
              ),
              12.height,
              AppTextField(
                textFieldType: TextFieldType.MULTILINE,
                controller: _detailsCont,
                maxLength: 2000,
                minLines: 3,
                maxLines: 6,
                enabled: !_submitting,
                decoration: inputDecoration(
                  context,
                  hint: languages.lblReportDetailsHint,
                  fillColor: context.scaffoldBackgroundColor,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$len/2000',
                  style: secondaryTextStyle(size: 11),
                ),
              ),
              16.height,
              Row(
                children: [
                  TextButton(
                    onPressed:
                        _submitting ? null : () => finish(context, false),
                    child: Text(
                      languages.lblCancel,
                      style: primaryTextStyle(color: textSecondaryColorGlobal),
                    ),
                  ).expand(),
                  8.width,
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: kAppPrimaryGradient,
                      borderRadius: radius(8),
                    ),
                    child: SizedBox(
                      height: 44,
                      width: double.infinity,
                      child: _submitting
                          ? Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: white,
                                ),
                              ),
                            )
                          : AppButton(
                              margin: EdgeInsets.zero,
                              text: languages.lblSubmitReport,
                              color: Colors.transparent,
                              elevation: 0,
                              textStyle: boldTextStyle(color: white),
                              height: 44,
                              width: double.infinity,
                              onTap: _submit,
                            ),
                    ),
                  ).expand(flex: 2),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
