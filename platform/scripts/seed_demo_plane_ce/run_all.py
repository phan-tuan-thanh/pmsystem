#!/usr/bin/env python3
"""
Main script to seed demo data for Plane CE
Usage: python run_all.py [--reset]
"""
import sys
import os
import argparse
import logging
from datetime import datetime, timedelta
from faker import Faker
from api_client import PlaneAPIClient
from config import (
    DEMO_USER_COUNT,
    DEMO_PROJECT_COUNT,
    DEMO_ISSUES_PER_PROJECT,
    DEMO_SPRINTS_PER_PROJECT,
    DEMO_COMMENTS_COUNT,
    DEMO_SCENARIOS
)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

fake = Faker()

def create_demo_users(client: PlaneAPIClient, count: int = DEMO_USER_COUNT) -> list:
    """Create demo users"""
    logger.info(f"Creating {count} demo users...")
    users = []

    try:
        existing_users = client.list_users()
        logger.info(f"Found {len(existing_users)} existing users")
    except Exception as e:
        logger.warning(f"Could not fetch existing users: {e}")
        existing_users = []

    # User roles for the demo Agile project
    roles = ['Product Owner', 'Scrum Master', 'Developer', 'QA Engineer', 'Business Analyst', 'UX Designer', 'Stakeholder']

    for i, role in enumerate(roles * (count // len(roles) + 1))[:count]:
        email = f"{role.lower().replace(' ', '_')}{i % len(roles)}@plane.local"

        # Check if user already exists
        if any(u.get('email') == email for u in existing_users):
            logger.info(f"User {email} already exists, skipping")
            continue

        try:
            user = client.create_user(
                email=email,
                first_name=fake.first_name(),
                last_name=fake.last_name()
            )
            users.append(user)
            logger.info(f"Created user: {email}")
        except Exception as e:
            logger.error(f"Error creating user {email}: {e}")

    logger.info(f"Successfully created {len(users)} new demo users")
    return users

def create_demo_projects(client: PlaneAPIClient, workspace_id: str, count: int = DEMO_PROJECT_COUNT) -> list:
    """Create demo projects"""
    logger.info(f"Creating {count} demo projects in workspace {workspace_id}...")
    projects = []

    project_templates = [
        {"name": "E-Commerce Platform", "desc": "Building a modern e-commerce platform"},
        {"name": "Mobile App", "desc": "Cross-platform mobile application"},
        {"name": "API Gateway", "desc": "Microservices API gateway"},
        {"name": "Analytics Dashboard", "desc": "Real-time analytics platform"},
        {"name": "Content Management", "desc": "Headless CMS solution"},
        {"name": "Chat Application", "desc": "Real-time messaging platform"},
        {"name": "Data Pipeline", "desc": "ETL and data processing"},
        {"name": "DevOps Platform", "desc": "Infrastructure automation"},
        {"name": "Customer Portal", "desc": "Self-service customer platform"},
        {"name": "Admin Dashboard", "desc": "Administrative management system"},
    ]

    for i in range(count):
        template = project_templates[i % len(project_templates)]
        project_name = f"{template['name']} {i//len(project_templates) + 1}".strip()
        identifier = f"PROJ{i+1:03d}"

        try:
            project = client.create_project(
                workspace_id=workspace_id,
                name=project_name,
                identifier=identifier,
                description=template['desc']
            )
            projects.append(project)
            logger.info(f"Created project: {project_name} ({identifier})")
        except Exception as e:
            logger.error(f"Error creating project {project_name}: {e}")

    logger.info(f"Successfully created {len(projects)} demo projects")
    return projects

def create_demo_sprints(client: PlaneAPIClient, workspace_id: str, project_id: str, count: int = DEMO_SPRINTS_PER_PROJECT) -> list:
    """Create demo sprints (cycles)"""
    logger.info(f"Creating {count} demo sprints for project {project_id}...")
    sprints = []

    start_date = datetime.now()
    for i in range(count):
        sprint_name = f"Sprint {i+1}"
        sprint_start = start_date + timedelta(weeks=i*2)
        sprint_end = sprint_start + timedelta(weeks=2)

        try:
            sprint = client.create_cycle(
                workspace_id=workspace_id,
                project_id=project_id,
                name=sprint_name,
                start_date=sprint_start.date().isoformat(),
                end_date=sprint_end.date().isoformat()
            )
            sprints.append(sprint)
            logger.info(f"Created sprint: {sprint_name}")
        except Exception as e:
            logger.error(f"Error creating sprint {sprint_name}: {e}")

    logger.info(f"Successfully created {len(sprints)} demo sprints")
    return sprints

def create_demo_issues(client: PlaneAPIClient, workspace_id: str, project_id: str, count: int = DEMO_ISSUES_PER_PROJECT) -> list:
    """Create demo issues"""
    logger.info(f"Creating {count} demo issues for project {project_id}...")
    issues = []

    issue_templates = [
        "Implement user authentication flow",
        "Create dashboard layout",
        "Setup database migrations",
        "Write API documentation",
        "Refactor legacy code",
        "Add unit tests",
        "Optimize database queries",
        "Fix critical bug",
        "Design UI mockups",
        "Setup CI/CD pipeline",
    ]

    priorities = ["urgent", "high", "medium", "low"]

    for i in range(count):
        template = issue_templates[i % len(issue_templates)]
        issue_name = f"{template} {i // len(issue_templates) + 1}".strip()
        priority = priorities[i % len(priorities)]

        try:
            issue = client.create_issue(
                workspace_id=workspace_id,
                project_id=project_id,
                name=issue_name,
                description=f"This is a demo issue: {fake.paragraph()}",
                priority=priority
            )
            issues.append(issue)
            if (i + 1) % 10 == 0:
                logger.info(f"Created {i+1} issues...")
        except Exception as e:
            logger.error(f"Error creating issue {issue_name}: {e}")

    logger.info(f"Successfully created {len(issues)} demo issues")
    return issues

def seed_all_data(client: PlaneAPIClient, reset: bool = False):
    """Seed all demo data"""
    logger.info("Starting Plane CE demo data seeding...")

    # Get or create workspace
    try:
        workspaces = client.list_workspaces()
        if workspaces:
            workspace = workspaces[0]
            workspace_id = workspace.get('id') or workspace.get('slug')
            logger.info(f"Using existing workspace: {workspace.get('name')} ({workspace_id})")
        else:
            raise Exception("No workspace found")
    except Exception as e:
        logger.error(f"Error getting workspace: {e}")
        logger.info("Creating default workspace...")
        workspace = client.create_workspace(
            name="Default Workspace",
            slug="default",
            description="Default workspace for Plane CE"
        )
        workspace_id = workspace.get('id') or workspace.get('slug')

    # Create users
    logger.info("\n--- Creating Demo Users ---")
    users = create_demo_users(client, DEMO_USER_COUNT)

    # Create projects
    logger.info("\n--- Creating Demo Projects ---")
    projects = create_demo_projects(client, workspace_id, DEMO_PROJECT_COUNT)

    # Create sprints and issues for each project
    logger.info("\n--- Creating Demo Sprints and Issues ---")
    for project in projects[:5]:  # Limit to first 5 projects for demo
        project_id = project.get('id') or project.get('slug')
        sprints = create_demo_sprints(client, workspace_id, project_id, DEMO_SPRINTS_PER_PROJECT)
        issues = create_demo_issues(client, workspace_id, project_id, DEMO_ISSUES_PER_PROJECT)

    logger.info("\n✅ Demo data seeding completed successfully!")
    logger.info(f"Created {len(users)} users, {len(projects)} projects")

def main():
    parser = argparse.ArgumentParser(description="Seed demo data for Plane CE")
    parser.add_argument("--reset", action="store_true", help="Reset and recreate all demo data")
    args = parser.parse_args()

    try:
        logger.info("Connecting to Plane CE API...")
        client = PlaneAPIClient()
        logger.info("Successfully authenticated with Plane CE API")

        seed_all_data(client, reset=args.reset)

    except Exception as e:
        logger.error(f"Fatal error during seeding: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
