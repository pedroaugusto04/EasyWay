import dotenv from 'dotenv';

//const environment = process.env.NODE_ENV || 'dev';
const environment = 'prod';

dotenv.config({ path: `.env.${environment}` });