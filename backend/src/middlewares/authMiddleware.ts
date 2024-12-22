import { Request, Response, NextFunction } from "express";
import { verifyToken } from "../utils/jwtAuth";

export const authenticateMiddleware = (req: Request, res: Response, next: NextFunction): void => {
  const token = req.headers.authorization;
  const routeUserId = req.params.id;

  if (!token) {
    res.status(401).json({ message: "Token não fornecido." });
    return; 
  }
  try {
    verifyToken(token, routeUserId);
    next(); 
  } catch (error) {
    res.status(401).json({ message: "Token inválido." });
    return; 
  }
};
