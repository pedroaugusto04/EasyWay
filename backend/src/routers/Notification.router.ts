import { Router } from "express";
import { NotificationController } from "../controllers/NotificationController";

const notificationRouter = Router();

notificationRouter.post("/:deviceToken",NotificationController.sendNotification);

export {notificationRouter}