"""Compatibility shim for the built-in memory provider.

The built-in MEMORY.md / USER.md store is not a networked memory backend, but
older tests and initialization paths still expect a ``BuiltinMemoryProvider``
object that can be registered with ``MemoryManager``. Keep this lightweight
adapter so the manager can thread common kwargs through alongside plugin
providers without special cases.
"""

from __future__ import annotations

from typing import Any, Dict, List

from agent.memory_provider import MemoryProvider


class BuiltinMemoryProvider(MemoryProvider):
    """No-op provider representing Hermes' always-on built-in memory."""

    def __init__(self) -> None:
        self._init_kwargs: Dict[str, Any] = {}
        self._init_session_id: str | None = None

    @property
    def name(self) -> str:
        return "builtin"

    def is_available(self) -> bool:
        return True

    def initialize(self, session_id: str, **kwargs) -> None:
        self._init_session_id = session_id
        self._init_kwargs = dict(kwargs)

    def get_tool_schemas(self) -> List[Dict[str, Any]]:
        return []
