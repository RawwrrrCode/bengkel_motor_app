class Sparepart {
  final String id;
  final String nama;
  final String kategori;
  final int harga;
  final int stok;

  const Sparepart({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.stok,
  });

  Sparepart copyWith({String? nama, String? kategori, int? harga, int? stok}) =>
      Sparepart(
        id: id,
        nama: nama ?? this.nama,
        kategori: kategori ?? this.kategori,
        harga: harga ?? this.harga,
        stok: stok ?? this.stok,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'kategori': kategori,
    'harga': harga,
    'stok': stok,
  };

  factory Sparepart.fromJson(Map<String, dynamic> json) => Sparepart(
    id: json['id'] as String,
    nama: json['nama'] as String,
    kategori: json['kategori'] as String,
    harga: json['harga'] as int,
    stok: json['stok'] as int,
  );
}
