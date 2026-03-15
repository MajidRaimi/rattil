import { Elysia } from "elysia";
import { cors } from "@elysiajs/cors";

const app = new Elysia()
  .use(cors())
  .get("/", () => ({ message: "Quran API is running" }))
  .listen(3000);

console.log(`🕌 Quran API is running at http://${app.server?.hostname}:${app.server?.port}`);
