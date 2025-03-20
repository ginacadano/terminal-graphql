import dotenv from "dotenv";
import jwt from "jsonwebtoken";

dotenv.config();

const appContext = ({ req }) => {
  const token = req.headers.authorization || "";

  if (token) {
    // Check if the token starts with "Bearer "
    if (!token.startsWith("Bearer ")) {
      throw new Error("Authorization header must start with 'Bearer '");
    }

    //Extract the token
    const actualToken = token.split(" ")[1];

    try {
      const decoded = jwt.verify(actualToken, process.env.ACCESS_TOKEN_SECRET);

      // Check if the token is expired
      const currentTime = Math.floor(Date.now() / 1000); // Current time in seconds
      if (decoded.exp < currentTime) {
        throw new Error("Token has expired. Please log in again.");
      }

      const { username, usertype } = decoded;

      return {
        content: {
          username: username,
          usertype: usertype,
        },
        type: "success",
        message: "Authorized!"
      };
    } catch (err) {
      console.error("Token verification expired:", err);
      throw new Error("Invalid token. Please log in again.");
    }
  }

  // Return a structured response when no token is present
  return {
    content: {
      username: null,
    usertype: null,
    },
    type: "error",
    message: "Not Authenticated"
  };
};

export default appContext;
