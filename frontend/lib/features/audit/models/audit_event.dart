class AuditEvent {
  final int id;
  final String action, result, resource, hash;
  final String? actorName;
  final DateTime occurredAt;
  const AuditEvent({
    required this.id,
    required this.action,
    required this.result,
    required this.resource,
    required this.hash,
    this.actorName,
    required this.occurredAt,
  });
  factory AuditEvent.fromJson(Map<String, dynamic> j) => AuditEvent(
    id: j['id'],
    action: j['action'],
    result: j['result'],
    resource: j['resource'],
    hash: j['hash'],
    actorName: j['actor_name'],
    occurredAt: DateTime.parse(j['occurred_at']),
  );
}
