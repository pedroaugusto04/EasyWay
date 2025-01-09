import dotenv from "dotenv";
import { Request, Response } from 'express';
import { NotificationService } from "../services/NotificationService";

dotenv.config();

export class NotificationController {

  public static async sendNotification(req: Request, res: Response) {
    try {
      const deviceToken = req.params.deviceToken;
    
      const {title,body} = req.body;

      await NotificationService.sendNotification(deviceToken, title,body);
    
      res.send("Notificação enviada com sucesso!");
    } catch(error){
      res.status(500).send("Erro ao enviar notificação!");
    }
  }
}
