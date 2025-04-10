// Import bcrypt for password hashing and verification
import bcrypt from "bcrypt";
// Import database connection pool helper
import { pool } from "../helpers/dbHelper.js";
import generateToken from "../helpers/tokenHelper.js";

// Define GraphQL resolver for handling login functionality
export const loginResolver = {
  Mutation: {
    // Mutation for user login
    userLogin: async (_, { username, password }) => {
      const client = await pool.connect(); // Get a database connection
      let response = {
        type: "error",
        message: "invalid credential",
        token: "",
      };
      try {
        console.log("Attempting login for:", username);

        // Query to fetch user details based on username
        const query = {
          text: "SELECT * FROM fn_login($1)", // Calls a PostgreSQL function to get user data
          values: [username], // Pass the username as a parameter
        };

        const result = await client.query(query);

        // If no user is found, return an error message
        if (result.rows.length === 0) {
          console.log("User not found in DB.");
          return { type: "error", message: "Invalid credentials", token: "" };
        }

        // Extract user data from the query result
        const user = result.rows[0].fn_login;
        console.log("Stored:", user.row);

        // Compare input password with stored hashed password
        const isValid = await bcrypt.compare(password, user.password);
        console.log("Password verification result:", isValid);

        // If password is incorrect, return an error message
        if (isValid) {
          const token = await generateToken(user);
          response = {
            type: "success",
            message: "Login Successfully!",
            token: token,
          };
        }
        return response;

        // If login is successful, return a success message
      } catch (err) {
        console.error("Login Error:", err.message);
        throw new Error(err.message); // Throw an error if something goes wrong
      } finally {
        client.release(); // Release the database connection
      }
    },
  },
};
