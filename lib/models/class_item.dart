class ClassItem {
  final String id;
  final String classListId;
  final String name;
  final String teacher;
  final String term;
  final int year;
  final DateTime? addedAt;
  final DateTime? lastActivityAt;

  const ClassItem({
    required this.id,
    this.classListId = '',
    required this.name,
    required this.teacher,
    required this.term,
    required this.year,
    this.addedAt,
    this.lastActivityAt,
  });

  String get semesterLabel => '$term $year';

  factory ClassItem.fromClassListJson(Map<String, dynamic> json) {
    final catalog = json['classCatalogId'];
    final catalogJson = catalog is Map<String, dynamic>
        ? catalog
        : <String, dynamic>{};

    final firstName = (catalogJson['instructorFirst'] as String? ?? '').trim();
    final lastName = (catalogJson['instructorLast'] as String? ?? '').trim();
    final teacher = [firstName, lastName].where((part) => part.isNotEmpty).join(' ');

    return ClassItem(
      id: catalogJson['_id'] as String? ?? '',
      classListId: json['_id'] as String? ?? '',
      name: catalogJson['courseName'] as String? ?? 'Untitled class',
      teacher: teacher.isEmpty ? 'Unknown instructor' : teacher,
      term: catalogJson['term'] as String? ?? 'Term',
      year: catalogJson['year'] is int
          ? catalogJson['year'] as int
          : int.tryParse('${catalogJson['year']}') ?? DateTime.now().year,
      addedAt: DateTime.tryParse(json['addedAt'] as String? ?? ''),
      lastActivityAt: DateTime.tryParse(json['lastActivityAt'] as String? ?? ''),
    );
  }
}
