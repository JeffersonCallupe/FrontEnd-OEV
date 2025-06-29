import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/domain/entities/course/course_model.dart';
import 'package:oev_mobile_app/domain/entities/dto/course_enrolled.dart';
import 'package:oev_mobile_app/presentation/providers/auth_provider.dart';
import 'package:oev_mobile_app/presentation/providers/courses_providers/courses_provider.dart';
import 'package:oev_mobile_app/presentation/providers/enrollment_providers/enrollment_provider.dart';
import 'package:oev_mobile_app/presentation/screens/course/course_content.dart';
import 'package:oev_mobile_app/presentation/screens/course/certificado.dart';
import 'package:oev_mobile_app/presentation/screens/course/course_editable_content.dart';

final searchQueryProvider = StateProvider<String>((ref) => "");
final showCompletedProvider = StateProvider<bool>((ref) => false);
