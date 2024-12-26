import { Router } from "express";
import { DeviceTokenController } from "../controllers/DeviceTokenController";

const deviceTokenRouter = Router();

deviceTokenRouter.post("/",DeviceTokenController.saveDeviceToken);

export {deviceTokenRouter}