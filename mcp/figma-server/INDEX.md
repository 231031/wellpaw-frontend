# Figma MCP Configuration

This directory contains the Figma Model Context Protocol (MCP) server for the WellPaw Flutter project.

## Files

- `server.js` - MCP server implementation
- `package.json` - Dependencies and scripts
- `README.md` - Full documentation
- `SETUP.md` - Quick setup guide
- `.env` - Environment variables (create this file)

## Quick Start

```bash
# 1. Install dependencies
npm install

# 2. Create .env with your Figma token and file key
echo "FIGMA_API_KEY=your_token_here" > .env
echo "FIGMA_FILE_KEY=your_file_key_here" >> .env

# 3. Start the server
npm start
```

## Available Tools

1. **get_file_nodes** - Retrieve specific design elements
2. **get_file_components** - Get all components from design system
3. **get_component_sets** - Extract component variants
4. **get_file_styles** - Get design tokens (colors, typography, effects)
5. **export_component** - Export as SVG, PNG, or PDF
6. **get_page_hierarchy** - Navigate page structure

## Environment Setup

Get your credentials:
1. **Figma Token**: https://www.figma.com/settings/account → "Personal access tokens"
2. **File Key**: Open your Figma file → copy key from URL after `/file/`

## Integration

Use with Claude agents:
- `@frontend-developer` - Extract design and build UI
- `@code-reviewer` - Validate Flutter implementation matches design
- Any agent can access Figma data via MCP tools

## Documentation

- See `README.md` for detailed tool documentation
- See `SETUP.md` for step-by-step setup
- Check Figma API docs: https://www.figma.com/developers/api

## Security

⚠️ **Important**: Never commit `.env` file

Add to `.gitignore`:
```
mcp/figma-server/.env
```

## Support

For API issues, check [Figma Developers](https://www.figma.com/developers)
