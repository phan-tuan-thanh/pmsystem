"""
Configuration for Plane CE API and database connections
"""
import os
from dotenv import load_dotenv

# Load environment variables from the parent directory (.env file)
env_path = os.path.join(os.path.dirname(__file__), '../../.env')
load_dotenv(env_path)

# Plane CE API Configuration
PLANE_API_BASE_URL = os.getenv('PLANE_API_BASE_URL', 'https://app.local.test/api')
PLANE_ADMIN_EMAIL = os.getenv('PLANE_ADMIN_EMAIL', 'admin@plane.local')
PLANE_ADMIN_PASSWORD = os.getenv('PLANE_ADMIN_PASSWORD', 'PlaneAdmin123!')

# Database Configuration (for direct seeding if needed)
POSTGRES_HOST = os.getenv('POSTGRES_HOST', 'localhost')
POSTGRES_PORT = int(os.getenv('POSTGRES_PORT', 5432))
POSTGRES_USER = os.getenv('POSTGRES_USER', 'postgres')
POSTGRES_PASSWORD = os.getenv('POSTGRES_PASSWORD', 'StrongPostgresPassword123')
POSTGRES_DB = os.getenv('POSTGRES_DB', 'postgres')

PLANE_POSTGRES_DB = os.getenv('PLANE_POSTGRES_DB', 'plane_ce')
PLANE_POSTGRES_USER = os.getenv('PLANE_POSTGRES_USER', 'plane_ce')
PLANE_POSTGRES_PASSWORD = os.getenv('PLANE_POSTGRES_PASSWORD', 'PlanePass123!')

# Seed Configuration
DEMO_USER_COUNT = 30
DEMO_PROJECT_COUNT = 20
DEMO_ISSUES_PER_PROJECT = 50
DEMO_SPRINTS_PER_PROJECT = 4
DEMO_COMMENTS_COUNT = 500

# Demo Data Scenarios
DEMO_SCENARIOS = {
    'agile_team': {
        'name': 'Agile Reference Project',
        'description': 'A comprehensive Agile project demonstrating best practices',
        'roles': [
            'Product Owner',
            'Scrum Master',
            'Developer',
            'QA Engineer',
            'Business Analyst',
            'UX Designer',
            'Stakeholder'
        ]
    }
}
