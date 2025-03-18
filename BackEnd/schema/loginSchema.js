export const loginSchema = `#graphql
type User {
    user_id: Int!
    username: String!
    usertype: String!
}

type loginResponse {
    type: String!
    message: String!
}

input InputLogIn {
    username: String!
    password: String!
}
`;
    