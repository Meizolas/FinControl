import { createRemoteJWKSet, jwtVerify } from 'jose';
let jwks;
export async function authenticate(req,res,next){
  try {
    if (process.env.DEMO_MODE==='true' && process.env.NODE_ENV!=='production' && req.headers['x-demo-user']) {
      req.identity={ email:String(req.headers['x-demo-user']), mfa:true, demo:true }; return next();
    }
    if (process.env.NODE_ENV==='test' && process.env.ALLOW_TEST_AUTH==='true' && req.headers['x-test-user']) {
      req.identity={ email:req.headers['x-test-user'], mfa:req.headers['x-test-mfa']==='true' }; return next();
    }
    const token=req.headers.authorization?.replace(/^Bearer /,''); if(!token) throw new Error('missing');
    const issuer=process.env.OIDC_ISSUER; jwks ||= createRemoteJWKSet(new URL(`${issuer}/protocol/openid-connect/certs`));
    const {payload}=await jwtVerify(token,jwks,{issuer,audience:process.env.OIDC_AUDIENCE});
    const methods=payload.amr || []; const mfa=methods.includes('otp') || String(payload.acr||'').includes('2');
    req.identity={email:payload.email,sub:payload.sub,mfa}; next();
  } catch { res.status(401).json({error:'Autenticação inválida ou expirada.'}); }
}
export async function loadUser(req,res,next){
  const {pool}=await import('./db.js'); const q=await pool.query('SELECT * FROM users WHERE email=$1 AND active=true',[req.identity.email]);
  if(!q.rows[0]) return res.status(401).json({error:'Usuário inativo ou não cadastrado.'});
  if(!req.identity.mfa) return res.status(401).json({error:'Autenticação multifator obrigatória.'});
  req.user=q.rows[0]; next();
}
export const requireRole=(...roles)=>(req,res,next)=>roles.includes(req.user.role)?next():res.status(403).json({error:'Acesso não autorizado para este perfil.'});
