# Plane CE AI Service

AI-powered features for enhanced Agile project management in Plane CE.

## Overview

The Plane AI Service provides intelligent features to support Agile teams:

- **Issue Description Generation** - AI-assisted issue writing with acceptance criteria
- **Priority Analysis** - Intelligent backlog prioritization based on business context
- **Sprint Planning** - Recommendations based on team velocity and capacity
- **Agile Metrics** - AI-generated insights and metrics
- **Retrospective Suggestions** - Automated improvement suggestions

## Architecture

```
┌─────────────────────────────────────────────────┐
│         Plane CE Frontend/Backend               │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│      Plane AI Service (FastAPI)                 │
├─────────────────────────────────────────────────┤
│ • Generate descriptions                         │
│ • Analyze priorities                            │
│ • Suggest sprint plans                          │
│ • Calculate metrics                             │
│ • Retrospective suggestions                     │
└──────────────────┬──────────────────────────────┘
                   │
        ┌──────────┼──────────┐
        ▼          ▼          ▼
    ┌────────┐ ┌────────┐ ┌─────────┐
    │ Redis  │ │ Postgres│ │ OpenAI  │
    │ (Queue)│ │ (Store) │ │ (LLM)   │
    └────────┘ └────────┘ └─────────┘
```

## Prerequisites

- Docker & Docker Compose
- Python 3.11+ (for local development)
- Plane CE running and accessible
- (Optional) OpenAI API key for LLM features

## Configuration

Environment variables in `../../.env`:

```env
# Plane AI Service
PLANE_AI_SERVICE_TOKEN=your-api-token
PLANE_AI_DB=plane_ai
PLANE_AI_POSTGRES_USER=plane_ai
PLANE_AI_POSTGRES_PASSWORD=PlaneAIPass123!

# OpenAI Configuration (optional)
OPENAI_API_KEY=sk-...
OPENAI_API_BASE=https://api.openai.com/v1
LLM_MODEL=gpt-3.5-turbo
```

## Deployment

The AI service is deployed as part of the platform stack:

```bash
# Start AI service with other services
./scripts/up.sh

# View AI service logs
./scripts/logs.sh plane-ai

# Check health
curl https://ai.local.test/health/
```

## API Endpoints

### Health Check
```
GET /health/
```

Response:
```json
{
  "status": "healthy",
  "version": "1.0.0"
}
```

### Generate Issue Description
```
POST /api/v1/generate-issue-description
```

Request:
```json
{
  "title": "Implement user authentication",
  "context": "OAuth2 integration with Authentik",
  "project_type": "backend"
}
```

Response:
```json
{
  "description": "Implementation of user authentication...",
  "acceptance_criteria": [
    "OAuth2 flow implemented",
    "User session management working",
    "Security review passed"
  ],
  "suggested_story_points": 8
}
```

### Analyze Priority
```
POST /api/v1/analyze-priority
```

Request:
```json
{
  "issues": [
    {"id": "1", "title": "Bug fix", "importance": 8},
    {"id": "2", "title": "Feature", "importance": 5}
  ],
  "business_context": "Q1 release planning"
}
```

Response:
```json
{
  "prioritized_issues": [...],
  "reasoning": "Issues prioritized based on impact and dependencies"
}
```

### Suggest Sprint Plan
```
POST /api/v1/suggest-sprint-plan
```

Request:
```json
{
  "project_id": "proj123",
  "workspace_id": "ws123",
  "team_velocity": 25,
  "backlog_count": 50
}
```

Response:
```json
{
  "recommended_issues": ["Issue 1", "Issue 2", ...],
  "estimated_duration": "2 weeks",
  "risk_assessment": "Low risk - team velocity aligns"
}
```

### Get Agile Metrics
```
GET /api/v1/agile-metrics/{workspace_id}/{project_id}
```

Response:
```json
{
  "project_id": "proj123",
  "velocity_trend": "Improving",
  "cycle_time_average": "5 days",
  "delivery_pace": "Consistent",
  "team_capacity_utilization": "85%",
  "recommendations": [...]
}
```

### Get Retrospective Suggestions
```
GET /api/v1/retrospective-suggestions/{workspace_id}/{project_id}/{sprint_id}
```

Response:
```json
{
  "sprint_id": "sprint123",
  "what_went_well": [...],
  "what_can_improve": [...],
  "action_items": [...]
}
```

## Local Development

### Setup

```bash
cd platform/plane-ai
pip install -r requirements.txt
```

### Run Locally

```bash
# Set environment variables
export PLANE_API_BASE_URL=https://app.local.test/api
export OPENAI_API_KEY=sk-...

# Start service
python main.py
```

The service will be available at `http://localhost:8001`

### Testing

```bash
# Health check
curl http://localhost:8001/health/

# Generate description
curl -X POST http://localhost:8001/api/v1/generate-issue-description \
  -H "Content-Type: application/json" \
  -d '{"title": "Test issue", "project_type": "backend"}'
```

## Features in Development

### Phase 1 (Current)
- ✅ Basic API structure
- ✅ Health monitoring
- ✅ Mock implementations for testing

### Phase 2
- [ ] OpenAI integration for issue description
- [ ] Database storage for suggestions
- [ ] Priority analysis with ML
- [ ] Sprint capacity optimization

### Phase 3
- [ ] Team performance analytics
- [ ] Predictive sprint planning
- [ ] Automated retrospective insights
- [ ] Integration with Slack notifications

## Integration with Plane CE

To integrate AI features into Plane CE:

1. **Plugin Development** - Create Plane CE plugins that call AI endpoints
2. **Custom Fields** - Add AI-generated suggestions to issue creation
3. **Automation** - Trigger AI analysis on issue updates
4. **Dashboard Widgets** - Display AI insights in custom dashboards

## Troubleshooting

### Service not responding

```bash
# Check if service is running
docker ps | grep plane-ai

# View logs
./scripts/logs.sh plane-ai

# Restart service
docker compose -f plane-ai/docker-compose.yml restart
```

### OpenAI API errors

Ensure `OPENAI_API_KEY` is set correctly in `.env`. Service works in demo mode without API key.

### Database connection issues

Verify `PLANE_AI_POSTGRES_PASSWORD` matches the configured value.

## Documentation

- [Plane CE Docs](https://docs.plane.so)
- [OpenAI API](https://platform.openai.com/docs)
- [FastAPI](https://fastapi.tiangolo.com)

## License

Same as Plane CE project
