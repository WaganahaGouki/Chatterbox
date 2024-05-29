import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorder {
  FlutterSoundRecorder? _recorder;
  String? _filePath;
  bool _isRecording = false;

  AudioRecorder() {
    _recorder = FlutterSoundRecorder();
  }

  Future<void> init() async {
    await _recorder!.openRecorder();
    _filePath = '${(await getTemporaryDirectory()).path}/audio.aac';
  }

  Future<void> startRecording() async {
    if (!_recorder!.isRecording) {
      await _recorder!.startRecorder(toFile: _filePath);
      _isRecording = true;
    }
  }

  Future<void> stopRecording() async {
    if (_recorder!.isRecording) {
      await _recorder!.stopRecorder();
      _isRecording = false;
    }
  }

  Future<void> dispose() async {
    await _recorder!.closeRecorder();
  }

  String? get filePath => _filePath;
  bool get isRecording => _isRecording;
}