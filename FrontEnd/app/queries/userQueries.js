import { gql } from "@apollo/client";

const GET_USERS = gql`
  query Users {
    users {
      user_id
      username
      usertype
    }
  }
`;

export default GET_USERS;
