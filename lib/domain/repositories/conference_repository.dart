import 'package:oev_mobile_app/domain/entities/conference/conference_model.dart';
import 'package:oev_mobile_app/domain/entities/dto/request/conference_dto.dart';

abstract class ConferenceRepository {
  Future<List<Conference>> getConference();
  Future<Conference> getConferenceById(int conferenceId);
  Future<void> deleteConferenceById(int conferenceId);
  Future<Conference> addConference(
      int userId, ConferenceRequestDTO conferenceRequestDTO);
  Future<void> updateConference(
      int conferenceId, Map<String, dynamic> conferenceData);
}
