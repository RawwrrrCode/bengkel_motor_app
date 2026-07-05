import '../models/jasa.dart';
import '../models/sparepart.dart';

/// Default starter catalog copied into a bengkel's `spareparts`/`jasa`
/// subcollections when they finish onboarding (`SetupBengkelScreen`), so a
/// newly-registered bengkel isn't left with a totally empty catalog.
List<Sparepart> seedSpareparts() => [
  Sparepart(
    id: 'p1',
    nama: 'Oli Mesin AHM MPX2 (0,8L)',
    kategori: 'Oli & Cairan',
    harga: 55000,
    stok: 24,
  ),
  Sparepart(
    id: 'p2',
    nama: 'Kampas Rem Depan',
    kategori: 'Pengereman',
    harga: 85000,
    stok: 12,
  ),
  Sparepart(
    id: 'p3',
    nama: 'Busi NGK CPR9EA',
    kategori: 'Kelistrikan',
    harga: 28000,
    stok: 40,
  ),
  Sparepart(
    id: 'p4',
    nama: 'Aki GS GTZ5S',
    kategori: 'Kelistrikan',
    harga: 220000,
    stok: 6,
  ),
  Sparepart(
    id: 'p5',
    nama: 'Ban Belakang IRC 100/80-14',
    kategori: 'Ban',
    harga: 235000,
    stok: 8,
  ),
  Sparepart(
    id: 'p6',
    nama: 'V-Belt Set Original',
    kategori: 'CVT',
    harga: 165000,
    stok: 10,
  ),
  Sparepart(
    id: 'p7',
    nama: 'Roller CVT Set',
    kategori: 'CVT',
    harga: 90000,
    stok: 15,
  ),
  Sparepart(
    id: 'p8',
    nama: 'Filter Udara',
    kategori: 'Filter',
    harga: 45000,
    stok: 3,
  ),
];

List<Jasa> seedJasa() => [
  Jasa(id: 'j1', nama: 'Jasa Servis Rutin', harga: 90000),
  Jasa(id: 'j2', nama: 'Jasa Ganti Oli', harga: 25000),
  Jasa(id: 'j3', nama: 'Jasa Ganti Kampas Rem', harga: 50000),
  Jasa(id: 'j4', nama: 'Jasa Bongkar CVT', harga: 65000),
  Jasa(id: 'j5', nama: 'Jasa Tune Up Mesin', harga: 100000),
  Jasa(id: 'j6', nama: 'Jasa Ganti Ban', harga: 30000),
  Jasa(id: 'j7', nama: 'Jasa Servis Injeksi/Karburator', harga: 75000),
  Jasa(id: 'j8', nama: 'Jasa Ganti Aki', harga: 20000),
];
