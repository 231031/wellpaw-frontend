#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import axios from "axios";
import dotenv from "dotenv";

dotenv.config();

const FIGMA_API_KEY = process.env.FIGMA_API_KEY;
const FIGMA_FILE_KEY = process.env.FIGMA_FILE_KEY;
const BASE_URL = "https://api.figma.com/v1";

if (!FIGMA_API_KEY) {
  console.error("Error: FIGMA_API_KEY environment variable is not set");
  process.exit(1);
}

const axiosInstance = axios.create({
  baseURL: BASE_URL,
  headers: {
    "X-FIGMA-TOKEN": FIGMA_API_KEY,
    "Content-Type": "application/json",
  },
});

const server = new Server(
  {
    name: "figma-mcp",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Tool definitions
const tools = [
  {
    name: "get_file_nodes",
    description:
      "Get specific nodes from a Figma file (components, frames, pages)",
    inputSchema: {
      type: "object",
      properties: {
        file_key: {
          type: "string",
          description:
            "Figma file key (can be omitted if FIGMA_FILE_KEY is set)",
        },
        node_ids: {
          type: "array",
          items: { type: "string" },
          description: "List of node IDs to retrieve (leave empty for all)",
        },
      },
      required: [],
    },
  },
  {
    name: "get_file_components",
    description: "Get all components from a Figma file (design system)",
    inputSchema: {
      type: "object",
      properties: {
        file_key: {
          type: "string",
          description: "Figma file key (defaults to FIGMA_FILE_KEY)",
        },
      },
      required: [],
    },
  },
  {
    name: "get_component_sets",
    description: "Get all component sets and variants",
    inputSchema: {
      type: "object",
      properties: {
        file_key: {
          type: "string",
          description: "Figma file key (defaults to FIGMA_FILE_KEY)",
        },
      },
      required: [],
    },
  },
  {
    name: "get_file_styles",
    description: "Get all design tokens (colors, typography, effects, grids)",
    inputSchema: {
      type: "object",
      properties: {
        file_key: {
          type: "string",
          description: "Figma file key (defaults to FIGMA_FILE_KEY)",
        },
      },
      required: [],
    },
  },
  {
    name: "export_component",
    description: "Export a component as SVG, PNG, or PDF",
    inputSchema: {
      type: "object",
      properties: {
        file_key: {
          type: "string",
          description: "Figma file key",
        },
        node_ids: {
          type: "array",
          items: { type: "string" },
          description: "Node IDs to export",
        },
        format: {
          type: "string",
          enum: ["svg", "png", "pdf"],
          description: "Export format",
        },
      },
      required: ["node_ids", "format"],
    },
  },
  {
    name: "get_page_hierarchy",
    description: "Get page structure and component hierarchy",
    inputSchema: {
      type: "object",
      properties: {
        file_key: {
          type: "string",
          description: "Figma file key",
        },
        page_name: {
          type: "string",
          description: "Page name to retrieve (optional)",
        },
      },
      required: [],
    },
  },
];

// Tool implementations
async function getFileNodes(fileKey, nodeIds = []) {
  const key = fileKey || FIGMA_FILE_KEY;
  if (!key) throw new Error("File key required");

  const params = {};
  if (nodeIds.length > 0) {
    params.ids = nodeIds.join(",");
  }

  const response = await axiosInstance.get(`/files/${key}/nodes`, { params });
  return {
    file: response.data.name,
    nodes: response.data.nodes,
    version: response.data.version,
  };
}

async function getFileComponents(fileKey) {
  const key = fileKey || FIGMA_FILE_KEY;
  if (!key) throw new Error("File key required");

  const response = await axiosInstance.get(`/files/${key}/components`);
  const components = response.data.components;

  return {
    file: response.data.name,
    totalComponents: Object.keys(components).length,
    components: components,
  };
}

async function getComponentSets(fileKey) {
  const key = fileKey || FIGMA_FILE_KEY;
  if (!key) throw new Error("File key required");

  const response = await axiosInstance.get(`/files/${key}`);
  const componentSets = [];

  const extractComponentSets = (node) => {
    if (node.componentSetId) {
      componentSets.push({
        id: node.id,
        name: node.name,
        componentSetId: node.componentSetId,
        type: node.type,
      });
    }
    if (node.children) {
      node.children.forEach(extractComponentSets);
    }
  };

  if (response.data.document) {
    extractComponentSets(response.data.document);
  }

  return {
    file: response.data.name,
    componentSets,
  };
}

async function getFileStyles(fileKey) {
  const key = fileKey || FIGMA_FILE_KEY;
  if (!key) throw new Error("File key required");

  const response = await axiosInstance.get(`/files/${key}/styles`);
  const styles = response.data.styles;

  const stylesByType = {
    colors: [],
    typography: [],
    effects: [],
    grids: [],
  };

  Object.values(styles).forEach((style) => {
    if (style.styleType === "FILL") {
      stylesByType.colors.push(style);
    } else if (style.styleType === "TEXT") {
      stylesByType.typography.push(style);
    } else if (style.styleType === "EFFECT") {
      stylesByType.effects.push(style);
    } else if (style.styleType === "GRID") {
      stylesByType.grids.push(style);
    }
  });

  return {
    file: response.data.name,
    stylesByType,
    totalStyles: Object.keys(styles).length,
  };
}

async function exportComponent(fileKey, nodeIds, format) {
  const key = fileKey || FIGMA_FILE_KEY;
  if (!key) throw new Error("File key required");

  const response = await axiosInstance.post(`/files/${key}/export`, {
    ids: nodeIds,
    format,
    use_absolute_bounds: true,
  });

  return {
    exports: response.data.exports,
    renderTime: response.data.render_time,
  };
}

async function getPageHierarchy(fileKey, pageName) {
  const key = fileKey || FIGMA_FILE_KEY;
  if (!key) throw new Error("File key required");

  const response = await axiosInstance.get(`/files/${key}`);

  const buildHierarchy = (node, depth = 0) => {
    const item = {
      id: node.id,
      name: node.name,
      type: node.type,
      depth,
    };

    if (node.children) {
      item.children = node.children.map((child) =>
        buildHierarchy(child, depth + 1)
      );
    }

    return item;
  };

  let pages = [];
  if (response.data.document && response.data.document.children) {
    pages = response.data.document.children.map((page) => ({
      id: page.id,
      name: page.name,
      type: page.type,
      hierarchy: page.children
        ? page.children.map((child) => buildHierarchy(child))
        : [],
    }));

    if (pageName) {
      pages = pages.filter((page) =>
        page.name.toLowerCase().includes(pageName.toLowerCase())
      );
    }
  }

  return {
    file: response.data.name,
    pages,
  };
}

// Register request handlers
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return { tools };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  try {
    const { name, arguments: args } = request.params;
    let result;

    switch (name) {
      case "get_file_nodes":
        result = await getFileNodes(args.file_key, args.node_ids || []);
        break;
      case "get_file_components":
        result = await getFileComponents(args.file_key);
        break;
      case "get_component_sets":
        result = await getComponentSets(args.file_key);
        break;
      case "get_file_styles":
        result = await getFileStyles(args.file_key);
        break;
      case "export_component":
        result = await exportComponent(
          args.file_key,
          args.node_ids,
          args.format
        );
        break;
      case "get_page_hierarchy":
        result = await getPageHierarchy(args.file_key, args.page_name);
        break;
      default:
        throw new Error(`Unknown tool: ${name}`);
    }

    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(result, null, 2),
        },
      ],
    };
  } catch (error) {
    return {
      content: [
        {
          type: "text",
          text: `Error: ${error.message}`,
        },
      ],
      isError: true,
    };
  }
});

// Start server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Figma MCP Server running on stdio");
}

main().catch(console.error);
