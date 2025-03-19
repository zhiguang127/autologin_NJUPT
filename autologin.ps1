# �����ϸ�ģʽ
Set-StrictMode -Version Latest

# ��������һ������˺�
# �����˺ŵ������ǣ�ѧ��@��Ӫ��
# �ƶ���B210313XX@cmcc
# ���ţ�B210313XX@njxy
# У԰����B210313XX
$user_account = "B21031314@cmcc"
# ��������һ���������
$user_password = "�������"

# ��������һ�������������������
$adapterName = "��̫��"
$wifiName = "WLAN"

# ��������һ�����wifi����
$networkSSID = "NJUPT-CMCC"


#�����ֻ�����ߣ������������������ȡIP��ַ���������������������ߵ�������Ϊ����������ĺ�������46�У������������ע�͵�
function GetIP {
    # ��ȡ"wifiName"��������������Ϣ
    $netAdapter = Get-NetAdapter 
    $wifiadapter = $netAdapter | Where-Object { $_.Name -eq $wifiName }
    # ��һ����������Ƿ���������wifi
    if($wifiadapter){
        if($wifiadapter.Status -ne "Up"){
            Write-Host "Adapter $($wifiadapter.Name) is not connected with wifi."
            netsh wlan connect name="$networkSSID"
            Start-Sleep -Seconds 1
        }
        $wifiadapter = $netAdapter | Where-Object { $_.Name -eq $wifiName }
    }
    #��ȡWLAN��������10.16��ͷ��IPv4��ַ
    if($wifiadapter.Status -eq "Up"){
        Write-Host "Adapter $($wifiadapter.Name) is connected with wifi."
        $wlan_user_ip = (Get-NetIPAddress -InterfaceIndex $wifiadapter.InterfaceIndex).IPAddress | Where-Object { $_ -like "10.16*" }
        # Write-Host $wlan_user_ip
        # Read-Host -Prompt "Press Enter to continue"
        return $wlan_user_ip
    }
}

#�������������������ߵ�������Ϊ�����������������ȡIP��ַ�����ֻ�����ߣ�����ֱ��������ĺ�������52�У������������ע�͵�
# function GetIP {
#     # ��ȡ"adapterName"��������������Ϣ
#     $netAdapter = Get-NetAdapter 
#     $adapter = $netAdapter | Where-Object { $_.Name -eq $adapterName }
#     $wifiadapter = $netAdapter | Where-Object { $_.Name -eq $wifiName }
#     # ��һ��������������Ƿ�������������
#     if ($adapter) {
#         if ($adapter.Status -eq "Up" -and $adapter.LinkSpeed -gt 0) {
#             Write-Host "Adapter $($adapter.Name) is connected with cable."
#             #�����˾ͻ�ȡ��������10.16��ͷ��IPv4��ַ
#             $wlan_user_ip = (Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex).IPAddress | Where-Object { $_ -like "10.16*" }
#             return $wlan_user_ip
#         } else {
#             if($wifiadapter){
#                 #����Ƿ���������ָ�����Ƶ�wifi
#                 if($wifiadapter.Status -ne "Up"){
#                     Write-Host "Adapter $($wifiadapter.Name) is not connected with wifi."
#                     netsh wlan connect name="$networkSSID"
#                     Start-Sleep -Seconds 1
#                 }
#                 $wifiadapter = $netAdapter | Where-Object { $_.Name -eq $wifiName }
#             }
#             #��ȡWLAN��������10.16��ͷ��IPv4��ַ
#             if($wifiadapter.Status -eq "Up"){
#                 Write-Host "Adapter $($wifiadapter.Name) is connected with wifi."
#                 $wlan_user_ip = (Get-NetIPAddress -InterfaceIndex $wifiadapter.InterfaceIndex).IPAddress | Where-Object { $_ -like "10.16*" }
#                 return $wlan_user_ip
#             }
#         }
#     } else {
#         Write-Host "Adapter with name $($adapterName) not found."
#         #������������ʾ��˵������������֣�Ҳ����adapterName��д����
#     }
# }

# ��Ȼ���������⣬ֻ�����ߣ��������ĺ������ҳ���Ҫ�õ���䣬Ȼ��Ѳ���Ҫ��ɾ��������
$connection = $false
# ���������������У԰��
function Connect{
    #����GetIP����,��ȡIP�ַ�������ɸѡ����10.16��ͷ��IP��ַ
    $str = GetIP
    #ֻҪstrΪ�գ��ͻ�һֱѭ����ֱ����ȡ��IP��ַ
    while($null -eq $str){
        $str = GetIP
    }

    $wlan_user_ip = $str | Where-Object { $_ -like "10.16*" }
    while ($null -eq $wlan_user_ip){
        Write-Host "IP address not found."
        $wlan_user_ip = GetIP | Where-Object { $_ -like "10.16*" }
    }
    #����һ��ip��ַ
    Write-Host $wlan_user_ip
    #����һ���س���������Ϳ��Կ���ip��ַ�ˣ����Ե�ʱ����
    Read-Host -Prompt "Press Enter to continue"

    # ����HTTP����

    $url = "https://p.njupt.edu.cn:802/eportal/portal/login?callback=dr1003&login_method=1&user_account=,0,$user_account&user_password=$user_password&wlan_user_ip=$wlan_user_ip&wlan_user_ipv6=&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=&jsVersion=4.1.3&terminal_type=1&lang=zh-cn&v=2533&lang=zh"

    Write-Host "Sending HTTP request..."
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing
    # Write-Host $response.StatusCode

    # ��������URL
    # Write-Host $url
    $connection = $false
    # ѭ������Ping����DNS��������ֱ���ɹ���������Ϊ�˷�ֹ��¼ʧ��
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
#����Connect����
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
