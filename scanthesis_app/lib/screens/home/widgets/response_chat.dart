import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlighting/flutter_highlighting.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:provider/provider.dart';
import 'package:scanthesis_app/models/api_response.dart';
import 'package:scanthesis_app/provider/theme_provider.dart';
import 'package:scanthesis_app/utils/code_theme_util.dart';

import 'package:scanthesis_app/utils/style_util.dart';

class ResponseChat extends StatefulWidget {
  final ApiResponse response;

  const ResponseChat({super.key, required this.response});

  @override
  State<ResponseChat> createState() => _ResponseChatState();
}

class _ResponseChatState extends State<ResponseChat> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode(context);
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(12),
      width: 730,
      child: GptMarkdown(
        // key: ValueKey(Provider.of<ThemeProvider>(context).getThemeMode),
        // key: ValueKey(Theme.of(context).brightness),
        key: ValueKey(Theme.of(context).colorScheme),
        widget.response.text,
        // _markdownWithCodeMix,
        codeBuilder: (context, name, code, closed) {
          final ScrollController codeScrollController = ScrollController();

          return Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.3,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Container(
              constraints: BoxConstraints(maxWidth: 730),
              child: Column(
                children: [
                  _codeCardHeader(languageName: name, codeToCopy: code),
                  Scrollbar(
                    interactive: true,
                    thumbVisibility: true,
                    trackVisibility: true,
                    radius: Radius.circular(2),
                    controller: codeScrollController,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: codeScrollController,
                      child: _codeCardContent(
                        languageName: name,
                        code: code,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        style: GoogleFonts.nunito().copyWith(
          fontSize: 18,
          color: colorScheme.onSurface,
        ),
        highlightBuilder: (context, text, style) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: StyleUtil.windowButtonGrey.withAlpha(35),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(text, style: GoogleFonts.sourceCodePro()),
          );
        },
      ),
    );
  }

  Widget _codeCardHeader({
    required String languageName,
    required String codeToCopy,
  }) {
    final GlobalKey<TooltipState> tooltipKey = GlobalKey<TooltipState>();
    String tooltipMessage = "Copy Code";

    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      width: double.maxFinite,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(languageName.isEmpty ? "plaintext" : languageName),
          ),
          StatefulBuilder(
            builder: (context, setState) {
              return Tooltip(
                key: tooltipKey,
                message: tooltipMessage,
                triggerMode: TooltipTriggerMode.manual,
                child: MouseRegion(
                  onExit: (_) {
                    Tooltip.dismissAllToolTips();
                  },
                  child: IconButton(
                    onHover: (value) {
                      if (value) {
                        setState(() {
                          tooltipMessage = "Copy Code";
                        });
                      }
                    },
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: codeToCopy));
                      setState(() {
                        tooltipMessage = "Copied!";
                        tooltipKey.currentState?.ensureTooltipVisible();
                      });
                      // await Future.delayed(Duration(seconds: 1)).then((_) {
                      //   Tooltip.dismissAllToolTips();
                      // });
                    },
                    icon: Icon(Icons.copy, size: 16),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // CopyButtonWithTooltip(codeToCopy: codeToCopy),
        ],
      ),
    );
  }

  Widget _codeCardContent({
    required String languageName,
    required String code,
    required bool isDarkMode,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      // height: 900,
      constraints: BoxConstraints(minWidth: 730 - 32), // 32 = 18 padding horizontal
      color: Theme.of(context).colorScheme.onSecondary,
      // child: Text(
      //   code,
      //   style: GoogleFonts.sourceCodePro().copyWith(
      //     color: Theme.of(context).colorScheme.onSurface,
      //   ),
      // ),
      child: HighlightView(
        code,
        languageId: languageName,
        theme: CodeThemeUtil.darculaTheme,
        textStyle: GoogleFonts.sourceCodePro().copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        selectable: true,
        selectionColor: StyleUtil.primaryColor.withAlpha(127),
      ),
    );
  }

  String _markdown =
      "Kode tersebut adalah fungsi asynchronous Dart yang membaca file gambar dari `ClipboardReader`. Mari kita uraikan langkah demi langkah:\n\n**1. `static Future<File?> readImageFile(ClipboardReader reader, FileFormat format) async {`**\n\n* Ini mendeklarasikan fungsi statis bernama `readImageFile` yang mengembalikan `Future<File?>`.  Artinya, fungsi ini akan mengembalikan masa depan (Future) yang mungkin berisi objek `File` (jika berhasil membaca file) atau `null` (jika gagal).  Kata kunci `static` berarti fungsi ini dapat dipanggil tanpa membuat instance dari kelas tempat fungsi ini berada.\n* Fungsi ini menerima dua parameter:\n    * `ClipboardReader reader`:  Objek yang digunakan untuk mengakses data dari clipboard.\n    * `FileFormat format`:  Format file gambar (mungkin enum atau tipe data lain yang mewakili format seperti JPG, PNG, dll.).  Parameter ini sebenarnya tidak digunakan dalam kode yang ditampilkan.\n\n**2. `final completer = Completer<File?>();`**\n\n* Ini membuat objek `Completer<File?>`.  `Completer` digunakan untuk mengelola `Future`.  `Completer` memungkinkan kode untuk menyelesaikan `Future` secara asinkron di suatu titik nanti dalam eksekusi.  `File?>` menunjukkan bahwa `Future` akan menyelesaikan dengan `File` atau `null`.\n\n**3. `reader.getFile(format, (file) async {`**\n\n* Ini memanggil metode `getFile` pada objek `reader`.  Metode ini mungkin merupakan metode khusus yang disediakan oleh `ClipboardReader` untuk mendapatkan file dari clipboard.\n* Fungsi anonim asinkron dilewatkan sebagai callback ke `getFile`. Fungsi ini akan dieksekusi setelah `getFile` selesai.  Parameter `file` akan berisi objek `File` yang dibaca dari clipboard.\n\n**4. `try { ... } catch (e) { ... }`**\n\n* Blok `try-catch` menangani kemungkinan error selama proses pembacaan file.\n\n**5. `// Try to read all data at once (more efficient)`**\n**6. `final allData = await file.readAll();`**\n\n* Didalam blok `try`, kode berusaha membaca semua data dari file sekaligus menggunakan `file.readAll()`.  Ini lebih efisien daripada membaca data secara bertahap.  `await` membuat eksekusi fungsi ini berhenti sampai operasi `file.readAll()` selesai.\n\n**7. `if (allData.isNotEmpty) { ... }`**\n\n* Memeriksa apakah data yang dibaca tidak kosong.\n\n**8. `final tempFile = await _bytesToFile(allData);`**\n\n* Jika data tidak kosong, kode memanggil fungsi `_bytesToFile` (yang tidak ditampilkan dalam kode) untuk membuat objek `File` sementara dari data byte (`allData`).  `await` digunakan karena `_bytesToFile` juga mungkin merupakan fungsi asynchronous.\n\n**9. `completer.complete(tempFile);`**\n\n* Objek `Completer` diselesaikan dengan objek `File` sementara.  Ini berarti `Future` yang dikembalikan oleh fungsi `readImageFile` akan menyelesaikan dengan nilai `tempFile`.\n\n**10. `completer.complete(null);`**\n\n* Kode ini dieksekusi jika terjadi error (di dalam blok `catch`) atau jika `allData` kosong.  `Future` akan menyelesaikan dengan nilai `null` untuk menunjukkan kegagalan.\n\n**11. `print('Error reading image file: \$e');`**\n\n* Mencetak pesan error ke konsol.\n\n**12. `return completer.future;`**\n\n* Akhirnya, fungsi mengembalikan `future` dari `completer`.  Ini adalah `Future` yang akan berisi objek `File` yang berhasil dibaca atau `null` jika terjadi error.\n\n\nSecara ringkas, kode ini dirancang untuk membaca file gambar dari clipboard, dan mengembalikan `Future` yang akan berisi objek `File` yang mewakili gambar tersebut jika berhasil, atau `null` jika terjadi kesalahan.  Fungsi `_bytesToFile` yang belum dijelaskan merupakan bagian penting yang mengubah data byte menjadi objek `File`.\n";

  String _markdownWithCode =
      "```dart\nstatic Future<File?> _readFile(ClipboardReader reader, FileFormat format) async {\n  final completer = Completer<File?>();\n\n  reader.getFile(format, (file) async {\n    try {\n      // Try to read all data at once (more efficient)\n      final allData = await file.readAsBytes();\n      if (allData.isNotEmpty) {\n        final tempFile = await _bytesToFile(allData);\n        completer.complete(tempFile);\n        return;\n      }\n    } catch (e) {\n      print('Error reading image file: \$e');\n    }\n    completer.complete(null);\n  });\n\n  return completer.future;\n}\n```\n";

  String _markdownWithCodeMix =
      "Kode yang diberikan adalah fungsi asynchronous Dart yang membaca file dari `ClipboardReader` dan mengembalikannya sebagai `Future<File>`.  Mari kita uraikan kode baris demi baris:\n\n```dart\nstatic Future<File?> readImageFile(ClipboardReader reader, FileFormat format) async {\n  final completer = Completer<File?>();\n\n  reader.getFile(format, (file) async {\n    try {\n      // Try to read all data at once (more efficient)\n      final allData = await file.readAll();\n      if (allData.isNotEmpty) {\n        final tempFile = await _bytesToFile(allData);\n        completer.complete(tempFile);\n        return;\n      }\n    } catch (e) {\n      print('Error reading image file: \$e');\n      completer.complete(null);\n    }\n    completer.complete(null);\n  });\n\n  return completer.future;\n}\n```\n\n**Penjelasan:**\n\n1. **`static Future<File?> readImageFile(ClipboardReader reader, FileFormat format) async { ... }`**:  Ini adalah deklarasi fungsi `static` (artinya bisa dipanggil tanpa membuat instance kelas) yang bernama `readImageFile`. Fungsi ini menerima dua argumen:\n    * `reader`:  Objek `ClipboardReader` yang digunakan untuk mengakses data dari clipboard.\n    * `format`:  Objek `FileFormat` yang menentukan format file yang dibaca (misalnya, `FileFormat.png`, `FileFormat.jpg`).\n    Fungsi ini mengembalikan `Future<File?>`, yang berarti akan mengembalikan objek `File` atau `null` secara asynchronous (tidak langsung). `?` menunjukkan bahwa hasilnya bisa null.\n\n2. **`final completer = Completer<File?>();`**:  Sebuah `Completer` dibuat untuk mengelola `Future`.  `Completer` digunakan untuk menyelesaikan `Future` ketika operasi membaca file selesai.\n\n3. **`reader.getFile(format, (file) async { ... });`**:  Fungsi `getFile` dari `ClipboardReader` dipanggil.  Fungsi ini menerima format file sebagai argumen dan sebuah callback (fungsi anonim `async`).  Callback ini akan dijalankan ketika `getFile` berhasil mendapatkan objek `file` dari clipboard.\n\n4. **`try { ... } catch (e) { ... }`**: Blok `try-catch` digunakan untuk menangani kemungkinan kesalahan saat membaca file.\n\n5. **`final allData = await file.readAll();`**:  Data file dibaca secara keseluruhan (`readAll()`) secara asynchronous (`await`).  Hasilnya disimpan dalam variabel `allData`.\n\n6. **`if (allData.isNotEmpty) { ... }`**:  Kondisi ini memeriksa apakah data yang dibaca tidak kosong.\n\n7. **`final tempFile = await _bytesToFile(allData);`**:  Jika data tidak kosong, fungsi `_bytesToFile` (yang tidak ditunjukkan dalam kode ini, tetapi diasumsikan sebagai fungsi untuk membuat file dari data byte) dipanggil secara asynchronous untuk menyimpan data ke file sementara. Hasilnya disimpan dalam `tempFile`.\n\n8. **`completer.complete(tempFile);`**:  `Completer` diselesaikan dengan objek `File` (tempFile), mengindikasikan bahwa operasi membaca file berhasil.\n\n9. **`completer.complete(null);`**:  Jika terjadi kesalahan atau data kosong, `Completer` diselesaikan dengan `null`.\n\n10. **`return completer.future;`**:  Fungsi mengembalikan `Future` yang dihasilkan oleh `completer`.  Pemanggil fungsi ini bisa kemudian menggunakan `.then` atau `async/await` untuk memproses hasil (File atau null) ketika `Future` selesai.\n\n**Fungsi `_bytesToFile` (yang tidak ditampilkan):** Fungsi ini kemungkinan mengambil data byte (`List<int>`) sebagai input dan mengembalikan sebuah `Future<File>` yang menyelesaikan ketika file telah dibuat dan data telah ditulis ke dalamnya.\n\nSingkatnya, kode ini menyediakan cara yang aman dan efisien untuk membaca gambar atau file lain dari clipboard secara asynchronous di Dart, menangani kesalahan dengan baik, dan mengembalikan hasil melalui sebuah `Future`.  Fungsi ini sangat bergantung pada implementasi `ClipboardReader` dan `_bytesToFile`, yang mungkin spesifik untuk sebuah library atau framework tertentu.\n";
}
