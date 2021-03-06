Function Connect-ArkNights([switch]$reconnect){
	$start=get-date
	Function Show-ConnectInfo(){
		[CmdletBinding()]param(
			[Parameter(Mandatory=$True)]
			[string]$info
		)
		write-host ("{0:HH:mm:ss} -- $info" -f (get-date))
	}
	
	If( $reconnect ){
		adb_server shell am force-stop com.hypergryph.arknights 2>$null
	}
	# 请把MUMU模拟器启动程序NemuPlayer.exe 添加到环境变量里面
	If( !($ms = ps NemuPlayer -ea 4) ){ # ms = mumu simulator
		Try{
			Show-ConnectInfo "1. 启动MUMU模拟器"
			# 启动MUMU模拟器, 等待初始时间，让模拟器加载好, 根据自己电脑性能自己调节初始等待时间
			start NemuPlayer -ea 1 ; sleep 10 
		}Catch{
			throw $_
		}
	}else{
		Show-ConnectInfo "1. MUMU模拟器已启动"
	}
	
	Show-ConnectInfo "2. 连接安卓调试桥"
	
	# 请把MUMU模拟器 自带的安卓调试桥程序 adb_server.exe 添加到环境变量里面
	$cnt=0
	:out_loop
	Do{
	    $connect_result = adb_server connect '127.0.0.1:7555'
		Switch -regex ($connect_result){
			"connected"{ break out_loop} # $connect_result ; 
			"empty host name"{ adb_server kill-server ; adb_server start-server}
		    # "unable to connect"{sleep 2 ; break}
		    default{sleep 2}
		}
		If( $cnt -gt 299 ){
			throw "Unable to connect to android simulator in 10mins!" ; return
		}
	}While( $true )

	
	#貌似长时间连接会断开，所以加了一个后台定时(半小时)连接的事件
	if (!(Get-Job|?{$_.Command -imatch "adb_server connect"})) {
		Start-Job {do {sleep 1800 ; if(ps NemuPlayer -ea 4){adb_server connect '127.0.0.1:7555'}} while (1)}|out-null
	}
	
	Show-ConnectInfo "3. 判断mumu模拟器程序界面是否加载出来"
	do {
		sleep 2
	} until ((ps NemuPlayer).MainWindowTitle -imatch 'MuMu模拟器')

	Show-ConnectInfo "4. 判断安卓模拟器是否完全加载完成"
	do {
		sleep 2
	} until ((adb_server shell ps 2>$null) -imatch 'com.android.systemui')

	Show-ConnectInfo "5. 查看安卓模拟器分辨率"
	# 3. 查看安卓模拟器分辨率
	$cnt=0
	Do{
		$r = ((adb_server shell wm size 2>$null) -join "").Split(':')[-1] 2>$null
		If( $r.Length -gt 0 ){
			$Global:ANR = Switch -regex ($r){ # ANR = ArkNights Resolution
				"1920x1080"{ 'r1080' ; break}
				"2560x1440"{ 'r2k' ; break}
				default{
					throw "Unsupported resolution so far:$_" ; return
				}
			}
			break
		}else{
			sleep 1
		}
	}While( $true )
	
	Show-ConnectInfo "5.1 模拟器分辨率为:$r"
	Show-ConnectInfo "6. 启动明日方舟/激活窗口"
	
	# 6. 启动明日方舟/激活窗口
	Try{
		If( (adb_server shell ps) -imatch "com.hypergryph.arknights" ){
			# 发现明日方舟程序已经启动，激活明日方舟进程为活动窗口
			Show-ConnectInfo '6.1 发现明日方舟程序已经启动，激活明日方舟进程为活动窗口'
			adb_server shell am start -n com.hypergryph.arknights/com.u8.sdk.U8UnityContext 1>$null
			
			If( ! (Test-ANHomePage ) ){
				Show-ConnectInfo '6.2 发现不在主界面，尝试回到主界面'
				Set-ANHomePage
				If( ! (Test-ANHomePage ) ){ 
					Show-ConnectInfo '6.2.1 无法回到主界面，杀掉进程，重新登陆'
					adb_server shell am force-stop com.hypergryph.arknights # 杀掉明日方舟进程
					sleep 2
					Connect-ArkNights
					return
				}else{
					Show-ConnectInfo '6.2.1 成功回到主界面，准备重新登录'
				}
			}else{
				Show-ConnectInfo '6.2 已在主界面，准备重新登录'
			}
			# 目前脚本没法是否是手机之后登录了，但是模拟器的主界面窗口还在，所以这里直接退出重新登陆
			$root_node = $Global:ANXML.ArkNights.relogin.setting

			Show-ConnectInfo '6.3 点击 “设置”'
			# adb_server shell input tap $root_node.$Global:ANR.x $root_node.$Global:ANR.y ; sleep 1
			adb_server shell input tap 100 100 ; sleep 2
			
			Show-ConnectInfo '6.4 点击 “账户”'
			# adb_server shell input tap $root_node.game.$Global:ANR.x $root_node.game.$Global:ANR.y
			adb_server shell input tap 354 322 ; sleep 2
			
			# 向下滑动到“退出该账号”显示出来
			# adb_server shell input swipe 1000 500 500 200 ; sleep 2

			Show-ConnectInfo '6.5 点击 “退出”'
			adb_server shell input tap $root_node.game.exit.$Global:ANR.x $root_node.game.exit.$Global:ANR.y ; sleep 1
			
			Show-ConnectInfo '6.6 点击 "✔"确认退出'
			adb_server shell input tap $root_node.game.exit.confirm.$Global:ANR.x $root_node.game.exit.confirm.$Global:ANR.y
			
		}else{
			# 未发现正在运行的明日方舟程序， 尝试启动
			Show-ConnectInfo '6.1 未发现正在运行的明日方舟程序， 尝试启动'
			adb_server shell am start -n com.hypergryph.arknights/com.u8.sdk.U8UnityContext 1>$null
			sleep 20 # 等待明日方舟启动，根据自己电脑性能自己调节初始等待时间
			$start_time=get-date
			Do{ # 检测 正下方黄色 "START" 字符串
				New-ANScreenShot
				Try{
					If( Test-ANWordExist $Global:ANXML.ArkNights.login.loadingpage.$Global:ANR.x $Global:ANXML.ArkNights.login.loadingpage.$Global:ANR.y $Global:ANXML.ArkNights.login.loadingpage.$Global:ANR.w $Global:ANXML.ArkNights.login.loadingpage.$Global:ANR.h 'eng' '8384658284'){
						break
					}
					If( (   (get-date) - $start_time  ).Seconds -gt 59){
						throw "Timeout(60s) to find success loading page!" ; return
					}
				}Catch{
					sleep 1
				}Finally{
				}
			}While( $true )
			adb_server shell input tap 500 500 # 点击任一点进入登录界面（我这里随便取了一个坐标）
			sleep 5 # 等待登录界面加载出来， 根据自己电脑性能自己调节初始等待时间
		}
		$loop_cnt=0
		Do{
			If( Test-ANLoginPage ){
				break
			}
			If( $loop_cnt++ -gt 29 ){
				throw "Timeout(30s) to find main login page!" ; return
			}
			sleep 1
		}While( $true )
		Show-ConnectInfo "7. 开始(重新)登陆"
		Start-ANLogin -SkipLoginPageCheck # 登录明日方舟
	}Catch{
		throw $_
	}
	
	Show-ConnectInfo "8. 检查基建退出提醒"
	
	# 8. 从配置文件检查基建退出提醒
	If( $Global:ANXML.ArkNights.base.exitwarning -inotmatch "false" ){
		# write-warning (cat "$PSScriptRoot\ExitBaseWarning" -Encoding UTF8)
		write-warning "请手动在游戏设置里把退出基建提醒关掉,确定关掉后再按任意键继续."
		read-host " "
		$Global:ANXML.ArkNights.base.exitwarning = "false"
		$Global:ANXML.Save("$PSScriptRoot\ArkNightsConfig.xml")
	}
	$usetime = (get-date) - $start
	Write-Verbose ("总计用时{0}分{1}秒" -f $usetime.Minutes,$usetime.Seconds) -Verbose
}

