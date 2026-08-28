void main() {
  double panjang = 10;
  double lebar = 5;
  print('Luas persegi panjang: ${hitungLuas(panjang, lebar)}');

  final profil = Profil(
    nama: 'najla Nuricia Laudy',
    nim: 244107020091,
    email: null,
  );

  print(profil.perkenalan());
}

double hitungLuas (double panjang, double lebar) {
  return panjang * lebar;
}

class Profil {
  Profil({
    required this.nama,
    required this.nim,
    required this.email,
  });

  final String nama;
  final int nim;
  final String? email;

  String perkenalan() => 'Halo, nama saya $nama dan nim saya $nim';
}