import 'package:url_launcher/url_launcher.dart';

Future<void> openGoogleMaps(double lat, double lng) async {
  final Uri url = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
  );

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw 'ไม่สามารถเปิด Google Maps ได้';
  }
}
