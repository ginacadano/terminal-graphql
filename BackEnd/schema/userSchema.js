export const userSchema = `#graphql
    type User {
        user_id: Int
        username: String!
        usertype: String!
    }

    type addUserResponse {
        content: User
        type: String!
        message: String!
    }

    type updateUserResponse {
        type: String!
        message: String!
    }

    type deleteUserResponse {
        type: String!
        message: String!
    }

    input AddUserInput {
        username: String!
        password: String!
        usertype: String!
    }

    input UpdateUserInput {
        username: String
        password: String
        usertype: String
    }
`;
