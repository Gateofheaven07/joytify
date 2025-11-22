import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'feedback_item.g.dart';

@JsonSerializable()
@HiveType(typeId: 9)
class FeedbackItem extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String name;
  
  @HiveField(3)
  final String email;
  
  @HiveField(4)
  final FeedbackType type;
  
  @HiveField(5)
  final String subject;
  
  @HiveField(6)
  final String message;
  
  @HiveField(7)
  final DateTime createdAt;
  
  @HiveField(8)
  final FeedbackStatus status;

  const FeedbackItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.type,
    required this.subject,
    required this.message,
    required this.createdAt,
    this.status = FeedbackStatus.submitted,
  });

  factory FeedbackItem.fromJson(Map<String, dynamic> json) => _$FeedbackItemFromJson(json);
  Map<String, dynamic> toJson() => _$FeedbackItemToJson(this);

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        email,
        type,
        subject,
        message,
        createdAt,
        status,
      ];

  FeedbackItem copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    FeedbackType? type,
    String? subject,
    String? message,
    DateTime? createdAt,
    FeedbackStatus? status,
  }) {
    return FeedbackItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}

@HiveType(typeId: 10)
enum FeedbackType {
  @HiveField(0)
  bug,
  
  @HiveField(1)
  feature,
  
  @HiveField(2)
  general,
  
  @HiveField(3)
  complaint,
  
  @HiveField(4)
  compliment,
}

@HiveType(typeId: 11)
enum FeedbackStatus {
  @HiveField(0)
  submitted,
  
  @HiveField(1)
  inReview,
  
  @HiveField(2)
  resolved,
  
  @HiveField(3)
  closed,
}

// Extension methods for better display
extension FeedbackTypeExtension on FeedbackType {
  String get displayName {
    switch (this) {
      case FeedbackType.bug:
        return 'Laporkan Bug';
      case FeedbackType.feature:
        return 'Saran Fitur';
      case FeedbackType.general:
        return 'Pertanyaan Umum';
      case FeedbackType.complaint:
        return 'Keluhan';
      case FeedbackType.compliment:
        return 'Pujian';
    }
  }

  String get description {
    switch (this) {
      case FeedbackType.bug:
        return 'Laporkan masalah atau error yang Anda temui';
      case FeedbackType.feature:
        return 'Usulkan fitur baru yang ingin Anda lihat';
      case FeedbackType.general:
        return 'Pertanyaan umum tentang aplikasi';
      case FeedbackType.complaint:
        return 'Sampaikan keluhan atau ketidakpuasan';
      case FeedbackType.compliment:
        return 'Berikan pujian atau apresiasi';
    }
  }
}

extension FeedbackStatusExtension on FeedbackStatus {
  String get displayName {
    switch (this) {
      case FeedbackStatus.submitted:
        return 'Terkirim';
      case FeedbackStatus.inReview:
        return 'Sedang Ditinjau';
      case FeedbackStatus.resolved:
        return 'Terselesaikan';
      case FeedbackStatus.closed:
        return 'Ditutup';
    }
  }
}
