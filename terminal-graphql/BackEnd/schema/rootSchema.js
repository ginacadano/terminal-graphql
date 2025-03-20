export const rootSchema = `#graphql
type Query {
    users: [User] 
    user(id: Int!): User

    vehicles: [Vehicles]
    vehicle(plate_no: String): Vehicles

    schedules: [Schedule]
    schedule(id: Int!): Schedule

    penalties: [Penalty]
    penalty(id: Int!): Penalty
}

type Mutation {
    addUserAccount(useraccounts: AddUserInput!, admin_id: Int!): addUserResponse
    updateUserAccount(useraccounts: UpdateUserInput!, admin_id: Int!, user_id: Int!): updateUserResponse
    deleteUserAccount(admin_id: Int!, user_id: Int!): deleteUserResponse

    addVehicle(vehicles: AddVehicleInput!, admin_id: Int!): addVehicleResponse 
    updateVehicle(vehicles: EditVehicleInput!, admin_id: Int!, vehicle_id: Int!): editVehicleResponse
    deleteVehicle(plate_no: String, admin_id: Int!): deleteVehicleResponse

    addSchedule(schedules: AddScheduleInput!,or_id: Int!): addScheduleResponse
    updateSchedule(schedule_id: Int!, schedules: EditScheduleInput!, or_id: Int!): editScheduleResponse
    deleteSchedule(or_id: Int!, schedule_id: Int!): deleteScheduleResponse

    addPenalty(penalties: AddPenaltyInput!, admin_id: Int!): addPenaltyResponse
    updatePenalty(penalty_id: Int!, penalties: EditPenaltyInput!, admin_id: Int!): addPenaltyResponse 
    deletePenalty(id: Int!): Penalty
    markPenaltyAsPaid(penalty_id: Int!, paid_date: String, or_no: String!): ResponseMessage!

    userLogin(username: String!, password: String!): loginResponse
}
`;
