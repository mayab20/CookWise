import "dotenv/config";
import express from "express";
import cors from "cors";
import mongoose from "mongoose";

// Routes
import usersRoute from "./routes/userRoutes.js";
import pantryRoute from "./routes/pantryRoutes.js";
import recipesRoute from "./routes/recipeRoutes.js";
import shoppingRoute from "./routes/shoppingListRoutes.js";
import itemsRoute from "./routes/itemRoutes.js";
import adminRoutes from "./routes/adminRoutes.js";


const app = express();
app.use(
  cors()
);
app.use(express.json());

// MongoDB connection
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("MongoDB connected"))
  .catch((err) => console.log(err));



app.get('/', (req, res) => {
  res.send('API is running');
});

app.use("/users", usersRoute);
app.use("/pantry", pantryRoute);
app.use("/recipes", recipesRoute);
app.use("/shopping-list", shoppingRoute);
app.use("/items", itemsRoute);
app.use("/admin", adminRoutes);



// Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
