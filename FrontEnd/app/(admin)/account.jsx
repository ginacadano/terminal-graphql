import React, { useState } from "react";
import {
  View,
  Text,
  ActivityIndicator,
  FlatList,
  StyleSheet,
  Modal,
  TouchableOpacity,
  TextInput,
  Alert,
} from "react-native";
import { useQuery, useMutation } from "@apollo/client";
import GET_USERS from "../queries/userQueries";
import ADD_USER from "../mutations/addUserMutation";
import UPDATE_USER from "../mutations/updateUserMutation";
import DELETE_USER from "../mutations/deleteUserMutation";
import { LinearGradient } from "expo-linear-gradient";

export default function Account() {
  const { loading, error, data, refetch } = useQuery(GET_USERS);
  const [addUser] = useMutation(ADD_USER);
  const [updateUser] = useMutation(UPDATE_USER);
  const [deleteUser] = useMutation(DELETE_USER);

  const [modalVisible, setModalVisible] = useState(false);
  const [editMode, setEditMode] = useState(false);
  const [selectedUser, setSelectedUser] = useState(null);
  const [username, setUsername] = useState("");
  const [usertype, setUsertype] = useState("");

  const openAddModal = () => {
    setEditMode(false);
    setUsername("");
    setUsertype("");
    setModalVisible(true);
  };

  const openEditModal = (user) => {
    setEditMode(true);
    setSelectedUser(user);
    setUsername(user.username);
    setUsertype(user.usertype);
    setModalVisible(true);
  };

  const handleSubmit = async () => {
    if (!username || !usertype) return;

    if (editMode && selectedUser) {
      await updateUser({
        variables: {
          user_id: selectedUser.user_id,
          username,
          usertype,
        },
      });
    } else {
      await addUser({ variables: { username, usertype } });
    }

    setModalVisible(false);
    refetch();
  };

  const handleDelete = async (user_id) => {
    Alert.alert(
      "Confirm Delete",
      "Are you sure you want to delete this user?",
      [
        { text: "Cancel", style: "cancel" },
        {
          text: "Delete",
          style: "destructive",
          onPress: async () => {
            await deleteUser({ variables: { user_id } });
            refetch();
          },
        },
      ]
    );
  };

  const renderItem = ({ item }) => (
    <View style={styles.itemContainer}>
      <View style={styles.itemRow}>
        <View style={styles.textContainer}>
          <Text style={styles.username}>{item.username}</Text>
          <Text style={styles.usertype}>Type: {item.usertype}</Text>
        </View>
        <View style={styles.buttonGroup}>
          <TouchableOpacity
            onPress={() => openEditModal(item)}
            style={styles.editBtn}
          >
            <Text style={styles.actionText}>Edit</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => handleDelete(item.user_id)}
            style={styles.deleteBtn}
          >
            <Text style={styles.actionText}>Delete</Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );

  if (loading) {
    return <ActivityIndicator size="large" style={styles.centered} />;
  }

  if (error) {
    return (
      <View style={styles.centered}>
        <Text style={styles.errorText}>Error: {error.message}</Text>
      </View>
    );
  }

  return (
    <LinearGradient
      colors={["#a1f4ff", "#c9b6e4", "#a0c7c7"]}
      style={styles.container}
    >
      <View style={styles.container}>
        <FlatList
          data={data.users}
          renderItem={renderItem}
          keyExtractor={(item) => item.user_id.toString()}
          ListHeaderComponent={
            <>
              <Text style={styles.header}>User Accounts</Text>
              <TouchableOpacity onPress={openAddModal} style={styles.addButton}>
                <Text style={styles.addButtonText}>+ Add User</Text>
              </TouchableOpacity>
            </>
          }
        />

        <Modal visible={modalVisible} animationType="slide" transparent>
          <View style={styles.modalBackground}>
            <View style={styles.modalContainer}>
              <Text style={styles.modalTitle}>
                {editMode ? "Edit User" : "Add User"}
              </Text>
              <TextInput
                style={styles.input}
                placeholder="Username"
                value={username}
                onChangeText={setUsername}
              />
              <TextInput
                style={styles.input}
                placeholder="User Type"
                value={usertype}
                onChangeText={setUsertype}
              />
              <View style={styles.modalButtons}>
                <TouchableOpacity
                  onPress={() => setModalVisible(false)}
                  style={styles.cancelBtn}
                >
                  <Text style={styles.actionText}>Cancel</Text>
                </TouchableOpacity>
                <TouchableOpacity onPress={handleSubmit} style={styles.saveBtn}>
                  <Text style={styles.actionText}>Save</Text>
                </TouchableOpacity>
              </View>
            </View>
          </View>
        </Modal>
      </View>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 16 },
  centered: { flex: 1, justifyContent: "center", alignItems: "center" },
  errorText: { color: "red", fontSize: 16 },
  header: {
    fontSize: 24,
    fontWeight: "bold",
    textAlign: "center",
    marginBottom: 10,
  },
  addButton: {
    backgroundColor: "rgb(100, 139, 105)",
    padding: 12,
    borderRadius: 8,
    marginBottom: 10,
    alignItems: "center",
  },
  addButtonText: { color: "#fff", fontSize: 16 },
  itemContainer: {
    backgroundColor: "#f9f9f9",
    padding: 12,
    marginBottom: 12,
    borderRadius: 10,
    shadowColor: "#000",
    shadowOpacity: 0.1,
    shadowRadius: 6,
    elevation: 3,
  },
  itemRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  textContainer: {
    flex: 1,
  },
  username: { fontSize: 18, fontWeight: "600" },
  usertype: { fontSize: 14, color: "#666" },
  buttonGroup: {
    flexDirection: "row",
    gap: 8,
  },
  editBtn: {
    backgroundColor: "#2196F3",
    paddingVertical: 6,
    paddingHorizontal: 10,
    borderRadius: 5,
    marginRight: 6,
  },
  deleteBtn: {
    backgroundColor: "#f44336",
    paddingVertical: 6,
    paddingHorizontal: 10,
    borderRadius: 5,
  },
  actionText: { color: "#fff", fontSize: 14 },
  modalBackground: {
    flex: 1,
    justifyContent: "center",
    backgroundColor: "rgba(0,0,0,0.4)",
    padding: 20,
  },
  modalContainer: {
    backgroundColor: "#fff",
    borderRadius: 10,
    padding: 20,
    elevation: 10,
  },
  modalTitle: { fontSize: 20, fontWeight: "bold", marginBottom: 10 },
  input: {
    borderWidth: 1,
    borderColor: "#ccc",
    padding: 10,
    borderRadius: 6,
    marginBottom: 10,
  },
  modalButtons: {
    flexDirection: "row",
    justifyContent: "flex-end",
  },
  cancelBtn: {
    backgroundColor: "#888",
    padding: 10,
    borderRadius: 6,
    marginRight: 10,
  },
  saveBtn: {
    backgroundColor: "#4CAF50",
    padding: 10,
    borderRadius: 6,
  },
});
