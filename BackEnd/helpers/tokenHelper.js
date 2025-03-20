import jwt from "jsonwebtoken";

const generateToken = async(user) => {
    const {username, usertype} = user;
    console.log("Payload", user)
    const accessToken = await jwt.sign(
        {username: username, usertype: usertype,},
        
        process.env.ACCESS_TOKEN_SECRET,
        {expiresIn: "1m"}

    );
return accessToken;
}
export default generateToken;