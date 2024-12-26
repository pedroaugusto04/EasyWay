import WebSocket from 'ws';

export const connections: Map<string, WebSocket[]> = new Map();