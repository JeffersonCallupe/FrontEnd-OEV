import 'package:flutter/material.dart';
import 'package:oev_mobile_app/domain/entities/conference/conference_model.dart';
import 'package:oev_mobile_app/presentation/widgets/conference/conference_detail.dart';

class ConferenceCard extends StatelessWidget {
  final Conference conference;
  const ConferenceCard({required this.conference, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ConferenceDetailPage(conferenceId: conference.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF32343E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 13,
            ),
            Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF32343E),
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    // image: AssetImage('assets/images/fisinext.png'),
                    image: NetworkImage(conference.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(conference.name,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(conference.creatorName,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(conference.totalStudents.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
