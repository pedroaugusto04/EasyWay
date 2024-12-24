import { Router } from "express";
import { UserController } from "../controllers/UserController";

const userRouter = Router();

userRouter.get("/",UserController.getUsers);
userRouter.get("/:searchQuery",UserController.getUsersByQuery);
userRouter.post("/isDriver/",UserController.verifyUserIsDriver);
userRouter.delete("/routes/",UserController.deleteUserFromRoute);
userRouter.get("/:userId/deviceToken",UserController.getUserDeviceToken);

export {userRouter}