import { pool } from "../database/DatabaseConfig";

export class DriverService {
  
  public static async getDriverIdByUserId(userId: string): Promise<string | null> {
    const client = await pool.connect();
    try {
      const sqlStatement = `
        SELECT id AS driver_id
        FROM Drivers
        WHERE user_id = $1;
      `;

      const result = await client.query(sqlStatement, [userId]);

      if (result.rows.length > 0) {
        return result.rows[0].driver_id; 
      } else {
        return null; 
      }
    } catch (error) {
      console.error(`Erro ao recuperar driver_id para o usuário: ${userId}:`, error);
      throw error;
    } finally {
      await client.release();
    }
  }
}
