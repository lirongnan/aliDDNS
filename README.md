# Aliyun DDNS for OpenWrt

这是一个基于 Aliyun DNS API 的 OpenWrt DDNS 插件示例工程，提供配置文件、启动脚本以及一个轻量级的 DDNS 客户端脚本。

## 功能

- 调用 Aliyun DNS API 获取/更新解析记录
- 支持定时轮询更新
- 支持定时获取解析记录
- 支持解析记录增删改查
- 支持从 OpenWrt 接口读取当前 IP
- 支持自动同步路由公网 IP（A/AAAA）
- 统计 Aliyun API 访问频率（每小时次数）

## 目录结构

```
Makefile
src/
  etc/config/aliddns
  etc/init.d/aliddns
  usr/bin/aliddns.sh
```

## 配置

编辑 `/etc/config/aliddns`，填写以下字段：

- `access_key_id`：阿里云 AccessKey ID
- `access_key_secret`：阿里云 AccessKey Secret
- `domain`：主域名，例如 `example.com`
- `rr`：记录值，例如 `@` 或 `home`
- `type`：记录类型，例如 `A`
- `ttl`：记录 TTL，默认 `600`
- `ip_source`：OpenWrt 接口名，例如 `wan`
- `interval`：轮询间隔（秒），默认 `300`
- `auto_interval`：自动同步公网 IP 的间隔（秒），默认 `300`
- `log_path`：日志文件路径，默认 `/var/log/aliddns.log`
- `api_endpoint`：阿里云 DNS API 地址，默认 `https://alidns.aliyuncs.com/`
- `api_version`：阿里云 DNS API 版本，默认 `2015-01-09`
- `mode`：服务模式，`sync`（默认）/ `list` / `auto`
- `record_id`：用于更新/删除记录时指定 RecordId
- `value`：用于添加/更新记录的目标值
- `page_size`：获取记录列表的分页大小，默认 `100`
- `list_rr`：获取记录列表时的 RR 过滤（可选）
- `list_type`：获取记录列表时的类型过滤（可选）
- `ip_override`：手动指定 IP（可选，优先生效）

示例：

```
config aliddns 'main'
  option enabled '1'
  option access_key_id 'your_key_id'
  option access_key_secret 'your_secret'
  option domain 'example.com'
  option rr 'home'
  option type 'A'
  option ttl '600'
  option ip_source 'wan'
  option interval '300'
  option auto_interval '300'
  option log_path '/var/log/aliddns.log'
  option api_endpoint 'https://alidns.aliyuncs.com/'
  option api_version '2015-01-09'
  option mode 'sync'
  option record_id ''
  option value ''
  option page_size '100'
  option list_rr ''
  option list_type ''
  option ip_override ''
```

## 使用

启动服务：

```
/etc/init.d/aliddns enable
/etc/init.d/aliddns start
```

手动执行一次：

```
/usr/bin/aliddns.sh --once
```

定时获取解析记录（后台服务）：

1. 配置 `/etc/config/aliddns`：

```
option mode 'list'
```

2. 启用服务：

```
/etc/init.d/aliddns enable
/etc/init.d/aliddns start
```

解析记录增删改查：

```
/usr/bin/aliddns.sh --list
/usr/bin/aliddns.sh --add
/usr/bin/aliddns.sh --update
/usr/bin/aliddns.sh --delete
```

说明：

- `--add`/`--update` 使用 `value` 作为记录值
- `--update`/`--delete` 优先使用 `record_id`，为空时按 `rr`/`type` 匹配第一条记录
- `mode=auto` 会按 `auto_interval` 周期同步路由公网 IP 到已配置的自动记录

## 升级

升级时直接执行 `opkg install /tmp/aliDDNS_*.ipk`，配置文件 `/etc/config/aliddns` 会保留。
不要使用 `opkg remove` 或强制重装，否则会清空配置。

## UI

UI 文件位于 `ui/index.html`，用于显示记录并执行添加/更新/删除操作。打包后会安装到 `/www/aliddns/index.html`。

UI 期望的 API 端点（示例）：

- `GET /cgi-bin/aliddns/records?domain=example.com`
- `POST /cgi-bin/aliddns/records`
- `PUT /cgi-bin/aliddns/records/{recordId}`
- `DELETE /cgi-bin/aliddns/records/{recordId}?domain=example.com`
- `GET /cgi-bin/aliddns/domains`
- `GET /cgi-bin/aliddns/settings`
- `POST /cgi-bin/aliddns/settings`
- `GET /cgi-bin/aliddns/public-ip`
- `GET /cgi-bin/aliddns/logs?level=info|error`
- `GET /cgi-bin/aliddns/auto-records`
- `POST /cgi-bin/aliddns/auto-records`
- `DELETE /cgi-bin/aliddns/auto-records/{recordId}`
- `GET /cgi-bin/aliddns/api-stats`
- `POST /cgi-bin/aliddns/api-stats`（清零统计）

说明：

- UI 需要先从 `GET /cgi-bin/aliddns/domains` 获取可用域名。
- 只有在 UI 中添加域名后，才会显示该域名的解析记录列表。
- UI 的 AccessKey、刷新间隔、默认 TTL 等配置通过 `settings` 接口保存在路由器（UCI）。
- UI 支持为 A/AAAA 记录启用“自动获取路由公网 IP”模式，后台会按 `auto_interval` 自动同步。
- UI 顶部显示 API 每小时访问次数，双击数字可清零重新统计。
- 如需在无后端时调试 UI，可使用 `mock/mock.config.json`（模板见 `mock/mock.config.template.json`）。
- 需确保 uhttpd 启用 CGI（默认 `/cgi-bin` 前缀）。

## 调试

以下步骤可帮助你排查问题：

1. 启用并重启服务，确认配置已加载：

```
/etc/init.d/aliddns enable
/etc/init.d/aliddns restart
```

2. 查看日志：

- 如果配置了 `log_path`（默认 `/var/log/aliddns.log`），直接查看：

```
tail -n 100 /var/log/aliddns.log
```

- 如果未配置 `log_path`，日志会写入系统日志：

```
logread -e aliddns
```

3. 手动单次执行，验证 API 调用与 IP 获取：

```
/usr/bin/aliddns.sh --once
```

4. 检查当前 IP 是否能正确获取（以 `wan` 为例）：

```
ubus call network.interface.wan status
```

5. 验证 UCI 配置是否正确：

```
uci show aliddns
```

6. 若提示 API 认证失败，请确认 AccessKey 权限包含 Aliyun DNS 相关权限，并检查系统时间是否准确（时间偏差会导致签名失败）。

7. 查看 API 访问统计：

```
curl -s http://127.0.0.1/cgi-bin/aliddns/api-stats
```

说明：统计保存在 `/tmp/aliddns_api_stats`，重启或清理 `/tmp` 后会重置。

## 构建

将当前目录放入 OpenWrt 的 `package/` 下，然后在菜单中选择 `Network -> aliDDNS`。
