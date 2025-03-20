// Import bcrypt for password hashing
import bcrypt from "bcrypt";
// Import database connection pool helper
import { pool } from "../helpers/dbHelper.js";
import GraphQLJSON from "graphql-type-json"; // Import JSON scalar

// Define GraphQL resolvers for user-related queries and mutations
import {
    CustomDateTimeScalar,
    DateScalar,
    DateTimeScalar,
    TimeScalar,
  } from "../helpers/scalarHandler.js";
  
  export const penaltyResolver = {
    Date: DateScalar,
    Time: TimeScalar,
    DateTime: DateTimeScalar,
    CustomDateTime: CustomDateTimeScalar,
    JSON: GraphQLJSON, // Add JSON scalar

  
    
    // Query resolvers handle fetching user data
    Query: {
        // Fetch all users from the database
        penalties: async () => {
            const client = await pool.connect();
            try {
                const query = {
                    text: "SELECT * FROM penalties", // SQL query to get all users
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
        penalty: async (_, { id }) => {
            const client = await pool.connect();
            try {
                const query = {
                    text: "SELECT * FROM penalties WHERE penalty_id = $1", // SQL query with parameter
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
        addPenalty: async (_, { penalties, admin_id }, context) => {
            console.log("context", context);

            if (context.type == "error") {
              return {
                type: "error",
                message: context.message,
              };
            }
            console.log("Add User Input Details: ",penalties, admin_id);
            const client = await pool.connect();
            
            try {

                let response = {
                    content: null,
                    type: "",
                    message: "",
                };

                // Call a PostgreSQL function to add a new user
                const query = {
                    text: "SELECT * FROM fn_admin_add_penalty($1, $2, $3, $4, $5) AS result",
                    values: [admin_id, penalties.violation, penalties.violation_date, penalties.amount_penalty, penalties.plate_no],
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
        updatePenalty: async (_, { admin_id, penalty_id, penalties }, context) => {
            console.log("context", context);

      if (context.type == "error") {
        return {
          type: "error",
          message: context.message,
        };
      }

            const client = await pool.connect();
            try {
                let response = {
                    type: "",
                    message: "",
                };

                // Call a PostgreSQL function to update user details
                const query = {
                    text: "SELECT fn_admin_update_penalty($1, $2, $3, $4, $5, $6) AS result",
                    values: [admin_id, penalty_id, penalties.violation, penalties.violation_date, penalties.amount_penalty, penalties.plate_no],
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

        markPenaltyAsPaid: async (_, { penalty_id, paid_date, or_no }, context) => {
            console.log("context", context);

      if (context.type == "error") {
        return {
          type: "error",
          message: context.message,
        };
      }
            const client = await pool.connect();
            try {
                let response = {
                    content: null,
                    type: "",
                    message: "",
                };
    
                // Call the PostgreSQL function to mark a penalty as paid
                const query = {
                    text: "SELECT fn_mark_penalty_as_paid($1, $2, $3) AS result",
                    values: [penalty_id, paid_date, or_no],
                };
    
                const result = await client.query(query);
    
                // Process the result and return appropriate response
                if (result && result.rows.length > 0) {
                    const res = result.rows[0].result;
                    console.log("Mark Penalty as Paid Result:", res);
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
                throw new Error("Failed to mark penalty as paid.");
            } finally {
                client.release(); // Release the database connection
            }
        },

        // Delete a user account
        deletePenalty: async (_, { admin_id, user_id }, context) => {
            console.log("context", context);

      if (context.type == "error") {
        return {
          type: "error",
          message: context.message,
        };
      }
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
