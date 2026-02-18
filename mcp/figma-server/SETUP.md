# WellPaw Figma MCP Server - Setup Guide

## Quick Start (5 minutes)

### Step 1: Get Your Figma Token

1. Visit https://www.figma.com/settings/account
2. Find "Personal access tokens"
3. Click "Create a new token"
4. Copy and save the token (you'll only see it once)

### Step 2: Get Your File Key

Open your Figma design file in the browser:
- URL looks like: `https://www.figma.com/file/{FILE_KEY}/project-name`
- Copy everything between `/file/` and the next `/`

### Step 3: Create Environment File

In `mcp/figma-server/`, copy `.env.example` to `.env`:

```env
FIGMA_API_KEY=figd_abc123...
FIGMA_FILE_KEY=xyz789...
```

### Step 4: Install & Run

```bash
cd mcp/figma-server
npm install
npm start
```

You should see: `Figma MCP Server running on stdio`

## Using with Claude

Once running, Claude can:

```
@frontend-developer
Extract the color palette and typography from our Figma design system
using the Figma MCP. Then create a Flutter ThemeData with Material ColorScheme.
```

```
@code-reviewer
Get all components from Figma and compare them with our Flutter widgets.
Identify any inconsistencies between design and implementation.
```

## Common Tasks

### Get Design Tokens

```
Use the Figma MCP to extract:
1. All colors (get_file_styles for FILL type)
2. Typography settings (TEXT type styles)
3. Spacing/grid systems (GRID type)
Then generate a Flutter tokens file.
```

### Map Components to Flutter

```
1. Get all Figma components (get_file_components)
2. For each component, extract properties
3. Create Flutter widget equivalents
4. Document the mapping
```

### Export Component Icons

```
Export all icon components from Figma as SVG:
1. Find icon component IDs
2. Use export_component with format: "svg"
3. Save to assets/icons/
```

### Audit Design System

```
Compare Figma design system with Flutter implementation:
1. Get_file_components to list all Figma components
2. List all Flutter widgets in lib/
3. Identify coverage gaps
4. Plan missing implementations
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "FIGMA_API_KEY is not set" | Create `.env` file with your token |
| "File not found" | Verify `FIGMA_FILE_KEY` and your token has access |
| "Connection error" | Check internet and Figma API status |
| Server crashes | Check token validity and file key |

## What's Next?

1. ✅ Set up server (done above)
2. Ask Claude to extract design tokens
3. Generate Flutter theme files
4. Map Figma components to Flutter widgets
5. Use for design-to-code automation

## Help

See `README.md` for detailed documentation of all tools and API details.
