#!/bin/sh

# === 核心安全：自后台运行机制 ===
if [ "$1" != "bg_run" ]; then
    rm -f /var/run/update_core* /tmp/AdGuardHome_update.log
    touch /var/run/update_core
    /usr/share/AdGuardHome/update_core.sh bg_run "$1" </dev/null >/tmp/AdGuardHome_update.log 2>&1 &
    exit 0
fi

shift
# ==========================================================

PATH="/usr/sbin:/usr/bin:/sbin:/bin"
binpath="/usr/bin/AdGuardHome"
update_mode=$1

core_version=$(uci get adguardhome.config.core_version 2>/dev/null || true)
update_url=$(uci get adguardhome.config.update_url 2>/dev/null || true)

case "${core_version}" in
beta)
	core_api_url=https://api.github.com/repos/AdguardTeam/AdGuardHome/releases
	;;
*)
	core_api_url=https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest
	;;
esac

EXIT(){
    rm -rf /var/run/update_core /tmp/AdGuardHome_Update 2>/dev/null
    if [ "$1" != "0" ]; then
        touch /var/run/update_core_error
    fi
    exit $1
}

trap "EXIT 1" SIGTERM SIGINT

rm -rf /var/run/update_core_error /var/run/update_core_done 2>/dev/null
touch /var/run/update_core

Check_Task(){
    running_tasks="$(ps w | grep -v grep | grep 'AdGuardHome' | grep 'update_core' | wc -l)"
	case $1 in
	force)
		echo "已请求强制更新"
		echo "正在终止 ${running_tasks} 个运行中的更新任务 ..."
		ps w | grep -v grep | grep -v $$ | grep 'AdGuardHome' | grep 'update_core' | awk '{print $1}' | xargs kill -9 2>/dev/null
		;;
	*)
		[ "${running_tasks}" -gt 2 ] && echo -e "已有 ${running_tasks} 个更新任务正在运行。请稍候或手动停止它们。" && EXIT 2
		;;
	esac
}

Check_Downloader() {
	if command -v curl >/dev/null 2>&1; then
		PKG="curl"
		return
	fi

	if command -v wget >/dev/null 2>&1; then
		PKG="wget"
		return
	fi

	echo "未安装 curl 或 wget，无法检查更新！" >&2
	EXIT 1
}

Check_Updates(){
	Check_Downloader
	case "${PKG}" in
	curl)
		Downloader="curl -L -k -o"
		_Downloader="curl -s"
	;;
	wget)
		Downloader="wget --no-check-certificate -T 5 -O"
		_Downloader="wget -q -O -"
	;;
	esac
	echo "[${PKG}] 正在检查更新 ..."
	Cloud_Version="$(${_Downloader} ${core_api_url} 2>/dev/null | grep 'tag_name' | egrep -o "v[0-9].+[0-9.]" | awk 'NR==1')"
	if [ -z "${Cloud_Version}" ]; then
		echo "检查更新失败，请检查网络连接。" >&2
		EXIT 1
	fi

	if [ -f "${binpath}" ]; then
		Current_Version="$(${binpath} --version 2>/dev/null | egrep -o "v[0-9].+[0-9]" | sed -r 's/(.*), c(.*)/\1/')"
	else
		Current_Version="未知"
	fi
	[ -z "${Current_Version}" ] && Current_Version="未知"

	echo "二进制路径: ${binpath%/*}"
	echo "当前版本: ${Current_Version}"
	echo "最新版本: ${Cloud_Version}"

	if [ ! "${Cloud_Version}" = "${Current_Version}" ] || [ "$1" = force ]; then
		Update_Core || EXIT 1
	else
		echo "已经是最新版本。"
		EXIT 0
	fi
	EXIT 0
}

Update_Core(){
	rm -rf "/tmp/AdGuardHome_Update" > /dev/null 2>&1
	mkdir -p "/tmp/AdGuardHome_Update" || { echo "无法创建临时目录"; EXIT 1; }

	GET_Arch
	eval link="${update_url}"
	echo "下载链接: ${link}"
	echo "文件名: ${link##*/}"
	echo "正在下载 AdGuardHome 内核 ..."

	if ! $Downloader "/tmp/AdGuardHome_Update/${link##*/}" "${link}"; then
		echo "下载失败。"
		rm -rf "/tmp/AdGuardHome_Update"
		EXIT 1
	fi

	if [ "${link##*.}" = "gz" ]; then
		echo "正在解压 AdGuardHome ..."
		if ! tar -zxf "/tmp/AdGuardHome_Update/${link##*/}" -C "/tmp/AdGuardHome_Update/"; then
			echo "解压失败！"
			rm -rf "/tmp/AdGuardHome_Update"
			EXIT 1
		fi
		if [ ! -e "/tmp/AdGuardHome_Update/AdGuardHome/AdGuardHome" ]; then
			echo "解压失败：找不到二进制文件！"
			rm -rf "/tmp/AdGuardHome_Update"
			EXIT 1
		fi
		downloadbin="/tmp/AdGuardHome_Update/AdGuardHome/AdGuardHome"
	else
		downloadbin="/tmp/AdGuardHome_Update/${link##*/}"
	fi

	chmod +x "${downloadbin}" 2>/dev/null || true
	echo "内核大小: $(awk 'BEGIN{printf "%.2fMB\n",'$((`ls -l $downloadbin | awk '{print $5}'`))'/1000000}')"

	/etc/init.d/AdGuardHome stop > /dev/null 2>&1
	echo "正在将 AdGuardHome 二进制文件移动到 ${binpath%/*} ..."

	if ! mv -f "${downloadbin}" "${binpath}"; then
		echo -e "内核文件移动失败！\n可能是磁盘空间不足所致。"
		rm -rf "/tmp/AdGuardHome_Update"
		EXIT 1
	fi

	rm -rf /tmp/AdGuardHome_Update
	chmod +x ${binpath}
    echo "正在重启 AdGuardHome 服务 ..."
    /etc/init.d/adguardhome restart > /dev/null 2>&1

	echo "AdGuardHome 内核更新成功！"
	touch /var/run/update_core_done
    EXIT 0
}

GET_Arch() {
	Archt="$(uname -m)"
	case "${Archt}" in
	i386|i686)
		Arch="i386"
	;;
	x86_64|amd64)
		Arch="amd64"
	;;
	mipsel|mipsel*)
		Arch="mipsle_softfloat"
	;;
	mips|mips*)
		Arch="mips_softfloat"
	;;
	mips64el)
		Arch="mips64le_softfloat"
	;;
	mips64)
		Arch="mips64_softfloat"
	;;
	armv5*|armv5l|armv5tel)
		Arch="armv5"
	;;
	armv6*|armv6l)
		Arch="armv6"
	;;
	armv7*|armv7l)
		Arch="armv7"
	;;
	arm|armhf)
		Arch="armv7"
	;;
	aarch64)
		Arch="arm64"
	;;
	*)
		echo "不支持的架构: [${Archt}]" 
		EXIT 1
	esac
    echo "检测到架构: ${Arch}"
}


main(){
	Check_Task ${update_mode}
	Check_Updates ${update_mode}
}

main