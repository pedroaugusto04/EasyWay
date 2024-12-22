import { Router } from "express";
import { LoginController } from "../controllers/LoginController";

const loginRouter = Router();


loginRouter.post("/login",LoginController.login);

export {loginRouter}