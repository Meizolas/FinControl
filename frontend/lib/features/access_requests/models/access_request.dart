class AccessRequestModel {
  final String id, resourceName, justification, status;
  final String? requesterName;
  final DateTime createdAt;
  const AccessRequestModel({
    required this.id,
    required this.resourceName,
    required this.justification,
    required this.status,
    this.requesterName,
    required this.createdAt,
  });
  factory AccessRequestModel.fromJson(Map<String, dynamic> j) =>
      AccessRequestModel(
        id: j['id'],
        resourceName: j['resource_name'],
        justification: j['justification'],
        status: j['status'],
        requesterName: j['requester_name'],
        createdAt: DateTime.parse(j['created_at']),
      );
}
