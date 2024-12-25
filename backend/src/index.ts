import express from 'express';
import cors from "cors";
import { notificationRouter } from './routers/Notification.router';
import dotenv from 'dotenv';
import { loginRouter } from './routers/Login.router';
import { deviceTokenRouter } from './routers/DeviceToken.router';
import { authenticateMiddleware } from './middlewares/authMiddleware';
import { userRouter } from './routers/User.router';
import { routesRouter } from './routers/Routes.router';

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;


app.use('/login',loginRouter);

app.use('/notification',authenticateMiddleware,notificationRouter);
app.use('/deviceToken',authenticateMiddleware,deviceTokenRouter);
app.use('/users',userRouter);
app.use('/routes',authenticateMiddleware,routesRouter);

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});
