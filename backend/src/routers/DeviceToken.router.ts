import { Router } from "express";
import { DeviceTokenController } from "../controllers/DeviceTokenController";
import { authenticateMiddleware } from "../middlewares/authMiddleware";

const deviceTokenRouter = Router();

deviceTokenRouter.post("/",DeviceTokenController.saveDeviceToken);

export {deviceTokenRouter}