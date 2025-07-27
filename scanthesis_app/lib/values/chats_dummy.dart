import 'dart:io';
import 'package:scanthesis_app/models/chat.dart';
import 'package:scanthesis_app/models/api_request.dart';
import 'package:scanthesis_app/models/api_response.dart';

class ChatsDummy {
  static final List<Chat> chats = [
    Chat(
      request: ApiRequest(
        files: [File('dummy/path/file1.pdf')],
        prompt: 'Ringkas dokumen ini menjadi 3 paragraf.',
      ),
      response: ApiResponse.success(body: 'Ringkasan dokumen 1 yang berisi tiga paragraf.'),
    ),
    Chat(
      request: ApiRequest(
        files: [File('dummy/path/file2.docx')],
        prompt: 'Buatkan abstrak dari dokumen ini.',
      ),
      response: ApiResponse.success(body: 'Abstrak dokumen 2.'),
    ),
    Chat(
      request: ApiRequest(
        files: [File('dummy/path/file3.txt')],
        prompt: 'Apa kata kunci yang bisa diambil dari dokumen ini?',
      ),
      response: ApiResponse.success(body: 'Kata kunci dari dokumen 3 adalah AI, Machine Learning, Data.'),
    ),
    Chat(
      request: ApiRequest(
        files: [File('dummy/path/file4.pdf')],
        prompt: 'Buatkan kesimpulan dari dokumen ini.',
      ),
      response: ApiResponse.success(body: 'Kesimpulan dokumen 4 adalah tentang dampak teknologi di era digital.'),
    ),
    Chat(
      request: ApiRequest(
        files: [File('dummy/path/file5.doc')],
        prompt: 'Terjemahkan dokumen ini ke bahasa Inggris.',
      ),
      response: ApiResponse.success(body: 'This is the English translation of document 5.'),
    ),
    Chat(
      request: ApiRequest(
        files: [File('dummy/path/file6.pdf')],
        prompt: 'Tolong buat ringkasan 1 paragraf dari dokumen ini.',
      ),
      response: ApiResponse.success(body: 'Ringkasan singkat dari dokumen 6 dalam satu paragraf.'),
    ),
    Chat(
      request: ApiRequest(
        files: [File('dummy/path/file7.docx')],
        prompt: 'Analisis dokumen ini dari sisi ekonomi.',
      ),
      response: ApiResponse.success(body: 'Analisis ekonomi dokumen 7 menyebutkan tren positif di sektor keuangan.'),
    ),
    Chat(
      request: ApiRequest(
        files: [File('dummy/path/file8.txt')],
        prompt: 'Buatkan bullet point dari isi dokumen ini.',
      ),
      response: ApiResponse.success(body: '- Poin 1\n- Poin 2\n- Poin 3 dari dokumen 8.'),
    ),
    Chat(
      request: ApiRequest(
        files: [File('dummy/path/file9.pdf')],
        prompt: 'Tulis ulang dokumen ini dengan bahasa yang lebih sederhana.',
      ),
      response: ApiResponse.success(body: 'Dokumen 9 telah ditulis ulang dengan bahasa sederhana.'),
    ),
    Chat(
      request: ApiRequest(
        files: [File('dummy/path/file10.doc')],
        prompt: 'Buatkan daftar isi dari dokumen ini.',
      ),
      response: ApiResponse.success(body: '1. Pendahuluan\n2. Metodologi\n3. Hasil\n4. Kesimpulan'),
    ),
  ];
}
