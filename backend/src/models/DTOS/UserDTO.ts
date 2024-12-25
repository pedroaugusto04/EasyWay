export class UserDTO {
    id: number;
    name: string;
    email: string;
    is_driver: boolean;  // 0 = not a driver, 1 = is a driver
    lat: DoubleRange;
    lng: DoubleRange;

    constructor(id: number, name: string, email: string, password: string, is_driver: boolean, device_token: string, lat: DoubleRange, lng: DoubleRange) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.is_driver = is_driver;
        this.lat = lat;
        this.lng = lng;
    }
}