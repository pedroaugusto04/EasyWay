import dotenv from "dotenv";
import { Request, Response } from 'express';
import { LoginService } from "../services/LoginService";

dotenv.config();

export class LoginController {

  public static async login(req: Request, res: Response) {
    try {
      const { email, password } = req.body;

      const user = await LoginService.login(email);

      /*
      if (user) {
        const isAValidPassword = await comparePasswords(password, user.password);
        if (isAValidPassword) {
          const { password,isGoogleLogin,createdAt,updatedAt, ...dtoUser } = user;
          const token = generateToken(dtoUser);
          return res.status(200).json({ message: "Login bem-sucedido.", dtoUser, token });
        }
      }*/

      res.status(401).send("Credenciais inválidas.");
    } catch (error) {
      console.error("Erro na rota /login:", error);
      res.status(500).send("Erro inesperado eu realizar login.");
    }
  }
}
