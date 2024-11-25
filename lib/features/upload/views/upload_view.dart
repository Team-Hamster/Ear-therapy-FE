import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ear_fe/core/constants/colors.dart';
import 'package:ear_fe/features/analysis/views/analysis_view.dart';
import 'package:ear_fe/features/loading/views/loading_view.dart';

class UploadView extends StatefulWidget {
  final String symptomName;

  const UploadView({Key? key, required this.symptomName}) : super(key: key);

  @override
  State<UploadView> createState() => _UploadViewState();
}

class _UploadViewState extends State<UploadView> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isAnalyzing = false;
  String _serverStatus = "Checking server status...";

  @override
  void initState() {
    super.initState();
    pingServer(); // 앱 시작 시 서버 상태 확인
  }

  Future<void> pingServer() async {
    try {
      final url = Uri.parse("http://192.168.0.165:5000/ping");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _serverStatus = "Server is running.";
          });
        } else {
          setState(() {
            _serverStatus = "Server responded, but not operational.";
          });
        }
      } else {
        setState(() {
          _serverStatus = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _serverStatus = "Failed to connect to server: $e";
      });
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _takePhoto();
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('카메라 권한 필요'),
            content: const Text('사진 촬영을 위해 카메라 권한이 필요합니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => openAppSettings(),
                child: const Text('설정으로 이동'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _image = File(photo.path);
      });
      Navigator.pop(context); // Modal Bottom Sheet 닫기
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _image = File(image.path);
        });
        Navigator.pop(context); // Modal Bottom Sheet 닫기
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이미지를 불러오는데 실패했습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사진을 선택하거나 촬영해주세요'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 로딩 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoadingView(),
      ),
    );

    try {
      final url = Uri.parse("http://192.168.0.165:5000/analyze");
      final request = http.MultipartRequest('POST', url);

      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
      request.fields['symptom'] = widget.symptomName;

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);

        if (data['status'] == 'success') {
          final resultImageUrl = data['result_image'];
          // 분석 결과 화면으로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AnalysisView(
                symptomName: widget.symptomName,
                analysisImageUrl: resultImageUrl,
              ),
            ),
          );
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception("서버 에러: ${response.statusCode}");
      }
    } catch (e) {
      Navigator.pop(context); // 로딩 화면 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('분석 중 오류가 발생했습니다: $e')),
      );
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.25,
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _requestCameraPermission,
                child: _buildOption("카메라 촬영", Icons.camera_alt),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _pickImage,
                child: _buildOption("파일 선택", Icons.photo_library),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String title, IconData icon) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.primaryColor,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'SUITE',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사진 업로드 제목
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              color: AppColors.white,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '사진 업로드',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 증상명 표시 (패딩 추가)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                widget.symptomName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            if (_image != null)
                              TextButton(
                                onPressed: _isAnalyzing ? null : _analyzeImage,
                                child: _isAnalyzing
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppColors.primaryColor,
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        '분석하기',
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(
                          color: Colors.grey,
                          height: 20,
                          thickness: 1,
                        ),
                        const SizedBox(height: 20),
                        // 이미지 업로드
                        Container(
                          width: double.infinity,
                          height: 280,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _image != null
                                ? Image.file(
                                    _image!,
                                    fit: BoxFit.cover,
                                  )
                                : const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '귀 사진을 촬영해주세요',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                            fontFamily: 'SUITE',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 8), // 두 텍스트 사이의 간격
                                        Text(
                                          '혈자리를 분석하여 표시해드립니다.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                            fontFamily: 'SUITE',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        const Spacer(),
                        Center(
                          child: Container(
                            width: 70,
                            height: 70,
                            margin: const EdgeInsets.only(bottom: 40),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryColor,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _isAnalyzing ? null : () => _showBottomSheet(context),
                                borderRadius: BorderRadius.circular(35),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
