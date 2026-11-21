import 'dotenv/config';
import { pool } from '../src/db.js';
const users = [
  ['ana-assessora','Ana Souza','ana.assessora@fincontrol.demo','assessor'],
  ['gestor-ti','Carlos Lima','gestor.ti@fincontrol.demo','gestor'],
  ['compliance','Marina Costa','compliance@fincontrol.demo','compliance'],
  ['diretor','Rafael Alves','diretor@fincontrol.demo','direcao']
];
for (const u of users) await pool.query(`INSERT INTO users(oidc_sub,name,email,role) VALUES($1,$2,$3,$4)
 ON CONFLICT(email) DO UPDATE SET name=excluded.name,role=excluded.role`,u);
for (const r of [['extratos','Extratos de clientes','Saldos e movimentações inteiramente fictícios.'],['folha','Folha de pagamento','Prévia salarial demonstrativa, sem dados reais.'],['relatorios','Relatórios financeiros','Indicadores financeiros simulados para a demonstração.']])
 await pool.query(`INSERT INTO resources(code,name,description) VALUES($1,$2,$3) ON CONFLICT(code) DO UPDATE SET name=excluded.name,description=excluded.description`,r);
console.log('Dados de demonstração carregados.'); await pool.end();
