import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperProfilePage extends StatelessWidget {
  const DeveloperProfilePage({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(
      url.contains('mailto:') || url.contains('http') ? url : 'mailto:$url',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('⚠️ لا يمكن فتح الرابط: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'مطور البرنامج',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.primary, width: 3),
              ),
              child: const CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage('images/develepor.jpg'),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'المهندس عمرو خالد الشلوي',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'مطور برمجيات متخصص في تطوير تطبيقات الهاتف المحمول، يسعى لتقديم حلول تقنية مبتكرة تلبي احتياجات المستخدمين بكفاءة. يتميز بخبرة في تصميم وتطوير واجهات استخدام سلسة، مع التركيز على الأداء العالي والجودة الفائقة لضمان تجربة استخدام متميزة.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Cairo',
                  fontSize: 17,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),

            Text(
              'للتواصل، يُرجى الضغط على الروابط أدناه:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 25),

            _buildContactButton(
              context: context,
              icon: FontAwesomeIcons.whatsapp,
              label: '218914018648',
              color: const Color(0xFF25D366),
              url: 'https://wa.me/218914018648',
            ),
            const SizedBox(height: 10),

            _buildContactButton(
              context: context,
              icon: FontAwesomeIcons.instagram,
              label: 'sa4nad',
              color: const Color(0xFFC13584),
              url: 'https://www.instagram.com/sa4nad?igsh=YzJ5ZXhpemFnMXJr',
            ),
            const SizedBox(height: 10),

            _buildContactButton(
              context: context,
              icon: FontAwesomeIcons.envelope,
              label: 'eng.amro@uod.edu.ly',
              color: Colors.red,
              url: 'mailto:eng.amro@uod.edu.ly',
            ),
            const SizedBox(height: 10),

            _buildContactButton(
              context: context,
              icon: FontAwesomeIcons.xTwitter,
              label: 'sa4nad',
              color: Colors.black87,
              url: 'https://x.com/sa4nad?t=I-txjUDNveJP4rU9b3Qa5g&s=09',
            ),
            const SizedBox(height: 10),

            // زر الفيسبوك المضاف
            _buildContactButton(
              context: context,
              icon: FontAwesomeIcons.facebook,
              label: 'سند المسماري',
              color: const Color(0xFF1877F2),
              url: 'https://www.facebook.com/share/1Fj52eavrY/',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required BuildContext context,
    required dynamic icon,
    required String label,
    required Color color,
    required String url,
  }) {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: FaIcon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        onPressed: () => _launchURL(url),
      ),
    );
  }
}
