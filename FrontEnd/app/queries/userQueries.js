import { gql } from "@apollo/client";

const GET_USERS = gql`
  query UserQuery {
    users {
      username
      usertype
    }
  }
`;

export default GET_USERS;
