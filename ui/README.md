UI Settings

Overview
- The UI stores configuration on the router via `/cgi-bin/aliddns/settings`.
- Settings include AccessKey, refresh interval, and default TTL.
 - Mock mode is available via a local config file.

Setup
1) Open the UI page.
2) Click "Settings" and fill in your AccessKey ID/Secret.
3) Save settings, then click "Add domain" to load available domains.

Mock mode
1) Copy `mock/mock.config.template.json` to `mock/mock.config.json`.
2) Set `"enabled": true` and provide `domains` / `seedRecords`.
3) Reload the UI page (no API calls will be made).

Notes
- The UI calls `/cgi-bin/aliddns/*` and expects a backend to proxy requests to Aliyun.
- Domain lists come from `GET /cgi-bin/aliddns/domains`.
- Ensure uhttpd has CGI enabled (default `/cgi-bin`).
