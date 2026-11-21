import crypto from 'node:crypto';
export async function audit(client, { actorId=null, action, resource, result, details={} }) {
  const last = await client.query('SELECT hash FROM audit_log ORDER BY id DESC LIMIT 1 FOR UPDATE');
  const previous = last.rows[0]?.hash || null;
  const payload = JSON.stringify({ actorId, action, resource, result, details, previous });
  const hash = crypto.createHash('sha256').update(payload).digest('hex');
  await client.query('INSERT INTO audit_log(actor_id,action,resource,result,details,previous_hash,hash) VALUES($1,$2,$3,$4,$5,$6,$7)',[actorId,action,resource,result,details,previous,hash]);
}
