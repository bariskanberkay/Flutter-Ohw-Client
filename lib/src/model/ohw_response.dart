class OhwResponse {
  OhwResponse({
    this.id,
    this.text,
    this.children,
    this.min,
    this.value,
    this.max,
    this.imageUrl,
  });

  int? id;
  String? text;
  List<OhwResponse>? children;
  String? min;
  String? value;
  String? max;
  String? imageUrl;

  factory OhwResponse.fromJson(Map<String, dynamic> json) => OhwResponse(
    id: json["id"] == null ? null : json["id"],
    text: json["Text"] == null ? null : json["Text"],
    children: json["Children"] == null ? null : List<OhwResponse>.from(json["Children"].map((x) => OhwResponse.fromJson(x))),
    min: json["Min"] == null ? null : json["Min"],
    value: json["Value"] == null ? null : json["Value"],
    max: json["Max"] == null ? null : json["Max"],
    imageUrl: json["ImageURL"] == null ? null : json["ImageURL"],
  );

}