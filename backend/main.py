import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from backend.routers import portfolio, triage, simulation, borrower

# Configure structured logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s"
)
logger = logging.getLogger("kerdos.backend")

app = FastAPI(
    title="Kerdos Microfinance Contagion API",
    description="Backend API serving ML models, econometric explainers, and simulation datasets from code1/model_outputs/",
    version="1.0.0"
)

# Enable CORS for Flutter Web and desktop clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(portfolio.router)
app.include_router(triage.router)
app.include_router(simulation.router)
app.include_router(borrower.router)

@app.get("/api/health")
def health_check():
    return {
        "status": "HEALTHY",
        "service": "Kerdos Backend",
        "version": "1.0.0",
        "zero_emoji_compliant": True
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("backend.main:app", host="127.0.0.1", port=8000, reload=True)
