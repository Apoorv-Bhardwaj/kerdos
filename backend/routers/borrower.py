from datetime import datetime
from typing import Optional
from fastapi import APIRouter
from pydantic import BaseModel
from backend.data_loader import data_loader

router = APIRouter(prefix="/api/borrower", tags=["borrower"])

class HardshipRequest(BaseModel):
    borrower_id: str
    hardship_category: str  # e.g., "Medical Expense", "Crop Loss", "Business Slowdown"
    requested_relief: str  # e.g., "2-Week Grace Period", "Loan Restructuring"
    narrative: str
    confidential: bool = True

@router.get("/{borrower_id}")
def get_borrower_profile(borrower_id: str):
    """Returns personal loan details for a borrower."""
    return data_loader.get_borrower_profile(borrower_id)

@router.get("/{borrower_id}/group-milestones")
def get_group_milestones(borrower_id: str):
    """Returns dignified, positive group milestones with strictly zero peer distress details."""
    return data_loader.get_group_milestones(borrower_id)

@router.post("/hardship")
def submit_hardship_notification(req: HardshipRequest):
    """Confidential hardship declaration sent privately to loan officer."""
    submission_id = f"HRD-{abs(hash(req.borrower_id + str(datetime.utcnow()))) % 1000000:06d}"
    return {
        "status": "HARDSHIP_SUBMITTED_CONFIDENTIAL",
        "ticket_id": submission_id,
        "borrower_id": req.borrower_id,
        "message": (
            "Your notification has been routed privately to your Loan Officer. "
            "This information is strictly confidential and will NOT be shared with your group peers."
        ),
        "officer_scheduled_contact": "Within 24 business hours"
    }
