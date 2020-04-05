library cough_detection;

import 'dart:async';
import 'dart:core';
import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

part 'cough.dart';
part 'cough_detection_streaming.dart';
part 'filehandler.dart';