import React, { useState, useEffect } from "react";
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  TouchableOpacity,
  ScrollView,
  ActivityIndicator
} from "react-native";
import { LinearGradient } from "expo-linear-gradient";
import { Ionicons } from "@expo/vector-icons";
import { Link, useRouter } from "expo-router";
import * as SecureStore from "expo-secure-store";
import { useQuery } from "@apollo/client";
import {GET_USERS} from "../../queries/userQueries";

// Define the component
export default function Account () {
  // Define all state at the top level
  const [userId, setUserId] = useState(null);
  const [userType, setUserType] = useState("");
  const [logoutError, setLogoutError] = useState("");
  const router = useRouter();
  
  // All hooks must be called at the top level
  const { loading, error, data } = useQuery(GET_USERS);
  
  // Get user info on component mount
  useEffect(() => {
    async function getUserInfo() {
      try {
        const storedUserType = await SecureStore.getItemAsync("user_type");
        const storedUserId = await SecureStore.getItemAsync("user_id");
        
        if (storedUserType) setUserType(storedUserType);
        if (storedUserId) setUserId(storedUserId);
      } catch (err) {
        console.error("Error retrieving user info:", err);
      }
    }
    
    getUserInfo();
  }, []);
  
  // Define functions after all hooks
  async function handleLogout() {
    try {
      await SecureStore.deleteItemAsync("user_token");
      await SecureStore.deleteItemAsync("user_type");
      await SecureStore.deleteItemAsync("user_id");
      // Use router instead of window.location for React Native
      router.replace("/(tabs)");
    } catch (err) {
      console.error("Logout error:", err);
      setLogoutError("Failed to logout. Please try again.");
    }
  }
  
  // Calculate derived data after all hooks
  const currentUser = data?.users?.find(user => user.user_id === userId) || null;
  
  // Handle loading state
  if (loading) {
    return (
      <LinearGradient
        colors={["#a1f4ff", "#c9b6e4", "#a0c7c7"]}
        style={styles.container}
      >
        <SafeAreaView style={styles.safeArea}>
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="large" color="#76A37C" />
            <Text style={styles.loadingText}>Loading your account...</Text>
          </View>
        </SafeAreaView>
      </LinearGradient>
    );
  }
  
  // Handle error state
  if (error) {
    return (
      <LinearGradient
        colors={["#a1f4ff", "#c9b6e4", "#a0c7c7"]}
        style={styles.container}
      >
        <SafeAreaView style={styles.safeArea}>
          <View style={styles.errorContainer}>
            <Ionicons name="alert-circle-outline" size={60} color="#d32f2f" />
            <Text style={styles.errorText}>Error loading account information</Text>
            <Text style={styles.errorSubtext}>{error.message}</Text>
            <TouchableOpacity 
              style={styles.retryButton} 
              onPress={() => router.replace("/(admin)/account")}
            >
              <Text style={styles.retryButtonText}>Try Again</Text>
            </TouchableOpacity>
          </View>
        </SafeAreaView>
      </LinearGradient>
    );
  }
  
  // Main render
  return (
    <LinearGradient
      colors={["#a1f4ff", "#c9b6e4", "#a0c7c7"]}
      style={styles.container}
    >
      <SafeAreaView style={styles.safeArea}>
        <ScrollView contentContainerStyle={styles.scrollContent}>
          <View style={styles.backButtonContainer}>
            <TouchableOpacity style={styles.backButton}>
              <Link href="/(tabs)">
                <Ionicons name="arrow-back" size={24} color="#444" />
              </Link>
            </TouchableOpacity>
          </View>

          <View style={styles.headerContainer}>
            <Text style={styles.headerTitle}>My Account</Text>
            <Text style={styles.headerSubtitle}>
              {currentUser ? `Welcome back, ${currentUser.username}!` : "Welcome to your account"}
            </Text>
          </View>

          <View style={styles.profileContainer}>
            <View style={styles.profileImageContainer}>
              <View style={styles.profileImage}>
                <Ionicons name="person" size={60} color="#76A37C" />
              </View>
            </View>

            {currentUser ? (
              <View style={styles.userInfoContainer}>
                <View style={styles.infoItem}>
                  <Text style={styles.infoLabel}>Username</Text>
                  <Text style={styles.infoValue}>{currentUser.username}</Text>
                </View>
                
                <View style={styles.infoItem}>
                  <Text style={styles.infoLabel}>Account Type</Text>
                  <Text style={styles.infoValue}>{currentUser.usertype}</Text>
                </View>
                
                <View style={styles.infoItem}>
                  <Text style={styles.infoLabel}>User ID</Text>
                  <Text style={styles.infoValue}>{currentUser.user_id}</Text>
                </View>
              </View>
            ) : (
              <View style={styles.noUserContainer}>
                <Text style={styles.noUserText}>
                  {userId ? "User information not found" : "Please log in to view your account"}
                </Text>
                {!userId && (
                  <TouchableOpacity 
                    style={styles.loginButton}
                    onPress={() => router.push("/login")}
                  >
                    <Text style={styles.loginButtonText}>Log In</Text>
                  </TouchableOpacity>
                )}
              </View>
            )}
          </View>

          {currentUser && (
            <>
              <View style={styles.optionsContainer}>
                <TouchableOpacity style={styles.optionItem}>
                  <Ionicons name="settings-outline" size={24} color="#444" style={styles.optionIcon} />
                  <Text style={styles.optionText}>Account Settings</Text>
                  <Ionicons name="chevron-forward" size={20} color="#888" />
                </TouchableOpacity>
                
                <TouchableOpacity style={styles.optionItem}>
                  <Ionicons name="shield-checkmark-outline" size={24} color="#444" style={styles.optionIcon} />
                  <Text style={styles.optionText}>Privacy & Security</Text>
                  <Ionicons name="chevron-forward" size={20} color="#888" />
                </TouchableOpacity>
                
                <TouchableOpacity style={styles.optionItem}>
                  <Ionicons name="help-circle-outline" size={24} color="#444" style={styles.optionIcon} />
                  <Text style={styles.optionText}>Help & Support</Text>
                  <Ionicons name="chevron-forward" size={20} color="#888" />
                </TouchableOpacity>
              </View>

              <View style={styles.logoutButtonContainer}>
                <TouchableOpacity
                  onPress={handleLogout}
                  style={styles.logoutButton}
                >
                  <Text style={styles.logoutButtonText}>Log Out</Text>
                  <Ionicons name="log-out-outline" size={24} color="white" />
                </TouchableOpacity>
              </View>
              
              {logoutError ? (
                <Text style={styles.errorMessage}>{logoutError}</Text>
              ) : null}
            </>
          )}
        </ScrollView>
      </SafeAreaView>
    </LinearGradient>
  );
};

