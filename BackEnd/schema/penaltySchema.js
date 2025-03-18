export const penaltySchema = `#graphql
    scalar Date
    scalar DateTime
    scalar CustomDateTime
    scalar Time
    scalar JSON

    type Penalty {
        penalty_id: ID!
        violation: String!
        violation_date: Date!
        amount_penalty: Float
        paid: Float
        paid_date: String
        or_no: String
        plate_no: String!
    }

    type ResponseMessage {
        content: JSON
        type: String
        message: String
    }

    type addPenaltyResponse {
        content: Penalty
        type: String
        message: String
    }

    input AddPenaltyInput {
        violation: String!
        violation_date: Date!
        amount_penalty: Float
        plate_no: String!
    }

    input EditPenaltyInput {
        violation: String!
        violation_date: Date!
        amount_penalty: Float
        plate_no: String!
    }

    # ✅ Add Mutation Section Here
    type Mutation {
        markPenaltyAsPaid(penalty_id: Int!, paid_date: String, or_no: String!): ResponseMessage!
    }
`;
