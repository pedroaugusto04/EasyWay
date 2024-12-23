import { pool } from "../database/DatabaseConfig";
import { Route } from "../models/Route";
import { User } from "../models/User";

export class RoutesService {

  public static async getUserRoutes(userId: string): Promise<Route[]> {
    const client = await pool.connect();
    try {
      const sqlStatement = `
        SELECT r.id AS route_id, r.name AS route_name, r.origin, r.destination, r.driver_id, r.created_at,
               ur.user_id AS passenger_id, u.name AS passenger_name, u.email AS passenger_email,
               u.lat AS passenger_lat, u.lng as passenger_lng
        FROM Routes r
        JOIN Drivers d ON r.driver_id = d.id
        LEFT JOIN Users_Routes ur ON r.id = ur.route_id
        LEFT JOIN Users u ON ur.user_id = u.id
        WHERE d.user_id = $1;
      `;
  
      const result = await client.query(sqlStatement, [userId]);
  
      // Mapeamento dos resultados para a estrutura das rotas, incluindo os passageiros
      const routes = result.rows.reduce((acumulator: Route[], row: any) => {
        let route = acumulator.find(r => r.id === row.route_id);

        if (!route) {
          route = {
            id: row.route_id,
            name: row.route_name,
            origin: row.origin,
            destination: row.destination,
            driver_id: row.driver_id,
            passengers: [] 
          };
          acumulator.push(route);
        }

        if (row.passenger_id) {
          const passenger = new User(
            row.passenger_id,
            row.passenger_name,
            row.passenger_email,
            '', 
            false,
            row.passenger_lat,
            row.passenger_lng
          );
          route.passengers!.push(passenger);
        }
      
        return acumulator;
      }, []);

      return routes;
  
    } catch (error) {
      console.error("Erro ao buscar as rotas do motorista: ", error);
      throw error;
    } finally {
      client.release();
    }
}


  public static async createRoute(route: Route, driverId: string): Promise<void> {

    const client = await pool.connect();
    try {

      await client.query('BEGIN');

      const sqlStatement = `
        INSERT INTO Routes (name, origin, destination, driver_id)
        VALUES ($1, $2, $3, $4) RETURNING id;
      `;
      
      const result = await client.query(sqlStatement, [
        route.name, 
        route.origin, 
        route.destination, 
        driverId
      ]);

      const routeId = result.rows[0].id;

      if (route.passengers && route.passengers.length > 0) {
        const userRouteInsert = route.passengers.map(user => {
          return client.query(`
            INSERT INTO Users_Routes (user_id, route_id)
            VALUES ($1, $2);
          `, [user.id, routeId]);
        });

        await Promise.all(userRouteInsert);
      }

      await client.query('COMMIT');
      
    } catch (error) {
      console.error("Erro ao salvar a rota e associar os usuários:", error);

      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release(); 
    }
  }
}
