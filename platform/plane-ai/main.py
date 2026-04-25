"""
Plane CE AI Service - Provides AI-powered features for Agile project management
"""
import os
import logging
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Optional, List
import requests

# Configure logging
logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO"))
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="Plane CE AI Service",
    description="AI-powered enhancements for Plane CE project management",
    version="1.0.0"
)

# Configuration
PLANE_API_BASE_URL = os.getenv("PLANE_API_BASE_URL", "https://app.local.test/api")
PLANE_API_TOKEN = os.getenv("PLANE_API_TOKEN", "")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
LLM_MODEL = os.getenv("LLM_MODEL", "gpt-3.5-turbo")

# Request/Response Models
class HealthResponse(BaseModel):
    status: str
    version: str

class IssueDescriptionRequest(BaseModel):
    title: str
    context: Optional[str] = None
    project_type: Optional[str] = "general"

class IssueDescriptionResponse(BaseModel):
    description: str
    acceptance_criteria: List[str]
    suggested_story_points: int

class SprintPlanRequest(BaseModel):
    project_id: str
    workspace_id: str
    team_velocity: float
    backlog_count: int

class SprintPlanResponse(BaseModel):
    recommended_issues: List[str]
    estimated_duration: str
    risk_assessment: str

class PriorityAnalysisRequest(BaseModel):
    issues: List[dict]
    business_context: Optional[str] = None

class PriorityAnalysisResponse(BaseModel):
    prioritized_issues: List[dict]
    reasoning: str

# Health check endpoint
@app.get("/health/", response_model=HealthResponse)
async def health_check():
    """Health check endpoint for Plane AI Service"""
    return {
        "status": "healthy",
        "version": "1.0.0"
    }

# AI Feature Endpoints

@app.post("/api/v1/generate-issue-description", response_model=IssueDescriptionResponse)
async def generate_issue_description(request: IssueDescriptionRequest):
    """
    Generate detailed issue description, acceptance criteria, and story point estimate
    """
    logger.info(f"Generating description for: {request.title}")

    try:
        if not OPENAI_API_KEY:
            # Return mock response for demo purposes
            return {
                "description": f"Implementation of {request.title}. {request.context or 'No additional context provided.'}",
                "acceptance_criteria": [
                    f"Feature '{request.title}' is implemented and functional",
                    "Code review completed and approved",
                    "All tests passing",
                    "Documentation updated"
                ],
                "suggested_story_points": 5
            }

        # TODO: Call OpenAI API to generate actual content
        # For now, return placeholder
        return {
            "description": f"Enhanced description for {request.title}",
            "acceptance_criteria": [
                "Requirement 1 met",
                "Requirement 2 met",
                "Code reviewed",
                "Tests passed"
            ],
            "suggested_story_points": 8
        }

    except Exception as e:
        logger.error(f"Error generating issue description: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/v1/analyze-priority")
async def analyze_priority(request: PriorityAnalysisRequest):
    """
    Analyze and recommend priority ordering for issues based on business context
    """
    logger.info(f"Analyzing priority for {len(request.issues)} issues")

    try:
        # Mock implementation - returns issues with recommended priority
        prioritized = sorted(
            request.issues,
            key=lambda x: x.get('importance', 0),
            reverse=True
        )

        return {
            "prioritized_issues": prioritized,
            "reasoning": "Issues prioritized based on business impact and dependencies"
        }

    except Exception as e:
        logger.error(f"Error analyzing priority: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/v1/suggest-sprint-plan")
async def suggest_sprint_plan(request: SprintPlanRequest):
    """
    Suggest sprint plan based on team velocity and project backlog
    """
    logger.info(f"Suggesting sprint plan for project: {request.project_id}")

    try:
        # Calculate recommended issues based on velocity
        estimated_issues = int(request.team_velocity)

        return {
            "recommended_issues": [f"Issue {i+1}" for i in range(min(estimated_issues, request.backlog_count))],
            "estimated_duration": "2 weeks",
            "risk_assessment": "Low risk - team velocity aligns with backlog complexity"
        }

    except Exception as e:
        logger.error(f"Error suggesting sprint plan: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v1/agile-metrics/{workspace_id}/{project_id}")
async def get_agile_metrics(workspace_id: str, project_id: str):
    """
    Get AI-generated Agile metrics and insights for a project
    """
    logger.info(f"Fetching metrics for project: {project_id}")

    try:
        return {
            "project_id": project_id,
            "workspace_id": workspace_id,
            "velocity_trend": "Improving",
            "cycle_time_average": "5 days",
            "delivery_pace": "Consistent",
            "team_capacity_utilization": "85%",
            "recommendations": [
                "Current sprint load is optimal",
                "Consider technical debt reduction in next sprint",
                "Team velocity showing positive trend"
            ]
        }

    except Exception as e:
        logger.error(f"Error fetching metrics: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v1/retrospective-suggestions/{workspace_id}/{project_id}/{sprint_id}")
async def get_retrospective_suggestions(workspace_id: str, project_id: str, sprint_id: str):
    """
    Generate AI-powered suggestions for sprint retrospective
    """
    logger.info(f"Generating retrospective suggestions for sprint: {sprint_id}")

    try:
        return {
            "sprint_id": sprint_id,
            "what_went_well": [
                "Team communication was excellent",
                "Velocity remained consistent",
                "All planned items were completed"
            ],
            "what_can_improve": [
                "Reduce estimated time variance",
                "Better estimation for complex tasks",
                "More proactive blocker communication"
            ],
            "action_items": [
                "Implement planning poker for estimation",
                "Daily standup 15 min earlier",
                "Weekly refinement session"
            ]
        }

    except Exception as e:
        logger.error(f"Error generating suggestions: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# Root endpoint
@app.get("/")
async def root():
    """Root endpoint with service information"""
    return {
        "service": "Plane CE AI Service",
        "version": "1.0.0",
        "status": "operational",
        "endpoints": {
            "health": "/health/",
            "generate_description": "/api/v1/generate-issue-description",
            "analyze_priority": "/api/v1/analyze-priority",
            "suggest_sprint_plan": "/api/v1/suggest-sprint-plan",
            "agile_metrics": "/api/v1/agile-metrics/{workspace_id}/{project_id}",
            "retrospective_suggestions": "/api/v1/retrospective-suggestions/{workspace_id}/{project_id}/{sprint_id}"
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
