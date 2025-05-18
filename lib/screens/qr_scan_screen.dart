

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> with WidgetsBindingObserver {
  MobileScannerController? cameraController;
  bool isScanning = true;
  bool hasPermission = false;
  bool isInitialized = false;
  bool isTorchOn = false;
  bool isFrontCamera = false;

  @override
  void initState() {
    super.initState();
    _simulateScan();

    WidgetsBinding.instance.addObserver(this);
    _checkPermission();


  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (hasPermission && !isInitialized) {
          _initializeCamera();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _disposeCamera();
        break;
      default:
        break;
    }
  }

  void _disposeCamera() {
    if (cameraController != null) {
      cameraController!.dispose();
      cameraController = null;
      isInitialized = false;
    }
  }

  Future<void> _checkPermission() async {
    try {
      final status = await Permission.camera.status;
      if (status.isGranted) {
        setState(() {
          hasPermission = true;
        });
        _initializeCamera();
      } else {
        final result = await Permission.camera.request();
        if (result.isGranted) {
          setState(() {
            hasPermission = true;
          });
          _initializeCamera();
        } else {
          _showPermissionDeniedDialog();
        }
      }
    } catch (e) {
      print('Error checking permission: $e');
      _showErrorDialog('Không thể kiểm tra quyền camera');
    }
  }

  void _initializeCamera() {
    if (!mounted) return;

    try {
      _disposeCamera();

      setState(() {
        cameraController = MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: isFrontCamera ? CameraFacing.front : CameraFacing.back,
          torchEnabled: isTorchOn,
        );
        isInitialized = true;
      });

    } catch (e) {
      print('Error initializing camera: $e');
      _showErrorDialog('Không thể khởi tạo camera');
    }
  }

  void _toggleTorch() async {
    if (cameraController != null) {
      try {
        setState(() {
          isTorchOn = !isTorchOn;
        });
        await cameraController!.toggleTorch();
      } catch (e) {
        print('Error toggling torch: $e');
      }
    }
  }

  void _switchCamera() async {
    if (cameraController != null) {
      try {
        setState(() {
          isFrontCamera = !isFrontCamera;
        });
        await cameraController!.switchCamera();
      } catch (e) {
        print('Error switching camera: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Lỗi'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  void _showPermissionDeniedDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Cần quyền truy cập Camera'),
            content: const Text(
              'Ứng dụng cần quyền truy cập camera để quét mã QR. '
                  'Vui lòng cấp quyền trong Cài đặt để sử dụng tính năng này.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => openAppSettings(),
                child: const Text('Mở Cài đặt'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Xóa màu nền mặc định của Scaffold
      backgroundColor: Colors.black,

      // Dùng ExtendBodyBehindAppBar để body extend lên phía sau AppBar
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        elevation: 0, // Xóa shadow
        backgroundColor: Colors.transparent, // AppBar trong suốt

        // Thêm một gradient mờ để text dễ đọc hơn
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
        ),

        title: const Text(
          'Quét mã',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        actions: [
          if (hasPermission && isInitialized) ...[
            IconButton(
              icon: Icon(
                isTorchOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
              onPressed: _toggleTorch,
            ),
            IconButton(
              icon: Icon(
                isFrontCamera ? Icons.cameraswitch : Icons.cameraswitch,
                color: Colors.white,
              ),
              onPressed: _switchCamera,
            ),
            const SizedBox(width: 8), // Padding bên phải
          ],
        ],

        // Thêm SystemUiOverlayStyle để thanh status bar phù hợp
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      body: !hasPermission || !isInitialized
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'Đang khởi tạo camera...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      )
          : Stack(
        children: [
          MobileScanner(
            controller: cameraController!,
            onDetect: (capture) {
              final barcode = capture.barcodes.firstOrNull;
              if (barcode == null || !isScanning) return;

              final String? rawValue = barcode.rawValue;
              if (rawValue == null) return;

              setState(() {
                isScanning = false;
              });

              try {
                final uri = Uri.parse(rawValue);

                final projectId = uri.queryParameters['projectId'];
                final block = uri.queryParameters['block'];
                final index = uri.queryParameters['index'];

                if (projectId != null && block != null && index != null) {
                  context.go(
                    '/measurement_qr/$projectId/$block/$index',
                  );
                } else {
                  _showErrorDialog('QR không hợp lệ: thiếu tham số');
                }
              } catch (e) {
                _showErrorDialog('QR không hợp lệ: ${e.toString()}');
              }
            },

          ),
          QRScannerOverlay(
            animationAsset: 'assets/animations/qr_scan_animation.json',
            overlayColor: Colors.black54,
            scanAreaSize: 0.7,
          ),
        ],
      ),
    );
  }

  void _simulateScan() {
    if (!mounted) return;

    const projectId = '68246953aaec28168be2f90d';
    const blockIndex = 0;
    const plotIndex = 1;

    // Tạm dừng quét để tránh lặp lại nếu có real camera
    setState(() {
      isScanning = false;
    });

    context.go(
      '/measurement_qr/$projectId/$blockIndex/$plotIndex',
    );
  }
}



// Class ScannerOverlay giữ nguyên như cũ


class QRScannerOverlay extends StatelessWidget {
  final String animationAsset;
  final Color overlayColor;
  final double scanAreaSize;

  const QRScannerOverlay({
    Key? key,
    required this.animationAsset,
    this.overlayColor = Colors.black54,
    this.scanAreaSize = 0.7,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double scanAreaWidth = screenSize.width * scanAreaSize;

    return Stack(
      children: [
        // Lớp overlay mờ
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            overlayColor,
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: scanAreaWidth,
                  height: scanAreaWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),


        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: const Offset(0, -42),
                child: Container(
                  width: scanAreaWidth,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Quét QR của ô thí nghiệm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: scanAreaWidth,
                height: scanAreaWidth,
                child: Stack(
                  children: [
                    // Khung quét 4 góc
                    CustomPaint(
                      painter: CornersPainter(),
                      child: Container(),
                    ),
                    // Animation Lottie
                    // Lottie.asset(
                    //   animationAsset,
                    //   fit: BoxFit.contain,
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class CornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const double cornerLength = 30; // Độ dài của các góc

    // Góc trên bên trái
    canvas.drawLine(
      const Offset(0, cornerLength),
      const Offset(0, 0),
      paint,
    );
    canvas.drawLine(
      const Offset(0, 0),
      Offset(cornerLength, 0),
      paint,
    );

    // Góc trên bên phải
    canvas.drawLine(
      Offset(size.width - cornerLength, 0),
      Offset(size.width, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );

    // Góc dưới bên trái
    canvas.drawLine(
      Offset(0, size.height - cornerLength),
      Offset(0, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );

    // Góc dưới bên phải
    canvas.drawLine(
      Offset(size.width - cornerLength, size.height),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height - cornerLength),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
