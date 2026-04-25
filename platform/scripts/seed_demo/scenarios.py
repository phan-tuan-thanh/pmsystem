"""
scenarios.py — Định nghĩa 5 kịch bản Agile và logic phân phối xác suất
"""
import random

# ── Định nghĩa kịch bản ───────────────────────────────────────────────────────
SCENARIOS = {
    "happy_path": {
        "label":        "Thành Công",
        "status_dist":  {"completed": 0.85, "in_progress": 0.10, "blocked": 0.05},
        "bug_ratio":    0.08,
        "spike_ratio":  0.03,
        "spillover":    0.05,
        "velocity_trend": "increasing",   # tăng đều
    },
    "bug_heavy": {
        "label":        "Nhiều Lỗi",
        "status_dist":  {"completed": 0.62, "in_review": 0.15, "in_progress": 0.13, "blocked": 0.10},
        "bug_ratio":    0.30,
        "spike_ratio":  0.04,
        "spillover":    0.12,
        "velocity_trend": "dip_then_recover",
    },
    "delay": {
        "label":        "Chậm Trễ",
        "status_dist":  {"completed": 0.58, "spillover": 0.27, "in_progress": 0.15},
        "bug_ratio":    0.10,
        "spike_ratio":  0.02,
        "spillover":    0.27,
        "velocity_trend": "volatile",
    },
    "priority_shift": {
        "label":        "Đổi Ưu Tiên",
        "status_dist":  {"completed": 0.68, "blocked": 0.18, "in_progress": 0.14},
        "bug_ratio":    0.10,
        "spike_ratio":  0.12,
        "spillover":    0.10,
        "velocity_trend": "unstable",
    },
    "resource_overload": {
        "label":        "Quá Tải Nguồn Lực",
        "status_dist":  {"completed": 0.65, "in_progress": 0.22, "blocked": 0.13},
        "bug_ratio":    0.12,
        "spike_ratio":  0.05,
        "spillover":    0.15,
        "velocity_trend": "slow",
    },
}

# ── Status tiếng Việt → giá trị lưu DB ───────────────────────────────────────
STATUS_MAP = {
    "completed":   "completed",
    "in_progress": "in_progress",
    "in_review":   "in_review",
    "blocked":     "blocked",
    "spillover":   "in_progress",   # spillover vẫn là in_progress nhưng flag is_spillover=True
    "backlog":     "backlog",
    "todo":        "todo",
}

BLOCKED_REASONS = {
    "happy_path":       ["Chờ xác nhận thiết kế", "Phụ thuộc task khác"],
    "bug_heavy":        ["Lỗi chặn không thể test", "Môi trường test bị lỗi", "QA trả lại do sai spec"],
    "delay":            ["Tài nguyên chưa sẵn sàng", "Yêu cầu chưa rõ ràng", "Task phụ thuộc chưa xong"],
    "priority_shift":   ["Chờ xác nhận từ PO", "Yêu cầu thay đổi giữa chừng", "Tạm hoãn theo quyết định stakeholder"],
    "resource_overload":["Dev đang bận dự án khác", "Senior đang review PR khác", "Chờ code review từ lead"],
}

TASK_TYPES = {
    "story": "story",
    "bug":   "bug",
    "task":  "task",
    "spike": "spike",
}

PRIORITIES = ["critical", "high", "medium", "low"]
STORY_POINTS = [1, 2, 3, 5, 8, 13]


def pick_status(scenario_key: str, sprint_status: str) -> tuple:
    """
    Trả về (status, is_spillover, blocked_reason).
    - sprint_status: 'completed' | 'active' | 'planning'
    """
    sc = SCENARIOS[scenario_key]
    dist = sc["status_dist"].copy()

    # Sprint đã hoàn thành → thiên về completed
    if sprint_status == "completed":
        dist = {k: v * (1.5 if k == "completed" else 0.5) for k, v in dist.items()}
    # Sprint đang chạy → không có completed quá nhiều
    elif sprint_status == "active":
        dist = {k: v * (0.6 if k == "completed" else 1.2) for k, v in dist.items()}
    # Sprint chưa bắt đầu → backlog
    elif sprint_status == "planning":
        return "backlog", False, None

    # Chuẩn hóa
    total = sum(dist.values())
    dist = {k: v / total for k, v in dist.items()}

    r = random.random()
    cumulative = 0.0
    chosen = "in_progress"
    for status, prob in dist.items():
        cumulative += prob
        if r <= cumulative:
            chosen = status
            break

    is_spillover = (chosen == "spillover") or (
        sprint_status == "completed" and random.random() < sc["spillover"]
    )

    blocked_reason = None
    if chosen == "blocked":
        reasons = BLOCKED_REASONS.get(scenario_key, ["Chờ xử lý"])
        blocked_reason = random.choice(reasons)

    return STATUS_MAP.get(chosen, "in_progress"), is_spillover, blocked_reason


def pick_task_type(scenario_key: str) -> str:
    sc = SCENARIOS[scenario_key]
    r = random.random()
    if r < sc["bug_ratio"]:
        return "bug"
    if r < sc["bug_ratio"] + sc["spike_ratio"]:
        return "spike"
    if random.random() < 0.3:
        return "task"
    return "story"


def pick_priority(task_type: str, scenario_key: str) -> str:
    if task_type == "bug":
        return random.choices(PRIORITIES, weights=[0.30, 0.40, 0.20, 0.10])[0]
    if scenario_key == "priority_shift" and random.random() < 0.15:
        return "critical"
    return random.choices(PRIORITIES, weights=[0.10, 0.25, 0.45, 0.20])[0]


def pick_story_points(task_type: str) -> int:
    if task_type == "spike":
        return random.choice([3, 5, 8])
    if task_type == "bug":
        return random.choice([1, 2, 3])
    return random.choices(STORY_POINTS, weights=[0.10, 0.20, 0.30, 0.25, 0.10, 0.05])[0]


def calc_velocity(sprint_index: int, total_sprints: int, scenario_key: str) -> int:
    """Tính velocity (story points) theo kịch bản."""
    base = 30
    trend = SCENARIOS[scenario_key]["velocity_trend"]
    progress = sprint_index / max(total_sprints - 1, 1)

    if trend == "increasing":
        v = base + int(progress * 20) + random.randint(-3, 3)
    elif trend == "dip_then_recover":
        dip = abs(progress - 0.5)
        v = base - int((0.5 - dip) * 20) + random.randint(-5, 5)
    elif trend == "volatile":
        v = base + random.randint(-15, 15)
    elif trend == "unstable":
        v = base + random.choices([-10, 0, 10], weights=[0.3, 0.4, 0.3])[0] + random.randint(-5, 5)
    else:  # slow
        v = base - 8 + random.randint(-5, 5)

    return max(v, 10)
