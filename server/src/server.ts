import app from "@/app";

const PORT = 8000;

app.listen(PORT, () => {
  console.log(`[OK] Server running at: http://localhost:${PORT}`);
});