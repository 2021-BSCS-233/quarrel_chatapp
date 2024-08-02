import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatelessWidget {
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Color? fieldColor;
  final String fieldLabel;
  final TextEditingController controller;
  final double? fieldHeight;
  final double? fieldRadius;
  final double? horizontalMargin;
  final double? verticalMargin;
  final double? contentTopPadding;
  final Function? onChange;
  final Function? hideLetters;
  final List<TextInputFormatter>? inputFormats;
  final int? maxLength;
  final int? maxLines;
  final FocusNode? fieldFocusNode;

  const InputField(
      {super.key,
      required this.fieldLabel,
      required this.controller,
      this.suffixIcon,
      this.prefixIcon,
      this.fieldColor,
      this.fieldHeight,
      this.onChange,
      this.hideLetters,
      this.inputFormats,
      this.fieldRadius,
      this.horizontalMargin,
      this.verticalMargin,
      this.maxLength,
      this.contentTopPadding,
      this.maxLines,
      this.fieldFocusNode});

  @override
  Widget build(BuildContext context) {
    bool hidden = true;
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: horizontalMargin ?? 5, vertical: verticalMargin ?? 0),
      height: fieldHeight,
      child: TextFormField(
        focusNode: fieldFocusNode,
        inputFormatters: inputFormats,
        maxLength: maxLength,
        minLines: 1,
        maxLines: maxLines ?? 1,
        onChanged: (e) {
          onChange != null ? onChange!() : null;
        },
        obscureText: suffixIcon == CupertinoIcons.eye ? hidden : false,
        controller: controller,
        decoration: InputDecoration(
          counterText: '',
          isCollapsed: true,
          contentPadding: EdgeInsets.fromLTRB(prefixIcon != null ? 5.0 : 15,
              contentTopPadding == null ? 6.5 : contentTopPadding!, 5.0, 5.0),
          //made it so if you pass all_inclusive icon it becomes invisible as a
          //temp solution for this field height not working problem
          //PS all_inclusive icon cuz its the least use apparently
          prefixIcon: prefixIcon == Icons.all_inclusive
              ? Icon(
                  prefixIcon,
                  color: Colors.transparent,
                )
              : prefixIcon != null
                  ? Icon(prefixIcon)
                  : null,
          suffixIcon: suffixIcon == CupertinoIcons.eye
              ? InkWell(
                  onTap: () {
                    hidden = !hidden;
                  },
                  child: const Icon(CupertinoIcons.eye),
                )
              : suffixIcon == Icons.all_inclusive
                  ? Icon(
                      suffixIcon,
                      color: Colors.transparent,
                    )
                  : suffixIcon != null
                      ? Icon(suffixIcon)
                      : null,
          fillColor: fieldColor ?? Color(0xFF202020),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(fieldRadius ?? 25)),
            borderSide: BorderSide.none,
          ),
          label: Text(fieldLabel),
          hintText: '',
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
      ),
    );
  }
}
