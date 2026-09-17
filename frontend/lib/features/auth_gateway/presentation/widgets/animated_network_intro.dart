import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Full-screen, high-performance pulsating network mesh.
/// Renders an ambient constellation of hundreds of micro-nodes, interconnected JLG
/// cluster hubs, and a continuous contagion propagation wave.
/// Engineered for zero lag via batched draw calls and pre-computed geometry.
class AnimatedNetworkIntro extends StatefulWidget {
  const AnimatedNetworkIntro({super.key, this.isFullScreen = true, this.size = 280});

  final bool isFullScreen;
  final double size;

  @override
  State<AnimatedNetworkIntro> createState() => _AnimatedNetworkIntroState();
}

class _AnimatedNetworkIntroState extends State<AnimatedNetworkIntro>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final _FullScreenMeshPainter _painter;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    _painter = _FullScreenMeshPainter(animation: _controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFullScreen) {
      return SizedBox.expand(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _painter,
          ),
        ),
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _painter,
        ),
      ),
    );
  }
}

class _FullScreenMeshPainter extends CustomPainter {
  _FullScreenMeshPainter({required this.animation})
      : super(repaint: animation) {
    _buildGeometry();
  }

  final Animation<double> animation;

  // Primary hubs and network topology
  late final List<Offset> _hubs;
  late final List<List<int>> _edges;
  late final List<int> _clusters;

  // Ambient constellation of micro-nodes across the entire canvas
  static const int _ambientCount = 750;
  late final List<Offset> _ambientPoints;
  late final List<double> _ambientPhases;
  // Pre-allocated reusable buffer for drawPoints (zero allocation per frame)
  final List<Offset> _ambientOffsets = List<Offset>.filled(_ambientCount, Offset.zero);

  // Key contagion propagation path
  static const int _seedNode = 2;
  static const List<int> _contagionPath = [2, 6, 12, 18, 26, 34, 42];

  void _buildGeometry() {
    final random = math.Random(101);

    // 1. Ambient Constellation: 750 micro-nodes spanning full canvas (0.01 - 0.99)
    _ambientPoints = List.generate(_ambientCount, (_) {
      return Offset(
        0.01 + random.nextDouble() * 0.98,
        0.01 + random.nextDouble() * 0.98,
      );
    });
    _ambientPhases = List.generate(_ambientCount, (_) => random.nextDouble() * math.pi * 2);

    // 2. Primary Community Hubs: 48 nodes across 6 organic solidarity clusters
    _hubs = [];
    _clusters = [];
    _edges = [];

    final clusterCenters = [
      const Offset(0.12, 0.14), // Top-Left perimeter
      const Offset(0.88, 0.14), // Top-Right perimeter
      const Offset(0.12, 0.50), // Mid-Left perimeter
      const Offset(0.88, 0.50), // Mid-Right perimeter
      const Offset(0.14, 0.86), // Bottom-Left perimeter
      const Offset(0.86, 0.86), // Bottom-Right perimeter
    ];

    final countsPerCluster = [8, 8, 8, 8, 8, 8];
    int nodeIndex = 0;

    for (int c = 0; c < clusterCenters.length; c++) {
      final center = clusterCenters[c];
      final count = countsPerCluster[c];
      final clusterNodes = <int>[];

      for (int i = 0; i < count; i++) {
        final angle = (2 * math.pi / count) * i + (random.nextDouble() * 0.25);
        final r = 0.07 + random.nextDouble() * 0.06;
        final pos = Offset(
          (center.dx + r * math.cos(angle)).clamp(0.03, 0.97),
          (center.dy + r * math.sin(angle)).clamp(0.03, 0.97),
        );
        _hubs.add(pos);
        _clusters.add(c);
        clusterNodes.add(nodeIndex);
        nodeIndex++;
      }

      // Intra-cluster ring edges
      for (int i = 0; i < clusterNodes.length; i++) {
        _edges.add([clusterNodes[i], clusterNodes[(i + 1) % clusterNodes.length]]);
      }
      // Cross chord
      _edges.add([clusterNodes[0], clusterNodes[count ~/ 2]]);
      _edges.add([clusterNodes[1], clusterNodes[count ~/ 2 + 1]]);
    }

    // Inter-cluster bridge edges
    _edges.add([3, 9]);    // Cluster 0 to 1
    _edges.add([5, 17]);   // Cluster 0 to 2
    _edges.add([11, 25]);  // Cluster 1 to 3
    _edges.add([19, 27]);  // Cluster 2 to 3
    _edges.add([21, 33]);  // Cluster 2 to 4
    _edges.add([29, 41]);  // Cluster 3 to 5
    _edges.add([35, 43]);  // Cluster 4 to 5
  }

  // Cached Paint objects for zero allocation during 60 FPS rendering
  static final Paint _bgGradientPaint = Paint();
  static final Paint _ambientPaint = Paint()
    ..isAntiAlias = true
    ..strokeCap = StrokeCap.round;
  static final Paint _edgePaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  static final Paint _bridgeEdgePaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;
  static final Paint _particlePaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;
  static final Paint _nodeGlowPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;
  static final Paint _nodeCorePaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;
  static final Paint _nodeRingPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final t = animation.value;

