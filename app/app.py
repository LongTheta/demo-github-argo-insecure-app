"""Minimal Flask app for demo-github-argo-insecure-app."""

from flask import Flask

app = Flask(__name__)


@app.route("/")
def index():
    """Health check and info endpoint."""
    return {"status": "ok", "app": "demo-github-argo-insecure-app"}


@app.route("/health")
def health():
    """Health check for Kubernetes probes."""
    return {"status": "healthy"}, 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
