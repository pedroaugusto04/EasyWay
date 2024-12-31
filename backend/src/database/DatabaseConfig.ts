import fs from 'fs'; 
import { Pool } from 'pg';

const environment: 'development' | 'production' = (process.env.NODE_ENV || 'development') as 'development' | 'production'; 

const config = {
  development: {
    user: process.env.PG_USER,
    host: process.env.PG_HOST,
    database: process.env.PG_DATABASE,
    password: process.env.PG_PASSWORD,
    port: parseInt(process.env.PG_PORT || '5432'),
  },
  production: {
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
