"""
setup_ui.py — Tạo menu + table view pages cho 4 collections chính
Sử dụng NocoBase uiSchemas API để tạo giao diện tự động.
"""
import uuid
from config import APIClient

# ── Tạo UID ngắn kiểu NocoBase ────────────────────────────────────────────────
def uid() -> str:
    return uuid.uuid4().hex[:11]

# ── Cấu hình 4 pages sẽ tạo ───────────────────────────────────────────────────
PAGES = [
    {"title": "Dự Án",      "icon": "ProjectOutlined",      "collection": "projects"},
    {"title": "Công Việc",  "icon": "CheckSquareOutlined",  "collection": "tasks"},
    {"title": "Sprints",    "icon": "CalendarOutlined",     "collection": "sprints"},
    {"title": "Thành Viên", "icon": "TeamOutlined",         "collection": "members"},
]


def _menu_schema(page_title: str, icon: str) -> tuple:
    """Trả về (menu_uid, schema) cho 1 menu item."""
    m_uid = uid()
    p_uid = uid()
    schema = {
        "x-uid":       m_uid,
        "type":        "void",
        "title":       page_title,
        "x-component": "Menu.Item",
        "x-component-props": {"icon": icon},
        "x-initializer": "MenuItemInitializers",
        "properties": {
            "page": {
                "x-uid":       p_uid,
                "type":        "void",
                "x-component": "Page",
                "x-async":     True,
                "properties":  {},
            }
        },
    }
    return m_uid, p_uid, schema


def _table_block_schema(collection: str) -> dict:
    """Schema cho block bảng dữ liệu đơn giản."""
    return {
        "x-uid":      uid(),
        "type":       "void",
        "x-decorator": "TableBlockProvider",
        "x-decorator-props": {
            "collection": collection,
            "resource":   collection,
            "action":     "list",
            "params":     {"pageSize": 20, "sort": ["-createdAt"]},
            "rowKey":     "id",
            "showIndex":  True,
            "dragSort":   False,
        },
        "x-component": "CardItem",
        "x-component-props": {"title": ""},
        "x-filter-targets": [],
        "properties": {
            "actions": {
                "type":        "void",
                "x-initializer": "TableActionInitializers",
                "x-component": "ActionBar",
                "x-component-props": {"style": {"marginBottom": 16}},
                "properties":  {},
            },
            "table": {
                "type":        "array",
                "x-initializer": "TableColumnInitializers",
                "x-component": "TableV2",
                "x-use-component-props": "useTableBlockProps",
                "x-component-props": {"rowKey": "id", "rowSelection": {"type": "checkbox"}},
                "properties":  {},
            },
        },
    }


def get_admin_menu_uid(client: APIClient) -> str:
    """Lấy UID của admin menu từ NocoBase."""
    try:
        result = client.get("/api/uiSchemas/nocobase-admin-menu")
        uid_val = result.get("data", {}).get("x-uid", "nocobase-admin-menu")
        return uid_val
    except Exception:
        return "nocobase-admin-menu"


def create_page(client: APIClient, page_cfg: dict, menu_uid_key: str) -> bool:
    title      = page_cfg["title"]
    collection = page_cfg["collection"]
    icon       = page_cfg["icon"]

    m_uid, p_uid, menu_schema = _menu_schema(title, icon)

    # Bước 1: Tạo menu item
    try:
        client.post("/api/uiSchemas:insertAdjacent", {
            "associatedKey": menu_uid_key,
            "position":      "beforeEnd",
            "schema":        menu_schema,
        })
        print(f"  ✅ Menu '{title}' (uid: {m_uid})")
    except Exception as e:
        print(f"  ❌ Menu '{title}': {e}")
        return False

    # Bước 2: Thêm table block vào page
    try:
        client.post("/api/uiSchemas:insertAdjacent", {
            "associatedKey": p_uid,
            "position":      "beforeEnd",
            "schema":        _table_block_schema(collection),
        })
        print(f"     + Table block cho '{collection}'")
    except Exception as e:
        print(f"     ⚠️  Table block: {e} (menu đã tạo, cần thêm block thủ công)")

    return True


def seed(client: APIClient) -> None:
    print("\n🖥  Thiết lập giao diện (UI Pages)...\n")

    menu_key = get_admin_menu_uid(client)
    print(f"  Admin menu key: {menu_key}\n")

    success = 0
    for page in PAGES:
        if create_page(client, page, menu_key):
            success += 1

    print(f"\n✅ Đã tạo {success}/{len(PAGES)} pages.\n")
    if success < len(PAGES):
        print("  💡 Các page còn lại cần tạo thủ công trong NocoBase UI.\n")


if __name__ == "__main__":
    seed(APIClient())
