import dotenv from "dotenv";
import { Request, Response } from 'express';
import { LoginService } from "../services/LoginService";
import { comparePasswords } from "../utils/bcrypt";
import { User } from "../models/User";
import { generateToken } from "../utils/jwtAuth";

dotenv.config();

export class LoginController {

  public static async login(req: Request, res: Response) {
    try {
      const { email, password } = req.body;

      const user: User|null = await LoginService.login(email);

      if (user) {
        const isAValidPassword = await comparePasswords(password, user.password);
        if (isAValidPassword) {
          const { password, ...dtoUser } = user;
          const jwtToken = generateToken(dtoUser);

          res.status(200).json({ message: "Login bem-sucedido.", dtoUser, jwtToken });
          return;
        } 
      }
      
      res.status(401).send("Credenciais inválidas.");
    } catch (error) {
      console.error("Erro ao logar:", error);
      res.status(500).send("Erro inesperado eu realizar login.");
    }
  }
}
