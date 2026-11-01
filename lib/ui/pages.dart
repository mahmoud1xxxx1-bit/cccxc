import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/level_data.dart';
import '../game/pixel_game.dart';
import '../game/run_session.dart';
import '../game/sound_fx.dart';
import 'rift_model.dart';
import 'theme.dart';

void openLevel(BuildContext context, RiftModel model) {
  Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => PlayScreen(model: model)));
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.model});
  final RiftModel model;
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  var _tab = 0;
  static const _tabs = [
    (Icons.home_rounded, 'HOME'),
    (Icons.layers_rounded, 'WORLDS'),
    (Icons.emoji_events_rounded, 'RANKS'),
    (Icons.shopping_bag_outlined, 'SHOP'),
  ];

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: widget.model,
        builder: (context, _) => Scaffold(
          body: SafeArea(
            child: IndexedStack(index: _tab, children: [
              _HomeTab(model: widget.model),
              _WorldsTab(model: widget.model),
              LeaderboardPage(model: widget.model, inShell: true),
              const _ShopTab(),
            ]),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              color: RiftColors.surface,
              padding: const EdgeInsets.only(top: 8, bottom: 7),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final selected = index == _tab;
                  return Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _tab = index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(_tabs[index].$1,
                              color: selected ? RiftColors.gold : RiftColors.muted),
                          const SizedBox(height: 4),
                          Text(_tabs[index].$2, style: TextStyle(
                              color: selected ? RiftColors.gold : RiftColors.muted,
                              fontSize: 10, fontWeight: FontWeight.w800)),
                        ]),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      );
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.model});
  final RiftModel model;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 17, 18, 28),
        children: [
          Row(children: [
            const Icon(Icons.grid_view_rounded, color: RiftColors.gold, size: 29),
            const SizedBox(width: 9),
            const Expanded(child: Text('PIXEL RIFT', style: TextStyle(
                color: RiftColors.text, fontSize: 23,
                fontWeight: FontWeight.w900, letterSpacing: 1.0))),
            IconButton(onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => ProfilePage(model: model))),
                icon: const Icon(Icons.person_outline)),
            IconButton(onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => SettingsPage(model: model))),
                icon: const Icon(Icons.settings_outlined)),
          ]),
          const SizedBox(height: 28),
          const Text('BREAK THE PATTERN.', style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
          const SizedBox(height: 5),
          const Text('Break pixels. Beat the clock.', style: TextStyle(color: RiftColors.muted)),
          const SizedBox(height: 26),
          RiftPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Text('WORLD 01', style: TextStyle(color: RiftColors.gold,
                  fontWeight: FontWeight.w800, fontSize: 12)),
              Spacer(),
              Text('WONDERS OF ARABIA', style: TextStyle(color: RiftColors.muted, fontSize: 11)),
            ]),
            const SizedBox(height: 14),
            const _DesertArt(height: 160),
            const SizedBox(height: 16),
            const Text('DESERT GATE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            const Text('LEVEL 01  ·  2,300 PIXELS',
                style: TextStyle(color: RiftColors.muted, fontSize: 12)),
            const SizedBox(height: 10),
            Text('PERSONAL BEST  ${model.bestTimeMs == null ? '--:--.---' : formatTime(model.bestTimeMs!)}',
                style: const TextStyle(color: RiftColors.teal,
                    fontWeight: FontWeight.w800, letterSpacing: 0.4)),
            const SizedBox(height: 16),
            RiftButton(text: 'PLAY LEVEL 01', icon: Icons.play_arrow_rounded,
                onPressed: () => openLevel(context, model)),
          ])),
          const SizedBox(height: 15),
          Row(children: [
            Expanded(child: _MenuTile(icon: Icons.emoji_events_outlined,
              title: 'LEADERBOARD', subtitle: 'Local best available',
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => LeaderboardPage(model: model))))),
            const SizedBox(width: 11),
            Expanded(child: _MenuTile(icon: Icons.public,
              title: 'WORLDS', subtitle: '1 level playable',
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => _WorldsPage(model: model))))),
          ]),
          const SizedBox(height: 24),
          const Center(child: Text('VERSION 0.1.0  ·  OFFLINE PROTOTYPE',
              style: TextStyle(color: RiftColors.muted, fontSize: 10))),
        ],
      );
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.title,
      required this.subtitle, required this.onTap});
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: RiftPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: RiftColors.teal, size: 28),
        const SizedBox(height: 17),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: RiftColors.muted, fontSize: 11)),
      ])));
}

