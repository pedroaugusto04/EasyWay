export class User {
    id: number;
    name: string;
    email: string;
    password: string;
    is_driver: boolean;  // 0 = not a driver, 1 = is a driver
    lat: DoubleRange;
    lng: DoubleRange;

    constructor(id: number, name: string, email: string, password: string, is_driver: boolean, lat: DoubleRange, lng: DoubleRange) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.password = password;
        this.is_driver = is_driver;
        this.lat = lat;
        this.lng = lng;
    }
}