import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';

const Color darkBlue = Color.fromARGB(255, 18, 32, 47);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: darkBlue,
      ),
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(
          child: ExampleMultiPageText(),
        ),
      ),
    );
  }
}

class MultiPageText extends StatefulWidget {
  /// The entire text that has to be distributed across one or
  /// more pages.
  final String fullText;

  /// The [TextStyle] that is applied to the [fullText].
  final TextStyle textStyle;

  /// The size of the entire widget.
  ///
  /// This size's height is the upper limit for the [PageTextContainer]'s that contains
  /// each page text. If the [PageNavigatorMenu] is included (i.e. if
  /// [usePageNavigation] is `true`), its height (50 pixel) will be deducted
  /// leaving the only remaining height for the [PageTextContainer].
  final Size size;

  /// The padding that will be applied to the [PageTextContainer].
  final EdgeInsets paddingTextBox;

  /// Whether the [PageNavigatorMenu] will be rendered below the [PageTextContainer].
  final bool usePageNavigation;

  /// The [PageTextContainer]'s decoration.
  final BoxDecoration? decoration;

  /// Creates a widget that distributes the provided text across as many pages as necessary.
  ///
  /// Besides the TextContainer that holds the text for the given page, the widget can also
  /// contain a PageNavigatorMenu for navigating between the different pages.
  const MultiPageText({
    Key? key,
    required this.fullText,
    required this.size,
    this.textStyle = const TextStyle(
      fontSize: 10,
      color: Colors.white,
    ),
    this.paddingTextBox = const EdgeInsets.all(
      10,
    ),
    this.usePageNavigation = true,
    this.decoration,
  }) : super(key: key);

  @override
  State<MultiPageText> createState() => _MultiPageTextState();
}

class _MultiPageTextState extends State<MultiPageText> {
  int _currentPageIndex = 0;
  final double _pageNavigatorHeight = 40;
  final int _upperLayoutRunsLimit = 20;
  late List<String> _pages;
  late Size _availableSize;

  @override
  void initState() {
    _pages = _getPageTexts();
    super.initState();
  }

  List<String> _getPageTexts() {
    List<String> pages = <String>[];
    String remainingText = widget.fullText;
    _availableSize = _calculateAvailableSize(
      size: widget.size,
      padding: widget.paddingTextBox,
      usePageNavigation: widget.usePageNavigation,
    );
    double widthFactor = 0.5;
    int retries = 0;
    int pageCharacterLimit = _estimatePageCharacterLimit(
      size: _availableSize,
      textStyle: widget.textStyle,
      widthFactor: widthFactor,
    );
    while (remainingText.isNotEmpty) {
      final String pageTextEstimate = _getPageTextEstimate(
        text: remainingText,
        pageCharacterLimit: pageCharacterLimit,
      );
      final PageProperties pageProperties = _getPageText(
        text: pageTextEstimate,
        textStyle: widget.textStyle,
        size: _availableSize,
      );
      if (_shouldOptimizeEstimates(pageProperties.layoutRuns)) {
        // Optimize widthFactor for better pageTextEstimates
        widthFactor = _updateWidthFactor(
          widthFactor: widthFactor,
          layoutRuns: pageProperties.layoutRuns,
          upperLayoutRunsLimit: _upperLayoutRunsLimit,
        );
        // Update pageCharacterLimit
        pageCharacterLimit = _estimatePageCharacterLimit(
          size: _availableSize,
          textStyle: widget.textStyle,
          widthFactor: widthFactor,
        );
      }
      if (_performRetry(pageProperties.layoutRuns, retries)) {
        retries++;
        continue;
      }
      pages.add(pageProperties.text);
      remainingText =
          remainingText.substring(pageProperties.text.length).trimLeft();
      retries = 0;
    }
    return pages;
  }

  /// Calculates the available space for the [ui.ParagraphBuilder] (i.e. its width constraint).
  ///
  /// That means subtracting any padding of the enclosing [Container] as well as removing the
  /// height of the page navigation (only if [usePageNavigation] is `true`).
  Size _calculateAvailableSize({
    required Size size,
    required EdgeInsets padding,
    required bool usePageNavigation,
  }) {
    double availableHeight = size.height -
        (widget.paddingTextBox.top + widget.paddingTextBox.bottom);
    if (usePageNavigation) {
      availableHeight = availableHeight - _pageNavigatorHeight;
    }
    final double availableWidth =
        size.width - (widget.paddingTextBox.right + widget.paddingTextBox.left);
    return Size(availableWidth, availableHeight);
  }

  /// Updates the [widthFactor] based on the number of actual [layoutRuns].
  ///
  /// If the [upperLayoutRunsLimit] was exceeded, we want to tighten our character estimate
  /// (hence increase the [widthFactor] by `0.05`). Otherwise (i.e. if [layoutRuns] = `1`) the
  /// constraint should be loosened (decrease the [widthFactor] by `0.05`).
  double _updateWidthFactor({
    required double widthFactor,
    required int layoutRuns,
    required int upperLayoutRunsLimit,
  }) {
    final double newWidthFactor = layoutRuns >= upperLayoutRunsLimit
        ? widthFactor + 0.05
        : widthFactor - 0.05;
    return newWidthFactor;
  }

