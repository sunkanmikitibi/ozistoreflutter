import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/features/language/controllers/language_controller.dart';
import 'package:sixam_mart_store/features/order/controllers/order_controller.dart';
import 'package:sixam_mart_store/features/order/widgets/invoice_dialog_widget.dart';
import 'package:sixam_mart_store/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart_store/features/order/domain/models/order_model.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:image/image.dart' as img;

class InVoicePrintScreen extends StatefulWidget {
  final OrderModel? order;
  final List<OrderDetailsModel>? orderDetails;
  final bool? isPrescriptionOrder;
  final double dmTips;
  const InVoicePrintScreen({super.key, required this.order, required this.orderDetails, this.isPrescriptionOrder = false, required this.dmTips});

  @override
  State<InVoicePrintScreen> createState() => _InVoicePrintScreenState();
}

class _InVoicePrintScreenState extends State<InVoicePrintScreen> {
  bool connected = false;
  List<BluetoothInfo>? availableBluetoothDevices;
  bool _isLoading = false;
  final List<int> _paperSizeList = [80, 58];
  int _selectedSize = 80;
  ScreenshotController screenshotController = ScreenshotController();
  String? _warningMessage;

  Future<void> getBluetooth() async {
    setState(() {
      _isLoading = true;
    });

    final List<BluetoothInfo> bluetoothDevices = await PrintBluetoothThermal.pairedBluetooths;
    if (kDebugMode) {
      print("Bluetooth list: $bluetoothDevices");
    }
    connected = await PrintBluetoothThermal.connectionStatus;

    if(!connected) {
      _warningMessage = null;
      Get.find<OrderController>().setBluetoothMacAddress('');
    } else {
      _warningMessage = 'please_enable_your_location_and_bluetooth_in_your_system'.tr;
    }

    setState(() {
      availableBluetoothDevices = bluetoothDevices;
      _isLoading = false;
    });

  }

