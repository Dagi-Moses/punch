import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:flutter/material.dart';

class InputWidget extends StatelessWidget {
  final String? hintText;
  final String? errorText;
  final Widget? prefixIcon;
  final double? height;
  final String? topLabel;
  final bool? obscureText;
  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final Key? kKey;
  final TextEditingController? kController;
  final String? kInitialValue;

  InputWidget({
    this.hintText,
    this.prefixIcon,
    this.height = 48.0,
    this.topLabel = "",
    this.obscureText = false,
    required this.onSaved,
    this.keyboardType,
    this.errorText,
    this.onChanged,
    this.validator,
    this.kKey,
    this.kController,
    this.kInitialValue,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(topLabel!),
        const SizedBox(height: 4.0),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: secondaryColor,
            //color: Theme.of(context).buttonColor,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: TextFormField(
            initialValue: kInitialValue,
            controller: kController,
            key: kKey,
            keyboardType: keyboardType,
            onSaved: onSaved,
            onChanged: onChanged,
            validator: validator,
            obscureText: obscureText!,
            decoration: InputDecoration(
                prefixIcon: prefixIcon,
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(74, 77, 84, 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  //gapPadding: 16,
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                errorStyle: const TextStyle(height: 0, color: Colors.transparent),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  //gapPaddings: 16,
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                hintText: hintText,
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.white54),
                errorText: errorText),
          ),
        )
      ],
    );
  }
}
