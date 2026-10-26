import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => MainPage(
    index: 0,
    child: Column(
      children: [
        Container(
          color: ink,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        tooltip: 'Search barbershops',
                        onPressed: () => context.open('/search'),
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      Text('Barbershops NY', style: display(18, Colors.white)),
                      IconButton(
                        tooltip: 'Open map',
                        onPressed: () => context.open('/map'),
                        icon: const Icon(
                          Icons.map_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                const SlotStrip(days: true, dark: true),
                const SizedBox(height: 22),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 16, bottom: 110),
            itemCount: shops.length,
            separatorBuilder: (_, i) =>
                const Divider(thickness: 16, color: pale, height: 32),
            itemBuilder: (context, i) => ShopCard(shops[i], index: i),
          ),
        ),
      ],
    ),
  );
}

class ShopCard extends StatelessWidget {
  const ShopCard(
    this.shop, {
    super.key,
    required this.index,
    this.photo = true,
  });
  final Shop shop;
  final int index;
  final bool photo;
  void open(BuildContext context) {
    AppScope.of(context).select(shop: index);
    context.open('/shop');
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (photo)
        GestureDetector(
          onTap: () => open(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Photo(shop.image, height: 230, width: double.infinity),
          ),
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => open(context),
              child: Text(shop.name, style: display(32)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    shop.address,
                    style: const TextStyle(color: Color(0xFFB8B8BB)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  ' • ${shop.walk} min. ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                RoundButton(
                  Icons.location_on_outlined,
                  onTap: () {
                    AppScope.of(context).select(shop: index);
                    context.open('/map-small');
                  },
                ),
              ],
            ),
            const Divider(),
            ShopStats(shop),
            const Divider(),
          ],
        ),
      ),
      SlotStrip(key: ValueKey('shop-slots-$index')),
      Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
        child: Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              AppScope.of(context).select(shop: index);
              context.open('/booking');
            },
            child: const Text('Book a visit  →'),
          ),
        ),
      ),
    ],
  );
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final query = TextEditingController();
  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = shops
        .where((s) => s.name.toLowerCase().contains(query.text.toLowerCase()))
        .toList();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PageHeader('Search'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: TextField(
                controller: query,
                onChanged: (_) => setState(() {}),
                style: display(26),
                decoration: InputDecoration(
                  labelText: 'Search barbershops',
                  labelStyle: const TextStyle(color: muted),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    tooltip: 'Map',
                    onPressed: () => context.open('/map'),
                    icon: const Icon(Icons.map_outlined),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: result.isEmpty
                  ? const Center(
                      child: Text('No barbershops found. Try another name.'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(22),
                      itemCount: result.length,
                      separatorBuilder: (_, i) => const SizedBox(height: 18),
                      itemBuilder: (context, i) {
                        final shop = result[i];
                        return SurfaceCard(
                          onTap: () {
                            AppScope.of(
                              context,
                            ).select(shop: shops.indexOf(shop));
                            context.open('/shop');
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(shop.name, style: display(18)),
                                  ),
                                  const Icon(Icons.chevron_right, color: muted),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${shop.address} • ${shop.walk} min.',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ShopStats(shop),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.level = 0});
  final int level;
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final transform = TransformationController();
  late int level = widget.level;
  @override
  void dispose() {
    transform.dispose();
    super.dispose();
  }

  void zoom(double factor) {
    final next = (transform.value.getMaxScaleOnAxis() * factor).clamp(1.0, 3.0);
    transform.value = Matrix4.identity()..scaleByDouble(next, next, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      backgroundColor: ink,
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: transform,
              minScale: 1,
              maxScale: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const Photo('map', radius: 0),
                  ...List.generate(3, (i) {
                    final active = level > 0 && state.shopIndex == i;
                    return Align(
                      alignment: [
                        const Alignment(-.3, -.44),
                        const Alignment(.36, -.3),
                        const Alignment(.17, .1),
                      ][i],
                      child: GestureDetector(
                        key: ValueKey('map-pin-$i'),
                        onTap: () {
                          state.select(shop: i);
                          setState(() => level = 1);
                        },
                        child: Container(
                          width: active ? 42 : 20,
                          height: active ? 42 : 20,
                          decoration: BoxDecoration(
                            color: orange,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: active
                              ? const Icon(
                                  Icons.content_cut,
                                  color: Colors.white,
                                  size: 25,
                                )
                              : null,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: RoundButton(
                  Icons.close,
                  background: Colors.white60,
                  onTap: () => Navigator.canPop(context)
                      ? Navigator.pop(context)
                      : context.root('/home'),
                ),
              ),
            ),
          ),
          Positioned(
            right: 22,
            top: MediaQuery.sizeOf(context).height * .29,
            child: Column(
              children: [
                RoundButton(
                  Icons.add,
                  background: Colors.white60,
                  onTap: () => zoom(1.3),
                ),
                const SizedBox(height: 16),
                RoundButton(
                  Icons.remove,
                  background: Colors.white60,
                  onTap: () => zoom(.77),
                ),
                const SizedBox(height: 24),
                RoundButton(
                  Icons.near_me,
                  background: Colors.white60,
                  onTap: () {
                    transform.value = Matrix4.identity();
                    context.notice('Showing the reference neighborhood.');
                  },
                ),
              ],
            ),
          ),
          if (level > 0)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height:
                    MediaQuery.sizeOf(context).height *
                    (level == 1
                        ? .39
                        : level == 2
                        ? .85
                        : .91),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onVerticalDragEnd: (d) => setState(
                        () => level = (d.primaryVelocity ?? 0) < 0
                            ? (level + 1).clamp(1, 3)
                            : (level - 1).clamp(0, 3),
                      ),
                      onTap: () =>
                          setState(() => level = level == 3 ? 1 : level + 1),
                      child: Container(
                        width: 100,
                        height: 25,
                        alignment: Alignment.center,
                        child: Container(
                          width: 38,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: level == 3
                            ? const ShopReviewsBody()
                            : _details(context, state),
                      ),
                    ),
                    if (level == 3)
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
            ),
        ],
      ),
    );
  }

  Widget _details(BuildContext context, AppState state) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(state.shop.name, style: display(32)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    state.shop.address,
                    style: const TextStyle(color: muted),
                  ),
                ),
                Text(' • ${state.shop.walk} min.'),
              ],
            ),
            const Divider(),
            ShopStats(state.shop),
            const Divider(),
          ],
        ),
      ),
      const SlotStrip(),
      if (level >= 2) ...[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 22),
          child: Divider(),
        ),
        const ShopPrices(),
        const SizedBox(height: 26),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Photos', style: display(24)),
              TextButton(
                onPressed: () => setState(() => level = 3),
                child: const Text('See all'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Photo(state.shop.image, height: 230, width: double.infinity),
        ),
        Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              TextButton(
                onPressed: () => setState(() => level = 3),
                child: const Text('Rating and reviews →'),
              ),
              FilledButton(
                onPressed: () => context.open('/booking'),
                child: const Text('Book'),
              ),
            ],
          ),
        ),
      ] else
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: TextButton(
            onPressed: () => setState(() => level = 2),
            child: const Text('View prices and photos →'),
          ),
        ),
    ],
  );
}

