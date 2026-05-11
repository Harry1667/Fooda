import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// 相機拍照頁面
/// 對應 PHP 版本的相機功能
class CameraScreen extends StatefulWidget {
  final Function(Uint8List imageBytes) onImageCaptured;

  const CameraScreen({
    super.key,
    required this.onImageCaptured,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _error;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// 初始化相機
  Future<void> _initializeCamera() async {
    try {
      // 檢查相機權限
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        setState(() {
          _error = '${AppLocalizations.of(context)!.cameraError} (Permission Denied)';
          _isLoading = false;
        });
        return;
      }

      // 獲取可用相機
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _error = AppLocalizations.of(context)!.cameraError ?? 'Camera Error';
          _isLoading = false;
        });
        return;
      }

      // 初始化相機控制器
      await _setupCamera(_selectedCameraIndex);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '${AppLocalizations.of(context)!.cameraError ?? 'Camera Error'}: $e';
        _isLoading = false;
      });
    }
  }

  /// 設置相機
  Future<void> _setupCamera(int cameraIndex) async {
    if (_cameras == null || _cameras!.isEmpty) return;

    // 釋放之前的控制器
    await _controller?.dispose();

    // 創建新的控制器
    _controller = CameraController(
      _cameras![cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '${AppLocalizations.of(context)!.cameraError}: $e';
        _isLoading = false;
      });
    }
  }

  /// 切換前後鏡頭
  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    setState(() {
      _isLoading = true;
    });

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    await _setupCamera(_selectedCameraIndex);
  }

  /// 拍照
  Future<void> _takePicture() async {
    if (!_isInitialized || _controller == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final image = await _controller!.takePicture();
      final imageBytes = await image.readAsBytes();

      // 返回圖片數據
      widget.onImageCaptured(imageBytes);
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = '${AppLocalizations.of(context)!.cameraError}: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(AppLocalizations.of(context)!.takePhoto),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.cameraNotReady ?? 'Camera not ready',
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    return Stack(
      children: [
        // 相機預覽
        Positioned.fill(
          child: CameraPreview(_controller!),
        ),

        // 底部控制欄
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 切換鏡頭按鈕
                  if (_cameras != null && _cameras!.length > 1)
                    _buildControlButton(
                      icon: Icons.flip_camera_ios,
                      onPressed: _switchCamera,
                    )
                  else
                    const SizedBox(width: 60),

                  // 拍照按鈕
                  GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),

                  // 佔位空間
                  const SizedBox(width: 60),
                ],
              ),
            ),
          ),
        ),

        // 頂部提示
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              child: Text(
                AppLocalizations.of(context)!.cameraTip ?? 'Place food in center',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
        onPressed: onPressed,
      ),
    );
  }
}