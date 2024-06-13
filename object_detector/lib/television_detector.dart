import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class ObjectDetectionPage extends StatefulWidget {
  const ObjectDetectionPage({Key? key}) : super(key: key);

  @override
  _ObjectDetectionPageState createState() => _ObjectDetectionPageState();
}

class _ObjectDetectionPageState extends State<ObjectDetectionPage> {
  final ImagePicker _picker = ImagePicker();
  late ObjectDetector _objectDetector;
  String _detectedObjects = '';

  @override
  void initState() {
    super.initState();
    _initializeObjectDetector();
  }

  void _initializeObjectDetector() {
    final options = ObjectDetectorOptions(
      classifyObjects: true,
      multipleObjects: true,
      mode: DetectionMode.single, // Use the correct value for mode
    );
    _objectDetector = ObjectDetector(options: options);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await _detectObjects(image.path);
    }
  }

  Future<void> _detectObjects(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final detectedObjects = await _objectDetector.processImage(inputImage);

    setState(() {
      _detectedObjects = detectedObjects.isEmpty
          ? 'No objects detected.'
          : detectedObjects
              .map((detectedObject) =>
                  detectedObject.labels.map((label) => label.text).join(', '))
              .join('\n');
    });
  }

  @override
  void dispose() {
    _objectDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Object Detection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image from Camera'),
            ),
            const SizedBox(height: 20),
            Text(_detectedObjects),
          ],
        ),
      ),
    );
  }
}
