class FinancialResource {
  final String id, code, name, description;
  final bool allowed;
  const FinancialResource({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.allowed,
  });
  factory FinancialResource.fromJson(Map<String, dynamic> j) =>
      FinancialResource(
        id: j['id'],
        code: j['code'],
        name: j['name'],
        description: j['description'],
        allowed: j['allowed'] ?? false,
      );
}
