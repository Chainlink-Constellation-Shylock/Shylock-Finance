import express, { Application } from 'express';
import router from './routes/router';
import { errorHandler } from './middlewares/middleware';
import cors from 'cors'

const app: Application = express();

const PORT = process.env.PORT || 3001;

const allowedOrigins = ['http://localhost:3000'];

const options: cors.CorsOptions = {
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  }
};

// Allow all origins for now, testing purpose
app.use(cors());
app.use(express.json());
app.use('/', router);
app.use(errorHandler);

const server = app.listen(PORT, () => {
  if (PORT == 3001) {
    console.log(`Server is running at http://localhost:${PORT}`);
  } else {
    console.log(`Server is running at ${PORT}`);
  }

});

// Handle termination signals
process.on('SIGINT', gracefulShutdown);
process.on('SIGTERM', gracefulShutdown);

export function gracefulShutdown() {
  console.log("\nGracefully shutting down. Closing the server connection.");
  server.close(() => {
    console.log("Server closed.");
    process.exit();
  });
}

export default app;
