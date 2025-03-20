// Import bcrypt for password hashing
import bcrypt from "bcrypt";
// Import database connection pool helper
import { pool } from "../helpers/dbHelper.js";

import {
    CustomDateTimeScalar,
    DateScalar,
    DateTimeScalar,
    TimeScalar,
  } from "../helpers/scalarHandler.js";
  
  export const scheduleResolver = {
    Date: DateScalar,
    Time: TimeScalar,
    DateTime: DateTimeScalar,
    CustomDateTime: CustomDateTimeScalar,
  
    
    // Query resolvers handle fetching user data
    Query: {
        // Fetch all users from the database
        schedules: async () => {
            const client = await pool.connect();
            try {
                const query = {
                    text: "SELECT * FROM schedules", // SQL query to get all users
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
        schedule: async (_, { id }) => {
            const client = await pool.connect();
            try {
                const query = {
                    text: "SELECT * FROM schedules WHERE schedule_id = $1", // SQL query with parameter
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
        addSchedule: async (_, { schedules, or_id }, context) => {
            console.log("context", context);

      if (context.type == "error") {
        return {
          type: "error",
          message: context.message,
        };
      }
            console.log("Add User Input Details: ",schedules, or_id);
            const client = await pool.connect();
            
            try {

                let response = {
                    content: null,
                    type: "",
                    message: "",
                };

                // Call a PostgreSQL function to add a new user
                const query = {
                    text: "SELECT * FROM fn_or_add_schedule($1, $2, $3, $4, $5, $6) AS result",
                    values: [or_id, schedules.date, schedules.plate_no, schedules.departure_time, schedules.arrival_time, schedules.destination],
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
        updateSchedule: async (_, { or_id, schedule_id, schedules }, context) => {
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
                    text: "SELECT fn_or_update_schedule($1, $2, $3, $4, $5, $6, $7) AS result",
                    values: [or_id, schedule_id, schedules.date, schedules.plate_no, schedules.departure_time, schedules.arrival_time, schedules.destination],
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
        deleteSchedule: async (_, { or_id, schedule_id }, context) => {
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
                    text: "SELECT fn_or_delete_schedule($1, $2) AS result",
                    values: [or_id, schedule_id],
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
