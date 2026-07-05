class Bengkel {
  final String id;
  final String ownerUid;
  final String nama;
  final String alamat;
  final double rating;
  final int ulasan;
  final String jarak;
  final String jam;
  final bool buka;
  final String spesialis;
  final bool verified;

  const Bengkel({
    required this.id,
    required this.ownerUid,
    required this.nama,
    required this.alamat,
    required this.rating,
    required this.ulasan,
    required this.jarak,
    required this.jam,
    required this.buka,
    required this.spesialis,
    required this.verified,
  });

  Bengkel copyWith({double? rating, int? ulasan}) => Bengkel(
    id: id,
    ownerUid: ownerUid,
    nama: nama,
    alamat: alamat,
    rating: rating ?? this.rating,
    ulasan: ulasan ?? this.ulasan,
    jarak: jarak,
    jam: jam,
    buka: buka,
    spesialis: spesialis,
    verified: verified,
  );

  Map<String, dynamic> toJson() => {
    'ownerUid': ownerUid,
    'nama': nama,
    'alamat': alamat,
    'rating': rating,
    'ulasan': ulasan,
    'jarak': jarak,
    'jam': jam,
    'buka': buka,
    'spesialis': spesialis,
    'verified': verified,
  };

  factory Bengkel.fromJson(String id, Map<String, dynamic> json) => Bengkel(
    id: id,
    ownerUid: json['ownerUid'] as String,
    nama: json['nama'] as String,
    alamat: json['alamat'] as String,
    rating: (json['rating'] as num).toDouble(),
    ulasan: json['ulasan'] as int,
    jarak: json['jarak'] as String,
    jam: json['jam'] as String,
    buka: json['buka'] as bool,
    spesialis: json['spesialis'] as String,
    verified: json['verified'] as bool,
  );
}
