UI Settings

Overview
- The UI stores configuration on the router via `/cgi-bin/aliddns/settings`.
- The tracked domain list is stored on the router via `/cgi-bin/aliddns/tracked-domains`.
- Settings include AccessKey, refresh interval, and default TTL.

Setup
1) Open the UI page.
2) Click "Settings" and fill in your AccessKey ID/Secret.
3) Save settings, then click "Add domain" to load available domains.

Notes
- The UI calls `/cgi-bin/aliddns/*` and expects a backend to proxy requests to Aliyun.
- Domain lists come from `GET /cgi-bin/aliddns/domains`.
- Tracked domains are synced with `GET/POST /cgi-bin/aliddns/tracked-domains`.
- Ensure uhttpd has CGI enabled (default `/cgi-bin`).
