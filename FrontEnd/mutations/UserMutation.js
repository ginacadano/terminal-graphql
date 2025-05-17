import { gql } from "@apollo/client";

export const ADD_USER = gql`
mutation AddUserAccount($useraccounts: AddUserInput!, $adminId: Int!) {
  addUserAccount(useraccounts: $useraccounts, admin_id: $adminId) {
    content {
      user_id
      username
      usertype
    }
    message
    type
  }
}
`;

export const UPDATE_USER = gql`
mutation UpdateUserAccount(
$useraccounts: UpdateUserInput!, 
$adminId: Int!, 
$userId: Int!
) {
  updateUserAccount(
  useraccounts: $useraccounts, 
  admin_id: $adminId, 
  user_id: $userId
  ) {
    type
    message
  }
}
`;

export const DELETE_USER = gql`
mutation DeleteUserAccount($adminId: Int!, $userId: Int!) {
  deleteUserAccount(admin_id: $adminId, user_id: $userId) {
    type
    message
  }
}
`;