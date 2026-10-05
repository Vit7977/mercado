import express from 'express';
import "dotenv/config";

const PORT = process.env.API_PORT || 3000;

const api = express();

api.listen(PORT, ()=> {
    console.log(`API http://localhost:${PORT}`)
})