
class AppImagePath {
  AppImagePath._();

  static const String logoDir = 'assets/logo';
  static const String imagesDir = 'assets/images';

  static const String logoTaladthai = '$logoDir/taladthai_logo.png';
  static String image(String fileName) => '$imagesDir/$fileName';
  static String logo(String fileName) => '$logoDir/$fileName';
}
