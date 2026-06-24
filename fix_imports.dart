import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  for (var file in files) {
    var content = file.readAsStringSync();
    var newContent = content
        .replaceAll('splash screen/', 'splash_screen/')
        .replaceAll('home screen/', 'home_screen/')
        .replaceAll('loge in/', 'login/')
        .replaceAll('sign up/', 'sign_up/')
        .replaceAll('splash%20screen/', 'splash_screen/')
        .replaceAll('home%20screen/', 'home_screen/')
        .replaceAll('loge%20in/', 'login/')
        .replaceAll('sign%20up/', 'sign_up/')
        .replaceAll('Jadwaly/', 'jadwaly/')
        .replaceAll('Settings/', 'settings/')
        .replaceAll('Notifications/', 'notifications/')
        .replaceAll('widget/', 'widgets/')
        .replaceAll('widgt%20qady/', 'widgets/')
        .replaceAll('widgt qady/', 'widgets/')
        .replaceAll('loge_in.dart', 'login_screen.dart')
        .replaceAll(
          'custom_logein_textfild.dart',
          'custom_login_textfield.dart',
        )
        .replaceAll(
          'custom_signup_textfild.dart',
          'custom_signup_textfield.dart',
        )
        .replaceAll('castom_nevigator.dart', 'custom_navigator.dart')
        .replaceAll('custom_text_fild.dart', 'custom_textfield.dart');

    if (content != newContent) {
      file.writeAsStringSync(newContent);
      stdout.writeln('Updated imports in: ${file.path}');
    }
  }
  stdout.writeln('All imports updated successfully!');
}
