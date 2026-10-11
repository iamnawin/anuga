import type { NextConfig } from 'next';

// Staging is a static export served under a sub-path (scripts/build-staging.sh).
// The console is client-side only, so the export behaves like the normal build.
const staticExport = process.env.OPS_STATIC_EXPORT === '1';

const nextConfig: NextConfig = {
  reactStrictMode: true,
  poweredByHeader: false,
  ...(staticExport
    ? { output: 'export', basePath: process.env.OPS_BASE_PATH ?? '', trailingSlash: true }
    : {
        // The console never needs a search engine; keep it out of indexes.
        // (The staging host sets the same header for the static export.)
        async headers() {
          return [{ source: '/:path*', headers: [{ key: 'X-Robots-Tag', value: 'noindex, nofollow' }] }];
        },
      }),
};

export default nextConfig;
