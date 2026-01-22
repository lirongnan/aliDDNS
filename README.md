# Aliyun DDNS for OpenWrt

这是一个基于 Aliyun DNS API 的 OpenWrt DDNS 插件示例工程，提供配置文件、启动脚本以及一个轻量级的 DDNS 客户端脚本。

## 功能

- 调用 Aliyun DNS API 获取/更新解析记录
- 支持定时轮询更新
- 支持从 OpenWrt 接口读取当前 IP

## 目录结构

```
aliDDNS/
  Makefile
  files/
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
- `ip_source`：OpenWrt 接口名，例如 `wan`

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
  option log_path '/var/log/aliddns.log'
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

## 构建

将 `aliDDNS` 目录放入 OpenWrt 的 `package/` 下，然后在菜单中选择 `Network -> aliDDNS`。
