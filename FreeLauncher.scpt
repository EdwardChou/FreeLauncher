set configure to do shell script "ls ~ | awk '/lauconf/'"
if configure = "" then
    set f to info for (choose file with prompt ("选择播放器"))
    set apps to name of f
    set pass to text returned of (display dialog "输入本机密码(只用于开启代理服务)" with icon caution with title "Request password to configure proxy setting" buttons {"ok"} default button "ok" default answer "" giving up after 30 with hidden answer)
    set res to openApp(apps, pass)
    if res = "OK" then
        do shell script "echo " & apps & ">> ~/lauconf"
        do shell script "echo -n " & pass & " | openssl base64 >> ~/lauconf"
    end if
else
    set a to do shell script "awk 'NR==1{print}' ~/lauconf"
    set p to do shell script "awk 'NR==2{print}' ~/lauconf | openssl base64 -d"
    openApp(a, p)
end if



on openApp(appli, pass)
    tell application appli
        if it is running then
            quit
        end if
    end tell
    try
        set format to "\"" & "%s:%s" & "\"" as string
        set status to do shell script "networksetup -getwebproxy Wi-Fi | awk '/Serve/ {host=$2} /Port: / {port=$2} END { printf " & format & ", host, port}'"
        if status = ":0" then
            do shell script "sudo networksetup -setwebproxy Wi-Fi 202.105.247.122 9999 off" password pass with administrator privileges
            delay 2
            tell application appli to activate
            delay 15
            do shell script "sudo networksetup -setwebproxystate Wi-Fi off" password pass with administrator privileges
        else
            do shell script "sudo networksetup -setwebproxystate Wi-Fi on" password pass with administrator privileges
            delay 2
            tell application appli to activate
            delay 15
            do shell script "sudo networksetup -setwebproxystate Wi-Fi off" password pass with administrator privileges
        end if
        return "OK"
    on error errMsg
        display dialog "ERROR: " & errMsg
        return "ERR"
    end try
end openApp