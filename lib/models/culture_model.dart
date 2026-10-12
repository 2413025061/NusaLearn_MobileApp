class CultureDetail {
  final String title;
  final String content;

  const CultureDetail({
    required this.title,
    required this.content,
  });
}

class CultureItem {
  final String id;
  final String title;
  final String img;
  final String region; // 'Sumatera', 'Jawa', 'Kalimantan', 'Sulawesi', 'Bali & Nusa Tenggara', 'Maluku & Papua'
  final String desc;
  final List<CultureDetail> details;

  const CultureItem({
    required this.id,
    required this.title,
    required this.img,
    required this.region,
    required this.desc,
    required this.details,
  });

  String get traditionalDance {
    final dance = details.firstWhere(
      (d) => d.title.toLowerCase().contains('tari'),
      orElse: () => const CultureDetail(title: '', content: '-'),
    );
    return dance.content;
  }

  String get traditionalHouse {
    final house = details.firstWhere(
      (d) => d.title.toLowerCase().contains('rumah'),
      orElse: () => const CultureDetail(title: '', content: '-'),
    );
    return house.content;
  }

  String get traditionalLanguage {
    final lang = details.firstWhere(
      (d) => d.title.toLowerCase().contains('bahasa'),
      orElse: () => const CultureDetail(title: '', content: '-'),
    );
    return lang.content;
  }
}
