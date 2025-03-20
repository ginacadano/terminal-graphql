export const vehicleSchema = `#graphql
    type Vehicles {
        capacity: Int
        categories: String!
        driver_name: String!
        contact_no: String
        vehicle_name: String
        plate_no: String
        vehicle_id: Int!
    }

    input AddVehicleInput {
        capacity: Int
        categories: String!
        driver_name: String!
        contact_no: String
        vehicle_name: String
        plate_no: String!
    }

    input EditVehicleInput {
        plate_no: String
        capacity: Int
        categories: String
        driver_name: String
        contact_no: String
        vehicle_name: String
    }

    type addVehicleResponse {
        content: Vehicles
        type: String
        message: String
    }

    type editVehicleResponse {
    content: JSON
    type: String
    message: String
}
    type deleteVehicleResponse {
        type: String
        message: String
    }

        
`;
