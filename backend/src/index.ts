import express from 'express';
import cors from 'cors';
import { notificationRouter } from './routers/Notification.router';
import { loginRouter } from './routers/Login.router';
import { deviceTokenRouter } from './routers/DeviceToken.router';
import { authenticateMiddleware } from './middlewares/authMiddleware';
import { userRouter } from './routers/User.router';
import { routesRouter } from './routers/Routes.router';
import http from 'http';
import WebSocket, { WebSocketServer } from 'ws';
import { connections } from './webSocket/connection';
import './config/envConfig';

const app = express();
const server = http.createServer(app);

// Configurações do Express
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;

app.use('/login', loginRouter);
app.use('/notification', authenticateMiddleware, notificationRouter);
app.use('/deviceToken', authenticateMiddleware, deviceTokenRouter);
app.use('/users',userRouter);
app.use('/routes', authenticateMiddleware, routesRouter);

app.get('/ping', (req, res) => {
  res.send('API online');
});

const wss = new WebSocketServer({ server });

wss.on('connection', (ws: WebSocket, req) => {
  const urlParts = req.url?.split('/');
  const userType = urlParts ? urlParts[1] : null; // verifica se eh motorista ou passageiro
  const routeId = urlParts ? urlParts[2] : null;  // verifica o id da rota

  if (userType === 'driver' && routeId) {

    // se nao existir, ativa a rota
    if (!connections.has(routeId)) {
      connections.set(routeId, []); 
    }

    ws.on('message', (message: string) => {
      // envia para todos os passageiros
      sendMessageToPassengers(message,routeId);
    });

    ws.on('close', () => {
      connections.delete(routeId); // desconecta a rota
      ws.close();
    });
    return;
  }

  if (userType === 'passenger' && routeId) {
    if (!connections.has(routeId)) {
      ws.send(JSON.stringify({ error: 'Esta rota nao esta em andamento' }));
      return;
    }
    
    // conecta o passageiro na rota 
    connections.get(routeId)?.push(ws);

    ws.on('close', () => {
      ws.close();
    });

    return;
  }
  // erro na requisicao, fecha a conexao
  console.log('Tipo de usuário não especificado ou URL inválida');
  ws.close();
});

function sendMessageToPassengers(message: string, routeId: string) {
  const passengersWs = connections.get(routeId);
  if (!passengersWs || passengersWs.length === 0) return;

  connections.get(routeId)?.forEach(passengerWs => {
    try {
      const messageString = message.toString(); 

      const data = JSON.parse(message);
      const latitude = data.latitude;
      const longitude = data.longitude;

      const response = {
        latitude: latitude,
        longitude: longitude
      };

      passengerWs.send(JSON.stringify(response));

    } catch (err) {
      console.error(`Erro ao enviar mensagem para o passageiro da rota ${routeId}:`, err);
    }
  })
}

server.listen(PORT, () => {
  console.log(`Servidor HTTP e WebSocket rodando na porta ${PORT}`);
});
