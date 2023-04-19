import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../style/color_schema.dart';
import '../utils/decimal_text_input_formatter.dart';

class EntryDecimal extends StatelessWidget {
  final void Function(String)? onSubmitted;
  EntryDecimal({
    super.key,
    this.onSubmitted,
  });

  final _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        DecimalTextInputFormatter(decimalRange: 2),
      ],
      controller: _textEditingController,
      onSubmitted: (value) {
        _textEditingController.clear();
        onSubmitted?.call(value);
      },
      style: const TextStyle(color: colorI1),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.all(8),
        hintText: 'Input height',
        hintStyle: TextStyle(
          color: colorI1,
          fontSize: 13,
        ),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorI1),
            borderRadius: BorderRadius.all(Radius.circular(45))),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorI1),
            borderRadius: BorderRadius.all(Radius.circular(23))),
        fillColor: Colors.transparent,
        filled: true,
      ),
    );
  }
}
