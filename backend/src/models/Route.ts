import { User } from "./User";

export class Route {
    id: string;
    name: string;
    origin: string;
    destination: string;
    driver_id: string;
    passengers: Array<User>;

    constructor(id: string, name: string, origin: string, destination: string, driver_id: string,passengers: Array<User> = []) {
        this.id = id;
        this.name = name;
        this.origin = origin;
        this.destination = destination;
        this.driver_id = driver_id;
        this.passengers = passengers;
    }
}