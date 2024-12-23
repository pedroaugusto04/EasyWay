import { pool } from '../database/DatabaseConfig';
import { User } from '../models/User';

export class LoginService {

  public static async login(email: string): Promise<User | null> {
    const client = await pool.connect();
    try {
      const sqlStatement = "SELECT * FROM users WHERE email = $1";
      const res = await client.query(sqlStatement, [email]);

      if (res.rows.length > 0) {
        return res.rows[0] as User;
      }
      return null;
    } catch (error) {
      console.error("Erro ao buscar usuário pelo email:", error);
      throw error;
    } finally {
      await client.release();
    }
  }
}
