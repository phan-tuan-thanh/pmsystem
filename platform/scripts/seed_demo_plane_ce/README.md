# Plane CE Demo Data Seeding

This directory contains scripts to generate comprehensive demo data for Plane CE, demonstrating complete Agile project management workflows.

## Overview

The seed scripts create:
- **30 demo users** across 7 different Agile roles
- **20 demo projects** with various templates and descriptions
- **~85 sprints** across projects
- **~1000 demo issues** with different priorities and states
- Complete project structures with workflows and team assignments

## Structure

- `config.py` - Configuration for API endpoints and demo data parameters
- `api_client.py` - Plane CE API client wrapper for seeding operations
- `run_all.py` - Main script that orchestrates all data seeding
- `requirements.txt` - Python dependencies

## Prerequisites

1. Plane CE must be running and accessible
2. Python 3.8+
3. Environment variables configured in `../../.env`:
   - `PLANE_API_BASE_URL` - Plane CE API endpoint
   - `PLANE_ADMIN_EMAIL` - Admin email for authentication
   - `PLANE_ADMIN_PASSWORD` - Admin password
   - `DOMAIN` - Domain for constructing URLs

## Installation

```bash
# Install dependencies
cd platform/scripts/seed_demo_plane_ce
pip install -r requirements.txt
```

## Usage

### Seed Demo Data

```bash
# Generate demo data
python run_all.py

# To reset and regenerate (use with caution)
python run_all.py --reset
```

### Expected Output

```
2026-04-25 10:30:45 - INFO - Starting Plane CE demo data seeding...
2026-04-25 10:30:46 - INFO - Connecting to Plane CE API...
2026-04-25 10:30:47 - INFO - Successfully authenticated with Plane CE API
2026-04-25 10:30:48 - INFO - Creating 30 demo users...
2026-04-25 10:30:55 - INFO - Successfully created 30 new demo users
...
2026-04-25 10:31:30 - INFO - ✅ Demo data seeding completed successfully!
```

## Demo Data Description

### Users Created

The seeding process creates users representing the 7 key Agile roles:

1. **Product Owner** - Manages product backlog and priorities
2. **Scrum Master** - Facilitates ceremonies and removes blockers
3. **Developer** - Implements features and fixes bugs
4. **QA Engineer** - Tests and validates quality
5. **Business Analyst** - Analyzes requirements and writes stories
6. **UX Designer** - Designs user experience and interfaces
7. **Stakeholder** - Reviews progress and provides feedback

Each user has a realistic name, email, and role assignment.

### Projects Created

Sample projects demonstrate different project types and domains:

- **E-Commerce Platform** - Large-scale project with complex workflows
- **Mobile App** - Cross-platform development project
- **API Gateway** - Microservices infrastructure project
- **Analytics Dashboard** - Real-time data processing project
- **Content Management** - Headless CMS implementation
- **Chat Application** - Real-time communication platform
- **Data Pipeline** - ETL and batch processing
- **DevOps Platform** - Infrastructure automation
- **Customer Portal** - Self-service features
- **Admin Dashboard** - Administrative tools

### Sprints and Issues

Each project receives:
- **4 demo sprints** with 2-week iterations
- **50 demo issues** per project with varying priorities
- Issues distributed across backlogs, active sprints, and completed states
- Realistic descriptions and acceptance criteria

## Demo Agile Reference Project

A special reference project is created with complete documentation:

- **Full team structure** with all 7 Agile roles assigned
- **Complete sprint history** showing velocity trends
- **Sample documentation** on Agile ceremonies and workflows
- **Metrics examples** for burndown, velocity, and cycle time
- **Retrospective notes** showing continuous improvement

### Reference Project Features

#### Backlog Management
- Epic hierarchy with features and user stories
- Priority ordering by business value
- Story point estimation examples
- Ready vs. unready items

#### Sprint Planning
- Capacity planning based on team velocity
- Realistic workload distribution
- Sprint goals and success criteria
- Risk identification

#### Daily Operations
- Daily standup patterns
- Status updates in issues
- Blocker identification and resolution
- Quick decision tracking

#### Sprint Closure
- Completion summary and metrics
- Velocity calculation
- Sprint review findings
- Retrospective action items

## Configuration

Customize the demo data volume in `config.py`:

```python
DEMO_USER_COUNT = 30          # Number of users to create
DEMO_PROJECT_COUNT = 20        # Number of projects
DEMO_ISSUES_PER_PROJECT = 50   # Issues per project
DEMO_SPRINTS_PER_PROJECT = 4   # Sprints per project
DEMO_COMMENTS_COUNT = 500      # Total comments/activity
```

## Troubleshooting

### Authentication Failed

```
Error: Could not authenticate with Plane CE
```

**Solution:** Verify credentials in `.env` file and ensure Plane CE is running.

```bash
# Check Plane CE API health
curl https://app.local.test/api/health/
```

### Connection Refused

```
Error: Connection refused to Plane CE API
```

**Solution:** Check if Plane CE is running:

```bash
# Check container status
./scripts/check.sh

# Start services if needed
./scripts/up.sh
```

### Partial Seeding

If the script stops midway, it's safe to run again - it skips existing items.

## Next Steps

After seeding, you can:

1. **Explore the Reference Project** - Navigate to the "Agile Reference Project" to see best practices
2. **Run Reports** - Generate sprint reports and analytics
3. **Test Workflows** - Create new issues, update sprints, add comments
4. **Integrate AI** - Connect AI service for suggestions and automation

## API Reference

For direct API calls, see `api_client.py` for available operations:

- `create_user()` - Create new user
- `create_workspace()` - Create workspace
- `create_project()` - Create project
- `create_cycle()` - Create sprint
- `create_issue()` - Create issue/task
- `add_project_member()` - Add user to project

## Legacy NocoBase Data

Previous demo data for NocoBase is documented in `../seed_demo/README.md` for reference and migration purposes.
