import { gql } from "@apollo/client";

const LOGIN = gql`
  mutation Mutation($username: String!, $password: String!) {
    userLogin(username: $username, password: $password) {
      type
      message
      token
      user {
        userId
        username
        usertype
      }
    }
  }
`;

export default LOGIN;
