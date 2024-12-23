import dotenv from "dotenv";
import { Request, Response } from 'express';
import { DeviceTokenService } from "../services/DeviceTokenService";
import { getUserIdByToken } from "../utils/jwtAuth";

dotenv.config();

export class DeviceTokenController {

  public static async saveDeviceToken(req: Request, res: Response) {
    try {
      const token = req.headers.authorization;
      const {deviceToken} = req.body;

      if (!token) {
        res.status(401).send("Token de autenticação não fornecido.")
        return;
      }

      const userId = getUserIdByToken(token);

      await DeviceTokenService.saveDeviceToken(userId,deviceToken);
      
      res.status(200).send("Token do dispositivo salvo com sucesso!");
    } catch(error){
      console.error("Erro ao salvar token do dispositivo:",error);
      res.status(500).send("Erro ao salvar token do dispositivo!");
    }
  }
}
