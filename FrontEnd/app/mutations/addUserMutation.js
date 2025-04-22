import { gql } from "@apollo/client";

export default gql`
  mutation AddUser($username: String!, $usertype: String!) {
    addUser(username: $username, usertype: $usertype) {
      user_id
      username
      usertype
    }
  }
`;
