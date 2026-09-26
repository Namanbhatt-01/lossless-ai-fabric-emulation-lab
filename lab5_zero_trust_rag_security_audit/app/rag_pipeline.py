"""
Hardened Retrieval-Augmented Generation (RAG) Query Service with Chunk-Level RBAC
"""

from security_middleware import sanitize_user_input, enforce_rbac_vector_filter, SecurityException

class SecureRAGPipeline:
    def __init__(self):
        # Mock In-Memory Vector Store for testing and offline assertion
        self.vector_store = [
            {"id": "doc1", "text": "Public API Documentation", "tenant_id": "tenant_a", "clearance": "public"},
            {"id": "doc2", "text": "Internal Switch Architecture Blueprint", "tenant_id": "tenant_a", "clearance": "internal"},
            {"id": "doc3", "text": "Secret Cloud API Master Keys", "tenant_id": "tenant_a", "clearance": "secret"},
            {"id": "doc4", "text": "Tenant B Proprietary Weights", "tenant_id": "tenant_b", "clearance": "internal"}
        ]

    def query_rag(self, query: str, tenant_id: str, user_role: str):
        # Step 1: Input Sanitization
        sanitized_query = sanitize_user_input(query)
        
        # Step 2: RBAC Filter Resolution
        rbac_policy = enforce_rbac_vector_filter(tenant_id, user_role)
        
        # Step 3: Vector Search with Strict Tenant & Role Metadata Filter
        matched_chunks = []
        for chunk in self.vector_store:
            if chunk["tenant_id"] == rbac_policy["tenant_id"] and chunk["clearance"] in rbac_policy["clearance_level"]:
                matched_chunks.append(chunk)
                
        return {
            "query": sanitized_query,
            "status": "success",
            "retrieved_chunks": matched_chunks
        }
