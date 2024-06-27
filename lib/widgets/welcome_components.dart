
part of '../../animated_login.dart';

class _Title extends StatelessWidget {
  /// Column of logo and welcome texts.
  const _Title({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginTexts = context.read<LoginTexts>();
    final loginTheme = context.watch<LoginTheme>();
    return Padding(
      padding: loginTheme.titlePadding ??
          EdgeInsets.symmetric(vertical: DynamicSize(context).height * .8),
      child: BaseText(
        context.select<Auth, bool>((Auth auth) => auth.isAnimatedLogin)
            ? loginTexts.welcomeBack
            : loginTexts.welcome,
        style: TextStyles(context)
            .titleStyle(color: Colors.white)
            .merge(context.read<LoginTheme>().welcomeTitleStyle),
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginTexts = context.read<LoginTexts>();
    final loginTheme = context.watch<LoginTheme>();
    return Padding(
      padding: loginTheme.descriptionPadding ??
          EdgeInsets.symmetric(
            vertical:
                DynamicSize(context).height * (loginTheme.isLandscape ? 3 : 2),
          ),
      child: NotFittedText(
        context.select<Auth, bool>((Auth auth) => auth.isAnimatedLogin)
            ? loginTexts.welcomeBackDescription
            : loginTexts.welcomeDescription,
        style: TextStyles(context)
            .bodyStyle()
            .merge(context.read<LoginTheme>().welcomeDescriptionStyle),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.logo, Key? key}) : super(key: key);
  final Widget? logo;

  @override
  Widget build(BuildContext context) {
    final dynamicSize = DynamicSize(context);
    final loginTheme = context.read<LoginTheme>();
    return Container(
      constraints: BoxConstraints.tight(
        loginTheme.logoSize ??
            Size.fromHeight(
              dynamicSize.responsiveSize * (loginTheme.isLandscape ? 30 : 25),
            ),
      ),
      padding: loginTheme.logoPadding ??
          EdgeInsets.symmetric(
            vertical: dynamicSize.height * (loginTheme.isLandscape ? 2.8 : .8),
          ),
      child: logo,
    );
  }
}

class _ChangeActionButton extends StatelessWidget {
  /// Change action button in the welcome part.
  /// * Switches between the auth modes (login/signup).
  const _ChangeActionButton({required this.animate, Key? key})
      : super(key: key);

  /// Animate callback
  final AsyncCallback animate;

  @override
  Widget build(BuildContext context) {
    final loginTexts = context.read<LoginTexts>();
    final loginTheme = context.read<LoginTheme>();
    return RoundedButton(
      buttonText:
        
               loginTexts.login,
      onPressed: animate,
      borderColor: Colors.white,
      backgroundColor: Colors.red.shade700,
      buttonStyle: loginTheme.changeActionButtonStyle,
    );
  }
}

// class _ChangeActionTitle extends StatelessWidget {
//   /// Change action title in the welcome part.
//   // ignore: prefer_const_constructors_in_immutables
//   _ChangeActionTitle({this.showButtonText = false, this.animate, Key? key})
//       : super(key: key);

//   /// Determines whether to show button text or not
//   final bool showButtonText;

//   /// Animate callback
//   final VoidCallback? animate;

//   @override
//   Widget build(BuildContext context) {
//     final loginTexts = context.read<LoginTexts>();
//     final loginTheme = context.watch<LoginTheme>();
//     return Padding(
//       padding: loginTheme.changeActionPadding ??
//           (loginTheme.isLandscape
//               ? EdgeInsets.symmetric(vertical: DynamicSize(context).height * 2)
//               : EdgeInsets.only(top: DynamicSize(context).height * 2)),
//       child: showButtonText
//           ? Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 _changeActionTitle(context, loginTexts),
//                 _changeActionGesture(context, animate)
//               ],
//             )
//           : _changeActionTitle(context, loginTexts),
//     );
//   }

//   Widget _changeActionTitle(BuildContext context, LoginTexts loginTexts) =>
//       BaseText(
      
          
//            loginTexts.alreadyHaveAnAccount,
//         style: TextStyles(context)
//             .subtitleTextStyle()
//             .merge(context.read<LoginTheme>().changeActionTextStyle),
//       );

//   Widget _changeActionGesture(BuildContext context, VoidCallback? animate) =>
//       Padding(
//         padding: DynamicSize(context).lowLeftPadding,
//         child: InkWell(
//           onTap: animate,
//           child: _changeActionText(context),
//         ),
//       );

//   Widget _changeActionText(BuildContext context) {
//     final loginTexts = context.read<LoginTexts>();
//     return BaseText(
     
       
//           loginTexts.login,
//       style: TextStyles(context)
//           .subtitleTextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             decoration: TextDecoration.underline,
//           )
//           .merge(context.read<LoginTheme>().changeActionTextStyle),
//     );
//   }
// }

