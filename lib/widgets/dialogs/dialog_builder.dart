import 'package:punch/animated_login.dart';
import 'package:punch/decorations/text_styles.dart';
import 'package:punch/providers/login_theme.dart';
import 'package:punch/widgets/dialogs/animated_dialog.dart';

import 'package:punch/widgets/texts/base_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Dialog builder for displaying dialogs.
class DialogBuilder {
  /// Dialog builder for displaying dialogs.
  const DialogBuilder(this.context);

  /// Context to customize sizes.
  final BuildContext context;

  /// Shows error dialog.
  void showErrorDialog(String text) =>
      AnimatedDialog(contentText: text).show<void>(context);

  /// Shows multiple selection dialog.
  

  Widget _getSelectTitle(String titleText) => BaseText(
        titleText,
        style: context.read<LoginTheme>().dialogTheme?.titleStyle ??
            TextStyles(context).subBodyStyle(
              color: Theme.of(context).primaryColor.withOpacity(.7),
            ),
      );
}
