import 'package:flutter/foundation.dart';

/// 相機功能提供者
class CameraProvider extends ChangeNotifier {
  String? _capturedImagePath;
  bool _isProcessing = false;

  String? get capturedImagePath => _capturedImagePath;
  bool get isProcessing => _isProcessing;

  /// 設置拍攝的圖片路徑
  void setCapturedImage(String? path) {
    _capturedImagePath = path;
    notifyListeners();
  }

  /// 設置處理狀態
  void setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  /// 清除圖片
  void clearImage() {
    _capturedImagePath = null;
    _isProcessing = false;
    notifyListeners();
  }
}
