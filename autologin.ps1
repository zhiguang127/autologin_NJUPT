# 开启严格模式
Set-StrictMode -Version Latest

# 这里设置一下你的账号
# 其中账号的设置是：学号@运营商
# 移动：B210313XX@cmcc
# 电信：B210313XX@njxy
# 校园网：B210313XX
$user_account = "B21031314@cmcc"
# 这里设置一下你的密码
$user_password = "你的密码"

# 这里设置一下你的网络适配器名字
$adapterName = "以太网"
$wifiName = "WLAN"

# 这里设置一下你的wifi名字
$networkSSID = "NJUPT-CMCC"


#如果你只用无线，可以用这个函数来获取IP地址，如果你既用有线又用无线但以有线为主，用下面的函数（第46行），把这个函数注释掉
function GetIP {
    # 获取"wifiName"的网络适配器信息
    $netAdapter = Get-NetAdapter 
    $wifiadapter = $netAdapter | Where-Object { $_.Name -eq $wifiName }
    # 这一段用来检查是否连接上了wifi
    if($wifiadapter){
        if($wifiadapter.Status -ne "Up"){
            Write-Host "Adapter $($wifiadapter.Name) is not connected with wifi."
            netsh wlan connect name="$networkSSID"
            Start-Sleep -Seconds 1
        }
        $wifiadapter = $netAdapter | Where-Object { $_.Name -eq $wifiName }
    }
    #获取WLAN网卡的以10.16开头的IPv4地址
    if($wifiadapter.Status -eq "Up"){
        Write-Host "Adapter $($wifiadapter.Name) is connected with wifi."
        $wlan_user_ip = (Get-NetIPAddress -InterfaceIndex $wifiadapter.InterfaceIndex).IPAddress | Where-Object { $_ -like "10.16*" }
        # Write-Host $wlan_user_ip
        # Read-Host -Prompt "Press Enter to continue"
        return $wlan_user_ip
    }
}

#如果你既用有线又用无线但以有线为主，用这个函数来获取IP地址，如果只用无线，可以直接用下面的函数（第52行），把这个函数注释掉
# function GetIP {
#     # 获取"adapterName"的网络适配器信息
#     $netAdapter = Get-NetAdapter 
#     $adapter = $netAdapter | Where-Object { $_.Name -eq $adapterName }
#     $wifiadapter = $netAdapter | Where-Object { $_.Name -eq $wifiName }
#     # 这一段用来检查网卡是否连接上了网线
#     if ($adapter) {
#         if ($adapter.Status -eq "Up" -and $adapter.LinkSpeed -gt 0) {
#             Write-Host "Adapter $($adapter.Name) is connected with cable."
#             #接上了就获取该网卡以10.16开头的IPv4地址
#             $wlan_user_ip = (Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex).IPAddress | Where-Object { $_ -like "10.16*" }
#             return $wlan_user_ip
#         } else {
#             if($wifiadapter){
#                 #检查是否连接上了指定名称的wifi
#                 if($wifiadapter.Status -ne "Up"){
#                     Write-Host "Adapter $($wifiadapter.Name) is not connected with wifi."
#                     netsh wlan connect name="$networkSSID"
#                     Start-Sleep -Seconds 1
#                 }
#                 $wifiadapter = $netAdapter | Where-Object { $_.Name -eq $wifiName }
#             }
#             #获取WLAN网卡的以10.16开头的IPv4地址
#             if($wifiadapter.Status -eq "Up"){
#                 Write-Host "Adapter $($wifiadapter.Name) is connected with wifi."
#                 $wlan_user_ip = (Get-NetIPAddress -InterfaceIndex $wifiadapter.InterfaceIndex).IPAddress | Where-Object { $_ -like "10.16*" }
#                 return $wlan_user_ip
#             }
#         }
#     } else {
#         Write-Host "Adapter with name $($adapterName) not found."
#         #如果看到这个提示，说明你的网卡名字（也就是adapterName）写错了
#     }
# }

# 当然如果你很奇葩，只用有线，请从上面的函数里找出你要用的语句，然后把不需要的删掉就行了
$connection = $false
# 这个函数用来连接校园网
function Connect{
    #调用GetIP函数,获取IP字符串，并筛选出以10.16开头的IP地址
    $str = GetIP
    #只要str为空，就会一直循环，直到获取到IP地址
    while($null -eq $str){
        $str = GetIP
    }

    $wlan_user_ip = $str | Where-Object { $_ -like "10.16*" }
    while ($null -eq $wlan_user_ip){
        Write-Host "IP address not found."
        $wlan_user_ip = GetIP | Where-Object { $_ -like "10.16*" }
    }
    #回显一下ip地址
    Write-Host $wlan_user_ip
    #接受一个回车，这样你就可以看到ip地址了，调试的时候用
    Read-Host -Prompt "Press Enter to continue"

    # 发送HTTP请求

    $url = "https://p.njupt.edu.cn:802/eportal/portal/login?callback=dr1003&login_method=1&user_account=,0,$user_account&user_password=$user_password&wlan_user_ip=$wlan_user_ip&wlan_user_ipv6=&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=&jsVersion=4.1.3&terminal_type=1&lang=zh-cn&v=2533&lang=zh"

    Write-Host "Sending HTTP request..."
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing
    # Write-Host $response.StatusCode

    # 输出请求的URL
    # Write-Host $url
    $connection = $false
    # 循环尝试Ping阿里DNS服务器，直到成功，这里是为了防止登录失败
    for ($i = 0; $i -lt 10; $i++) {
        try {
            Test-Connection 223.5.5.5 -Count 1 -ErrorAction Stop
            Write-Host "Ping successful on retry."
            $connection = $true
            break
        } catch {
            Write-Host "Ping failed, retrying..."
            $response = Invoke-WebRequest -Uri $url # -UseBasicParsing
            Write-Host $response.StatusCode
            Start-Sleep -Seconds 1
        }
    }
    return $connection
}
#调用Connect函数
$connection = Connect

while($true){
    if($connection){
        Write-Host "Connection successful."
        break
    } else {
        Write-Host "Connection failed."
        $connection = Connect
    }
}
Stop-Process -Name powershell

# Read-Host -Prompt "Press Enter to continue"
