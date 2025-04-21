import React, { useState } from "react";
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  KeyboardAvoidingView,
  Platform,
} from "react-native";
import login from "../assets/styles/login";
import { LinearGradient } from "expo-linear-gradient";
import { Ionicons } from "@expo/vector-icons";
import { Link } from "expo-router";
import { useMutation } from "@apollo/client";
import { useRouter } from "expo-router";
import * as SecureStore from "expo-secure-store";
import LOGIN from "./mutations/loginMutation";

const Login = () => {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [passwordVisible, setPasswordVisible] = useState(false);
  const [loginError, setLoginError] = useState("");

  {
    loginError ? (
      <Text style={{ color: "red", marginBottom: 10 }}>{loginError}</Text>
    ) : null;
  }

  const togglePasswordVisibility = () => {
    setPasswordVisible(!passwordVisible);
  };

  const router = useRouter();

  const [login, { loading }] = useMutation(LOGIN, {
    onCompleted: async (data) => {
      console.log("Login response:", data);

      try {
        if (data?.userLogin?.token && data?.userLogin?.user) {
          const { token, user } = data.userLogin;

          await SecureStore.setItemAsync("user_token", token);
          await SecureStore.setItemAsync("user_type", user.usertype);

          if (user.usertype === "admin") {
            router.replace("/(admin)/account");
          } else if (user.usertype === "user") {
            router.replace("/(user)/home");
          } else {
            router.replace("/(tabs)");
          }
        } else {
          setLoginError("Invalid response format. Please try again.");
        }
      } catch (err) {
        setLoginError("Error saving credentials. Please try again.");
        console.error("Login completion error:", err);
      }
    },
    onError: (error) => {
      console.error("Login mutation error:", error);
      if (error.message.includes("Invalid credentials")) {
        setLoginError("Incorrect username or password.");
      } else {
        setLoginError(
          "Login failed. Please check your connection and try again."
        );
      }
    },
  });

  const handleLogin = async () => {
    setLoginError("");
    if (!username.trim() || !password.trim()) {
      setLoginError("Please enter both username and password");
      return;
    }

    try {
      await login({
        variables: {
          username: username.trim(),
          password: password.trim(),
        },
      });
    } catch (e) {
      console.error("Mutation execution error:", e);
    }
  };

  return (
    <LinearGradient
      colors={["#a1f4ff", "#c9b6e4", "#a0c7c7"]}
      style={styles.container}
    >
      <SafeAreaView style={styles.safeArea}>
        <KeyboardAvoidingView
          behavior={Platform.OS === "ios" ? "padding" : "height"}
          style={styles.keyboardAvoid}
        >
          <View style={styles.backButtonContainer}>
            <TouchableOpacity style={styles.backButton}>
              <Link href="/(tabs)">
                <Ionicons name="arrow-back" size={24} color="#444" />
              </Link>
            </TouchableOpacity>
          </View>

          <View style={styles.headerContainer}>
            <Text style={styles.headerTitle}>Log-in!</Text>
            <Text style={styles.headerSubtitle}>Sign in to your account</Text>
          </View>

          <View style={styles.formContainer}>
            <View style={styles.inputContainer}>
              <Ionicons
                name="person-outline"
                size={20}
                color="#888"
                style={styles.inputIcon}
              />
              <TextInput
                style={styles.input}
                placeholder="Username"
                placeholderTextColor="#888"
                value={username}
                onChangeText={setUsername}
              />
            </View>

            <View style={styles.inputContainer}>
              <Ionicons
                name="lock-closed-outline"
                size={20}
                color="#888"
                style={styles.inputIcon}
              />
              <TextInput
                style={styles.input}
                placeholder="Password"
                placeholderTextColor="#888"
                secureTextEntry={!passwordVisible}
                value={password}
                onChangeText={setPassword}
              />
              <TouchableOpacity
                onPress={togglePasswordVisibility}
                style={styles.passwordToggle}
              >
                <Ionicons
                  name={passwordVisible ? "eye-off-outline" : "eye-outline"}
                  size={22}
                  color="#888"
                />
              </TouchableOpacity>
            </View>

            <View style={styles.forgotPasswordContainer}>
              <TouchableOpacity>
                <Text style={styles.forgotPasswordText}>
                  Forgot your password?
                </Text>
              </TouchableOpacity>
            </View>

            <View style={styles.signInButtonContainer}>
              <TouchableOpacity
                onPress={handleLogin}
                style={styles.signInButton}
              >
                <Text style={styles.signInButtonText}>Sign in</Text>
                <Ionicons name="arrow-forward" size={24} color="white" />
              </TouchableOpacity>
            </View>
          </View>

          <View style={styles.footer}>
            <Text style={styles.footerText}>Don't have an account? </Text>
            <TouchableOpacity>
              <Text style={styles.createAccountText}>Create</Text>
            </TouchableOpacity>
          </View>
        </KeyboardAvoidingView>
      </SafeAreaView>
    </LinearGradient>
  );
};

export default Login;

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  safeArea: {
    flex: 1,
  },
  keyboardAvoid: {
    flex: 1,
    paddingHorizontal: 20,
  },
  backButtonContainer: {
    paddingTop: 20,
  },
  backButton: {
    padding: 10,
    width: 44,
  },
  headerContainer: {
    marginTop: 40,
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
    marginBottom: 60,
  },
  formContainer: {
    width: "100%",
  },
  inputContainer: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "white",
    borderRadius: 30,
    marginBottom: 20,
    paddingHorizontal: 15,
    height: 60,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  inputIcon: {
    marginRight: 10,
  },
  input: {
    flex: 1,
    fontSize: 16,
    color: "#333",
  },
  passwordToggle: {
    padding: 8,
  },
  forgotPasswordContainer: {
    alignItems: "flex-end",
    marginBottom: 40,
  },
  forgotPasswordText: {
    color: "#666",
    fontSize: 14,
  },
  signInButtonContainer: {
    alignItems: "flex-end",
    marginBottom: 40,
  },
  signInButton: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "rgb(118, 163, 124)",
    paddingVertical: 12,
    paddingHorizontal: 25,
    borderRadius: 30,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 3,
    elevation: 3,
  },
  signInButtonText: {
    color: "white",
    fontSize: 18,
    marginRight: 10,
    fontWeight: "500",
  },
  footer: {
    flexDirection: "row",
    justifyContent: "center",
    marginTop: "auto",
    marginBottom: 30,
  },
  footerText: {
    color: "#444",
    fontSize: 16,
  },
  createAccountText: {
    color: "#333",
    fontSize: 16,
    fontWeight: "600",
    textDecorationLine: "underline",
  },
});
