"""
Plane CE API Client for seeding demo data
"""
import requests
import json
from typing import Dict, List, Optional, Any
from config import PLANE_API_BASE_URL, PLANE_ADMIN_EMAIL, PLANE_ADMIN_PASSWORD

class PlaneAPIClient:
    def __init__(self, base_url: str = PLANE_API_BASE_URL, email: str = PLANE_ADMIN_EMAIL, password: str = PLANE_ADMIN_PASSWORD):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.token = None
        self.authenticate(email, password)

    def authenticate(self, email: str, password: str):
        """Authenticate with Plane CE API"""
        auth_url = f"{self.base_url}/auth/sign-in/"
        payload = {
            "email": email,
            "password": password
        }
        response = self.session.post(auth_url, json=payload)
        response.raise_for_status()
        data = response.json()
        self.token = data.get('access_token') or data.get('token')
        self.session.headers.update({
            "Authorization": f"Bearer {self.token}",
            "Content-Type": "application/json"
        })

    def _request(self, method: str, endpoint: str, **kwargs) -> Dict[str, Any]:
        """Make API request"""
        url = f"{self.base_url}{endpoint}"
        response = self.session.request(method, url, **kwargs)
        response.raise_for_status()
        return response.json() if response.content else {}

    def get(self, endpoint: str) -> Dict[str, Any]:
        """GET request"""
        return self._request("GET", endpoint)

    def post(self, endpoint: str, data: Dict[str, Any]) -> Dict[str, Any]:
        """POST request"""
        return self._request("POST", endpoint, json=data)

    def patch(self, endpoint: str, data: Dict[str, Any]) -> Dict[str, Any]:
        """PATCH request"""
        return self._request("PATCH", endpoint, json=data)

    def put(self, endpoint: str, data: Dict[str, Any]) -> Dict[str, Any]:
        """PUT request"""
        return self._request("PUT", endpoint, json=data)

    def delete(self, endpoint: str) -> Dict[str, Any]:
        """DELETE request"""
        return self._request("DELETE", endpoint)

    # User operations
    def create_user(self, email: str, first_name: str, last_name: str, password: str = None) -> Dict[str, Any]:
        """Create a new user"""
        data = {
            "email": email,
            "first_name": first_name,
            "last_name": last_name,
        }
        if password:
            data["password"] = password
        return self.post("/auth/sign-up/", data)

    def list_users(self) -> List[Dict[str, Any]]:
        """List all users"""
        response = self.get("/users/")
        return response.get('results', []) if isinstance(response, dict) else response

    # Workspace operations
    def create_workspace(self, name: str, slug: str, description: str = "") -> Dict[str, Any]:
        """Create a new workspace"""
        data = {
            "name": name,
            "slug": slug,
            "description": description
        }
        return self.post("/workspaces/", data)

    def list_workspaces(self) -> List[Dict[str, Any]]:
        """List all workspaces"""
        response = self.get("/workspaces/")
        return response.get('results', []) if isinstance(response, dict) else response

    # Project operations
    def create_project(self, workspace_id: str, name: str, identifier: str, description: str = "") -> Dict[str, Any]:
        """Create a new project"""
        data = {
            "name": name,
            "identifier": identifier,
            "description": description
        }
        return self.post(f"/workspaces/{workspace_id}/projects/", data)

    def list_projects(self, workspace_id: str) -> List[Dict[str, Any]]:
        """List projects in workspace"""
        response = self.get(f"/workspaces/{workspace_id}/projects/")
        return response.get('results', []) if isinstance(response, dict) else response

    # Issue operations
    def create_issue(self, workspace_id: str, project_id: str, name: str, description: str = "", priority: str = "medium") -> Dict[str, Any]:
        """Create a new issue"""
        data = {
            "name": name,
            "description": description,
            "priority": priority,
            "state": "backlog"
        }
        return self.post(f"/workspaces/{workspace_id}/projects/{project_id}/issues/", data)

    def list_issues(self, workspace_id: str, project_id: str) -> List[Dict[str, Any]]:
        """List issues in project"""
        response = self.get(f"/workspaces/{workspace_id}/projects/{project_id}/issues/")
        return response.get('results', []) if isinstance(response, dict) else response

    # Cycle (Sprint) operations
    def create_cycle(self, workspace_id: str, project_id: str, name: str, start_date: str, end_date: str) -> Dict[str, Any]:
        """Create a new cycle (sprint)"""
        data = {
            "name": name,
            "start_date": start_date,
            "end_date": end_date,
            "status": "planning"
        }
        return self.post(f"/workspaces/{workspace_id}/projects/{project_id}/cycles/", data)

    def list_cycles(self, workspace_id: str, project_id: str) -> List[Dict[str, Any]]:
        """List cycles in project"""
        response = self.get(f"/workspaces/{workspace_id}/projects/{project_id}/cycles/")
        return response.get('results', []) if isinstance(response, dict) else response

    # Module operations
    def create_module(self, workspace_id: str, project_id: str, name: str, description: str = "") -> Dict[str, Any]:
        """Create a new module"""
        data = {
            "name": name,
            "description": description
        }
        return self.post(f"/workspaces/{workspace_id}/projects/{project_id}/modules/", data)

    def list_modules(self, workspace_id: str, project_id: str) -> List[Dict[str, Any]]:
        """List modules in project"""
        response = self.get(f"/workspaces/{workspace_id}/projects/{project_id}/modules/")
        return response.get('results', []) if isinstance(response, dict) else response

    # Member operations
    def add_project_member(self, workspace_id: str, project_id: str, user_id: str, role: str = "member") -> Dict[str, Any]:
        """Add member to project"""
        data = {
            "member": user_id,
            "role": role
        }
        return self.post(f"/workspaces/{workspace_id}/projects/{project_id}/members/", data)

    def list_project_members(self, workspace_id: str, project_id: str) -> List[Dict[str, Any]]:
        """List project members"""
        response = self.get(f"/workspaces/{workspace_id}/projects/{project_id}/members/")
        return response.get('results', []) if isinstance(response, dict) else response
