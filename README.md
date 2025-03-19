# 用前必看

首先，要运行ps1类型的脚本，需要在powershell中设置执行策略，否则会报错。因为Windows是默认不给用户运行ps脚本的，具体操作如下：

1. 以管理员身份运行powershell（以管理员身份运行！）
2. 输入`Set-ExecutionPolicy RemoteSigned`
3. 输入`Y`确认（部分win11系统可能不需要，只要脚本可以正常运行就好了）
4. 这里有一个坑，就是你的电脑可能会有多个powershell，比如powershell、powershell7等，这里建议每一个poweshell都要设置一下执行策略
   对于安装了powershell7的win11用户而言，有可能你在手动运行脚本的时候没有任何问题，但是在自动化的时候就出现了问题，这是因为在win11里自动化依然使用的是系统原生的powershell，所以你需要在系统原生的powershell里设置执行策略，具体操作就是在搜索框里搜索powershell，然后右键以管理员身份运行，然后输入上面的命令

## 使用方法

1. 第一次使用时要打开配置一下网卡名称以及用户名和密码和wifi名称；
2. 首先打开auto_login.ps1（这里推荐使用VSCode打开，然后会看到乱码，这很正常，因为该ps1文件使用的是GBK编码，不使用该编码的话将无法兼容以中文命名的网络适配器，而VSC默认以UTF-8编码打开文件，所以要在VSC的右下角点击“UTF-8”，再在屏幕上部点击”编码重新打开”选择GB2132或者GBK），如果看到是中文的注释，那么就可以继续配置了；
3. 修改`$username`和`$password`为你的用户名和密码，然后修改`$adapterName`为你的有线网卡名，`$wifiName`为无线网卡名，`networkSSID`为你的wifi名称(在南邮大概就是NJUPT、NJUPT-CMCC等)；
4. 保存后，右键以管理员身份运行auto_login.ps1，如果没有报错，那么就可以了；

此外可以将整个脚本注册为计划任务，目录内的bat和xml文件就是留着干这个的，这里留个坑，等日后有时间慢慢填吧。

