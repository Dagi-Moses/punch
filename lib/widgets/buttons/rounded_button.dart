import 'package:punch/decorations/button_styles.dart';
import 'package:punch/decorations/text_styles.dart';
import 'package:punch/providers/auth.dart';
import 'package:punch/providers/authProvider.dart';
import 'package:punch/providers/login_theme.dart';
import 'package:punch/responsiveness/dynamic_size.dart';
import 'package:punch/widgets/texts/base_text.dart';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// An [ElevatedButton] with rounded corners.
class RoundedButton extends StatefulWidget {
  const RoundedButton({
    required this.buttonText,
    required this.onPressed,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.borderWidth = 1.4,
    this.width,
    this.height,
    this.buttonStyle,
    Key? key,
  }) : super(key: key);

  final String buttonText;
  final AsyncCallback? onPressed;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final double borderWidth;
  final double? width;
  final double? height;
  final ButtonStyle? buttonStyle;

  @override
  State<RoundedButton> createState() => _RoundedButtonState();
}

class _RoundedButtonState extends State<RoundedButton> {
  late LoginTheme loginTheme;

  @override
  Widget build(BuildContext context) {
    loginTheme = context.read<LoginTheme>();
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final loading = authProvider.textButtonLoading;
        return AnimatedContainer(
          width: _buttonWidth(loading),
          height: _buttonHeight,
          duration: const Duration(milliseconds: 300),
          child: _button(loading),
        );
      },
    );
  }

  Widget _button(bool loading) => ElevatedButton(
        style: widget.buttonStyle != null
            ? widget.buttonStyle!
                .merge(_defaultButtonStyle(context, loginTheme.isLandscape))
            : _defaultButtonStyle(context, loginTheme.isLandscape),
        onPressed: widget.onPressed,
        child: _buttonChild(loading),
      );

  Widget _buttonChild(bool loading) => loading
      ? SizedBox(
          height: _loadingSize(context),
          width: _loadingSize(context),
          child:
              CircularProgressIndicator(color: loginTheme.loadingButtonColor),
        )
      : BaseText(widget.buttonText, forceDefaultStyle: true);

  double _loadingSize(BuildContext context) =>
      loginTheme.loadingButtonSize ?? DynamicSize(context).responsiveSize * 10;

  double _buttonWidth(bool loading) => loading
      ? _loadingSize(context) * 3.3
      : widget.width ??
          DynamicSize(context).width * (loginTheme.isLandscape ? 14 : 38);

  double get _buttonHeight =>
      widget.height ??
      DynamicSize(context).height * (loginTheme.isLandscape ? 9 : 7.3);

  ButtonStyle _defaultButtonStyle(BuildContext context, bool isLandscape) =>
      ButtonStyles(context).roundedStyle(
        borderWidth: widget.borderWidth,
        backgroundColor: widget.backgroundColor,
        borderColor:
            widget.borderColor ?? (isLandscape ? Colors.white : Colors.white),
        borderRadius: widget.borderRadius,
        size: Size(_buttonWidth(false), _buttonHeight),
        textStyle: TextStyles(context).bodyStyle(
          color: isLandscape ? Colors.white : Theme.of(context).primaryColor,
          fontWeight: FontWeight.w500,
        ),
        foregroundColor: isLandscape ? Colors.white : Colors.red.shade700,
      );
}
