class Jasa {
  final String id;
  final String nama;
  final int harga;

  const Jasa({required this.id, required this.nama, required this.harga});

  Map<String, dynamic> toJson() => {'nama': nama, 'harga': harga};

  factory Jasa.fromJson(String id, Map<String, dynamic> json) => Jasa(
        id: id,
        nama: json['nama'] as String,
        harga: json['harga'] as int,
      );
}
