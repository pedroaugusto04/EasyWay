import WebSocket from 'ws';

interface RouteConnections {
  drivers: WebSocket[];
  passengers: WebSocket[];
}

// Mapa que mantém as conexões por rota
export const connections: { [routeId: string]: RouteConnections } = {};