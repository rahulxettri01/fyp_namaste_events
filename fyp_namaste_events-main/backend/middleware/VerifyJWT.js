const jwt = require("jsonwebtoken");

const VerifyJWT = (req, res, next) => {
  const token = req.header("Authorization"); // Get token from header
  console.log("in jwt");

  if (!token) {
    console.log("no jwt");
    return res
      .status(401)
      .json({ message: "Access Denied! No token provided." });
  }

  try {
    console.log("ef");

    const decoded = jwt.verify(token.split(" ")[1], "SECRET"); // Verify token
    req.user = decoded; // Attach user data to request

    next();
  } catch (error) {
    return res.status(403).json({ message: "Invalid or Expired Token" });
  }
};

module.exports = VerifyJWT;