class ShopPrices extends StatelessWidget {
  const ShopPrices({super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
        child: Text('Prices', style: display(24)),
      ),
      SizedBox(
        height: 205,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          itemCount: 3,
          separatorBuilder: (_, i) => const SizedBox(width: 16),
          itemBuilder: (context, i) {
            final index = [0, 1, 4][i], s = services[index];
            return GestureDetector(
              onTap: () {
                AppScope.of(context).select(service: index);
                context.open('/booking');
              },
              child: SizedBox(
                width: 130,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Photo(s.image, width: 130, height: 130),
                    const SizedBox(height: 6),
                    Text(
                      s.name,
                      style: const TextStyle(color: muted, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text('\$ ${s.price}', style: display(23)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          const PageHeader('Rating and reviews'),
          const Expanded(
            child: SingleChildScrollView(
              child: ShopReviewsBody(showPhoto: false),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: FilledButton(
              onPressed: () => showReviewEditor(context),
              child: const Text('Add review'),
            ),
          ),
        ],
      ),
    ),
  );
}

class ShopReviewsBody extends StatelessWidget {
  const ShopReviewsBody({super.key, this.showPhoto = true});
  final bool showPhoto;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showPhoto) ...[
            Text(s.shop.name, style: display(18)),
            const SizedBox(height: 18),
            Photo(s.shop.image, height: 180, width: double.infinity),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('Rating and reviews', style: display(22))),
                TextButton(
                  onPressed: () => context.open('/reviews'),
                  child: const Text('See all'),
                ),
              ],
            ),
          ],
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: gold, size: 34),
                Text(s.shop.rating, style: display(52)),
              ],
            ),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                '83 reviews',
                style: TextStyle(color: Colors.black26, fontSize: 14),
              ),
            ),
          ),
          const Divider(height: 50),
          const Center(
            child: Text(
              'Been here?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
          StarRating(
            value: s.userRating,
            onChanged: (i) => showReviewEditor(context, initial: i),
          ),
          const Divider(height: 48),
          if (s.userRating > 0)
            ReviewCard(
              name: s.name,
              body: s.userReview.isEmpty
                  ? 'Thank you for your visit!'
                  : s.userReview,
              rating: '${s.userRating},0',
            ),
          const ReviewCard(
            name: 'Jorge Miles',
            body:
                "Seriously one of the best, if not the best haircuts I've ever gotten.",
            rating: '5,0',
            photo: true,
          ),
          const ReviewCard(
            name: 'Tomothy Edwards',
            body: 'Overall great place, and skilled barbers.',
            rating: '4,9',
          ),
          const ReviewCard(
            name: 'Max Flores',
            body:
                "Best Barbershop I visited last year. It was really a new experience for me!",
            rating: '4,9',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.name,
    required this.body,
    required this.rating,
    this.photo = false,
  });
  final String name, body, rating;
  final bool photo;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: pale,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (photo)
              const Photo('barber-2', width: 48, height: 48, radius: 40)
            else
              CircleAvatar(
                backgroundColor: Colors.black12,
                child: Text(
                  name.split(' ').map((e) => e[0]).take(2).join(),
                  style: const TextStyle(
                    color: muted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Text(
                    '10.10.2026',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.star, color: gold),
            Text(rating),
          ],
        ),
        const SizedBox(height: 10),
        Text(body, style: const TextStyle(fontSize: 14)),
      ],
    ),
  );
}

class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: List.generate(
      5,
      (i) => IconButton(
        tooltip: '${i + 1} stars',
        onPressed: () => onChanged(i + 1),
        icon: Icon(
          i < value ? Icons.star : Icons.star_border,
          color: gold,
          size: 38,
        ),
      ),
    ),
  );
}

Future<void> showReviewEditor(BuildContext context, {int initial = 0}) async {
  final state = AppScope.of(context),
      controller = TextEditingController(text: AppScope.of(context).userReview);
  int rating = initial == 0 ? state.userRating : initial;
  await appSheet(
    context,
    StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your review', style: display(24)),
            const SizedBox(height: 16),
            StarRating(
              value: rating,
              onChanged: (i) => setState(() => rating = i),
            ),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tell us about your visit',
              ),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: rating == 0
                  ? null
                  : () {
                      state.review(rating, controller.text.trim());
                      Navigator.pop(context);
                    },
              child: const Text('Publish review'),
            ),
          ],
        ),
      ),
    ),
  );
  // Dispose after the closing sheet transition has released its text field.
  await Future<void>.delayed(const Duration(milliseconds: 300));
  controller.dispose();
}
