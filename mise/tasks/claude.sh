#!/usr/bin/env bash
# Converge Claude Code MCP servers and active plugin marketplaces.
set -euo pipefail

command -v claude > /dev/null 2>&1 || exit 0

claude mcp get deepwiki > /dev/null 2>&1 ||
    claude mcp add -s user -t http deepwiki https://mcp.deepwiki.com/mcp
claude mcp get codex > /dev/null 2>&1 ||
    claude mcp add -s user --transport stdio codex -- codex mcp-server

claude plugin marketplace add anthropics/claude-for-legal || true
for plugin in commercial-legal corporate-legal privacy-legal product-legal employment-legal \
    ai-governance-legal regulatory-legal ip-legal litigation-legal legal-clinic \
    law-student legal-builder-hub cocounsel-legal; do
    claude plugin install "$plugin@claude-for-legal" || true
done

claude plugin marketplace add anthropics/knowledge-work-plugins || true
for plugin in productivity sales customer-support product-management marketing legal \
    finance data enterprise-search bio-research cowork-plugin-management; do
    claude plugin install "$plugin@knowledge-work-plugins" || true
done
