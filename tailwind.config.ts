import type { Config } from "tailwindcss";

export default {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        // Emerald Trust Brand Palette
        primary: "#006c49",
        "primary-container": "#10b981",
        "on-primary-container": "#00422b",
        secondary: "#4648d4",
        "on-secondary": "#ffffff",
        "secondary-container": "#6063ee",
        background: "#f7f9fb",
        surface: "#ffffff",
        "outline-variant": "#bbcabf",
        outline: "#6c7a71",
        "surface-container-low": "#f2f4f6",
        "surface-container-lowest": "#ffffff",
        "surface-container-highest": "#e0e3e5",
        "on-surface": "#191c1e",
        "on-surface-variant": "#3c4a42",
        error: "#ba1a1a",
        "error-container": "#ffdad6",
        "on-error-container": "#93000a",
        "secondary-fixed": "#e1e0ff",
        "on-secondary-fixed": "#07006c",
        tertiary: "#515f74",
        "tertiary-fixed-dim": "#b9c7df",
        
        // Retained for safety / fallback
        ink: "#10201e",
        paper: "#f7f7f2",
        mint: "#c8f1df",
        forest: "#175747",
        coral: "#fa7560"
      },
      boxShadow: {
        soft: "0 18px 50px rgba(16,32,30,.10)",
        setup: "0px 4px 12px rgba(0,0,0,0.05)"
      }
    }
  },
  plugins: []
} satisfies Config;