class _DesertArt extends StatelessWidget {
  const _DesertArt({this.height = 155});
  final double height;
  @override
  Widget build(BuildContext context) => ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(height: height, width: double.infinity,
          child: CustomPaint(painter: _DesertPainter())));
}

class _DesertPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 60;
    final paint = Paint();
    canvas.drawRect(Offset.zero & size, paint..color = const Color(0xFF34251E));
    // Home preview uses the very same map as gameplay, not a fictitious picture.
    for (var y = 0; y < DesertGateLevel.rows; y++) {
      for (var x = 0; x < DesertGateLevel.columns; x++) {
        final c = DesertGateLevel.map[y][x];
        if (c == '.') continue;
        paint.color = c == '#' ? const Color(0xFF627386) :
            c == 'P' ? RiftColors.teal :
            c == 'G' ? RiftColors.gold :
            (x + y) % 3 == 0 ? const Color(0xFFD19A63) : const Color(0xFFBA8154);
        canvas.drawRect(Rect.fromLTWH(x * unit + .12,
            y * size.height / 45 + .08, unit - .20,
            size.height / 45 - .16), paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WorldsTab extends StatelessWidget {
  const _WorldsTab({required this.model});
  final RiftModel model;
  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(19),
        children: [
          const Text('WORLDS', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Explore original arcade environments.', style: TextStyle(color: RiftColors.muted)),
          const SizedBox(height: 24),
          RiftPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('01  ·  WONDERS OF ARABIA', style: TextStyle(
                color: RiftColors.gold, fontWeight: FontWeight.w900)),
            const SizedBox(height: 13),
            const _DesertArt(height: 125),
            const SizedBox(height: 13),
            const Text('LEVEL 01 — DESERT GATE', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            RiftButton(text: 'PLAY', onPressed: () => openLevel(context, model)),
          ])),
          const SizedBox(height: 13),
          for (final name in ['ARCADE LEGENDS', 'ANIME ENERGY', 'CINEMATIC WORLDS'])
            Padding(padding: const EdgeInsets.only(bottom: 12), child: RiftPanel(
              child: Row(children: [
                const Icon(Icons.lock_outline, color: RiftColors.muted),
                const SizedBox(width: 13),
                Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w800))),
                const Text('COMING SOON', style: TextStyle(color: RiftColors.muted, fontSize: 10)),
              ]),
            )),
        ],
      );
}

class _WorldsPage extends StatelessWidget {
  const _WorldsPage({required this.model});
  final RiftModel model;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('WORLDS')),
      body: SafeArea(child: _WorldsTab(model: model)));
}

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key, required this.model, this.inShell = false});
  final RiftModel model;
  final bool inShell;
  @override
  Widget build(BuildContext context) {
    final content = ListView(padding: const EdgeInsets.all(19), children: [
      const Text('LEADERBOARD', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
      const SizedBox(height: 5),
      const Text('DESERT GATE  ·  LEVEL 01', style: TextStyle(color: RiftColors.muted)),
      const SizedBox(height: 20),
      RiftPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.public, color: RiftColors.teal), SizedBox(width: 9),
          Text('GLOBAL RANKINGS', style: TextStyle(fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 12),
        const Text('Online verification is not connected in this prototype. '
            'No unverified times are presented as global scores.',
            style: TextStyle(color: RiftColors.muted)),
        const SizedBox(height: 16),
        const Text('ONLINE BOARD  ·  COMING SOON', style: TextStyle(
            color: RiftColors.gold, fontWeight: FontWeight.w800)),
      ])),
      const SizedBox(height: 13),
      RiftPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('MY LOCAL RECORD', style: TextStyle(color: RiftColors.teal,
            fontSize: 12, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(model.bestTimeMs == null ? '--:--.---' : formatTime(model.bestTimeMs!),
            style: const TextStyle(fontSize: 33, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        const Text('Practice result · Not globally ranked',
            style: TextStyle(color: RiftColors.muted)),
      ])),
    ]);
    if (inShell) return content;
    return Scaffold(appBar: AppBar(title: const Text('RANKINGS')),
        body: SafeArea(child: content));
  }
}

