UI Mock Config

Overview
- Place a local config at `mock/mock.config.json` to enable UI mock mode.
- This file is ignored by git and should not be committed.

Setup
1) Copy the template:
   cp mock/mock.config.template.json mock/mock.config.json
2) Edit `mock/mock.config.json` with your domains and seed records.
3) Reload the UI page.

Supported fields
- `enabled` (boolean): set to true to enable mock mode.
- `domains` (string[]): available domain list for the Add Domain modal.
- `trackedDomains` (string[]): domains that should be shown immediately.
- `seedRecords` (array): initial records added to each tracked domain (only if empty).
- `refreshIntervalSec` (number, optional): UI auto refresh interval in seconds.

Example
{
  "enabled": true,
  "refreshIntervalSec": 60,
  "domains": ["alpha.example", "bravo.example", "charlie.example"],
  "trackedDomains": ["alpha.example"],
  "seedRecords": [
    { "rr": "home", "type": "A", "value": "1.2.3.4", "ttl": 600, "status": "ENABLE" },
    { "rr": "api", "type": "CNAME", "value": "service.example.net", "ttl": 600, "status": "ENABLE" }
  ]
}

Notes
- When `enabled: true`, the UI uses localStorage and does not call the backend API.
- `trackedDomains` renders grouped lists immediately.
- API/hour stats are stored locally in localStorage for mock mode; double‑click the number to reset.