// Define styles
const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  safeArea: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
    paddingHorizontal: 20,
    paddingBottom: 30,
  },
  backButtonContainer: {
    paddingTop: 20,
  },
  backButton: {
    padding: 10,
    width: 44,
  },
  headerContainer: {
    marginTop: 20,
    alignItems: "center",
  },
  headerTitle: {
    fontSize: 40,
    fontWeight: "600",
    color: "#333",
    marginBottom: 10,
  },
  headerSubtitle: {
    fontSize: 20,
    color: "#444",
    marginBottom: 40,
    textAlign: "center",
  },
  profileContainer: {
    backgroundColor: "white",
    borderRadius: 20,
    padding: 20,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
    marginBottom: 30,
  },
  profileImageContainer: {
    alignItems: "center",
    marginBottom: 20,
  },
  profileImage: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: "#e8f5e9",
    justifyContent: "center",
    alignItems: "center",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  userInfoContainer: {
    marginBottom: 10,
  },
  infoItem: {
    marginBottom: 15,
  },
  infoLabel: {
    fontSize: 14,
    color: "#888",
    marginBottom: 5,
  },
  infoValue: {
    fontSize: 18,
    color: "#333",
    fontWeight: "500",
  },
  noUserContainer: {
    alignItems: "center",
    paddingVertical: 20,
  },
  noUserText: {
    fontSize: 16,
    color: "#666",
    marginBottom: 20,
  },
  loginButton: {
    backgroundColor: "rgb(118, 163, 124)",
    paddingVertical: 12,
    paddingHorizontal: 30,
    borderRadius: 30,
  },
  loginButtonText: {
    color: "white",
    fontSize: 16,
    fontWeight: "500",
  },
  optionsContainer: {
    backgroundColor: "white",
    borderRadius: 20,
    padding: 10,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
    marginBottom: 30,
  },
  optionItem: {
    flexDirection: "row",
    alignItems: "center",
    paddingVertical: 15,
    paddingHorizontal: 10,
    borderBottomWidth: 1,
    borderBottomColor: "#f0f0f0",
  },
  optionIcon: {
    marginRight: 15,
  },
  optionText: {
    flex: 1,
    fontSize: 16,
    color: "#444",
  },
  logoutButtonContainer: {
    alignItems: "center",
    marginTop: 10,
  },
  logoutButton: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#d32f2f",
    paddingVertical: 12,
    paddingHorizontal: 25,
    borderRadius: 30,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 3,
    elevation: 3,
  },
  logoutButtonText: {
    color: "white",
    fontSize: 18,
    marginRight: 10,
    fontWeight: "500",
  },
  errorMessage: {
    color: "#d32f2f",
    textAlign: "center",
    marginTop: 10,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  loadingText: {
    marginTop: 15,
    fontSize: 18,
    color: "#444",
  },
  errorContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    padding: 20,
  },
  errorText: {
    fontSize: 20,
    fontWeight: "600",
    color: "#333",
    marginTop: 20,
    marginBottom: 10,
  },
  errorSubtext: {
    fontSize: 16,
    color: "#666",
    textAlign: "center",
    marginBottom: 30,
  },
  retryButton: {
    backgroundColor: "rgb(118, 163, 124)",
    paddingVertical: 12,
    paddingHorizontal: 30,
    borderRadius: 30,
  },
  retryButtonText: {
    color: "white",
    fontSize: 16,
    fontWeight: "500",
  },
});

// Make sure to export the component as default
