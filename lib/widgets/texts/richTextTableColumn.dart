
import 'package:flutter/material.dart';
import 'package:paged_datatable/paged_datatable.dart';
import 'package:punch/admin/core/constants/color_constants.dart';


final class HighlightQueryColumn<K extends Comparable<K>, T>
    extends EditableTableColumn<K, T, String> {
  final InputDecoration inputDecoration;
  final TextStyle defaultStyle;
  final TextStyle highlightStyle;
  final String fieldLabel;
  final String? query;

  HighlightQueryColumn({
    required super.title,
    
    super.id,
    super.size = const FractionalColumnSize(.1),
    super.format = const AlignColumnFormat(alignment: Alignment.centerLeft),
    super.tooltip,
    super.sortable = false,
    required super.getter,
   required super.setter ,
    required this.fieldLabel,
    this.defaultStyle = const TextStyle(color: Colors.black), // Default value
    this.highlightStyle = const TextStyle(
      color: punchRed,
      fontWeight: FontWeight.bold,
    ), // Defaul
    this.query,
    this.inputDecoration =
        const InputDecoration(isDense: true, border: OutlineInputBorder()),
  });

  @override
  Widget build(BuildContext context, T item, int index) {
    // Adapt the getter to match the required signature
    String Function(T, int) _adaptedGetter = (item, _) => getter(item, index) ?? "";

   

    return HighlightTextFieldCell<T>(
      getter: _adaptedGetter,
      
      index: index,
      item: item,
      key: ValueKey(item),
      inputDecoration: inputDecoration,
      defaultStyle: defaultStyle,
      highlightStyle: highlightStyle,
      query: query,
      label: fieldLabel,
    );
  }
}

class HighlightTextFieldCell<T> extends StatefulWidget {
  final String Function(T, int) getter;
 
  final int index;
  final T item;
  final InputDecoration inputDecoration;
  final TextStyle defaultStyle;
  final TextStyle highlightStyle;
  final String? query;
  final String label;
  final bool showTooltip;
  final TextStyle? tooltipStyle;
  final BoxConstraints? tooltipConstraints;
  final double bottomSheetBreakpoint;

  const HighlightTextFieldCell({
    Key? key,
    required this.getter,
   
    required this.index,
    required this.item,
    required this.inputDecoration,
    this.defaultStyle = const TextStyle(color: Colors.black), // Default value
    this.highlightStyle = const TextStyle(
      color: punchRed,
      fontWeight: FontWeight.bold,
    ), // Defaul
    required this.label,
    this.query,
    this.showTooltip = false,
    this.tooltipStyle,
    this.tooltipConstraints,
    this.bottomSheetBreakpoint = 600.0,
  }) : super(key: key);

  @override
  _HighlightTextFieldCellState<T> createState() =>
      _HighlightTextFieldCellState<T>();
}

class _HighlightTextFieldCellState<T> extends State<HighlightTextFieldCell<T>> {
  late final TextEditingController textController;
  String? previousValue;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    previousValue = widget.getter(widget.item, widget.index);
    textController = TextEditingController(text: previousValue);
  }

  TextSpan _buildRichText(String text, String? query) {
    if (query == null || query.isEmpty) {
      return TextSpan(text: text, style: widget.defaultStyle);
    }

    final matches = query.allMatches(text.toLowerCase());
    if (matches.isEmpty) {
      return TextSpan(text: text, style: widget.defaultStyle);
    }

    final List<TextSpan> spans = [];
    int currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: widget.defaultStyle,
        ));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: widget.highlightStyle,
      ));
      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: widget.defaultStyle,
      ));
    }

    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    String cellValue = widget.getter(widget.item, widget.index);

    return GestureDetector(
      onDoubleTap: () async {
       
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          var offset = renderBox.localToGlobal(Offset.zero);
          var availableSize = MediaQuery.of(context).size;
          var drawWidth = availableSize.width / 3;
          var drawHeight = availableSize.height / 3;
          var size = renderBox.size;

          double x, y;
          if (offset.dx + drawWidth > availableSize.width) {
            x = offset.dx - drawWidth + size.width;
          } else {
            x = offset.dx;
          }

          if (offset.dy + drawHeight > availableSize.height) {
            y = offset.dy - drawHeight - size.height;
          } else {
            y = offset.dy + size.height;
          }
          
      },
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(),
            )
          : (widget.showTooltip
              ? Tooltip(
                  richMessage: WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: Container(
                      constraints: widget.tooltipConstraints ??
                          BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width / 2),
                      child: RichText(
                        text: _buildRichText(cellValue, widget.query),
                      ),
                    ),
                  ),
                  child: RichText(
                    text: _buildRichText(cellValue, widget.query),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : RichText(
                  text: _buildRichText(cellValue, widget.query),
                  overflow: TextOverflow.ellipsis,
                )),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
