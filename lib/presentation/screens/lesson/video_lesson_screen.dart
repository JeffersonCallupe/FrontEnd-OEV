import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:oev_mobile_app/config/constants/environment.dart';

class VideoLessonScreen extends StatefulWidget {
  final String lessonVideoKey;

  const VideoLessonScreen({super.key, required this.lessonVideoKey});

  @override
  State<VideoLessonScreen> createState() => _VideoLessonScreenState();
}

class _VideoLessonScreenState extends State<VideoLessonScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPresignedUrl();
  }

  Future<void> _fetchPresignedUrl() async {
    try {
      final response = await Dio(
        BaseOptions(baseUrl: Environment.apiUrl),
      ).get(
        '/s3/file/download-url',
        queryParameters: {
          'bucketName': Environment.bucketName,
          'key': widget.lessonVideoKey,
          'durationSeconds': 3600,
        },
      );

      final videoUrl = response.data['url'];
      _initializeVideoPlayer(videoUrl);
    } catch (e) {
      print('Error fetching presigned URL: $e');
      setState(() => _isLoading = false);
    }
  }

  void _initializeVideoPlayer(String videoUrl) {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: true,
          looping: true,
          allowFullScreen: true,
          allowMuting: true,
          showControls: true,
        );
        setState(() => _isLoading = false);
      });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading || _chewieController == null
            ? Container(
                color: const Color(0xff1E1E2C),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : Chewie(controller: _chewieController!),
      ),
    );
  }
}
