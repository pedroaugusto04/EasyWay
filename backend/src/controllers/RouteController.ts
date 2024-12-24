import dotenv from "dotenv";
import { Request, Response } from 'express';
import { getUserIdByToken } from "../utils/jwtAuth";
import { RoutesService } from "../services/RoutesService";
import { DriverService } from "../services/DriverService";
import { Route } from "../models/Route";

dotenv.config();

export class RoutesController {

  public static async getUserRoutes(req: Request, res: Response) {
    const token = req.headers.authorization;
    
    if (!token) {
        res.status(401).send("Token de autenticação não fornecido.")
        return;
    }

    const userId = getUserIdByToken(token);

    const routes: Route[] = await RoutesService.getUserRoutes(userId);

    const routesDTO = routes.map(route => ({
      id: route.id,
      name: route.name,
      origin: route.origin,
      destination: route.destination,
      passengers: route.passengers,
    }));
    
    if (!routesDTO) {
        res.status(500);
        return
    }
    
    res.status(200).json(routesDTO);
  }

  public static async createRoute(req: Request, res: Response) {

    try {
      const token = req.headers.authorization;
      const {route} = req.body;

      if (!token) {
        res.status(401).send("Token de autenticação não fornecido.")
        return;
      }

      const userId = getUserIdByToken(token);

      const driverId = await DriverService.getDriverIdByUserId(userId);

      if (!driverId){
        res.status(500).send("Erro ao buscar motorista relacionado ao usuário");
        return;
      }

      await RoutesService.createRoute(route,driverId);
      
      res.status(200).send("Rota criada com sucesso!");
    } catch(error){
      console.error("Erro ao criar rota:",error);
      res.status(500).send("Erro ao criar rota");
    }
  }


  public static async deleteRoute(req: Request, res: Response) {
    try {
        const token = req.headers.authorization;

        const routeId = req.params.routeId;

        if (!token) {
            res.status(401).send("Token de autenticação não fornecido.")
            return;
        }
            
        await RoutesService.deleteRoute(routeId);
        
        res.status(200).send("Sucesso ao deletar rota");
    } catch(error){
        console.error("Erro ao deletar rota:",error);
        res.status(500).send("Erro interno ao deletar rota!");
    }
  }
}
