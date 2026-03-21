import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../data/models/notification_model.dart';
import '../controllers/notification_controller.dart';

abstract class GrowWiseColors {
  static const Color scaffoldBg = Color(0xFF200E36);
  static const Color cardBg = Color(0xFF4E1D51);
  static const Color iconBg = Color(0xFF501E51);
  static const Color cardGradStart = Color(0xFF58295B);
  static const Color cardGradEnd = Color(0xFF381046);
  static const Color amber = Color(0xFFC88A28);
  static const Color amberLight = Color(0xFFE0A840);
  static const Color primaryPurple = Color(0xFF5C2868);
  static const Color violet = Color(0xFF8048AC);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFB8A0C0);
  static const Color textDim = Color(0xFF786090);
  static const Color navBg = Color(0xFF1C0A30);
  static const Color navIconActive = Color(0xFFC88A28);
  static const Color navIconInactive = Color(0xFF7A7498);
  static const Color accentAppointment = Color(0xFF7C3AED);
  static const Color accentVitamin = Color(0xFF059669);
  static const Color accentVaccination = Color(0xFFDC2626);
  static const Color accentGrowth = Color(0xFFC88A28);
}

class _NotifConfig {
  final IconData icon;
  final Color color;
  final String label;
  const _NotifConfig(this.icon, this.color, this.label);
}

const Map<NotificationType, _NotifConfig> _typeConfig = {
  NotificationType.appointment: _NotifConfig(
    Icons.calendar_today_rounded, _C.accentAppt, 'Appointment'),
  NotificationType.vitamin: _NotifConfig(
    Icons.medication_liquid_rounded, _C.accentVitamin, 'Supplement'),
  NotificationType.vaccination: _NotifConfig(
    Icons.vaccines_rounded, _C.accentVaccine, 'Vaccination'),
  NotificationType.growth: _NotifConfig(
    Icons.show_chart_rounded, _C.accentGrowth, 'Growth'),
};
 
_NotifConfig _configFor(NotificationType type) {
  return _typeConfig[type] ??
      const _NotifConfig(Icons.notifications_rounded, Color(0xFF7A7498), 'Info');
}
 
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}
 
class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
 
  late final NotificationController _ctrl;
  int _currentNavIndex = 0;
  late final AnimationController _listEntranceCtrl;
 
  @override
  void initState() {
    super.initState();
 
    _ctrl = Get.put(NotificationController());
 
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.refresh();
    });
 
    _listEntranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }
 
  @override
  void dispose() {
    _listEntranceCtrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.scaffoldBg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentNavIndex,
        onTap: (i) {
          setState(() => _currentNavIndex = i);
          HapticFeedback.selectionClick();
          const routes = ['/dashboard', '/growth', '/education', '/support'];
          if (i < routes.length) Get.toNamed(routes[i]);
        },
      ),
    );
  }
 
  Widget _buildHeader() {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(top: topPad + 12, left: 20, right: 20, bottom: 16),
      decoration: BoxDecoration(
        color: _C.scaffoldBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _C.iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: _C.textPrimary, size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      color: _C.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Obx(() {
                    final count = _ctrl.unreadCount;
                    if (count == 0) return const SizedBox.shrink();
                    return Text(
                      '$count unread',
                      style: const TextStyle(
                        color: _C.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
          Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _ctrl.hasNotifications
                    ? GestureDetector(
                        key: const ValueKey('clear'),
                        onTap: _ctrl.clearAll,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _C.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _C.amber.withOpacity(0.4), width: 1),
                          ),
                          child: const Text(
                            'Clear All',
                            style: TextStyle(
                              color: _C.amber,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              )),
        ],
      ),
    );
  }
 
  Widget _buildBody() {
    return Obx(() {
      if (_ctrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: _C.amber),
        );
      }
 
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        child: _ctrl.notifications.isEmpty
            ? const _EmptyState(key: ValueKey('empty'))
            : _buildList(key: const ValueKey('list')),
      );
    });
  }
 
  Widget _buildList({Key? key}) {
    return ListView.builder(
      key: key,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _ctrl.notifications.length,
      itemBuilder: (context, index) {
        if (index >= _ctrl.notifications.length) return const SizedBox.shrink();
 
        final notif = _ctrl.notifications[index];
        final staggerStart = (index * 0.1).clamp(0.0, 0.6);
        final staggerEnd = (staggerStart + 0.7).clamp(0.0, 1.0);
        final anim = CurvedAnimation(
          parent: _listEntranceCtrl,
          curve: Interval(staggerStart, staggerEnd, curve: Curves.easeOutCubic),
        );
 
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(anim),
            child: _NotifCard(
              key: ValueKey(notif.id),
              notification: notif,
              onDismiss: () => _ctrl.dismiss(notif.id),
              onTap: () => _showDetail(notif),
            ),
          ),
        );
      },
    );
  }
 
  void _showDetail(NotificationModel notif) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (_) => _DetailSheet(notification: notif),
    ).then((_) {
      _ctrl.markAsRead(notif.id);
    });
  }
}
 