class _ShopTab extends StatelessWidget {
  const _ShopTab();
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(19), children: [
    const Text('SHOP', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
    const SizedBox(height: 5),
    const Text('Only one permanent upgrade. No pay-to-win.',
        style: TextStyle(color: RiftColors.muted)),
    const SizedBox(height: 24),
    RiftPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.verified_user_outlined, color: RiftColors.gold, size: 42),
      const SizedBox(height: 15),
      const Text('REMOVE ADS — LIFETIME', style: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      const Text('One purchase. Ad-free experience forever.',
          style: TextStyle(color: RiftColors.muted)),
      const SizedBox(height: 19),
      const Text('✓  No interstitial ads'),
      const SizedBox(height: 8),
      const Text('✓  No subscriptions'),
      const SizedBox(height: 8),
      const Text('✓  No competitive advantage'),
      const SizedBox(height: 21),
      const Text('Google Play Billing is not connected yet. '
          'Purchases are disabled in this prototype.',
          style: TextStyle(color: RiftColors.muted, fontSize: 12)),
      const SizedBox(height: 13),
      const RiftButton(text: 'PURCHASE NOT AVAILABLE YET',
          icon: Icons.lock_outline, onPressed: null),
    ])),
  ]);
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.model});
  final RiftModel model;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('PROFILE')),
    body: AnimatedBuilder(animation: model,
      builder: (context, _) => ListView(padding: const EdgeInsets.all(19), children: [
        const RiftPanel(child: Row(children: [
          CircleAvatar(radius: 26, backgroundColor: RiftColors.raised,
              child: Icon(Icons.person, color: RiftColors.gold)),
          SizedBox(width: 15),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('GUEST PLAYER', style: TextStyle(fontWeight: FontWeight.w900)),
            Text('Offline account', style: TextStyle(color: RiftColors.muted)),
          ]),
        ])),
        const SizedBox(height: 14),
        RiftPanel(child: Column(children: [
          _StatLine('COMPLETED RUNS', '${model.victories}'),
          const Divider(),
          _StatLine('FAILED RUNS', '${model.failedRuns}'),
          const Divider(),
          _StatLine('PERSONAL BEST', model.bestTimeMs == null ? '--:--.---' : formatTime(model.bestTimeMs!)),
        ])),
        const SizedBox(height: 16),
        const Text('GOOGLE SIGN-IN WILL BE AVAILABLE AFTER FIREBASE SETUP.',
            style: TextStyle(color: RiftColors.muted, fontSize: 12)),
      ])),
  );
}

