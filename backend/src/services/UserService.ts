import { pool } from "../database/DatabaseConfig";
import { User } from "../models/User";

export class UserService {

  public static async getUsers(): Promise<User[]> {
    const client = await pool.connect();
    
    try {
      const sqlStatement = `
        SELECT * FROM users 
      `;
      
      const res = await client.query(sqlStatement);
  
      return res.rows;  
    } catch (error) {
      console.error(`Erro ao buscar usuarios:`, error);
      throw error; 
    } finally {
      await client.release(); 
    }
  }

  public static async getUsersByQuery(searchQuery: string): Promise<User[]> {
    const client = await pool.connect();
    
    try {
      const sqlStatement = `
        SELECT * FROM users 
        WHERE name ILIKE $1 OR email ILIKE $1
      `;
      
      const res = await client.query(sqlStatement, [`%${searchQuery}%`]);
  
      return res.rows;  
    } catch (error) {
      console.error(`Erro ao buscar usuarios:`, error);
      throw error; 
    } finally {
      await client.release(); 
    }
  }

  public static async verifyIsDriver(userId: string): Promise<boolean> {
    const client = await pool.connect();
    // verifica se o usuario eh um motorista ativo
    try {
      const sqlStatement = `
        SELECT EXISTS (
          SELECT 1
          FROM Drivers WHERE user_id = $1
        );
      `;

      const res = await client.query(sqlStatement, [userId]);
      return res.rows[0].exists;  
    } catch (error) {
      console.error(`Erro ao verificar se o usuário é um motorista ativo: ${userId}:`, error);
      throw error;
    } finally {
      await client.release();
    }
  }

  public static async deleteUserFromRoute(passengerId: string, routeId: string): Promise<void> {
    const client = await pool.connect();
    try {
        const sqlStatement = `
            DELETE FROM Users_Routes
            WHERE user_id = $1 AND route_id = $2;
        `;

        await client.query(sqlStatement, [passengerId, routeId]);

    } catch (error) {
        console.error(`Erro ao remover o usuário ${passengerId} da rota ${routeId}:`, error);
        throw error;
    } finally {
        await client.release();
    }
  }

  public static async getUserDeviceToken(userId: String): Promise<void> {
    const client = await pool.connect();
    try {
        const sqlStatement = `
            SELECT device_token 
            FROM Users 
            WHERE id = $1
        `;

        const result = await client.query(sqlStatement, [userId]);
        if (result.rows.length > 0) {
            const deviceToken = result.rows[0].device_token;
            return deviceToken || null;
        } else {
            console.log('Usuário não encontrado');
        }

    } catch (error) {
        console.error(`Erro ao buscar o deviceToken para o usuário ${userId}:`, error);
        throw error;
    } finally {
        await client.release();
    }
  }
}
