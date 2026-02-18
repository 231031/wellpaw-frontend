# Figma MCP Server for WellPaw Flutter

A Model Context Protocol (MCP) server that connects your WellPaw Flutter project to Figma, enabling design system integration, component extraction, and design-to-code workflows.

## Features

- 📦 **Design System Access**: Retrieve all components, styles, and design tokens from Figma
- 🎨 **Component Management**: Extract component sets, variants, and properties
- 🎯 **Style/Token Extraction**: Get colors, typography, effects, and grid systems
- 📄 **Export Capabilities**: Export components as SVG, PNG, or PDF
- 🏗️ **Hierarchy Navigation**: Explore page structures and component hierarchies

## Setup

### 1. Prerequisites

- Node.js 18+
- Figma account with API access
- Figma personal access token

### 2. Get Your Figma Token

1. Go to [Figma Settings](https://www.figma.com/settings/account)
2. Scroll to "Personal access tokens"
3. Click "Create a new token"
4. Copy the token (save it securely)

### 3. Get Your File Key

1. Open your Figma file in the browser
2. The URL format is: `https://www.figma.com/file/{FILE_KEY}/...`
3. Copy the `FILE_KEY` portion

### 4. Install Dependencies

```bash
cd mcp/figma-server
npm install
```

### 5. Configure Environment

Copy `.env.example` to `.env` in `mcp/figma-server/` and fill in your values:

```env
FIGMA_API_KEY=your_personal_access_token_here
FIGMA_FILE_KEY=your_figma_file_key_here
```

### 6. Test the Server

```bash
npm start
```

You should see: `Figma MCP Server running on stdio`

## Available Tools

### get_file_nodes
Retrieve specific nodes or all nodes from a Figma file.

```json
{
  "file_key": "optional_file_key",
  "node_ids": ["node1", "node2"]
}
```

### get_file_components
Get all components from the design system.

```json
{
  "file_key": "optional_file_key"
}
```

Returns:
- Component IDs and names
- Component properties
- Thumbnail URLs

### get_component_sets
Get all component sets and variants.

```json
{
  "file_key": "optional_file_key"
}
```

Returns:
- Component set structures
- Variant configurations
- Properties for each variant

### get_file_styles
Extract all design tokens (colors, typography, effects, grids).

```json
{
  "file_key": "optional_file_key"
}
```

Returns:
- Color styles and values
- Typography (font families, sizes, weights, line heights)
- Effects (shadows, blurs)
- Grid systems

### export_component
Export components as SVG, PNG, or PDF.

```json
{
  "file_key": "your_file_key",
  "node_ids": ["component_id"],
  "format": "svg"
}
```

### get_page_hierarchy
Get the structure of pages and components.

```json
{
  "file_key": "optional_file_key",
  "page_name": "optional_page_filter"
}
```

Returns:
- Page names and structures
- Component hierarchy
- Nested structure visualization

## Usage Examples

### Extract Design Tokens

```
Get all design tokens (colors, typography, effects) from our Figma design system.
Use the get_file_styles tool to retrieve them.
```

### Generate Flutter Color Palette

```
Retrieve all color styles from Figma and convert them to a Flutter Color class
with Material ColorScheme. Use get_file_styles for the colors.
```

### Map Components to Flutter Widgets

```
Get all component sets and their variants from Figma. For each component,
identify the Flutter widget mapping and properties. Use get_component_sets.
```

### Audit Design System Coverage

```
Extract all components from Figma and compare with implemented Flutter widgets.
Identify gaps in component coverage. Use get_file_components.
```

## Integration with Claude

Once configured, Claude can:

1. **Analyze Designs**: Review Figma design system structure
2. **Extract Tokens**: Automatically pull colors, typography, spacing
3. **Map Components**: Match Figma components to Flutter widgets
4. **Generate Code**: Create Flutter code from design specifications
5. **Verify Consistency**: Check if Flutter implementation matches Figma

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `FIGMA_API_KEY` | Your Figma personal access token | Yes |
| `FIGMA_FILE_KEY` | Default Figma file key | No (can be passed per call) |

## Troubleshooting

### "FIGMA_API_KEY is not set"
- Ensure `.env` file exists with `FIGMA_API_KEY`
- Verify your token is valid in Figma settings

### "File not found" errors
- Check the `FIGMA_FILE_KEY` is correct
- Verify you have access to the Figma file
- Ensure token has read permissions

### Rate limiting
- Figma API has rate limits (120 requests/minute)
- Implement caching for frequently accessed data

## Advanced Configuration

### Using with Claude Desktop

1. Install the MCP in Claude Desktop config:

```json
{
  "mcpServers": {
    "figma": {
      "command": "node",
      "args": ["/path/to/wellpaw-frontend/mcp/figma-server/server.js"],
      "env": {
        "FIGMA_API_KEY": "your_token",
        "FIGMA_FILE_KEY": "your_file_key"
      }
    }
  }
}
```

2. Restart Claude Desktop
3. Figma tools should now be available

## Example Workflows

### Design System → Flutter

1. Use `get_file_styles` to extract all tokens
2. Generate Flutter `theme.dart` with ColorScheme
3. Create constants file for spacing, typography
4. Validate against Material Design 3 guidelines

### Component Mapping

1. Use `get_file_components` to list all components
2. Document Flutter widget equivalents
3. Extract properties and constraints
4. Generate component mapping document

### Quality Audit

1. Get all Figma components
2. Compare with Flutter widget inventory
3. Identify missing implementations
4. Generate coverage report

## Security Notes

⚠️ **Never commit `.env` file** - Add to `.gitignore`

```gitignore
mcp/figma-server/.env
```

🔒 Use environment variables in CI/CD instead of hardcoding tokens

## Support

For issues with:
- **Figma API**: Check [Figma API Docs](https://www.figma.com/developers/api)
- **MCP Protocol**: See [MCP Documentation](https://modelcontextprotocol.io)
- **Flutter Integration**: Consult the Flutter agents guide

## License

Part of the WellPaw Flutter project.