class _StatLine extends StatelessWidget {
  const _StatLine(this.title, this.value);
  final String title, value;
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(title, style: const TextStyle(color: RiftColors.muted, fontSize: 12))),
    Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
  ]);
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.model});
  final RiftModel model;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('SETTINGS')),
    body: AnimatedBuilder(animation: model,
      builder: (context, _) => ListView(padding: const EdgeInsets.all(19), children: [
        RiftPanel(child: Column(children: [
          SwitchListTile(title: const Text('SOUND EFFECTS'),
              subtitle: const Text('Original arcade impact sounds'),
              value: model.soundEnabled, onChanged: model.setSound,
              activeThumbColor: RiftColors.teal),
          const Divider(),
          SwitchListTile(title: const Text('REDUCE EFFECTS'),
              subtitle: const Text('Disable ball trails'),
              value: model.reduceEffects, onChanged: model.setReduceEffects,
              activeThumbColor: RiftColors.teal),
          const Divider(),
          SwitchListTile(title: const Text('VIBRATION'),
              subtitle: const Text('Haptics planned for later release'),
              value: model.vibrationEnabled, onChanged: model.setVibration,
              activeThumbColor: RiftColors.teal),
        ])),
        const SizedBox(height: 16),
        const Text('LANGUAGE  ·  ENGLISH', style: TextStyle(color: RiftColors.muted)),
        const SizedBox(height: 10),
        const Text('GAME VERSION  ·  0.1.0', style: TextStyle(color: RiftColors.muted)),
      ])),
  );
}

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key, required this.model});
  final RiftModel model;
  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> with WidgetsBindingObserver {
  late final RunSession session;
  late final PixelRiftGame game;
  late final SoundFx sound;
  bool _handledEnd = false;

  @override
  void initState() {
    super.initState();
    session = RunSession()..addListener(_observeSession);
    sound = SoundFx(() => widget.model.soundEnabled);
    game = PixelRiftGame(session: session, sound: sound,
        reduceEffects: widget.model.reduceEffects);
    WidgetsBinding.instance.addObserver(this);
  }

  void _observeSession() {
    if (_handledEnd || !mounted) return;
    if (session.status == RunStatus.won || session.status == RunStatus.lost) {
      _handledEnd = true;
      if (session.status == RunStatus.won) {
        widget.model.recordVictory(session.elapsedMs);
      } else {
        widget.model.recordFailure();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showResult();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) session.pause();
  }

  Future<void> _pauseGame() async {
    if (session.status == RunStatus.won || session.status == RunStatus.lost) return;
    session.pause();
    final option = await showDialog<String>(
      context: context, barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('GAME PAUSED'),
        content: const Text('Pausing disqualifies this run from future online rankings. '
            'You can still finish and save your personal best.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, 'home'), child: const Text('HOME')),
          TextButton(onPressed: () => Navigator.pop(ctx, 'restart'), child: const Text('RESTART')),
          FilledButton(onPressed: () => Navigator.pop(ctx, 'resume'), child: const Text('RESUME')),
        ],
      ),
    );
    if (!mounted) return;
    if (option == 'home') {
      Navigator.of(context).pop();
    } else if (option == 'restart') {
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
          builder: (_) => PlayScreen(model: widget.model)));
    } else {
      session.resume();
    }
  }

  Future<void> _showResult() async {
    final won = session.status == RunStatus.won;
    final time = formatTime(session.elapsedMs);
    final isPersonalBest = won &&
        (widget.model.bestTimeMs == null || session.elapsedMs <= widget.model.bestTimeMs!);
    final option = await showDialog<String>(
      context: context, barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(won ? 'LEVEL COMPLETE' : 'RUN FAILED',
          style: TextStyle(color: won ? RiftColors.teal : RiftColors.coral,
              fontWeight: FontWeight.w900)),
        content: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('TIME  $time', style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('PIXELS  ${session.pixelsDestroyed} / ${DesertGateLevel.totalPixels}'),
          const SizedBox(height: 8),
          Text('LOSSES  ${session.losses} / 3'),
          if (isPersonalBest) const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('PERSONAL BEST!', style: TextStyle(color: RiftColors.gold))),
          const SizedBox(height: 9),
          const Text('LOCAL RESULT · ONLINE RANKING NOT ACTIVE',
              style: TextStyle(color: RiftColors.muted, fontSize: 11)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, 'home'), child: const Text('HOME')),
          TextButton(onPressed: () => Navigator.pop(ctx, 'rank'), child: const Text('RANKS')),
          FilledButton(onPressed: () => Navigator.pop(ctx, 'replay'), child: const Text('REPLAY')),
        ],
      ),
    );
    if (!mounted) return;
    if (option == 'replay') {
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
          builder: (_) => PlayScreen(model: widget.model)));
    } else if (option == 'rank') {
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
          builder: (_) => LeaderboardPage(model: widget.model)));
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    session.removeListener(_observeSession);
    session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Column(children: [
      AnimatedBuilder(animation: session, builder: (context, _) => Container(
        padding: const EdgeInsets.fromLTRB(17, 8, 14, 10),
        decoration: const BoxDecoration(color: RiftColors.surface),
        child: Column(children: [
          Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LEVEL 01', style: TextStyle(color: RiftColors.muted, fontSize: 10)),
                Text('DESERT GATE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
              ],
            )),
            Column(children: [
              const Text('TIME', style: TextStyle(color: RiftColors.muted, fontSize: 10)),
              Text(formatTime(session.elapsedMs), style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w900, fontFeatures: [FontFeature.tabularFigures()])),
            ]),
            const SizedBox(width: 12),
            IconButton(icon: const Icon(Icons.pause_circle_outline, size: 28),
                onPressed: _pauseGame),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _HudStat(label: 'PIXELS', value:
                '${session.pixelsDestroyed} / ${DesertGateLevel.totalPixels}', color: RiftColors.gold)),
            _HudStat(label: 'LOSSES', value: '${session.losses} / 3', color: RiftColors.coral),
          ]),
          const SizedBox(height: 9),
          ClipRRect(borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: session.progress, minHeight: 5,
              backgroundColor: RiftColors.raised, color: RiftColors.teal)),
        ]),
      )),
      Expanded(child: LayoutBuilder(builder: (context, constraints) => Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) {
          game.movePaddle(e.localPosition.dx);
          game.launch();
        },
        onPointerMove: (e) => game.movePaddle(e.localPosition.dx),
        child: ClipRect(child: GameWidget(game: game)),
      ))),
      AnimatedBuilder(animation: session, builder: (context, _) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 9),
        color: RiftColors.surface,
        child: Text(
          session.status == RunStatus.ready ? 'DRAG TO MOVE  ·  TAP TO LAUNCH' :
          session.status == RunStatus.paused ? 'PAUSED' :
          session.status == RunStatus.playing ? 'KEEP THE BALLS IN PLAY' : 'RUN FINISHED',
          textAlign: TextAlign.center,
          style: const TextStyle(color: RiftColors.muted, fontSize: 11, fontWeight: FontWeight.w700),
        ),
      )),
    ])),
  );
}

class _HudStat extends StatelessWidget {
  const _HudStat({required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: RiftColors.muted, fontSize: 10)),
      Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900,
          fontFeatures: const [FontFeature.tabularFigures()])),
    ],
  );
}
