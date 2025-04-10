// Import bcrypt for password hashing
import bcrypt from "bcrypt";
// Import database connection pool helper
import { pool } from "../helpers/dbHelper.js";

// Define GraphQL resolvers for user-related queries and mutations
export const userResolver = {
  // Query resolvers handle fetching user data
  Query: {
    // Fetch all users from the database
    users: async () => {
      const client = await pool.connect();
      try {
        const query = {
          text: "SELECT * FROM useraccounts", // SQL query to get all users
        };
        const result = await client.query(query);
        console.log("Result:", result.rows);
        return result.rows; // Return the list of users
      } catch (err) {
        console.error("Error:", err);
        throw new Error("Failed to fetch users.");
      } finally {
        client.release(); // Release the database connection
      }
    },

    // Fetch a single user by ID
    user: async (_, { id }) => {
      const client = await pool.connect();
      try {
        const query = {
          text: "SELECT * FROM useraccounts WHERE user_id = $1", // SQL query with parameter
          values: [id],
        };
        const result = await client.query(query);
        console.log("Result:", result.rows);
        return result.rows[0]; // Return the user object
      } catch (err) {
        console.error("Error:", err);
        throw new Error("Failed to fetch user.");
      } finally {
        client.release(); // Release the database connection
      }
    },
  },

  // Mutation resolvers handle modifying user data
  Mutation: {
    // Add a new user account
    addUserAccount: async (_, { useraccounts, admin_id }, context) => {
      console.log("context", context);

      //   if (context.type == "error") {
      //     return {
      //       type: "error",
      //       message: context.message,
      //     };
      //   }

      console.log("Add User Input Details: ", useraccounts, admin_id);
      const client = await pool.connect();

      try {
        const { username, password, usertype } = useraccounts;

        // Hash the password before storing it in the database
        const hashedPassword = await bcrypt.hash(password, 10);

        let response = {
          content: null,
          type: "",
          message: "",
        };

        // Call a PostgreSQL function to add a new user
        const query = {
          text: "SELECT * FROM fn_admin_add_useraccount($1, $2, $3, $4) AS result",
          values: [admin_id, username, hashedPassword, usertype],
        };

        const result = await client.query(query);

        // Process the result and return appropriate response
        if (result && result.rows.length > 0) {
          const res = result.rows[0].result;
          console.log("Added user result: ", res);
          if (res) {
            response = {
              content: res.content,
              type: res.type,
              message: res.message,
            };
          }
        }

        return response;
      } catch (err) {
        console.error("Error:", err);
        throw new Error("Failed to add user account.");
      } finally {
        await client.end(); // Close database connection
      }
    },

    // Update an existing user account
    updateUserAccount: async (
      _,
      { admin_id, user_id, useraccounts },
      context
    ) => {
      console.log("context", context);

      //   if (context.type == "error") {
      //     return {
      //       type: "error",
      //       message: context.message,
      //     };
      //   }

      const client = await pool.connect();
      try {
        let hashedPassword = useraccounts.password;

        // Hash password only if it's being updated
        if (useraccounts.password) {
          hashedPassword = await bcrypt.hash(useraccounts.password, 10);
        }

        let response = {
          type: "",
          message: "",
        };

        // Call a PostgreSQL function to update user details
        const query = {
          text: "SELECT fn_admin_update_useraccount($1, $2, $3, $4, $5) AS result",
          values: [
            admin_id,
            user_id,
            useraccounts.username,
            hashedPassword,
            useraccounts.usertype,
          ],
        };

        const result = await client.query(query);

        // Process the result and return appropriate response
        if (result && result.rows.length > 0) {
          const res = result.rows[0].result;
          console.log("Updated user result: ", res);
          if (res) {
            response = {
              type: res.type,
              message: res.message,
            };
          }
        }

        return response;
      } catch (err) {
        console.error("Error:", err);
        throw new Error("Failed to update user account.");
      } finally {
        await client.end(); // Close database connection
      }
    },

    // Delete a user account
    deleteUserAccount: async (_, { admin_id, user_id }, context) => {
      console.log("context", context);

      //   if (context.type == "error") {
      //     return {
      //       type: "error",
      //       message: context.message,
      //     };
      //   }
      const client = await pool.connect();
      try {
        let response = {
          type: "",
          message: "",
        };

        // Call a PostgreSQL function to delete a user
        const query = {
          text: "SELECT fn_admin_delete_useraccount($1, $2) AS result",
          values: [admin_id, user_id],
        };

        const result = await client.query(query);

        // Process the result and return appropriate response
        if (result && result.rows.length > 0) {
          const res = result.rows[0].result;
          console.log("Deleted user result: ", res);
          if (res) {
            response = {
              type: res.type,
              message: res.message,
            };
          }
        }
        return response;
      } catch (err) {
        console.error("Error:", err);
        throw new Error("Failed to delete user account.");
      } finally {
        await client.end(); // Close database connection
      }
    },
  },
};
