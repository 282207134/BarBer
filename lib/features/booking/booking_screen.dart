import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../discovery/discovery_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, this.calendar = false, this.picker});
  final bool calendar;
  final String? picker;
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late bool calendar = widget.calendar;
  @override
  void initState() {
    super.initState();
    if (widget.picker != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) openPicker(context, widget.picker!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PageHeader(s.shop.name, subtitle: s.shop.address),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 16, bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Date',
                            style: TextStyle(color: muted, fontSize: 14),
                          ),
                          TextButton(
                            onPressed: () =>
                                setState(() => calendar = !calendar),
                            child: Text(
                              calendar ? 'Close calendar' : 'Open calendar',
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (calendar)
                      CalendarDatePicker(
                        initialDate: s.date,
                        firstDate: DateUtils.dateOnly(DateTime.now()),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        onDateChanged: (day) => s.select(day: day),
                      )
                    else
                      const SlotStrip(days: true),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 22),
                      child: Divider(),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(22, 10, 22, 18),
                      child: Text(
                        'Time',
                        style: TextStyle(color: muted, fontSize: 14),
                      ),
                    ),
                    const SlotStrip(),
                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          const SizedBox(height: 10),
                          const Text(
                            'Select barber (optional)',
                            style: TextStyle(color: muted, fontSize: 14),
                          ),
                          const SizedBox(height: 18),
                          SurfaceCard(
                            onTap: () => openPicker(context, 'barbers'),
                            child: Row(
                              children: [
                                Photo(
                                  s.barber.image,
                                  width: 48,
                                  height: 48,
                                  radius: 50,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    s.barber.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.star, color: gold),
                                Text(s.barber.rating, style: display(23)),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: muted,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Select service',
                            style: TextStyle(color: muted, fontSize: 14),
                          ),
                          const SizedBox(height: 18),
                          SurfaceCard(
                            onTap: () => openPicker(context, 'services'),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.service.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${s.service.minutes} minutes',
                                        style: const TextStyle(
                                          color: Colors.black26,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$ ${s.service.price}',
                                  style: display(23),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: muted,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(22, 32, 22, 28),
              decoration: const BoxDecoration(
                color: ink,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$ ${s.service.price}',
                            style: display(24, Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.service.name,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: FilledButton(
                        onPressed: () => context.open('/confirmation'),
                        child: const Text('Book'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> openPicker(BuildContext context, String type) =>
    appSheet(context, PickerList(type: type));

class PickerList extends StatelessWidget {
  const PickerList({super.key, required this.type});
  final String type;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context), isBarber = type == 'barbers';
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .65,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
        itemCount: isBarber ? barbers.length : services.length,
        separatorBuilder: (_, i) => const Divider(height: 1),
        itemBuilder: (context, i) => InkWell(
          key: ValueKey('$type-$i'),
          onTap: () {
            s.select(barber: isBarber ? i : null, service: isBarber ? null : i);
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: isBarber
                ? Row(
                    children: [
                      Photo(
                        barbers[i].image,
                        width: 48,
                        height: 48,
                        radius: 50,
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Text(barbers[i].name)),
                      const Icon(Icons.star, color: gold),
                      Text(barbers[i].rating, style: display(23)),
                      const SizedBox(width: 12),
                      RoundButton(
                        Icons.info_outline,
                        size: 40,
                        onTap: () {
                          s.select(barber: i);
                          Navigator.pop(context);
                          context.open('/barber');
                        },
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(services[i].name),
                            const SizedBox(height: 6),
                            Text(
                              '${services[i].minutes} minutes',
                              style: const TextStyle(
                                color: Colors.black26,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text('\$ ${services[i].price}', style: display(23)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class BarberScreen extends StatelessWidget {
  const BarberScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PageHeader('Barber profile'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    Photo(s.barber.image, width: 112, height: 112, radius: 80),
                    const SizedBox(height: 26),
                    Text(
                      s.barber.name,
                      style: display(24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${s.barber.name.split(' ').first} specializes in classic professional cuts and textured styles. With experience across all lengths and textures, your barber will tailor a cut for you. Book now for a fresh new look!',
                      style: const TextStyle(
                        color: muted,
                        fontSize: 15,
                        height: 1.35,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _stat('5 yr', 'Experience'),
                        _stat('343', 'Happy clients'),
                        _stat('★ ${s.barber.rating}', 'Rating'),
                      ],
                    ),
                    const Divider(height: 50),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Barbers work', style: display(24)),
                    ),
                    const SizedBox(height: 18),
                    const Photo(
                      'barber-work',
                      width: double.infinity,
                      height: 230,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: FilledButton(
                onPressed: () => context.open('/booking'),
                child: const Text('Book'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String title, String caption) => Column(
    children: [
      Text(title, style: display(23)),
      const SizedBox(height: 6),
      Text(caption, style: const TextStyle(color: muted, fontSize: 14)),
    ],
  );
}

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key});
  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  bool saving = false;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      backgroundColor: ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 5,
                margin: const EdgeInsets.only(top: 30),
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const Spacer(flex: 2),
              Text('Confirmation', style: display(24, Colors.white)),
              const SizedBox(height: 18),
              Text(
                '${s.service.name} with ${s.barber.name},\n${s.shop.name} (${s.shop.address})\nat ${s.time}, ${dateLabel(s.date)} ${s.date.year}.',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 17,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        setState(() => saving = true);
                        final booked = await s.book();
                        if (!context.mounted) return;
                        if (booked) {
                          context.root('/confirmed');
                        } else {
                          setState(() => saving = false);
                          context.notice(
                            'This time is already reserved. Please choose another time.',
                          );
                        }
                      },
                child: Text(saving ? 'Confirming…' : 'Confirm'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.white12),
                onPressed: () => Navigator.canPop(context)
                    ? Navigator.pop(context)
                    : context.root('/booking'),
                child: const Text('Cancel'),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, this.bonus = false});
  final bool bonus;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Photo(
              bonus ? 'bonus' : 'confirmed',
              height: 200,
              width: 181,
              radius: 0,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            Text(bonus ? 'Congratulations!' : 'Done!', style: display(24)),
            const SizedBox(height: 16),
            Text(
              bonus
                  ? 'You get 5\$ on your bonus balance.'
                  : 'Your reservation has been confirmed.',
              style: const TextStyle(color: muted, fontSize: 17),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => context.root(bonus ? '/home' : '/reservations'),
              child: Text(bonus ? 'Book now' : 'My reservation'),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    ),
  );
}

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key, this.previous = false});
  final bool previous;
  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  late bool previous = widget.previous;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final upcoming = s.reservations
        .where((r) => !r.date.isBefore(DateUtils.dateOnly(DateTime.now())))
        .toList();
    return MainPage(
      index: 1,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const PageHeader('My reservation', back: false),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: Container(
                decoration: BoxDecoration(
                  color: pale,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  children: List.generate(
                    2,
                    (i) => Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => previous = i == 1),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: previous == (i == 1)
                                ? const Color(0xFFE2E2E4)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            i == 0 ? 'Upcoming' : 'Previous',
                            style: TextStyle(
                              fontSize: 14,
                              color: previous == (i == 1) ? ink : muted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 110),
                children: previous
                    ? [_previous(context)]
                    : upcoming.isEmpty
                    ? [
                        Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.event_available,
                                size: 60,
                                color: Colors.black26,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Your next great haircut awaits.',
                                style: display(20),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              FilledButton(
                                onPressed: () => context.root('/home'),
                                child: const Text('Find a barbershop'),
                              ),
                            ],
                          ),
                        ),
                      ]
                    : upcoming
                          .map(
                            (r) => Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: SurfaceCard(
                                onTap: () => appSheet(
                                  context,
                                  Padding(
                                    padding: const EdgeInsets.all(22),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Reservation details',
                                          style: display(24),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          '${dateLabel(r.date)} at ${r.time}\n${r.service.name} · ${r.barber.name}\n${r.shop.name}',
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 24),
                                        FilledButton(
                                          onPressed: () async {
                                            await s.cancel(r.id);
                                            if (context.mounted) {
                                              Navigator.pop(context);
                                            }
                                          },
                                          child: const Text(
                                            'Cancel reservation',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${dateLabel(r.date)} at ${r.time}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 17,
                                            ),
                                          ),
                                          const SizedBox(height: 7),
                                          Text(
                                            'Barber: ${r.barber.name}\nServices: ${r.service.name}\nAddress: ${r.shop.address}',
                                            style: const TextStyle(
                                              color: muted,
                                              fontSize: 14,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '\$ ${r.service.price}',
                                      style: display(23),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previous(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: pale,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '8 September at 12:45',
          style: TextStyle(
            color: muted,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Barber: Marjorie Williamson\nServices: Hair & Beard\nAddress: 1335 Avenue, New York',
          style: TextStyle(color: muted, fontSize: 14, height: 1.4),
        ),
        const Divider(),
        Text('Your review', style: display(18)),
        StarRating(
          value: AppScope.of(context).userRating,
          onChanged: (i) => showReviewEditor(context, initial: i),
        ),
      ],
    ),
  );
}
