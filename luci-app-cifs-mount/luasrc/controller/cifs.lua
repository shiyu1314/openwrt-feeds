module("luci.controller.cifs", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/cifs") then
		return
	end

	local page = entry({"admin", "services", "cifs"}, cbi("cifs"), _("Mount SMB NetShare"))
	page.dependent = true
	page.acl_depends = { "luci-app-cifs-mount" }
end
