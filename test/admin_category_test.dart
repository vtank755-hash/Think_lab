import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:think_lab/admin_category.dart';
import 'package:think_lab/admin_dashboard.dart';
import 'package:think_lab/category_repository.dart';

import 'test_utils.dart';

void main() {
  late CategoryRepository originalRepository;
  late FakeCategoryRepository fakeRepository;

  setUp(() {
    originalRepository = categoryRepository;
    fakeRepository = FakeCategoryRepository();
    categoryRepository = fakeRepository;
  });

  tearDown(() async {
    categoryRepository = originalRepository;
    await fakeRepository.dispose();
  });

  testWidgets('Dashboard Categories quick action opens admin category page', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AdminDashboardPage()));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('admin-quick-actions')),
        matching: find.text('Users'),
      ),
      findsNothing,
    );
    expect(find.text('Category'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const ValueKey('quick-action-categories')),
    );
    await tester.tap(find.byKey(const ValueKey('quick-action-categories')));
    await tester.pumpAndSettle();

    expect(find.byType(AdminCategoryPage), findsOneWidget);
    expect(find.text('MANAGE CATALOG'), findsOneWidget);
    expect(find.text('Development'), findsOneWidget);
  });

  testWidgets('Admin can add a category from the categories page', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AdminCategoryPage()));

    await tester.tap(find.byKey(const ValueKey('admin-category-add-button')));
    await tester.pumpAndSettle();
    expect(find.text('Add Category'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('category-name-input')),
      'Photography',
    );
    final createButton = find.byKey(const ValueKey('create-category-button'));
    await tester.ensureVisible(createButton);
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(find.text('7 Active Categories'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('admin-category-search')),
      'Photography',
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('delete-category-Photography')),
      findsOneWidget,
    );
  });

  testWidgets('Admin can edit a category from the categories page', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AdminCategoryPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('edit-category-Development')));
    await tester.pumpAndSettle();
    expect(find.text('Edit Category'), findsOneWidget);
    expect(find.textContaining('CAT-0192'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('category-name-input')),
      'Development Systems',
    );
    final saveButton = find.byKey(const ValueKey('save-category-changes'));
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('admin-category-search')),
      'Development Systems',
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('edit-category-Development Systems')),
      findsOneWidget,
    );
  });

  testWidgets('Admin category deletion updates the streamed list', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AdminCategoryPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('delete-category-Development')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(find.text('Development'), findsNothing);
    expect(find.text('5 Active Categories'), findsOneWidget);
  });
}
