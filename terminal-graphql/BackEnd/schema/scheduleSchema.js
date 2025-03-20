export const scheduleSchema = `#graphql
    scalar Date
    scalar DateTime
    scalar CustomDateTime
    scalar Time

    type Schedule {
        schedule_id: ID!
        date: Date
        departure_time: Time!
        arrival_time: Time!
        destination: String
        plate_no: String
    }

    type addScheduleResponse {
        content: Schedule
        type: String
        message: String
    }

    type editScheduleResponse {
        type: String
        message: String
    }

    type deleteScheduleResponse {
        type: String
        message: String
    }

    input AddScheduleInput {
        date: Date
        departure_time: Time!
        arrival_time: Time!
        destination: String
        plate_no: String
    }

    input EditScheduleInput {
        date: Date
        departure_time: Time!
        arrival_time: Time!
        destination: String
        plate_no: String
    }
`;
