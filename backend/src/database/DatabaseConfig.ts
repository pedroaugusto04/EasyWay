import fs from 'fs'; 
import { Pool } from 'pg';

const environment: 'dev' | 'prod' = (process.env.NODE_ENV || 'dev') as 'dev' | 'prod'; 


const config = {
  dev: {
    user: process.env.PG_USER,
    host: process.env.PG_HOST,
    database: process.env.PG_DATABASE,
    password: process.env.PG_PASSWORD,
    port: parseInt(process.env.PG_PORT || '5432'),
  },
  prod: {
    user: process.env.PG_USER,
    host: process.env.PG_HOST,
    database: process.env.PG_DATABASE,
    password: process.env.PG_PASSWORD,
    port: parseInt(process.env.PG_PORT || '5432'),
    ssl: {
      ca: fs.readFileSync("ca.pem")
    }
  },
};

export const pool = new Pool(config[environment]);
