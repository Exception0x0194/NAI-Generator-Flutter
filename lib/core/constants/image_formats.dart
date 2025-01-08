import 'package:super_clipboard/super_clipboard.dart';

const imageFormat = SimpleFileFormat(
  // JPG, PNG, GIF, WEBP, BMP
  uniformTypeIdentifiers: [
    'public.jpeg',
    'public.png',
    'com.compuserve.gif',
    'org.webmproject.webp',
    'com.microsoft.bmp'
  ],
  windowsFormats: ['JFIF', 'PNG', 'GIF', 'image/webp', 'image/bmp'],
  mimeTypes: [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
    'image/bmp'
  ],
);
