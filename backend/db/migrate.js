import 'dotenv/config';
import { readFile } from 'node:fs/promises';
import { pool } from '../src/db.js';
const sql = await readFile(new URL('./migrations/001_init.sql', import.meta.url), 'utf8');
await pool.query(sql); console.log('Migração concluída.'); await pool.end();
