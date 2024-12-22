import dotenv from "dotenv";
import { Request, Response } from 'express';
import { DeviceTokenService } from "../services/DeviceTokenService";

dotenv.config();

export class DeviceTokenController {

  public static async saveDeviceToken(req: Request, res: Response) {
    try {
      const {userId,deviceToken} = req.body;
      
      await DeviceTokenService.saveDeviceToken(userId,deviceToken);
    } catch(error){
      res.status(500).send("Erro ao salvar token do dispositivo!");
    }
  }
}
