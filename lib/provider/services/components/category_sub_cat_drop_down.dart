import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/caregory_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';

Future<CategoryData?> _showCategoryPicker(BuildContext context, List<CategoryData> items, String title) async {
  final TextEditingController searchCtrl = TextEditingController();
  List<CategoryData> filtered = List.from(items);

  return showDialog<CategoryData>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: Text(title, style: boldTextStyle()),
        contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 8),
        content: SizedBox(
          width: double.maxFinite,
          height: 380,
          child: Column(
            children: [
              TextField(
                controller: searchCtrl,
                autofocus: true,
                style: primaryTextStyle(),
                decoration: InputDecoration(
                  hintText: languages.lblSearchHere,
                  prefixIcon: Icon(Icons.search, size: 20),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                onChanged: (q) => setDialogState(() {
                  filtered = items.where((e) => e.name.validate().toLowerCase().contains(q.toLowerCase())).toList();
                }),
              ),
              8.height,
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text(languages.noDataFound, style: secondaryTextStyle()))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => ListTile(
                          dense: true,
                          title: Text(filtered[i].name.validate(), style: primaryTextStyle()),
                          onTap: () => Navigator.pop(ctx, filtered[i]),
                        ),
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(languages.lblCancel),
          ),
        ],
      ),
    ),
  );
}

class CategorySubCatDropDown extends StatefulWidget {
  final int? categoryId;
  final int? subCategoryId;
  final Function(int? val) onCategorySelect;
  final Function(int? val) onSubCategorySelect;
  final bool? isCategoryValidate;
  final bool? isSubCategoryValidate;
  final Color? fillColor;

  CategorySubCatDropDown({this.categoryId, this.subCategoryId, required this.onSubCategorySelect, required this.onCategorySelect, this.isSubCategoryValidate, this.isCategoryValidate, this.fillColor});

  @override
  State<CategorySubCatDropDown> createState() => _CategorySubCatDropDownState();
}

class _CategorySubCatDropDownState extends State<CategorySubCatDropDown> {
  List<CategoryData> categoryList = [];
  List<CategoryData> subCategoryList = [];

  CategoryData? selectedCategory;
  CategoryData? selectedSubCategory;

  final _catKey = GlobalKey<FormFieldState>();
  final _subCatKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
    getCategory();
  }

  Future<void> getSubCategory({required int categoryId}) async {
    await getSubCategoryList(catId: categoryId).then((value) {
      subCategoryList = value.data.validate();

      if (widget.subCategoryId != null) {
        selectedSubCategory = value.data!.firstWhere((e) => e.id == widget.subCategoryId);
        widget.onSubCategorySelect.call(selectedSubCategory?.id.validate());
      }
      setState(() {});
    }).catchError((e) { log(e.toString()); });
  }

  Future<void> getCategory() async {
    appStore.setLoading(true);
    await getCategoryList(perPage: 'all').then((value) {
      categoryList = value.data!;

      if (widget.categoryId != null) {
        selectedCategory = value.data!.firstWhere((e) => e.id == widget.categoryId);
        widget.onCategorySelect.call(selectedCategory?.id.validate());
        if (widget.subCategoryId != null) getSubCategory(categoryId: selectedCategory!.id.validate());
      }
      setState(() {});
    }).catchError((e) { toast(e.toString(), print: true); });
    appStore.setLoading(false);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget _buildPickerField({
    required GlobalKey<FormFieldState> fieldKey,
    required String label,
    required CategoryData? selected,
    required List<CategoryData> items,
    required bool validate,
    required Future<void> Function(CategoryData) onSelect,
  }) {
    return FormField<CategoryData>(
      key: fieldKey,
      initialValue: selected,
      validator: validate ? (v) => v == null ? errorThisFieldRequired : null : null,
      builder: (state) => InkWell(
        onTap: () async {
          if (items.isEmpty) return;
          final result = await _showCategoryPicker(context, items, label);
          if (result != null) {
            await onSelect(result);
            state.didChange(result);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: InputDecorator(
          decoration: inputDecoration(context, fillColor: widget.fillColor ?? context.scaffoldBackgroundColor, hint: label).copyWith(
            errorText: state.errorText,
            suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey),
          ),
          child: Text(
            selected?.name.validate() ?? '',
            style: primaryTextStyle(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPickerField(
          fieldKey: _catKey,
          label: languages.hintSelectCategory,
          selected: selectedCategory,
          items: categoryList,
          validate: widget.isCategoryValidate.validate(value: true),
          onSelect: (value) async {
            selectedCategory = value;
            widget.onCategorySelect.call(value.id.validate());
            if (selectedSubCategory != null) {
              selectedSubCategory = null;
              subCategoryList.clear();
              widget.onSubCategorySelect.call(null);
              _subCatKey.currentState?.didChange(null);
            }
            await getSubCategory(categoryId: value.id.validate());
          },
        ),
        16.height,
        _buildPickerField(
          fieldKey: _subCatKey,
          label: selectedCategory == null ? languages.hintSelectCategory : languages.lblSelectSubCategory,
          selected: selectedSubCategory,
          items: subCategoryList,
          validate: widget.isSubCategoryValidate.validate(value: false),
          onSelect: (value) async {
            selectedSubCategory = value;
            widget.onSubCategorySelect.call(value.id.validate());
            setState(() {});
          },
        ),
      ],
    );
  }
}
