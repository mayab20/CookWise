import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: {
      type: String,
      required: true,
      unique: true,
      match: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
    },
    password: { type: String, required: true },

    birthdate: { type: Date, required: true },
    sex: { type: String, required: true },

    allergies: [String],
    dietaryPreferences: [String],
    favoriteCuisines: [String],
    dislikedIngredients: [String],

    role: { type: String, enum: ["user", "admin"], default: "user" },
  },
  { timestamps: true }
);

const User = mongoose.model("User", userSchema);

export default User;
