import 'package:flutter/material.dart';
import 'package:soft_keyboard/src/utils/key_rows.dart';

import '../utils/enums.dart';

class NumericKeyboard extends StatefulWidget {
  const NumericKeyboard({
    required this.controller,
    this.height = 260,
    this.backgroundColor = const Color(0xff0a0a0a),
    this.actionKeyColor = const Color(0xff171717),
    this.numericKeyColor = const Color(0xff2d2d2d),
    this.keyTextStyle,
    this.enterKeyIcon,
    this.backspaceKeyIcon,
    this.keyBorderRadius = 10,
    this.actionKeyIconColor = Colors.white,
    this.onEnterTapped,
    this.onChanged,
    super.key,
  });

  /// The height of the keyboard
  final double height;

  /// The controller for the text field
  final TextEditingController controller;

  /// The color for the keyboard background
  final Color backgroundColor;

  /// The color for the action keys
  final Color actionKeyColor;

  /// The color for the alphanumeric keys
  final Color numericKeyColor;

  /// The text style for the numeric keys
  final TextStyle? keyTextStyle;

  /// The icon to show on enter key
  final IconData? enterKeyIcon;

  /// The icon to show on backspace key
  final IconData? backspaceKeyIcon;

  /// The border radius for the keys
  final double keyBorderRadius;

  /// Action key icon color
  final Color actionKeyIconColor;

  /// Callback Function for Enter Key
  final Function()? onEnterTapped;

  /// Callback when text is changed
  final Function(String)? onChanged;

  @override
  State<NumericKeyboard> createState() => _NumericKeyboardState();
}

class _NumericKeyboardState extends State<NumericKeyboard> {
  // Renders the keyboard rows
  Widget keyboardRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys
          .map(
            (e) => e == SpecialKey.space.name
                ? Expanded(child: actionKey(SpecialKey.space))
                : e.length > 1
                    ? actionKey(SpecialKey.values
                        .firstWhere((element) => element.name == e))
                    : numberKey(e),
          )
          .toList(),
    );
  }

  // Renders the number keys
  Widget numberKey(String kKey) {
    return InkWell(
      onTap: () {
        final selection = widget.controller.selection;
        final text = widget.controller.text;

        if (selection.isValid) {
          final newText = text.substring(0, selection.baseOffset) + kKey + text.substring(selection.baseOffset);
          widget.controller.text = newText;
          widget.controller.selection = selection.copyWith(
            baseOffset: selection.baseOffset + kKey.length,
            extentOffset: selection.baseOffset + kKey.length,
          );
        } else {
          widget.controller.text += kKey;
        }

        if (widget.onChanged != null) {
          widget.onChanged!(widget.controller.text);
        }
      },
      borderRadius: BorderRadius.circular(widget.keyBorderRadius),
      child: Container(
        width: MediaQuery.of(context).size.width / 4 - 12.5,
        height: 52,
        margin: const EdgeInsets.only(left: 10, top: 10),
        decoration: BoxDecoration(
          color: KeyRows.numericSpecialCases.contains(kKey)
              ? widget.actionKeyColor
              : widget.numericKeyColor,
          borderRadius: BorderRadius.circular(widget.keyBorderRadius),
        ),
        child: Center(
          child: Text(
            kKey,
            style: widget.keyTextStyle ??
                const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }

  // Returns the icon for the action keys
  Widget? getActionKeyIcon(SpecialKey key) {
    IconData iconData;
    Color iconColor = widget.actionKeyIconColor;
    double iconSize = 24;

    if (key == SpecialKey.backspace) {
      iconData = widget.backspaceKeyIcon ?? Icons.backspace_outlined;
    } else {
      iconData = widget.enterKeyIcon ?? Icons.keyboard_return;
    }

    return Icon(
      iconData,
      color: iconColor,
      size: iconSize,
    );
  }

  // Renders the action keys
  Widget actionKey(SpecialKey kKey) {
    return InkWell(
      onTap: () {
        if (kKey == SpecialKey.backspace) {
          if (widget.controller.text.isNotEmpty) {
            final selection = widget.controller.selection;
            final text = widget.controller.text;
            if (!selection.isValid || selection.baseOffset == 0) {
              // If there's no valid selection, or the caret is at the beginning,
              // there's nothing to remove, so just return.
              return;
            }
            final newCaretPosition = selection.baseOffset - 1; // Move caret back by one.
            // Create the new text by removing the character before the caret.
            final newText = text.substring(0, newCaretPosition) + text.substring(selection.baseOffset);

            // Update the text and set the new caret position.
            widget.controller.text = newText;
            widget.controller.selection = TextSelection.collapsed(offset: newCaretPosition);

            if (widget.onChanged != null) {
              widget.onChanged!(widget.controller.text);
            }
          }
        } else if (kKey == SpecialKey.enter) {
          if (widget.onEnterTapped != null) {
            widget.onEnterTapped!();
          } else {
            widget.controller.text += '\n';
          }
        }
      },
      borderRadius: BorderRadius.circular(widget.keyBorderRadius),
      child: Container(
        width: MediaQuery.of(context).size.width / 4 - 12.5,
        height: 52,
        margin: const EdgeInsets.only(left: 10, top: 10),
        decoration: BoxDecoration(
          color: widget.actionKeyColor,
          borderRadius: BorderRadius.circular(widget.keyBorderRadius),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: getActionKeyIcon(kKey),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.height,
      color: widget.backgroundColor,
      child: Wrap(
        // spacing: 10.0,
        // runSpacing: 10.0,
        children: List.generate(
          KeyRows.numericRow.length,
          (index) {
            return KeyRows.numericRow[index] == SpecialKey.enter.name
                ? actionKey(SpecialKey.enter)
                : KeyRows.numericRow[index] == SpecialKey.backspace.name
                    ? actionKey(SpecialKey.backspace)
                    : numberKey(KeyRows.numericRow[index]);
          },
        ),
      ),
    );
  }
}