# SIG # Begin signature block
# MIIFmwYJKoZIhvcNAQcCoIIFjDCCBYgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3u5ckSjgMstRz6sRkX1oDZ8E
# 0j+gggMwMIIDLDCCAhigAwIBAgIQ5nEzTE66NLBPoLYxG+E3AzAJBgUrDgMCHQUA
# MCAxHjAcBgNVBAMTFUNoYW95dWVQb3dlclNoZWxsQ2VydDAeFw0xOTEyMDYxMzU4
# NThaFw0zOTEyMzEyMzU5NTlaMCAxHjAcBgNVBAMTFUNoYW95dWVQb3dlclNoZWxs
# Q2VydDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALlP3thT4yCaCium
# ZZ53Li0hxYTXhxg8BjT6UC6tgjVXjbcbJmlLRql/hBxZDjkv9lgZY+XUX9TmYQ/A
# 4EgpYn5cb0uCleO1dk13gH45dgAg5bww+jsT4ano50ByHZ+HX+YAlrSo4nIFTqPx
# UBIck2ubEmS6i5b5BUAZQ1MeFl5BkqPUvBf/FJMDxdM1vz2DHLDwlExCufl44uF3
# 2z8UNis47Pnv3C2bXZkRiIbXD5JcVldc2UJ3tZ0b4DYuZ2XDh3y/1SHqKRQ9XVa4
# j7hhfkwYyE70422KDCR6eOCCMO5CClh7f1ulv25Ma5uNMdkwDKW4kQPp/6p55llv
# 60zABqECAwEAAaNqMGgwEwYDVR0lBAwwCgYIKwYBBQUHAwMwUQYDVR0BBEowSIAQ
# FgxXCr5ViLVCwfteKwzKaaEiMCAxHjAcBgNVBAMTFUNoYW95dWVQb3dlclNoZWxs
# Q2VydIIQ5nEzTE66NLBPoLYxG+E3AzAJBgUrDgMCHQUAA4IBAQBB3+Taarp2Kqsw
# 9XLJbp+Zni8xAwVsep28hL1pq/kQzkiJySh++b2eaYi3AKqWGd4OjAIyASBYWRp9
# rVMW1nSJZ6ajGmbJZRXZ3hd4TUoCX/DjrniT0Gqr8OvybbWNczM4NFfEBkKbzvz0
# aK582qRtoKG7uEYVaRr+SSWoxzVVIhZn1sAMK4Vx0HDmg0mq9R/QL8/vHEbYPWAj
# GoiTgjZYDjjEe1TxwBmF69AB4/87MZgnZNYbSGUCxFHy66Owj07X96pm5ORoUyTT
# ZXk2djKijlCXdnulEchOzSf/xPyp/AQaUB9LNbqfXYJMbWFSxGPfIMHMbUGrR7Az
# RljwtDPBMYIB1TCCAdECAQEwNDAgMR4wHAYDVQQDExVDaGFveXVlUG93ZXJTaGVs
# bENlcnQCEOZxM0xOujSwT6C2MRvhNwMwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcC
# AQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYB
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFDFO/1ldYQX1
# GwRW8t4grGSZBh5jMA0GCSqGSIb3DQEBAQUABIIBAHeZ2M2IlRU4nPxnc24lpoQm
# YqQ5e//HLm7ZN4MC9o6twT7q3WsF5RCaGLcAfm+uUCbpE4bi1H+x+zYMuE4MT/LE
# Tl6t8M0U4/TJrPrE012qrtHM0ToEerXmMBh+BO40HFhBTO4QdCcyXL1iBmdia7Qt
# mVXyKgzQ+mGCVTdTDC85bMuC++2jq0mrEClKIFdGn715wfNb8RAcRcn8iqb6E7OJ
# nIvzB/eYbHLFJolnwZRhUKLuncd9C/CpcIIouc1uCnId3aIX9OOXJFsJI3ARz3OY
# AEaxD9XQtwiI6E9wEi/7Pao0iF7Xgs82bd/evwPpeHh8xcJv37pXC2EhplOpmqw=
# SIG # End signature block
