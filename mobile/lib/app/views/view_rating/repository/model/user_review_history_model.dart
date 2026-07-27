class UserReviewHistoryModel {
  final String venueId;
  final String venueName;
  final double rating;
  final String comment;
  final String date;
  final DateTime? createdAt;

  const UserReviewHistoryModel({
    required this.venueId,
    required this.venueName,
    required this.rating,
    required this.comment,
    required this.date,
    this.createdAt,
  });
}