class _NotifCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onDismiss;
  final VoidCallback onTap;
 
  const _NotifCard({
    super.key,
    required this.notification,
    required this.onDismiss,
    required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    final cfg = _configFor(notification.type);
 
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart, 
      onDismissed: (_) => onDismiss(),
      confirmDismiss: (_) async => true,
      background: _swipeBackground(),
      child: GestureDetector(
        onTap: onTap,
        child: _cardBody(cfg),
      ),
    );
  }
 
  Widget _swipeBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade900.withOpacity(0.0), Colors.red.shade700],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
          SizedBox(height: 4),
          Text('Delete',
              style: TextStyle(color: Colors.white, fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
 
  Widget _cardBody(_NotifConfig cfg) {
    final isUnread = !notification.isRead;
 
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_C.cardGradStart, _C.cardGradEnd],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(color: cfg.color, width: 4),
          top: BorderSide(
            color: isUnread
                ? Colors.white.withOpacity(0.55)   
                : _C.violet.withOpacity(0.25),       
            width: isUnread ? 1.5 : 1.0,
          ),
          right: BorderSide(
            color: isUnread
                ? Colors.white.withOpacity(0.35)
                : _C.violet.withOpacity(0.1),
            width: isUnread ? 1.5 : 1.0,
          ),
          bottom: BorderSide(
            color: isUnread
                ? Colors.white.withOpacity(0.35)
                : _C.violet.withOpacity(0.1),
            width: isUnread ? 1.5 : 1.0,
          ),
        ),
 
        boxShadow: [
          if (isUnread)
            BoxShadow(
              color: Colors.white.withOpacity(0.12),
              blurRadius: 18,
              spreadRadius: 2,
              offset: Offset.zero,
            ),
          BoxShadow(
            color: cfg.color.withOpacity(isUnread ? 0.18 : 0.10),
            blurRadius: 20,
            spreadRadius: -2,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
 
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _iconChip(cfg),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _typeBadge(cfg),
                      const SizedBox(height: 6),
                      Text(
                        notification.title,
                        style: TextStyle(
                          color: isUnread ? _C.textPrimary : _C.textMuted,
                          fontSize: 14,
                          fontWeight: isUnread ? FontWeight.w700 : FontWeight.w400,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(width: 10),
                  Container(
                    width: 9, height: 9,
                    decoration: BoxDecoration(
                      color: cfg.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: cfg.color.withOpacity(0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
 
            const SizedBox(height: 12),
            Divider(color: _C.violet.withOpacity(0.2), height: 1, thickness: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isUnread ? 'Tap to read • Swipe to dismiss' : 'Swipe left to dismiss',
                  style: TextStyle(
                    color: _C.textDim.withOpacity(0.6),
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 11, color: _C.amber.withOpacity(0.8)),
                    const SizedBox(width: 4),
                    Text(
                      notification.timeAgo,
                      style: TextStyle(
                        color: _C.amber.withOpacity(0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _iconChip(_NotifConfig cfg) {
    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_C.iconBg, cfg.color.withOpacity(0.25)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cfg.color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: cfg.color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(cfg.icon, color: _C.amberLight, size: 24),
      ),
    );
  }
 
  Widget _typeBadge(_NotifConfig cfg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cfg.color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        cfg.label.toUpperCase(),
        style: TextStyle(
          color: cfg.color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
 
class _DetailSheet extends StatelessWidget {
  final NotificationModel notification;
  const _DetailSheet({required this.notification});
 
  @override
  Widget build(BuildContext context) {
    final cfg = _configFor(notification.type);
 
    return Container(
      margin: const EdgeInsets.only(top: 80),
      decoration: const BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: _C.textDim.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_C.iconBg, cfg.color.withOpacity(0.3)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: cfg.color.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: cfg.color.withOpacity(0.3),
                    blurRadius: 16, spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(cfg.icon, color: _C.amberLight, size: 30),
            ),
            const SizedBox(height: 16),
 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                notification.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _C.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time_rounded,
                    size: 12, color: _C.amber.withOpacity(0.8)),
                const SizedBox(width: 4),
                Text(
                  notification.timeAgo,
                  style: TextStyle(
                    color: _C.amber.withOpacity(0.9),
                    fontSize: 12, fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(color: _C.violet.withOpacity(0.3), thickness: 1),
            ),
            const SizedBox(height: 16),
 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                notification.body.isNotEmpty
                    ? notification.body
                    : 'No additional details available.',
                style: TextStyle(
                  color: _C.textMuted.withOpacity(0.9),
                  fontSize: 14, height: 1.65,
                ),
              ),
            ),
            const SizedBox(height: 28),
 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cfg.color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Got it',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
 
            SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
          ],
        ),
      ),
    );
  }
}
 
class _EmptyState extends StatefulWidget {
  const _EmptyState({super.key});
  @override
  State<_EmptyState> createState() => _EmptyStateState();
}
 
class _EmptyStateState extends State<_EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
 
  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }
 
  @override
  void dispose() { _pulse.dispose(); super.dispose(); }
 
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) {
          final op = 0.3 + _pulse.value * 0.4;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 140, height: 140,
                child: CustomPaint(
                  painter: _RingsPainter(op),
                  child: Center(
                    child: Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(colors: [
                          _C.violet.withOpacity(0.4), _C.iconBg]),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _C.violet.withOpacity(0.5), width: 1.5),
                      ),
                      child: Icon(Icons.notifications_off_outlined,
                          size: 30,
                          color: _C.textMuted.withOpacity(0.5 + op * 0.5)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text("You're all caught up!",
                style: TextStyle(color: _C.textPrimary, fontSize: 18,
                    fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('No new notifications right now.\nCheck back later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _C.textMuted.withOpacity(0.7), fontSize: 13, height: 1.6)),
            ],
          );
        },
      ),
    );
  }
}
 
class _RingsPainter extends CustomPainter {
  final double op;
  _RingsPainter(this.op);
 
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(c, 35.0 + i * 15,
          Paint()
            ..color = _C.primaryPurple.withOpacity((op - i * 0.1).clamp(0.0, 1.0))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
    }
  }
 
  @override
  bool shouldRepaint(_RingsPainter old) => old.op != op;
}
 
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});
 
  static const _items = [
    (Icons.home_rounded, Icons.home_outlined, 'Home'),
    (Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Tracker'),
    (Icons.school_rounded, Icons.school_outlined, 'Education'),
    (Icons.headset_mic_rounded, Icons.headset_mic_outlined, 'Support'),
  ];
 
  @override
  Widget build(BuildContext context) {
    final btm = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: _C.navBg,
        border: Border(top: BorderSide(
          color: _C.primaryPurple.withOpacity(0.35), width: 1)),
        boxShadow: [BoxShadow(
          color: _C.primaryPurple.withOpacity(0.15),
          blurRadius: 24, offset: const Offset(0, -8))],
      ),
      padding: EdgeInsets.only(top: 10, bottom: btm + 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) => _NavBtn(
          activeIcon: _items[i].$1,
          inactiveIcon: _items[i].$2,
          label: _items[i].$3,
          isActive: currentIndex == i,
          onTap: () => onTap(i),
        )),
      ),
    );
  }
}
 
class _NavBtn extends StatelessWidget {
  final IconData activeIcon, inactiveIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _NavBtn({
    required this.activeIcon, required this.inactiveIcon,
    required this.label, required this.isActive, required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: isActive ? 48 : 40, height: 32,
              decoration: BoxDecoration(
                color: isActive
                    ? _C.amber.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  isActive ? activeIcon : inactiveIcon,
                  color: isActive ? _C.navActive : _C.navInactive,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                color: isActive ? _C.navActive : _C.navInactive,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
              child: Text(label),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isActive ? 4 : 0, height: isActive ? 4 : 0,
              decoration: BoxDecoration(
                color: _C.amber, shape: BoxShape.circle,
                boxShadow: isActive
                    ? [BoxShadow(color: _C.amber.withOpacity(0.6), blurRadius: 6)]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}