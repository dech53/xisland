class CdnPath {
  String? url;
  double? rate;

  CdnPath({required this.url, required this.rate});
  CdnPath.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    rate = json['rate'];
  }
}

class CdnPathList {
  List<CdnPath>? items;

  CdnPathList({this.items});

  CdnPathList.fromJson(List<dynamic> jsonList) {
    items = jsonList
        .map((e) => CdnPath.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
