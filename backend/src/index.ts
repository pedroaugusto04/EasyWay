import express from 'express';
import cors from "cors";
import { notificationRouter } from './routers/Notification.router';
import dotenv from 'dotenv';
import { loginRouter } from './routers/Login.router';
import { deviceTokenRouter } from './routers/DeviceToken.router';

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;


app.use(loginRouter);
app.use(notificationRouter);
app.use(deviceTokenRouter);

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});
