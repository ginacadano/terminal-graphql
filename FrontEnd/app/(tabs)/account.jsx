import React, { useState } from "react";
import { ApolloProvider, useQuery } from "@apollo/client";
import AntDesign from "@expo/vector-icons/AntDesign";
import client1 from "../helpers/apolloClient";
import { ActivityIndicator } from "react-native-web";
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
        <Text>Error: {error.message}</Text>;
      </View>
    );
  }

  return (
    <ApolloProvider client={client1}>
      <View>
        {data.users.map((user) => (
          <View key={user.username}>{user.username}</View>
        ))}
      </View>
    </ApolloProvider>
  );
}
