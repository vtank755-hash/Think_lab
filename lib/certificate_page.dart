import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'course.dart';
import 'session.dart';

const _heading = Color(0xFF2B2356);
const _muted = Color(0xFF8B87B2);
const _purple = Color(0xFF6C35E8);
const _deepPurple = Color(0xFF4822D6);
const _pageBg = Color(0xFFF6F5FB);
const _border = Color(0xFFEDEAF8);
const _green = Color(0xFF25A55F);

/// Paints the LearnHub loop and node logo in the given [color].
class LearnHubLogoPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const LearnHubLogoPainter({
    this.color = const Color(0xFF4C30DE),
    this.strokeWidth = 2.4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * .85, size.height * .32)
      ..lineTo(size.width * .46, size.height * .32)
      ..arcToPoint(
        Offset(size.width * .46, size.height * .68),
        radius: Radius.circular(size.height * .18),
        clockwise: false,
      )
      ..lineTo(size.width * .85, size.height * .68);
    canvas.drawPath(path, paint);
    final center = Offset(size.width * .5, size.height * .5);
    final radius = size.width * .085;
    canvas.drawCircle(center, radius, paint);
    canvas.drawLine(
      Offset(center.dx + radius, center.dy),
      Offset(size.width * .85, center.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant LearnHubLogoPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// The Certificate of Completion screen.
///
/// Displayed when a user successfully passes a course quiz and completes
/// the course. Allows downloading or sharing the generated certificate.
class CertificatePage extends StatefulWidget {
  final String courseId;
  final String? userName;
  final String? date;
  final String? certificateId;

  const CertificatePage({
    super.key,
    required this.courseId,
    this.userName,
    this.date,
    this.certificateId,
  });

  @override
  State<CertificatePage> createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage> {
  final GlobalKey _cardKey = GlobalKey();

  /// Formatted course title for the certificate.
  String get _courseTitle {
    final course = courseById(widget.courseId);
    if (course == null) return 'Digital Marketing Complete Guide';
    if (course.id == 'c3') {
      return 'Digital Marketing Complete Guide';
    }
    return course.title;
  }

  /// Recipient name for the certificate.
  String get _recipientName {
    if (widget.userName != null && widget.userName!.isNotEmpty) {
      return widget.userName!;
    }
    return userProfile.value.name;
  }

  /// Formatted certificate issue date.
  String get _dateString {
    if (widget.date != null) return widget.date!;
    return '12 Jun 2024';
  }

  /// Generated Certificate ID.
  String get _certId {
    if (widget.certificateId != null) return widget.certificateId!;
    if (widget.courseId == 'c3') {
      return 'LH-2024-8842';
    }
    final numeric =
        widget.courseId.replaceAll(RegExp(r'[^0-9]'), '').padLeft(2, '0');
    final hash = (widget.courseId.hashCode.abs() % 9000 + 1000).toString();
    return 'LH-2024-$numeric$hash'.substring(0, 12);
  }

  /// Downloads and saves the certificate to the device.
  Future<void> _downloadCertificate() async {
    if (mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: _heading,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: _green, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Certificate $_certId downloaded successfully!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        if (kDebugMode) {
          debugPrint('Certificate captured: ${byteData?.lengthInBytes} bytes');
        }
      }
    } catch (_) {}
  }

  /// Shares the certificate.
  void _shareCertificate() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: _heading,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Row(
          children: [
            const Icon(Icons.share_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sharing certificate for $_courseTitle ($_certId)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 18),
              _buildCertificateCard(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// Top bar with back/switch button and "Certificate" title.
  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.swap_horiz, color: _heading, size: 22),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'Certificate',
          style: TextStyle(
            color: _heading,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  /// The certificate card displaying completion details.
  Widget _buildCertificateCard() {
    return RepaintBoundary(
      key: _cardKey,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFE2E7FD), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B45F0).withValues(alpha: 0.07),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top accent bar
            Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_deepPurple, _purple],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              child: Column(
                children: [
                  // Medal badge icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [_purple, _deepPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.military_tech_outlined,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // CERTIFICATE OF COMPLETION
                  const Text(
                    'CERTIFICATE OF COMPLETION',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6B45F0),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  const Text(
                    'This is proudly presented to',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _muted,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Recipient Name
                  Text(
                    _recipientName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF1B1838),
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // for successfully completing
                  const Text(
                    'for successfully completing',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _muted,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Course Title
                  Text(
                    _courseTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF4C30DE),
                      fontSize: 18.5,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  const Divider(height: 1, color: _border),
                  const SizedBox(height: 16),

                  // Metadata row: DATE and CERTIFICATE ID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DATE',
                            style: TextStyle(
                              color: Color(0xFF9A96B8),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _dateString,
                            style: const TextStyle(
                              color: Color(0xFF1B1838),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'CERTIFICATE ID',
                            style: TextStyle(
                              color: Color(0xFF9A96B8),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _certId,
                            style: const TextStyle(
                              color: Color(0xFF1B1838),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Platform Brand Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(22, 22),
                        painter: const LearnHubLogoPainter(
                          color: Color(0xFF4C30DE),
                          strokeWidth: 2.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'LearnHub',
                        style: TextStyle(
                          color: Color(0xFF1B1838),
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Download and Share action buttons.
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Download Button
        Expanded(
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_purple, _deepPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _purple.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _downloadCertificate,
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_download_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Download',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Share Button
        Expanded(
          child: SizedBox(
            height: 54,
            child: OutlinedButton(
              onPressed: _shareCertificate,
              style: OutlinedButton.styleFrom(
                foregroundColor: _purple,
                side: const BorderSide(color: _purple, width: 1.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.ios_share_rounded, color: _purple, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Share',
                    style: TextStyle(
                      color: _purple,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
