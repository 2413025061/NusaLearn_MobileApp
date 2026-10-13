class HeroItem {
  final String id;
  final String title;
  final String img;
  final String region; // 'Sumatera', 'Jawa', 'Kalimantan', 'Sulawesi', 'Bali & Nusa Tenggara', 'Maluku & Papua'
  final String info; // e.g. "Asal: Kalimantan Timur | Wafat: Wajo, Sulsel"
  final String desc; // Peran perjuangan
  final String fakta; // Fakta menarik

  const HeroItem({
    required this.id,
    required this.title,
    required this.img,
    required this.region,
    required this.info,
    required this.desc,
    required this.fakta,
  });
}
