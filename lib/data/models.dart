class Service {
  const Service(
    this.name,
    this.minutes,
    this.price, [
    this.image = 'service-cut',
  ]);
  final String name, image;
  final int minutes, price;
}

class Barber {
  const Barber(this.name, this.rating, this.image);
  final String name, rating, image;
}

class Shop {
  const Shop(
    this.name,
    this.address,
    this.rating,
    this.distance,
    this.walk,
    this.image,
  );
  final String name, address, rating, distance, image;
  final int walk;
}

const services = [
  Service('Hair Cut', 45, 35),
  Service('Beard Styling', 35, 25, 'service-beard'),
  Service('Hot towel shave', 50, 30, 'service-beard'),
  Service('Hair & Beard', 60, 55),
  Service('Re-style', 50, 45, 'service-style'),
  Service('Kid cut', 30, 30),
];
const barbers = [
  Barber('Marjorie Williamson', '4,9', 'barber-0'),
  Barber('Norma Black', '4,8', 'barber-1'),
  Barber('Greg Webb', '5,0', 'barber-2'),
  Barber('Kristin Miles', '5,0', 'barber-3'),
  Barber('Eduardo Pena', '4,9', 'barber-4'),
  Barber('Francisco Robertson', '4,9', 'barber-5'),
];
const shops = [
  Shop(
    'Pall Malls Barbers',
    '1335 Avenue, New York',
    '4,9',
    '1 km',
    10,
    'shop-shave',
  ),
  Shop(
    'Old Boys Barbers',
    'b/t S Stuyvesant Loop & Avenue',
    '5,0',
    '4 km',
    45,
    'shop-cut',
  ),
  Shop(
    'Oleaster Barbers',
    'b/t Hoyt St & Bond St Boerum',
    '4,2',
    '4,5 km',
    50,
    'barber-work',
  ),
  Shop(
    'Firma Barbers',
    '104 Atlantic Avenue, New York',
    '4,8',
    '2 km',
    20,
    'shop-cut',
  ),
];
const times = ['11:15', '12:00', '12:45', '13:30', '14:15', '15:00'];
const months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
String dateLabel(DateTime date) => '${date.day} ${months[date.month - 1]}';

class Reservation {
  const Reservation({
    required this.id,
    required this.date,
    required this.time,
    required this.serviceIndex,
    required this.barberIndex,
    required this.shopIndex,
  });
  final String id, time;
  final DateTime date;
  final int serviceIndex, barberIndex, shopIndex;
  Service get service => services[serviceIndex];
  Barber get barber => barbers[barberIndex];
  Shop get shop => shops[shopIndex];
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'time': time,
    'service': serviceIndex,
    'barber': barberIndex,
    'shop': shopIndex,
  };
  factory Reservation.fromJson(Map<String, dynamic> j) => Reservation(
    id: j['id'],
    date: DateTime.parse(j['date']),
    time: j['time'],
    serviceIndex: j['service'],
    barberIndex: j['barber'],
    shopIndex: j['shop'],
  );
}
