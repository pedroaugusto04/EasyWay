import { Router } from "express";
import { LoginController } from "../controllers/LoginController";

const loginRouter = Router();


loginRouter.post("/",LoginController.login);

export {loginRouter}