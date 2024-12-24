import { Router } from "express";
import { RoutesController } from "../controllers/RouteController";

const routesRouter = Router();

routesRouter.post("/",RoutesController.createRoute);
routesRouter.get("/",RoutesController.getUserRoutes);
routesRouter.delete("/:routeId",RoutesController.deleteRoute);

export {routesRouter}