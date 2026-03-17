"""Minimal test for demo app."""

def test_app_import():
    """Verify app module can be imported."""
    from app import app
    assert app is not None
