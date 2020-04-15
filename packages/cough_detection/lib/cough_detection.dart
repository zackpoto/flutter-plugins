library cough_detection;

import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'dart:io' show Platform;
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:spectrogram/spectrogram_base.dart' as Spectrogram;
import 'package:linalg/matrix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';

part 'cough.dart';
part 'cough_detection_streaming.dart';
part 'melmatrix.dart';
part 'file_handler.dart';