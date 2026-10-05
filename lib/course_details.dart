import 'package:flutter/material.dart';

import 'course.dart';

const _purple = Color(0xFF6B45F0);
const _title = Color(0xFF1C1C28);
const _grey = Color(0xFF8E8EA9);
const _chipBg = Color(0xFFF4F1FF);
const _star = Color(0xFFF5A623);

/// Full page for a single course: preview, stats, description, curriculum
/// and the price / cart / enrol actions.
class CourseDetails extends StatefulWidget {
  final Course course;

  const CourseDetails({super.key, required this.course});

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails> {
  bool _liked = false;

  Course get course => widget.course;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            _previewImage(),
            Padding(
              padding: const EdgeInsets.only(top: 268),
              child: _detailsSheet(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _purchaseBar(),
    );
  }

  // -------------------------------------------------------------------------
  // Preview with back / favourite / play controls
  // -------------------------------------------------------------------------

  Widget _previewImage() {
    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            course.image,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF2B2356),
              child: const Icon(Icons.code_rounded,
                  color: Colors.white70, size: 64),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x66000000)],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _roundButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  _roundButton(
                    icon: _liked ? Icons.favorite : Icons.favorite_border,
                    color: _liked ? const Color(0xFFFF4D6D) : _title,
                    onTap: () => setState(() => _liked = !_liked),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () => _showMessage('Playing preview…'),
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: _purple, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = _title,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Course content
  // -------------------------------------------------------------------------

  Widget _detailsSheet() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tagChip(course.tag),
          const SizedBox(height: 14),
          Text(
            course.title,
            style: const TextStyle(
              color: _title,
              fontSize: 27,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          _instructor(),
          const SizedBox(height: 18),
          _stats(),
          const SizedBox(height: 24),
          _sectionTitle('Description'),
          const SizedBox(height: 10),
          Text(
            course.description,
            style: const TextStyle(
              color: _grey,
              fontSize: 14,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Curriculum'),
          const SizedBox(height: 14),
          for (final lesson in course.curriculum) ...[
            _lessonRow(lesson),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _tagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _chipBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: _purple,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _title,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _instructor() {
    return Row(
      children: [
        ClipOval(
          child: Image.network(
            'https://i.pravatar.cc/120?u=${course.author}',
            width: 46,
            height: 46,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 46,
              height: 46,
              color: _chipBg,
              child: const Icon(Icons.person, color: _purple),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.author,
              style: const TextStyle(
                color: _title,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              course.authorRole,
              style: const TextStyle(color: _purple, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stats() {
    return Row(
      children: [
        _statCard(
          value: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, size: 17, color: _star),
              const SizedBox(width: 4),
              Text(course.rating, style: const TextStyle(fontSize: 16)),
            ],
          ),
          label: 'Rating',
        ),
        _statCard(
          value: Text(course.students, style: const TextStyle(fontSize: 16)),
          label: 'Students',
        ),
        _statCard(
          value: Text(course.duration, style: const TextStyle(fontSize: 16)),
          label: 'Duration',
        ),
      ],
    );
  }

  Widget _statCard({required Widget value, required String label}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _chipBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            DefaultTextStyle(
              style: const TextStyle(
                color: _title,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              child: value,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: _grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lessonRow(Lesson lesson) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _purple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.computer_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: const TextStyle(
                    color: _title,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  lesson.meta,
                  style: const TextStyle(color: _grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: _grey),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Price + actions
  // -------------------------------------------------------------------------

  Widget _purchaseBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Price',
                  style: TextStyle(color: _grey, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  course.price,
                  style: const TextStyle(
                    color: _purple,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () => _showMessage('${course.title} added to cart'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _purple,
                side: const BorderSide(color: _purple),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 14),
              ),
              child: const Text(
                'Add to Cart',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: () => _showMessage('Enrolling in ${course.title}'),
              style: FilledButton.styleFrom(
                backgroundColor: _purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 22, vertical: 14),
              ),
              child: const Text(
                'Enrol Now',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
