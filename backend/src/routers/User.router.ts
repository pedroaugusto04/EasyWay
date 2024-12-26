import { Router } from "express";
import { UserController } from "../controllers/UserController";
import { authenticateMiddleware } from "../middlewares/authMiddleware";

const userRouter = Router();

// sem autenticacao (cadastro usuario)
userRouter.post("/",UserController.createUser);


// rotas autenticadas
userRouter.get("/",authenticateMiddleware,UserController.getUsers);
userRouter.get("/:searchQuery",authenticateMiddleware,UserController.getUsersByQuery);
userRouter.post("/isDriver/",authenticateMiddleware,UserController.verifyUserIsDriver);
userRouter.delete("/routes/",authenticateMiddleware,UserController.deleteUserFromRoute);
userRouter.get("/:userId/deviceToken",authenticateMiddleware,UserController.getUserDeviceToken);
userRouter.get("/isDriver/routes/:routeId",authenticateMiddleware,UserController.verifyUserIsRouteDriver);
userRouter.post("/isDriver/routes/",authenticateMiddleware,UserController.verifyUserIsRoutesDriver);
userRouter.post("/userInfo",authenticateMiddleware,UserController.getUser);

export {userRouter}