  /// (Over)Estimates the character limit for a given page.
  ///
  /// The [widthFactor] is automatically chosen and adjusted by the parent function
  /// so that the resulting maximum character will be slightly overestimated.
  int _estimatePageCharacterLimit({
    required Size size,
    required TextStyle textStyle,
    required double widthFactor,
  }) {
    final characterHeight = textStyle.fontSize!;
    final characterWidth = characterHeight * widthFactor;
    return ((size.height * size.width) / (characterHeight * characterWidth))
        .ceil();
  }

  /// Retrieves the part of the [text] that fits within the [pageCharacterLimit] starting
  /// from the beginning of the string.
  String _getPageTextEstimate({
    required String text,
    required int pageCharacterLimit,
  }) {
    final initialPageTextEstimate =
        text.substring(0, math.min(pageCharacterLimit + 1, text.length));
    final substringIndex =
        initialPageTextEstimate.lastIndexOf(RegExp(r"\s+\b|\b\s+|[\.?!]"));
    final pageTextEstimate =
        text.substring(0, math.min(substringIndex + 1, text.length));
    return pageTextEstimate;
  }

  /// Determines the final text for the given page and returns the respective
  /// [PageProperties] with the number of necessary `layoutRuns` for optimization
  /// and the [text] itself.
  PageProperties _getPageText({
    required String text,
    required TextStyle textStyle,
    required Size size,
  }) {
    double paragraphHeight = 10000;
    String currentText = text;
    int layoutRuns = 0;
    final RegExp regExp = RegExp(r"\S+[\W]*$");
    while (paragraphHeight > size.height) {
      final paragraph = ParagraphPainter.layoutParagraph(
          text: currentText, textStyle: textStyle, size: size);
      paragraphHeight = paragraph.height;
      if (paragraphHeight > size.height) {
        currentText = currentText.replaceFirst(regExp, '');
      }
      layoutRuns = layoutRuns + 1;
    }

    return PageProperties(currentText, layoutRuns);
  }

  bool _performRetry(int layoutRuns, int retries) {
    return layoutRuns == 1 && retries <= 0;
  }

  bool _shouldOptimizeEstimates(int layoutRuns) {
    return layoutRuns > _upperLayoutRunsLimit || layoutRuns == 1;
  }

  void _updatePageIndex(PageUpdateOperation pageUpdateOperation) {
    switch (pageUpdateOperation) {
      case PageUpdateOperation.first:
        setState(() {
          _currentPageIndex = 0;
        });
        break;
      case PageUpdateOperation.previous:
        setState(() {
          _currentPageIndex--;
        });
        break;
      case PageUpdateOperation.next:
        setState(() {
          _currentPageIndex++;
        });
        break;
      case PageUpdateOperation.last:
        setState(() {
          _currentPageIndex = _pages.length - 1;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageTextContainer = PageTextContainer(
      text: _pages[_currentPageIndex],
      textStyle: widget.textStyle,
      padding: widget.paddingTextBox,
      size: _availableSize,
      decoration: widget.decoration,
    );
    return widget.usePageNavigation
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              pageTextContainer,
              PageNavigatorMenu(
                size: Size(widget.size.width, _pageNavigatorHeight),
                currentPageIndex: _currentPageIndex,
                pageCount: _pages.length,
                updatePageIndex: _updatePageIndex,
              ),
            ],
          )
        : pageTextContainer;
  }
}

class PageTextContainer extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final EdgeInsets padding;
  final Size size;
  final BoxDecoration? decoration;

  const PageTextContainer({
    Key? key,
    required this.text,
    required this.textStyle,
    required this.padding,
    required this.size,
    this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: decoration,
      child: CustomPaint(
        painter: ParagraphPainter(
          pageText: text,
          textStyle: textStyle,
        ),
        child: SizedBox(
          height: size.height,
          width: size.width,
        ),
      ),
    );
  }
}

class PageNavigatorMenu extends StatelessWidget {
  final Size size;
  final int currentPageIndex;
  final int pageCount;
  final void Function(PageUpdateOperation) updatePageIndex;

  const PageNavigatorMenu({
    Key? key,
    required this.size,
    required this.currentPageIndex,
    required this.pageCount,
    required this.updatePageIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height,
      width: size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(
              Icons.first_page,
            ),
            onPressed: currentPageIndex > 0
                ? () => updatePageIndex(
                      PageUpdateOperation.first,
                    )
                : null,
          ),
          IconButton(
            icon: const Icon(
              Icons.navigate_before,
            ),
            onPressed: currentPageIndex > 0
                ? () => updatePageIndex(
                      PageUpdateOperation.previous,
                    )
                : null,
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Page ${currentPageIndex + 1}',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.navigate_next,
            ),
            onPressed: currentPageIndex < pageCount - 1
                ? () => updatePageIndex(
                      PageUpdateOperation.next,
                    )
                : null,
          ),
          IconButton(
            icon: const Icon(
              Icons.last_page,
            ),
            onPressed: currentPageIndex < pageCount - 1
                ? () => updatePageIndex(
                      PageUpdateOperation.last,
                    )
                : null,
          ),
        ],
      ),
    );
  }
}