  Future<void> setConnect(String mac) async {
    final bool result = await PrintBluetoothThermal.connect(macPrinterAddress: mac);

    if (result) {
      setState(() {
        connected = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    getBluetooth();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _printReceipt(Uint8List screenshot) async {
    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
    if (connectionStatus) {
      List<int> ticket = await testTicket(screenshot);
      final result = await PrintBluetoothThermal.writeBytes(ticket);
      if (kDebugMode) {
        print("print result: $result");
      }
    } else {
      showCustomSnackBar('no_thermal_printer_connected'.tr);
    }
  }

  Future<List<int>> testTicket(Uint8List screenshot) async {
    List<int> bytes = [];
    final img.Image? image = img.decodeImage(screenshot);
    img.Image resized = img.copyResize(image!, width: _selectedSize == 80 ? 500 : 365);
    final profile = await CapabilityProfile.load();
    final generator = Generator(_selectedSize == 80 ? PaperSize.mm80 : PaperSize.mm58, profile);

    // Using `ESC *`
    bytes += generator.image(resized);

    bytes += generator.feed(2);
    // bytes += generator.cut();
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Text('paired_bluetooth'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                SizedBox(height: 20, width: 20,
                  child: _isLoading ?  CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ) : InkWell(
                    onTap: () => getBluetooth(),
                    child: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
                  ),
                ),
              ]),

              SizedBox(width: 100, child: DropdownButton<int>(
                hint: Text('select'.tr),
                value: _selectedSize,
                items: _paperSizeList.map((int? value) {
                  return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value''mm'));
                }).toList(),
                onChanged: (int? value) {
                  setState(() {
                    _selectedSize = value!;
                  });
                },
                isExpanded: true, underline: const SizedBox(),
              )),

            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            child: Column(children: [
              availableBluetoothDevices != null && (availableBluetoothDevices?.length ?? 0) > 0 ? ListView.builder(
                itemCount: availableBluetoothDevices?.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return GetBuilder<OrderController>(
                      builder: (orderController) {
                        bool isConnected = connected &&  availableBluetoothDevices![index].macAdress == orderController.getBluetoothMacAddress();

                        return Stack(children: [

                          ListTile(
                            selected: isConnected,
                            onTap: () {
                              if(availableBluetoothDevices?[index].macAdress.isNotEmpty ?? false) {
                                if(!connected) {
                                  orderController.setBluetoothMacAddress(availableBluetoothDevices?[index].macAdress);
                                }
                                setConnect(availableBluetoothDevices?[index].macAdress ?? '');
                              }
                            },
                            title: Text(availableBluetoothDevices?[index].name ?? ''),
                            subtitle: Text(
                              isConnected ? 'connected'.tr : "click_to_connect".tr,
                              style: robotoRegular.copyWith(color: isConnected ? null : Theme.of(context).primaryColor),
                            ),
                          ),

                          if(availableBluetoothDevices?[index].macAdress == orderController.getBluetoothMacAddress())
                            Positioned.fill(
                              child: Align(alignment: Get.find<LocalizationController>().isLtr ? Alignment.centerRight : Alignment.centerLeft, child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeExtraSmall,
                                  horizontal: Dimensions.paddingSizeLarge,
                                ),
                                child: Icon(Icons.check_circle_outline_outlined, color: Theme.of(context).primaryColor,),
                              )),
                            ),
                        ],
                        );
                      }
                  );
                }) : Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: Text(
                  _warningMessage?? '',
                  style: robotoRegular.copyWith(color: Colors.redAccent),
                ),
              ),

              InvoiceDialogWidget(
                order: widget.order, orderDetails: widget.orderDetails, isPrescriptionOrder: widget.isPrescriptionOrder,
                paper80MM: _selectedSize == 80, dmTips: widget.dmTips,
                screenshotController: screenshotController,
              ),
            ]),
          ),
        ),

        CustomButtonWidget(
          buttonText: 'print_invoice'.tr, height: 40,
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
          onPressed: () {
            screenshotController.capture(delay: const Duration(milliseconds: 10)).then((Uint8List? capturedImage) {
              //Capture Done
              if (kDebugMode) {
                print('Captured Image:  $capturedImage');
              }
              _printReceipt(capturedImage!);

            }).catchError((onError) {
              if (kDebugMode) {
                print(onError);
              }
            });
          },
        ),

      ],
    );
    // return _searchingMode ? SingleChildScrollView(
    //   padding: const EdgeInsets.all(Dimensions.fontSizeLarge),
    //   child: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //
    //       Text('paper_size'.tr, style: robotoMedium),
    //       Row(children: [
    //         Expanded(child: RadioListTile(
    //           title: Text('80_mm'.tr),
    //           groupValue: _paper80MM,
    //           dense: true,
    //           contentPadding: EdgeInsets.zero,
    //           value: true,
    //           onChanged: (bool? value) {
    //             _paper80MM = true;
    //             setState(() {});
    //           },
    //         )),
    //         Expanded(child: RadioListTile(
    //           title: Text('58_mm'.tr),
    //           groupValue: _paper80MM,
    //           contentPadding: EdgeInsets.zero,
    //           dense: true,
    //           value: false,
    //           onChanged: (bool? value) {
    //             _paper80MM = false;
    //             setState(() {});
    //           },
    //         )),
    //       ]),
    //       const SizedBox(height: Dimensions.paddingSizeSmall),
    //
    //       ListView.builder(
    //         itemCount: _devices.length,
    //         shrinkWrap: true,
    //         physics: const NeverScrollableScrollPhysics(),
    //         itemBuilder: (context, index) {
    //           return Padding(
    //             padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
    //             child: InkWell(
    //               onTap: () {
    //                 _selectDevice(_devices[index]);
    //                 setState(() {
    //                   _searchingMode = false;
    //                 });
    //               },
    //               child: Stack(children: [
    //
    //                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    //
    //                   Text(_devices[index].name),
    //
    //                   Visibility(
    //                     visible: !Platform.isWindows,
    //                     child: Text(_devices[index].macAdress),
    //                   ),
    //
    //                   index != _devices.length-1 ? Divider(color: Theme.of(context).disabledColor) : const SizedBox(),
    //
    //                 ]),
    //
    //                 (_selectedPrinter != null && _selectedPrinter!.macAdress == _devices[index].macAdress) ? const Positioned(
    //                   top: 5, right: 5,
    //                   child: Icon(Icons.check, color: Colors.green),
    //                 ) : const SizedBox(),
    //
    //               ]),
    //             ),
    //           );
    //         },
    //       ),
    //     ],
    //   ),
    // ) : InvoiceDialogWidget(
    //   order: widget.order, orderDetails: widget.orderDetails, isPrescriptionOrder: widget.isPrescriptionOrder,
    //   onPrint: (i.Image? image) => _printReceipt(image!), paper80MM: _paper80MM, dmTips: widget.dmTips,
    // );
  }
}