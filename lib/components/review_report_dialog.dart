import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/report_profile_reason_model.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:nb_utils/nb_utils.dart';

/// Report dialog for POST `/api/ugc/report-review` with reasons from GET `/api/ugc/report-reasons`.
class ReviewReportDialog extends StatefulWidget {
  final int reviewId;
  final String reviewType;

  const ReviewReportDialog({
    super.key,
    required this.reviewId,
    this.reviewType = 'booking_rating',
  });

  @override
  State<ReviewReportDialog> createState() => _ReviewReportDialogState();
}

class _ReviewReportDialogState extends State<ReviewReportDialog> {
  List<ReportProfileReason> _reasons = [];
  String? _selectedValue;
  final TextEditingController _detailsCont = TextEditingController();
  bool _loadingReasons = true;
  String? _loadError;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _detailsCont.addListener(() => setState(() {}));
    _fetchReasons();
  }

  Future<void> _fetchReasons() async {
    setState(() {
      _loadingReasons = true;
      _loadError = null;
    });
    try {
      final list = await getReportProfileReasons();
      if (!mounted) return;
      setState(() {
        _reasons = list;
        _selectedValue = list.isNotEmpty ? list.first.value : null;
        _loadingReasons = false;
        if (list.isEmpty) {
          _loadError = languages.lblReportProfileNoReasons;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingReasons = false;
        _loadError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _detailsCont.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || _selectedValue == null || _selectedValue!.isEmpty) return;
    setState(() => _submitting = true);
    try {
      final details = _detailsCont.text.trim();
      final res = await reportReview(
        reviewId: widget.reviewId,
        reason: _selectedValue!,
        reviewType: widget.reviewType,
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
                languages.lblReportReviewTitle,
                style: boldTextStyle(size: 18),
              ),
              8.height,
              Text(
                languages.lblSelectReportReason,
                style: secondaryTextStyle(size: 13),
              ),
              8.height,
              if (_loadingReasons)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                    ),
                  ),
                )
              else if (_loadError != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _loadError!,
                    style: secondaryTextStyle(color: redColor, size: 13),
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  // ignore: deprecated_member_use
                  value: _selectedValue,
                  dropdownColor: context.cardColor,
                  menuMaxHeight: 280,
                  decoration: inputDecoration(
                    context,
                    hint: languages.lblSelectReportReason,
                    fillColor: context.scaffoldBackgroundColor,
                  ),
                  items: _reasons
                      .map(
                        (r) => DropdownMenuItem<String>(
                          value: r.value,
                          child: Text(
                            r.label,
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
                          if (val != null) setState(() => _selectedValue = val);
                        },
                ),
              12.height,
              AppTextField(
                textFieldType: TextFieldType.MULTILINE,
                controller: _detailsCont,
                maxLength: 2000,
                minLines: 3,
                maxLines: 6,
                enabled: !_submitting && !_loadingReasons && _loadError == null && _reasons.isNotEmpty,
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
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(0, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      languages.lblCancel,
                      style: primaryTextStyle(color: textSecondaryColorGlobal),
                    ),
                  ).expand(flex: 2),
                  8.width,
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: kAppPrimaryGradient,
                      borderRadius: radius(8),
                    ),
                    child: SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: _submitting
                          ? Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
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
                              textStyle:
                                  boldTextStyle(color: white, size: 14),
                              height: 40,
                              width: double.infinity,
                              onTap: () {
                                if (_loadingReasons ||
                                    _reasons.isEmpty ||
                                    _selectedValue == null) {
                                  return;
                                }
                                _submit();
                              },
                            ),
                    ),
                  ).expand(flex: 1),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
