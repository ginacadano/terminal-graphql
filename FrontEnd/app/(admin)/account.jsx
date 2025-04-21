import React from "react";
import { useQuery } from "@apollo/client";
import { View, Text, ActivityIndicator } from "react-native";
import { GET_USERS } from "../queries/userQueries";

export default function Account() {
  const { loading, error, data } = useQuery(GET_USERS);

  if (loading) {
    return (
      <View style={{ flex: 1, justifyContent: "center", alignItems: "center" }}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  if (error) {
    return (
      <View style={{ flex: 1, justifyContent: "center", alignItems: "center" }}>
        <Text>Error: {error.message}</Text>
      </View>
    );
  }

  return (
    <View>
      {data.users.map((user) => (
        <View key={user.username}>
          <Text>{user.username}</Text>
        </View>
      ))}
    </View>
  );
}
