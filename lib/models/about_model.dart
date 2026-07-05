enum AboutType { terms, privacy, helpSupport, helpline, rateUs }

class AboutModel {
  String? title;
  String? image;
  AboutType type;

  AboutModel({this.title, this.image, required this.type});
}
