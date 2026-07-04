class Jasa {
  final String id;
  final String nama;
  final int harga;

  const Jasa({required this.id, required this.nama, required this.harga});

  Map<String, dynamic> toJson() => {'id': id, 'nama': nama, 'harga': harga};

  factory Jasa.fromJson(Map<String, dynamic> json) => Jasa(
        id: json['id'] as String,
        nama: json['nama'] as String,
        harga: json['harga'] as int,
      );
}
