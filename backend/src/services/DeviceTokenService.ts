import { pool } from "../database/DatabaseConfig";

export class DeviceTokenService {
  public static async saveDeviceToken(userId: string, deviceToken: string): Promise<void> {
    const client = await pool.connect();
    try {
      const sqlStatement = `
        UPDATE Users
        SET device_token = $2
        WHERE id = $1;
      `;

      await client.query(sqlStatement, [userId, deviceToken]);
    } catch (error) {
      console.error(`Erro ao salvar ou atualizar token do dispositivo para o usuário: ${userId}:`, error);
      throw error;
    } finally {
      await client.release();
    }
  }
}