import dotenv from "dotenv";
import { Request, Response } from 'express';
import { UserService } from "../services/UserService";
import { getUserIdByToken } from "../utils/jwtAuth";

dotenv.config();

export class UserController {

    public static async getUsers(req: Request, res: Response) {
        const token = req.headers.authorization;
        
        if (!token) {
            res.status(401).send("Token de autenticação não fornecido.")
            return;
        }

        const users = await UserService.getUsers();
    
        if (!users) {
            res.status(500);
            return
        }

        const usersDTO = users.map(({ password, ...dtoUser }) => dtoUser);

        res.status(200).json(usersDTO);
    }

    public static async getUsersByQuery(req: Request, res: Response) {
        const token = req.headers.authorization;
        
        if (!token) {
            res.status(401).send("Token de autenticação não fornecido.")
            return;
        }
        
        const searchQuery = req.params.searchQuery;

        const users = await UserService.getUsersByQuery(searchQuery);
    
        if (!users) {
            res.status(500);
            return
        }

        const usersDTO = users.map(({ password, ...dtoUser }) => dtoUser);

        res.status(200).json(usersDTO);
    }

    public static async verifyUserIsDriver(req: Request, res: Response) {
        try {
            const token = req.headers.authorization;

            if (!token) {
                res.status(401).send("Token de autenticação não fornecido.")
                return;
            }

            const userId = getUserIdByToken(token);

            const isDriver: boolean = await UserService.verifyIsDriver(userId);
            
            res.status(200).json({ isDriver });
        } catch(error){
            console.error("Erro ao verificar se o usuario eh um motorista ativo:",error);
            res.status(500).send("Erro interno ao verificar se o usuario eh um motorista ativo!");
        }
    }

    public static async deleteUserFromRoute(req: Request, res: Response) {
        try {
            const token = req.headers.authorization;

            const {passengerId,routeId} = req.body;

            if (!token) {
                res.status(401).send("Token de autenticação não fornecido.")
                return;
            }
                
            await UserService.deleteUserFromRoute(passengerId,routeId);
            
            res.status(200).send("Sucesso ao deletar usuário da rota");
        } catch(error){
            console.error("Erro ao verificar se o usuario eh um motorista ativo:",error);
            res.status(500).send("Erro interno ao verificar se o usuario eh um motorista ativo!");
        }
    }

    public static async getUserDeviceToken(req: Request, res: Response) {
        try {
            const token = req.headers.authorization;

            const userId = req.params.userId;

            if (!token) {
                res.status(401).send("Token de autenticação não fornecido.")
                return;
            }
            
            if (typeof userId !== 'string') {
                res.status(400).send("Id do usuário inválido ou não fornecido.");
                return;
            }

            const deviceToken = await UserService.getUserDeviceToken(userId);
            
            res.status(200).json({
                deviceToken: deviceToken,
            });
        } catch(error){
            console.error("Erro ao recuperar device token",error);
            res.status(500).send("Erro interno ao recuperar device token do usuario");
        }
    }
}
