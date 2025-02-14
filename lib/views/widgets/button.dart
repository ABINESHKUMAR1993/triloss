import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../constants/main_colors.dart';
import '../../constants/text_helpers.dart';

class Button extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final bool isDefault;
  final RxBool isLoading;

  const Button({
    super.key,
    this.onTap,
    required this.text,
    required this.isDefault,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDefault ? cRed : cWhite,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: cWhite),
        ),
      ),
      child:
          isLoading.value
              ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text("Loading...", style: TextHelper.pop14W500W),
                ],
              )
              : Center(
                child: Text(
                  text,
                  style: TextStyle(color: isDefault ? cWhite : cPrimaryColor),
                ),
              ),
    );
  }
}
