/// PDF books shipped in lib/assets/pdfbooks/.
/// Add entries here when you add new PDF files to that folder.
class PdfBooksConstants {
  PdfBooksConstants._();

  static const String basePath = 'lib/assets/pdfbooks';

  /// List of {path, title}. Path is the asset path; title is shown in the list.
  static const List<Map<String, String>> books = [
    // Example (add your PDFs here):
     {'path': '$basePath/kurdish.pdf', 'title': 'شێوازی بانگدان'},
     {'path': '$basePath/kurmanji.pdf', 'title': 'حوکمێن بانگدان و قامەتێ'},
     {'path': '$basePath/english.pdf', 'title': 'Rullings and principles of call to prayer and call to start prayer'},
     {'path': '$basePath/persian.pdf', 'title': 'آئینہ و قواعد بانگدان و قامەتێ'},
     {'path': '$basePath/arabic.pdf', 'title': 'أحكام الأذان والإقامة على في مذاهب الأربعة'},
  ];
}
