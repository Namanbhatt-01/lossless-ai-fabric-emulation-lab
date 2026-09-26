"""
Zero-Trust RAG Security Middleware: Input Sanitization, Token Limits, and RBAC Filter
"""

import re

FORBIDDEN_PROMPT_PATTERNS = [
    r"(?i)ignore\s+previous\s+instructions",
    r"(?i)system\s+override",
    r"(?i)reveal\s+system\s+prompt",
    r"(?i)bypass\s+filter",
    r"(?i)dan\s+mode"
]

class SecurityException(Exception):
    pass

def sanitize_user_input(prompt: str) -> str:
    """
    Scans input for adversarial prompt injection patterns.
    """
    if len(prompt) > 2000:
        raise SecurityException("Payload size exceeds permissible token limit (max 2000 chars)")
        
    for pattern in FORBIDDEN_PROMPT_PATTERNS:
        if re.search(pattern, prompt):
            raise SecurityException(f"Prompt rejected: Adversarial injection pattern matched: {pattern}")
            
    return prompt.strip()

def enforce_rbac_vector_filter(tenant_id: str, user_role: str) -> dict:
    """
    Enforces chunk-level vector metadata access control.
    """
    if user_role not in ["admin", "engineer", "guest"]:
        raise SecurityException("Invalid role permissions")
        
    allowed_clearances = {
        "admin": ["public", "internal", "confidential", "secret"],
        "engineer": ["public", "internal", "confidential"],
        "guest": ["public"]
    }
    
    return {
        "tenant_id": tenant_id,
        "clearance_level": allowed_clearances[user_role]
    }
