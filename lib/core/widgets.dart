import 'package:flutter/material.dart';
import 'theme.dart';
import 'app_state.dart';
import '../data/models.dart';

extension Navigation on BuildContext {
  Future<T?> open<T>(String path) => Navigator.of(this).pushNamed<T>(path);
  void root(String path) =>
      Navigator.of(this).pushNamedAndRemoveUntil(path, (_) => false);
  void notice(String message) =>
      ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
}

class Photo extends StatelessWidget {
  const Photo(
    this.name, {
    super.key,
    this.width,
    this.height,
    this.radius = 16,
    this.fit = BoxFit.cover,
  });
  final String name;
  final double? width, height;
  final double radius;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        .2126,
        .7152,
        .0722,
        0,
        0,
        .2126,
        .7152,
        .0722,
        0,
        0,
        .2126,
        .7152,
        .0722,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: Image.asset(
        'assets/images/$name.${['welcome', 'shop-shave', 'shop-cut', 'barber-work', 'map', 'service-cut', 'service-beard', 'service-style'].contains(name) ? 'jpg' : 'png'}',
        width: width,
        height: height,
        fit: fit,
      ),
    ),
  );
}

class RoundButton extends StatelessWidget {
  const RoundButton(
    this.icon, {
    super.key,
    required this.onTap,
    this.color = ink,
    this.background = pale,
    this.size = 48,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color color, background;
  final double size;
  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onTap,
    style: IconButton.styleFrom(
      backgroundColor: background,
      foregroundColor: color,
      fixedSize: Size(size, size),
    ),
    icon: Icon(icon),
  );
}

class PageHeader extends StatelessWidget {
  const PageHeader(
    this.title, {
    super.key,
    this.subtitle,
    this.back = true,
    this.trailing,
  });
  final String title;
  final String? subtitle;
  final bool back;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
    child: Row(
      children: [
        SizedBox(
          width: 48,
          child: back
              ? RoundButton(
                  Icons.chevron_left,
                  onTap: () => Navigator.canPop(context)
                      ? Navigator.pop(context)
                      : context.root('/home'),
                )
              : null,
        ),
        Expanded(
          child: Column(
            children: [
              Text(title, style: display(18), textAlign: TextAlign.center),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    subtitle!,
                    style: const TextStyle(color: muted, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: 48, child: trailing),
      ],
    ),
  );
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: const [
        BoxShadow(
          color: Color(0x10000000),
          blurRadius: 18,
          offset: Offset(0, 12),
        ),
        BoxShadow(color: Color(0x04000000), blurRadius: 2),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    ),
  );
}

class BottomNav extends StatelessWidget {
  const BottomNav(this.index, {super.key});
  final int index;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: 280,
      height: 66,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          3,
          (i) => IconButton(
            tooltip: ['Explore', 'Reservations', 'Profile'][i],
            onPressed: () =>
                context.root(['/home', '/reservations', '/profile'][i]),
            icon: Badge(
              isLabelVisible:
                  i == 1 && AppScope.of(context).reservations.isNotEmpty,
              smallSize: 5,
              backgroundColor: orange,
              child: Icon(
                [
                  Icons.content_cut,
                  Icons.calendar_month_outlined,
                  Icons.person_outline,
                ][i],
                size: 29,
                color: index == i ? ink : Colors.black26,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class MainPage extends StatelessWidget {
  const MainPage({
    super.key,
    required this.child,
    required this.index,
    this.background = Colors.white,
  });
  final Widget child;
  final int index;
  final Color background;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: background,
    body: Stack(
      children: [
        Positioned.fill(child: child),
        Align(alignment: Alignment.bottomCenter, child: BottomNav(index)),
      ],
    ),
  );
}

class SlotStrip extends StatelessWidget {
  const SlotStrip({super.key, this.days = false, this.dark = false});
  final bool days, dark;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final now = DateUtils.dateOnly(DateTime.now());
    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        itemCount: days ? 14 : times.length,
        separatorBuilder: (_, i) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final day = now.add(Duration(days: i));
          final selected = days
              ? DateUtils.isSameDay(s.date, day)
              : s.time == times[i];
          final active = dark ? orange : ink;
          return Material(
            color: selected
                ? active
                : dark
                ? const Color(0xFF484848)
                : pale,
            borderRadius: BorderRadius.circular(40),
            child: InkWell(
              key: ValueKey(days ? 'day-$i' : 'time-${times[i]}'),
              borderRadius: BorderRadius.circular(40),
              onTap: () => s.select(
                day: days ? day : null,
                slot: days ? null : times[i],
              ),
              child: SizedBox(
                width: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      days ? day.day.toString().padLeft(2, '0') : times[i],
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.2,
                        color: selected || dark ? Colors.white : ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      days
                          ? [
                              'MON',
                              'TUE',
                              'WED',
                              'THU',
                              'FRI',
                              'SAT',
                              'SUN',
                            ][day.weekday - 1]
                          : int.parse(times[i].split(':').first) < 12
                          ? 'AM'
                          : 'PM',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.2,
                        color: selected || dark ? Colors.white70 : muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ShopStats extends StatelessWidget {
  const ShopStats(this.shop, {super.key});
  final Shop shop;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: gold, size: 23),
            const SizedBox(width: 5),
            Text(shop.rating, style: display(23)),
          ],
        ),
        RichText(
          text: TextSpan(
            style: display(23),
            children: const [
              TextSpan(text: '\$\$'),
              TextSpan(
                text: '\$',
                style: TextStyle(color: Colors.black26),
              ),
            ],
          ),
        ),
        Row(
          children: [
            const Icon(Icons.near_me, color: Colors.black26, size: 22),
            const SizedBox(width: 5),
            Text(shop.distance, style: display(23)),
          ],
        ),
      ],
    ),
  );
}

class FormEntry extends StatefulWidget {
  const FormEntry({
    super.key,
    required this.label,
    required this.controller,
    this.secret = false,
    this.hint = '',
    this.type = TextInputType.text,
    this.validator,
    this.large = true,
  });
  final String label, hint;
  final TextEditingController controller;
  final bool secret, large;
  final TextInputType type;
  final String? Function(String?)? validator;
  @override
  State<FormEntry> createState() => _FormEntryState();
}

class _FormEntryState extends State<FormEntry> {
  bool hidden = true;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(color: Color(0xFFB8B8BB), fontSize: 16),
        ),
        TextFormField(
          key: ValueKey(widget.label),
          controller: widget.controller,
          keyboardType: widget.type,
          obscureText: widget.secret && hidden,
          validator: widget.validator,
          style: widget.large ? display(24) : const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            hintText: widget.hint,
            hintStyle: display(24, Colors.black26),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            suffixIcon: widget.secret
                ? IconButton(
                    tooltip: 'Show password',
                    onPressed: () => setState(() => hidden = !hidden),
                    icon: Icon(
                      hidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.black26,
                      size: 22,
                    ),
                  )
                : IconButton(
                    tooltip: 'Clear ${widget.label}',
                    onPressed: widget.controller.clear,
                    icon: const Icon(
                      Icons.cancel,
                      size: 14,
                      color: Colors.black26,
                    ),
                  ),
          ),
        ),
      ],
    ),
  );
}

String? emailValidator(String? value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value ?? '')
    ? null
    : 'Enter a valid email address';
String? requiredValidator(String? value) =>
    (value ?? '').trim().isEmpty ? 'This field is required' : null;
Future<T?> appSheet<T>(BuildContext context, Widget child) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: child,
        ),
      ),
    );
