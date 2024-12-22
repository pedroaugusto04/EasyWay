import { Router } from "express";
import { DeviceTokenController } from "../controllers/DeviceTokenController";
import { authenticateMiddleware } from "../middlewares/authMiddleware";

const deviceTokenRouter = Router();

deviceTokenRouter.use(authenticateMiddleware);

deviceTokenRouter.post("/deviceToken",DeviceTokenController.saveDeviceToken);

export {deviceTokenRouter}