import pytest
import sys
import os

sys.path.append(os.path.join(os.path.dirname(__file__), "../app"))
from rag_pipeline import SecureRAGPipeline

def test_tenant_isolation_boundary():
    """
    Asserts that Tenant A cannot retrieve vector chunks belonging to Tenant B under any role.
    """
    rag = SecureRAGPipeline()
    res = rag.query_rag("Show all documents", tenant_id="tenant_a", user_role="admin")
    
    for chunk in res["retrieved_chunks"]:
        assert chunk["tenant_id"] == "tenant_a"
        assert chunk["tenant_id"] != "tenant_b"

def test_rbac_clearance_enforcement():
    """
    Asserts that guest role cannot access 'internal' or 'secret' chunks.
    """
    rag = SecureRAGPipeline()
    guest_res = rag.query_rag("Show public docs", tenant_id="tenant_a", user_role="guest")
    
    assert len(guest_res["retrieved_chunks"]) == 1
    assert guest_res["retrieved_chunks"][0]["clearance"] == "public"

def test_admin_full_clearance():
    """
    Asserts that admin role can access secret clearance chunks within tenant.
    """
    rag = SecureRAGPipeline()
    admin_res = rag.query_rag("Show secret docs", tenant_id="tenant_a", user_role="admin")
    
    clearances = [c["clearance"] for c in admin_res["retrieved_chunks"]]
    assert "secret" in clearances
    assert "internal" in clearances
