import 'dart:convert';

class PhotoData {
  int? albumId;
  int? id;
  String? title;
  String? url;
  String? thumbnailUrl;

  PhotoData({
    this.albumId,
    this.id,
    this.title,
    this.url,
    this.thumbnailUrl,
  });

  factory PhotoData.fromMap(Map<String, dynamic> data) => PhotoData(
        albumId: data['albumId'] as int?,
        id: data['id'] as int?,
        title: data['title'] as String?,
        url: data['url'] as String?,
        thumbnailUrl: data['thumbnailUrl'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'albumId': albumId,
        'id': id,
        'title': title,
        'url': url,
        'thumbnailUrl': thumbnailUrl,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [PhotoData].
  factory PhotoData.fromJson(String data) {
    return PhotoData.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [PhotoData] to a JSON string.
  String toJson() => json.encode(toMap());
}
