Mock scripts live here.

Files:
- mock.template.sh: executable template; copy to mock.local.sh and fill values.
- mock.local.sh: your local runner (gitignored).
- uci/ubus/jsonfilter: minimal local stubs used by aliddns.sh (curl is real).

Quick start:
1) Copy template to local runner:
   cp ./mock/mock.template.sh ./mock/mock.local.sh
2) Edit ./mock/mock.local.sh and fill the config values (LOG_PATH defaults to /dev/stderr).
   Optional: API_ENDPOINT and API_VERSION can be set if Aliyun returns InvalidVersion.
   Optional: COMMAND selects which operation to run (e.g. --list/--add/--update/--delete/--daemon).
3) Run:
   ./mock/mock.local.sh

Examples:
- List records:
  COMMAND="--list"
- Add record:
  VALUE="1.2.3.4"
  COMMAND="--add"
- Update record:
  RECORD_ID="123456"
  VALUE="1.2.3.4"
  COMMAND="--update"
- Delete record:
  RECORD_ID="123456"
  COMMAND="--delete"
- Periodic list:
  MODE="list"
  COMMAND="--daemon"

Notes:
- This setup is for local dev only.
- Extend the mock scripts as needed.