class ParagraphPainter extends CustomPainter {
  final String pageText;
  final TextStyle textStyle;

  ParagraphPainter({
    required this.pageText,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paragraph = layoutParagraph(
      text: pageText,
      textStyle: textStyle,
      size: size,
    );
    canvas.drawParagraph(paragraph, Offset.zero);
  }

  static ui.Paragraph layoutParagraph({
    required String text,
    required TextStyle textStyle,
    required Size size,
  }) {
    final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        fontSize: textStyle.fontSize,
        fontFamily: textStyle.fontFamily,
        fontStyle: textStyle.fontStyle,
        fontWeight: textStyle.fontWeight,
        textAlign: TextAlign.left,
      ),
    )
      ..pushStyle(textStyle.getTextStyle())
      ..addText(text);
    final ui.Paragraph paragraph = paragraphBuilder.build()
      ..layout(
        ui.ParagraphConstraints(width: size.width),
      );
    return paragraph;
  }

  @override
  bool shouldRepaint(ParagraphPainter oldDelegate) =>
      oldDelegate.pageText != pageText || oldDelegate.textStyle != textStyle;
}

class PageProperties {
  final String text;
  final int layoutRuns;

  PageProperties(this.text, this.layoutRuns);

  @override
  String toString() {
    return '''PageProperties(
$text,
$layoutRuns
)''';
  }
}

enum PageUpdateOperation {
  first,
  previous,
  next,
  last,
}

// Call the widget
// 2022-05-17 尝试改为stateful widget，并加载assets文本数据，但是报错。应该还是文本处理逻辑没搞懂
class ExampleMultiPageText extends StatelessWidget {
  const ExampleMultiPageText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MultiPageText(
        textStyle: const TextStyle(
          fontSize: 10,
          color: Colors.white,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 1.0,
            color: Colors.grey,
          ),
        ),
        usePageNavigation: true,
        fullText:
            '''Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam et mollis orci. Sed ullamcorper leo ipsum, sit amet feugiat neque aliquam at. Vestibulum vehicula elit eget metus iaculis ultrices. Nunc faucibus vehicula justo vitae portaPhasellus vestibulum lectus non tellus accumsan, non dictum tellus bibendum. Nulla ornare eros vitae bibendum pharetra. Fusce sit amet lobortis ex. Proin condimentum imperdiet erat, lacinia suscipit est efficitur sit amet. Nunc laoreet luctus tortor, in accumsan velit. Donec cursus velit vehicula maximus finibus. Donec quis euismod quam. In vel lacus fringilla, rhoncus eros nec, elementum massa. Donec luctus lobortis ullamcorper.

Aenean lacus ligula, rutrum ac felis in, dictum sagittis est. Integer finibus arcu magna, eget bibendum odio dignissim id. Mauris ornare ipsum maximus malesuada efficitur. Duis pulvinar neque a lectus fermentum accumsan non id arcu. Quisque congue lectus eu ante efficitur, ac semper lectus volutpat. Pellentesque dignissim turpis quam, venenatis facilisis sem rutrum non. Praesent tincidunt sodales dolor a maximus. Aliquam sit amet quam vel augue mattis luctus. Duis placerat condimentum aliquam. Quisque bibendum in ipsum non pretium. Nam lobortis libero quam, sed lacinia ex rhoncus non. Fusce viverra felis vitae finibus tincidunt. In hac habitasse platea dictumst. Praesent mollis, turpis at iaculis pulvinar, lectus enim feugiat mi, ultricies auctor lacus sapien sed ipsum.

Etiam ac mi risus. In dictum purus sapien, non tempus magna tempor vel. Suspendisse finibus lectus et sem laoreet dignissim.

Maecenas erat mi, ultrices non sollicitudin non, tristique a est. Vestibulum interdum diam nec justo eleifend tincidunt. Nulla non nulla at nulla suscipit congue.

Mauris est dui, molestie sed tempus ac, accumsan eget urna. Nullam sit amet bibendum lacus, a pellentesque nisl. Aliquam lorem eros, finibus id enim eget, faucibus ultricies erat. Sed sed pulvinar tellus, nec euismod lectus. Quisque libero metus, congue nec suscipit ut, tincidunt eget odio. Aliquam sit amet cursus magna. Nam aliquam ipsum at eleifend auctor. Fusce eu metus dui. Nulla non lacus eros. Cras elementum, ante et tristique faucibus, risus enim dignissim est, id iaculis augue turpis vel massa. Sed cursus ultricies lorem.''',
        size: const Size(
          200,
          350,
        ),
      ),
    );
  }
}
