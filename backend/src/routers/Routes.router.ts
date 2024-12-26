import { Router } from "express";
import { RoutesController } from "../controllers/RouteController";

const routesRouter = Router();

routesRouter.post("/",RoutesController.createRoute);
routesRouter.get("/",RoutesController.getUserRoutes);
routesRouter.delete("/:routeId",RoutesController.deleteRoute);
routesRouter.post("/:routeId/passengers/:passengerId",RoutesController.addPassenger);
routesRouter.get("/users/driven",RoutesController.getRoutesDrivenByUser);

export {routesRouter}