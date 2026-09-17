from fastapi import APIRouter
from backend.data_loader import data_loader

router = APIRouter(prefix="/api", tags=["portfolio"])

@router.get("/summary")
def get_portfolio_summary():
    """Returns headline PAR metrics, active portfolio exposure, and causal risk breakdown."""
    return data_loader.get_portfolio_summary()

@router.get("/fairness")
def get_fairness_audit():
    """Returns demographic fairness audit table grouped by region."""
    return data_loader.get_fairness_audit()
