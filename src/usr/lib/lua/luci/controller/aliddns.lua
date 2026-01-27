module("luci.controller.aliddns", package.seeall)

function index()
  local page = entry({"admin", "services", "aliddns"}, template("aliddns"), _("AliDDNS"), 90)
  page.dependent = true
  page.acl_depends = { "luci-app-aliddns" }
end
