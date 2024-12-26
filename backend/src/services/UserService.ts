import { pool } from "../database/DatabaseConfig";
import { User } from "../models/User";

export class UserService {

  public static async createUser(user: User): Promise<void> {
    const client = await pool.connect(); 

    try {
      const sqlStatement = `
        INSERT INTO Users (name, email,password,lat,lng)
        VALUES ($1, $2, $3, $4, $5)
      `;

      const values = [user.name, user.email, user.password, user.lat,user.lng];

      await client.query(sqlStatement, values);

    } catch (error) {
      console.error('Erro ao criar usuário:', error);
      throw error;  
    } finally {
      await client.release();
    }
  }


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

  public static async getUser(userId: string): Promise<User | null> {
    const client = await pool.connect();
    
    try {
      const sqlStatement = `
        SELECT * FROM users 
        WHERE id = $1
      `;
      
      const res = await client.query(sqlStatement, [userId]);
  
      if (res.rows.length > 0){
        return res.rows[0];
      }
      return null;
    } catch (error) {
      console.error(`Erro ao buscar usuario:`, error);
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
        FROM Drivers
        JOIN Users ON Users.id = Drivers.user_id
        WHERE Drivers.user_id = $1
        AND Drivers.is_active = true
        AND Users.is_driver = true
      );`;

      const res = await client.query(sqlStatement, [userId]);
      return res.rows[0].exists;  
    } catch (error) {
      console.error(`Erro ao verificar se o usuário é um motorista ativo: ${userId}:`, error);
      throw error;
    } finally {
      await client.release();
    }
  }

  public static async verifyIsRouteDriver(userId: string, routeId: string): Promise<boolean> {
    const client = await pool.connect();
    try {
        const sqlStatement = `
        SELECT EXISTS (
            SELECT 1
            FROM Drivers
            JOIN Users ON Users.id = Drivers.user_id
            JOIN Routes ON Routes.driver_id = Drivers.id
            WHERE Drivers.user_id = $1
            AND Routes.id = $2
            AND Drivers.is_active = true
            AND Users.is_driver = true
        );`;

        const res = await client.query(sqlStatement, [userId, routeId]);
        return res.rows[0].exists;  
    } catch (error) {
        console.error(`Erro ao verificar se o usuário ${userId} é o motorista da rota ${routeId}:`, error);
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
