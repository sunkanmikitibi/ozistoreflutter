import 'package:sixam_mart_store/features/store/controllers/store_controller.dart';
import 'package:sixam_mart_store/features/store/domain/models/item_model.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:sixam_mart_store/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FoodVariationViewWidget extends StatefulWidget {
  final StoreController storeController;
  final Item? item;
  const FoodVariationViewWidget({super.key, required this.storeController, required this.item});

  @override
  State<FoodVariationViewWidget> createState() => _FoodVariationViewWidgetState();
}

class _FoodVariationViewWidgetState extends State<FoodVariationViewWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Text('variation'.tr, style: robotoBold),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      widget.storeController.variationList!.isNotEmpty ? ListView.builder(
        itemCount: widget.storeController.variationList!.length,
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemBuilder: (context, index){
          return Stack(children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
              child: Column(children: [
                Row(children: [
                  Expanded(child: CustomTextFieldWidget(
                    hintText: 'name'.tr,
                    showTitle: true,
                    // showShadow: true,
                    controller: widget.storeController.variationList![index].nameController,
                  )),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                    child: CheckboxListTile(
                      value: widget.storeController.variationList![index].required,
                      title: Text('required'.tr),
                      tristate: true,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value){
                        widget.storeController.setVariationRequired(index);
                      },
                    ),
                  )),
                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Text('select_type'.tr, style: robotoMedium),

                  Row( children: [
                    InkWell(
                      onTap: () =>  widget.storeController.changeSelectVariationType(index),
                      child: Row(children: [
                        Radio<bool>(
                          value: true,
                          groupValue: widget.storeController.variationList![index].isSingle,
                          onChanged: (bool? value){
                            widget.storeController.changeSelectVariationType(index);
                          },
                          activeColor: Theme.of(context).primaryColor,
                        ),
                        Text('single'.tr)
                      ]),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeLarge),

                    InkWell(
                      onTap: () =>  widget.storeController.changeSelectVariationType(index),
                      child: Row(children: [
                        Radio<bool>(
                          value: false,
                          groupValue: widget.storeController.variationList![index].isSingle,
                          onChanged: (bool? value){
                            widget.storeController.changeSelectVariationType(index);
                          },
                          activeColor: Theme.of(context).primaryColor,
                        ),
                        Text('multiple'.tr)
                      ]),
                    ),
                  ]),
                ]),

                Visibility(
                  visible: !widget.storeController.variationList![index].isSingle,
                  child: Row(children: [
                    Flexible(child: CustomTextFieldWidget(
                      hintText: 'minimum'.tr,
                      showTitle: true,
                      // showShadow: true,
                      inputType: TextInputType.number,
                      isNumber: true,
                      controller: widget.storeController.variationList![index].minController,
                    )),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Flexible(child: CustomTextFieldWidget(
                      hintText: 'maximum'.tr,
                      inputType: TextInputType.number,
                      showTitle: true,
                      // showShadow: true,
                      isNumber: true,
                      controller: widget.storeController.variationList![index].maxController,
                    )),

                  ]),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    ListView.builder(
                      itemCount: widget.storeController.variationList![index].options!.length,
                      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                          child: Row(children: [
                            Flexible(flex: 4, child: CustomTextFieldWidget(
                              hintText: 'option_name'.tr,
                              showTitle: true,
                              // showShadow: true,
                              controller: widget.storeController.variationList![index].options![i].optionNameController,
                            )),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Flexible(flex: 4, child: CustomTextFieldWidget(
                              hintText: 'additional_price'.tr,
                              showTitle: true,
                              // showShadow: true,
                              isAmount: true,
                              controller: widget.storeController.variationList![index].options![i].optionPriceController,
                              inputType: TextInputType.number,
                              inputAction: TextInputAction.done,
                            )),

                            Flexible(flex: 1, child: Padding(
                              padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                              child: widget.storeController.variationList![index].options!.length > 1 ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => widget.storeController.removeOptionVariation(index, i),
                              ) : const SizedBox(),
                            )),
                          ]),
                        );
                      },
                    ),

                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    InkWell(
                      onTap: () {
                        widget.storeController.addOptionVariation(index);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall), border: Border.all(color: Theme.of(context).primaryColor)),
                        child: Text('add_new_option'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                      ),
                    ),
                  ]),
                ),

              ]),
            ),

            Align(alignment: Alignment.topRight, child: IconButton(icon: const Icon(Icons.clear),
              onPressed: () => widget.storeController.removeVariation(index),
            )),
          ]);
        },
      ) : const SizedBox(),

      widget.storeController.variationList!.isNotEmpty ? InkWell(
        onTap: () {
          widget.storeController.addVariation();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
          child: Text('add_new_variation'.tr, style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeDefault)),
        ),
      ) : Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 0, blurRadius: 5)],
        ),
        child: InkWell(
          onTap: () {
            widget.storeController.addVariation();
          },
          child: Container(
            width: context.width,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
            decoration: BoxDecoration(color: Theme.of(context).disabledColor.withOpacity(0.1), borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
            child: Column(children: [

              const Icon(Icons.add, size: 24),

              Text('add_variation'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),

            ]),
          ),
        ),
      ),

      const SizedBox(height: Dimensions.paddingSizeLarge),

    ]);
  }
}