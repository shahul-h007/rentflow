// next.config.js
const path = require('path');
/** @type {import('next').NextConfig} */
const nextConfig = {
  // Explicitly set the Turbopack root to the project directory to avoid workspace detection issues
  turbopack: {
    root: path.resolve(__dirname),
  },
  // Optional: keep existing settings, can add future tweaks here
  reactStrictMode: true,
  swcMinify: true,
};
module.exports = nextConfig;
