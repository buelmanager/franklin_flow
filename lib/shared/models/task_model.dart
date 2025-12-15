// lib/shared/models/task_model.dart

/// ═══════════════════════════════════════════════════════════════════════════
/// Task 데이터 모델
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 사용법:
///   final task = Task(
///     id: 1,
///     title: '미팅',
///     status: 'pending',
///     progress: 0,
///     time: '2시간',
///     category: '업무',
///   );
/// ═══════════════════════════════════════════════════════════════════════════

enum TaskStatus { pending, inProgress, completed }

class Task {
  final int id;
  final String title;
  String status; // 'pending', 'in-progress', 'completed'
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

  /// 상태 문자열을 TaskStatus enum으로 변환
  TaskStatus get statusEnum {
    switch (status) {
      case 'completed':
        return TaskStatus.completed;
      case 'in-progress':
        return TaskStatus.inProgress;
      default:
        return TaskStatus.pending;
    }
  }

  /// 완료 여부
  bool get isCompleted => status == 'completed';

  /// 진행중 여부
  bool get isInProgress => status == 'in-progress';

  /// 대기중 여부
  bool get isPending => status == 'pending';

  /// 복사본 생성
  Task copyWith({
    int? id,
    String? title,
    String? status,
    int? progress,
    String? time,
    String? category,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      time: time ?? this.time,
      category: category ?? this.category,
    );
  }
}
