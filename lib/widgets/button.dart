import 'package:flutter/material.dart';

import '../style/color_schema.dart';

class Button extends StatelessWidget {
  final String? label;
  final Function()? onPressed;
  Button({super.key, this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(const Size(10, 90)),
          overlayColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.black.withOpacity(0.1);
              }
              return primaryColor; // используется цвет по умолчанию
            },
          ),
          backgroundColor: MaterialStateProperty.all<Color>(
              const Color.fromARGB(87, 33, 149, 243)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(60.0),
                  side: const BorderSide(color: primaryColor)))),
      onPressed: onPressed,
      child: Text(
        '$label',
        style: TextStyle(color: mainColor),
      ),
    );
  }
}
