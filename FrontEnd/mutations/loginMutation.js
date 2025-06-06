import { gql } from "@apollo/client";

export const LOGIN = gql`
  mutation UserLogin($username: String!, $password: String!) {
    userLogin(username: $username, password: $password) {
      type
      message
      token
      user {
        user_id
        username
        usertype
      }
    }
  }
`;


