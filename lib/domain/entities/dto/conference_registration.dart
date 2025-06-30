class ConferenceRegistration {
  final int id;
  final int userId;
  final int conferenceId;
  final String status;
  final DateTime registrationDate;
  final DateTime conferenceDate;
  final String conferenceName;
  final String conferenceImageUrl;
  final String conferenceCategory;
  final int conferenceTotalStudents;
  final String conferenceDescription;
  final String creatorName;

  ConferenceRegistration({
    required this.id,
    required this.userId,
    required this.conferenceId,
    required this.status,
    required this.registrationDate,
    required this.conferenceDate,
    required this.conferenceName,
    required this.conferenceImageUrl,
    required this.conferenceCategory,
    required this.conferenceTotalStudents,
    required this.conferenceDescription,
    required this.creatorName,
  });

  static ConferenceRegistration fromJson(Map<String, dynamic> json) {
    return ConferenceRegistration(
      id: json['id'],
      userId: json['userId'],
      conferenceId: json['conferenceId'],
      status: json['status'],
      registrationDate: DateTime.parse(json['registrationDate']),
      conferenceDate: DateTime.parse(json['conferenceDate']),
      conferenceName: json['conferenceName'],
      conferenceImageUrl: json['conferenceImageUrl'],
      conferenceCategory: json['conferenceCategory'],
      conferenceTotalStudents: json['conferenceTotalStudents'],
      conferenceDescription: json['conferenceDescription'],
      creatorName: json['creatorName'],
    );
  }
}
