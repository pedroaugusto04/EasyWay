import { Router } from "express";
import { NotificationController } from "../controllers/NotificationController";
import { authenticateMiddleware } from "../middlewares/authMiddleware";

const notificationRouter = Router();

//notificationRouter.use(authenticateMiddleware);

notificationRouter.post("/notification/:deviceToken",NotificationController.sendNotification);

export {notificationRouter}