    // 1. Soft Institutional Light Canvas Background
    _bgGradientPaint.shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFF9FBF9), // Soft alabaster
        Color(0xFFF1F6F2), // Light mint-ivory
        Color(0xFFEBF3ED), // Very soft sage
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _bgGradientPaint);

    // 2. High-Efficiency Batched Ambient Constellation (750 micro-nodes)
    // Rendered via canvas.drawPoints in a single GPU draw call using pre-allocated buffer
    final globalPulse = (math.sin(t * math.pi * 2) * 0.12 + 0.28);
    _ambientPaint.color = AppColors.ledger.withValues(alpha: globalPulse);
    _ambientPaint.strokeWidth = 2.0;

    for (int i = 0; i < _ambientCount; i++) {
      final p = _ambientPoints[i];
      final phase = _ambientPhases[i];
      final dx = p.dx * w + math.cos(t * math.pi * 2 + phase) * 2.5;
      final dy = p.dy * h + math.sin(t * math.pi * 2 + phase) * 2.5;
      _ambientOffsets[i] = Offset(dx, dy);
    }
    canvas.drawPoints(PointMode.points, _ambientOffsets, _ambientPaint);

    // 3. Network Edges (Filaments)
    _edgePaint.color = AppColors.ledger.withValues(alpha: 0.14);
    _bridgeEdgePaint.color = AppColors.statusRegional.withValues(alpha: 0.22);

    for (final edge in _edges) {
      final p1 = Offset(_hubs[edge[0]].dx * w, _hubs[edge[0]].dy * h);
      final p2 = Offset(_hubs[edge[1]].dx * w, _hubs[edge[1]].dy * h);
      final isBridge = _clusters[edge[0]] != _clusters[edge[1]];
      canvas.drawLine(p1, p2, isBridge ? _bridgeEdgePaint : _edgePaint);
    }

    // 4. Propagating Light Pulses Along Edges
    const activePackets = 24;
    for (int i = 0; i < activePackets; i++) {
      final edgeIdx = (i * 3 + 2) % _edges.length;
      final edge = _edges[edgeIdx];
      final p1 = Offset(_hubs[edge[0]].dx * w, _hubs[edge[0]].dy * h);
      final p2 = Offset(_hubs[edge[1]].dx * w, _hubs[edge[1]].dy * h);

      final packetT = (t * 1.2 + (i / activePackets)) % 1.0;
      final pos = Offset.lerp(p1, p2, packetT)!;

      final isContagionEdge = _contagionPath.contains(edge[0]) && _contagionPath.contains(edge[1]);
      final isStressPhase = t > 0.22 && t < 0.78;

      final packetColor = (isContagionEdge && isStressPhase)
          ? AppColors.statusContagion
          : AppColors.ledger;

      _particlePaint.color = packetColor.withValues(alpha: 0.75);
      canvas.drawCircle(pos, 2.4, _particlePaint);
    }

    // 5. Hub Nodes with Multi-Layer Radial Glow Halos
    for (int i = 0; i < _hubs.length; i++) {
      final center = Offset(_hubs[i].dx * w, _hubs[i].dy * h);
      Color nodeColor = AppColors.ledger;
      double radius = 4.6;
      double haloRadius = 0.0;
      Color haloColor = Colors.transparent;

      if (i == _seedNode) {
        // Shock node pulse
        if (t >= 0.18 && t < 0.82) {
          final pulse = math.sin((t - 0.18) / 0.64 * math.pi * 4).abs();
          nodeColor = AppColors.statusContagion;
          radius = 6.0 + pulse * 2.5;
          haloRadius = radius + 10.0 + pulse * 8.0;
          haloColor = AppColors.statusContagion.withValues(alpha: 0.25);
        }
      } else if (_contagionPath.contains(i)) {
        final pathIdx = _contagionPath.indexOf(i);
        final trigger = 0.22 + (pathIdx * 0.07);
        if (t >= trigger && t < 0.82) {
          final intensity = ((t - trigger) / 0.24).clamp(0.0, 1.0);
          nodeColor = Color.lerp(AppColors.ledger, AppColors.statusIsolated, intensity)!;
          if (pathIdx >= 3 && intensity > 0.5) {
            nodeColor = Color.lerp(AppColors.statusIsolated, AppColors.statusContagion, (intensity - 0.5) * 2.0)!;
          }
          radius = 5.2 + intensity * 1.8;
          haloRadius = radius + 7.0 * intensity;
          haloColor = nodeColor.withValues(alpha: 0.22);
        }
      } else {
        // Ambient rhythmic breathing
        final nodeBreathe = math.sin(t * math.pi * 2 + (i * 0.5)).abs();
        haloRadius = radius + 4.0 + nodeBreathe * 3.0;
        haloColor = AppColors.ledger.withValues(alpha: 0.08 + nodeBreathe * 0.06);
      }

      // Draw multi-layer glowing halo
      if (haloRadius > 0.0) {
        _nodeGlowPaint.color = haloColor;
        canvas.drawCircle(center, haloRadius, _nodeGlowPaint);

        _nodeRingPaint.color = nodeColor.withValues(alpha: 0.35);
        canvas.drawCircle(center, haloRadius * 0.75, _nodeRingPaint);
      }

      // Node core
      _nodeCorePaint.color = nodeColor;
      canvas.drawCircle(center, radius, _nodeCorePaint);

      // Node crisp rim
      _nodeRingPaint.color = Colors.white.withValues(alpha: 0.85);
      canvas.drawCircle(center, radius, _nodeRingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FullScreenMeshPainter oldDelegate) => false;
}