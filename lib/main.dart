import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const FranklinFlowApp());
}

// ═══════════════════════════════════════════════════════════════════════════
// 뉴모피즘 컬러 시스템
// ═══════════════════════════════════════════════════════════════════════════
class NeumorphicColors {
  // 베이스 컬러 (따뜻한 크림/베이지 톤)
  static const Color background = Color(0xFFE8E6E1);
  static const Color surface = Color(0xFFE8E6E1);

  // 그림자 컬러
  static const Color shadowDark = Color(0xFFBEBDB8);
  static const Color shadowLight = Color(0xFFFFFFFF);

  // 텍스트 컬러
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textTertiary = Color(0xFFB2BEC3);

  // 액센트 컬러
  static const Color accentBlue = Color(0xFF5B8DEF);
  static const Color accentPink = Color(0xFFFF8A9B);
  static const Color accentPurple = Color(0xFFB19CD9);
  static const Color accentGreen = Color(0xFF7ED6A8);
  static const Color accentOrange = Color(0xFFFFB067);
}

// ═══════════════════════════════════════════════════════════════════════════
// 메인 앱
// ═══════════════════════════════════════════════════════════════════════════
class FranklinFlowApp extends StatelessWidget {
  const FranklinFlowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Franklin Flow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: NeumorphicColors.background,
        fontFamily: 'SF Pro Display',
      ),
      home: const FranklinFlowHome(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 홈 화면
// ═══════════════════════════════════════════════════════════════════════════
class FranklinFlowHome extends StatefulWidget {
  const FranklinFlowHome({Key? key}) : super(key: key);

  @override
  State<FranklinFlowHome> createState() => _FranklinFlowHomeState();
}

class _FranklinFlowHomeState extends State<FranklinFlowHome> {
  int _selectedNavIndex = 0;
  int _selectedTaskIndex = -1;
  int _completionRate = 67;

  final List<Task> tasks = [
    Task(
      id: 1,
      title: '클라이언트 미팅',
      status: 'in-progress',
      progress: 55,
      time: '2시간',
      category: '업무',
    ),
    Task(
      id: 2,
      title: '이메일 답변',
      status: 'pending',
      progress: 0,
      time: '1시간',
      category: '업무',
    ),
    Task(
      id: 3,
      title: '문서 작성',
      status: 'completed',
      progress: 100,
      time: '1.5시간',
      category: '업무',
    ),
  ];

  void _changeTaskStatus(int index) {
    setState(() {
      if (tasks[index].status == 'completed') {
        tasks[index].status = 'pending';
        tasks[index].progress = 0;
      } else if (tasks[index].status == 'pending') {
        tasks[index].status = 'in-progress';
        tasks[index].progress = 30;
      } else {
        tasks[index].status = 'completed';
        tasks[index].progress = 100;
      }
      _updateCompletionRate();
    });
  }

  void _updateCompletionRate() {
    int completed = tasks.where((t) => t.status == 'completed').length;
    setState(() {
      _completionRate = ((completed / tasks.length) * 100).round();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildDateTimeCard(),
                const SizedBox(height: 28),
                _buildProgressSection(),
                const SizedBox(height: 28),
                _buildTasksSection(),
                const SizedBox(height: 28),
                _buildWeeklyGoals(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: NeumorphicColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Franklin Flow',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: NeumorphicColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Row(
          children: [
            NeumorphicButton(
              width: 48,
              height: 48,
              onTap: () {},
              child: Icon(
                Icons.notifications_none_rounded,
                color: NeumorphicColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            NeumorphicContainer(
              width: 48,
              height: 48,
              isConvex: true,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        NeumorphicColors.accentBlue.withOpacity(0.8),
                        NeumorphicColors.accentPurple.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'W',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Date & Time Card (레퍼런스 이미지 스타일)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDateTimeCard() {
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return NeumorphicContainer(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // 날짜 표시
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: NeumorphicColors.accentBlue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${now.month.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: NeumorphicColors.accentBlue,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 4),
                      child: Text(
                        '/${now.day.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: NeumorphicColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  weekdays[now.weekday - 1],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: NeumorphicColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // 아날로그 시계
          Expanded(
            flex: 2,
            child: NeumorphicContainer(
              width: 100,
              height: 100,
              isConvex: false,
              borderRadius: 50,
              child: CustomPaint(
                painter: ClockPainter(),
                size: const Size(100, 100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Progress Section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Progress',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: NeumorphicColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        NeumorphicContainer(
          padding: const EdgeInsets.all(32),
          child: Row(
            children: [
              // 원형 프로그레스
              Expanded(
                child: Center(
                  child: NeumorphicProgress(
                    size: 140,
                    progress: _completionRate / 100,
                    strokeWidth: 10,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_completionRate%',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w300,
                            color: NeumorphicColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: NeumorphicColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // 통계
              Expanded(
                child: Column(
                  children: [
                    _buildStatItem(
                      icon: Icons.check_circle_outline,
                      label: 'Completed',
                      value:
                          '${tasks.where((t) => t.status == 'completed').length}',
                      color: NeumorphicColors.accentGreen,
                    ),
                    const SizedBox(height: 16),
                    _buildStatItem(
                      icon: Icons.play_circle_outline,
                      label: 'In Progress',
                      value:
                          '${tasks.where((t) => t.status == 'in-progress').length}',
                      color: NeumorphicColors.accentOrange,
                    ),
                    const SizedBox(height: 16),
                    _buildStatItem(
                      icon: Icons.access_time,
                      label: 'Pending',
                      value:
                          '${tasks.where((t) => t.status == 'pending').length}',
                      color: NeumorphicColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: NeumorphicColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: NeumorphicColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tasks Section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Priority Tasks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: NeumorphicColors.textPrimary,
              ),
            ),
            NeumorphicButton(
              width: 36,
              height: 36,
              borderRadius: 12,
              onTap: () {},
              child: Icon(
                Icons.add,
                color: NeumorphicColors.accentBlue,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(
          tasks.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTaskCard(index),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(int index) {
    final task = tasks[index];
    final isSelected = _selectedTaskIndex == index;

    Color statusColor;
    IconData statusIcon;

    switch (task.status) {
      case 'completed':
        statusColor = NeumorphicColors.accentGreen;
        statusIcon = Icons.check;
        break;
      case 'in-progress':
        statusColor = NeumorphicColors.accentOrange;
        statusIcon = Icons.play_arrow;
        break;
      default:
        statusColor = NeumorphicColors.textTertiary;
        statusIcon = Icons.circle_outlined;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedTaskIndex = isSelected ? -1 : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: NeumorphicContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  // 상태 버튼
                  GestureDetector(
                    onTap: () => _changeTaskStatus(index),
                    child: NeumorphicContainer(
                      width: 44,
                      height: 44,
                      borderRadius: 14,
                      isConvex: task.status == 'completed',
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: task.status != 'pending'
                              ? statusColor.withOpacity(0.15)
                              : Colors.transparent,
                        ),
                        child: Icon(statusIcon, color: statusColor, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 태스크 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: task.status == 'completed'
                                ? NeumorphicColors.textTertiary
                                : NeumorphicColors.textPrimary,
                            decoration: task.status == 'completed'
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: NeumorphicColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.time,
                              style: TextStyle(
                                fontSize: 12,
                                color: NeumorphicColors.textTertiary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: NeumorphicColors.accentBlue.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                task.category,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: NeumorphicColors.accentBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 화살표
                  Icon(
                    isSelected
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_right,
                    color: NeumorphicColors.textTertiary,
                    size: 24,
                  ),
                ],
              ),
              // 확장 영역
              if (isSelected && task.status == 'in-progress') ...[
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 12,
                            color: NeumorphicColors.textTertiary,
                          ),
                        ),
                        Text(
                          '${task.progress}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: NeumorphicColors.accentOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    NeumorphicProgressBar(
                      progress: task.progress / 100,
                      color: NeumorphicColors.accentOrange,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Weekly Goals
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildWeeklyGoals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Week',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: NeumorphicColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildGoalCard(
                icon: '🏃',
                title: 'Workout',
                current: 2,
                total: 3,
                color: NeumorphicColors.accentPink,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGoalCard(
                icon: '📚',
                title: 'Reading',
                current: 5,
                total: 10,
                color: NeumorphicColors.accentPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGoalCard(
                icon: '💧',
                title: 'Water',
                current: 6,
                total: 8,
                color: NeumorphicColors.accentBlue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGoalCard(
                icon: '🧘',
                title: 'Meditation',
                current: 3,
                total: 7,
                color: NeumorphicColors.accentGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoalCard({
    required String icon,
    required String title,
    required int current,
    required int total,
    required Color color,
  }) {
    final progress = current / total;

    return NeumorphicContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 22)),
                ),
              ),
              Text(
                '$current/$total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: NeumorphicColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          NeumorphicProgressBar(progress: progress, color: color, height: 6),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Bottom Navigation
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(color: NeumorphicColors.background),
      child: NeumorphicContainer(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        borderRadius: 24,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, '홈', 0),
            _buildNavItem(Icons.bar_chart_rounded, '분석', 1),
            _buildNavItem(Icons.calendar_today_rounded, '일정', 2),
            _buildNavItem(Icons.settings_rounded, '설정', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _selectedNavIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedNavIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? NeumorphicColors.accentBlue.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive
                  ? NeumorphicColors.accentBlue
                  : NeumorphicColors.textTertiary,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: NeumorphicColors.accentBlue,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 뉴모피즘 컴포넌트들
// ═══════════════════════════════════════════════════════════════════════════

// 기본 뉴모피즘 컨테이너
class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final double? width;
  final double? height;
  final bool isConvex;

  const NeumorphicContainer({
    Key? key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.borderRadius = 24,
    this.width,
    this.height,
    this.isConvex = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: NeumorphicColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: isConvex
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  NeumorphicColors.shadowLight.withOpacity(0.8),
                  NeumorphicColors.surface,
                  NeumorphicColors.shadowDark.withOpacity(0.3),
                ],
                stops: const [0.0, 0.5, 1.0],
              )
            : null,
        boxShadow: [
          // 오른쪽 아래 어두운 그림자
          BoxShadow(
            color: NeumorphicColors.shadowDark.withOpacity(0.5),
            offset: const Offset(6, 6),
            blurRadius: 15,
            spreadRadius: 1,
          ),
          // 왼쪽 위 밝은 그림자
          BoxShadow(
            color: NeumorphicColors.shadowLight.withOpacity(0.9),
            offset: const Offset(-6, -6),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}

// 뉴모피즘 버튼 (눌림 효과)
class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final VoidCallback onTap;

  const NeumorphicButton({
    Key? key,
    required this.child,
    required this.width,
    required this.height,
    this.borderRadius = 16,
    required this.onTap,
  }) : super(key: key);

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: NeumorphicColors.surface,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _isPressed
              ? [
                  // 눌린 상태 - 내부 그림자
                  BoxShadow(
                    color: NeumorphicColors.shadowDark.withOpacity(0.3),
                    offset: const Offset(2, 2),
                    blurRadius: 5,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: NeumorphicColors.shadowLight.withOpacity(0.7),
                    offset: const Offset(-2, -2),
                    blurRadius: 5,
                    spreadRadius: -2,
                  ),
                ]
              : [
                  // 기본 상태
                  BoxShadow(
                    color: NeumorphicColors.shadowDark.withOpacity(0.4),
                    offset: const Offset(4, 4),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: NeumorphicColors.shadowLight.withOpacity(0.9),
                    offset: const Offset(-4, -4),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

// 뉴모피즘 원형 프로그레스
class NeumorphicProgress extends StatelessWidget {
  final double size;
  final double progress;
  final double strokeWidth;
  final Widget child;
  final Color? progressColor;

  const NeumorphicProgress({
    Key? key,
    required this.size,
    required this.progress,
    this.strokeWidth = 8,
    required this.child,
    this.progressColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: NeumorphicColors.surface,
        boxShadow: [
          BoxShadow(
            color: NeumorphicColors.shadowDark.withOpacity(0.4),
            offset: const Offset(6, 6),
            blurRadius: 15,
          ),
          BoxShadow(
            color: NeumorphicColors.shadowLight,
            offset: const Offset(-6, -6),
            blurRadius: 15,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(strokeWidth / 2 + 8),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: NeumorphicColors.surface,
            boxShadow: [
              // 내부 오목한 효과
              BoxShadow(
                color: NeumorphicColors.shadowDark.withOpacity(0.2),
                offset: const Offset(3, 3),
                blurRadius: 6,
                spreadRadius: -2,
              ),
              BoxShadow(
                color: NeumorphicColors.shadowLight.withOpacity(0.8),
                offset: const Offset(-3, -3),
                blurRadius: 6,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size - strokeWidth * 2 - 16,
                height: size - strokeWidth * 2 - 16,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: strokeWidth,
                  backgroundColor: NeumorphicColors.shadowDark.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressColor ?? NeumorphicColors.accentBlue,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// 뉴모피즘 프로그레스 바
class NeumorphicProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  final double height;

  const NeumorphicProgressBar({
    Key? key,
    required this.progress,
    required this.color,
    this.height = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: NeumorphicColors.surface,
        boxShadow: [
          // 내부 오목한 효과
          BoxShadow(
            color: NeumorphicColors.shadowDark.withOpacity(0.25),
            offset: const Offset(2, 2),
            blurRadius: 4,
            spreadRadius: -1,
          ),
          BoxShadow(
            color: NeumorphicColors.shadowLight.withOpacity(0.7),
            offset: const Offset(-1, -1),
            blurRadius: 3,
            spreadRadius: -1,
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 300),
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height / 2),
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 아날로그 시계 페인터
// ═══════════════════════════════════════════════════════════════════════════
class ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final now = DateTime.now();

    // 시침
    final hourAngle =
        (now.hour % 12 + now.minute / 60) * 30 * 3.14159 / 180 - 3.14159 / 2;
    final hourHand = Paint()
      ..color = NeumorphicColors.textPrimary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.5 * cos(hourAngle),
        center.dy + radius * 0.5 * sin(hourAngle),
      ),
      hourHand,
    );

    // 분침
    final minuteAngle = now.minute * 6 * 3.14159 / 180 - 3.14159 / 2;
    final minuteHand = Paint()
      ..color = NeumorphicColors.textSecondary
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.7 * cos(minuteAngle),
        center.dy + radius * 0.7 * sin(minuteAngle),
      ),
      minuteHand,
    );

    // 중앙 점
    final centerDot = Paint()
      ..color = NeumorphicColors.accentBlue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerDot);

    // 시간 표시 (12, 3, 6, 9)
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final markers = [
      {'text': '12', 'angle': -90},
      {'text': '3', 'angle': 0},
      {'text': '6', 'angle': 90},
      {'text': '9', 'angle': 180},
    ];

    for (var marker in markers) {
      final angle = marker['angle'] as int;
      final text = marker['text'] as String;
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: NeumorphicColors.textTertiary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      final radians = angle * 3.14159 / 180;
      final offset = Offset(
        center.dx + radius * 0.85 * cos(radians) - textPainter.width / 2,
        center.dy + radius * 0.85 * sin(radians) - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

double cos(double radians) => (radians == 0)
    ? 1
    : (radians == 3.14159 / 2 || radians == -3.14159 / 2)
    ? 0
    : (radians == 3.14159 || radians == -3.14159)
    ? -1
    : _cos(radians);

double sin(double radians) => (radians == 0)
    ? 0
    : (radians == 3.14159 / 2)
    ? 1
    : (radians == -3.14159 / 2)
    ? -1
    : (radians == 3.14159 || radians == -3.14159)
    ? 0
    : _sin(radians);

double _cos(double x) {
  double result = 1;
  double term = 1;
  for (int i = 1; i <= 10; i++) {
    term *= -x * x / ((2 * i - 1) * (2 * i));
    result += term;
  }
  return result;
}

double _sin(double x) {
  double result = x;
  double term = x;
  for (int i = 1; i <= 10; i++) {
    term *= -x * x / ((2 * i) * (2 * i + 1));
    result += term;
  }
  return result;
}

// ═══════════════════════════════════════════════════════════════════════════
// 데이터 모델
// ═══════════════════════════════════════════════════════════════════════════
class Task {
  final int id;
  final String title;
  String status;
  int progress;
  final String time;
  final String category;

  Task({
    required this.id,
    required this.title,
    required this.status,
    required this.progress,
    required this.time,
    required this.category,
  });
}
