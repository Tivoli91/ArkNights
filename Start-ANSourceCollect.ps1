Function Start-ANSourceCollect([switch]$AlreadyInBasePage,[switch]$UseDrone){
	Function Test-ANOrderExist(){
	    return (Test-ANWordExist $Global:ANXML.ArkNights.base.rect.order.o1.$Global:ANR.x $Global:ANXML.ArkNights.base.rect.order.o1.$Global:ANR.y $Global:ANXML.ArkNights.base.rect.order.o1.$Global:ANR.w $Global:ANXML.ArkNights.base.rect.order.o1.$Global:ANR.h 'chi_sim' '3574621333201322018412') -or (Test-ANWordExist $Global:ANXML.ArkNights.base.rect.order.o2.$Global:ANR.x $Global:ANXML.ArkNights.base.rect.order.o2.$Global:ANR.y $Global:ANXML.ArkNights.base.rect.order.o2.$Global:ANR.w $Global:ANXML.ArkNights.base.rect.order.o2.$Global:ANR.h 'chi_sim' '3574621333201322018412') #-or (Test-ANWordExist 1115 50 190 50 'chi_sim' '3574621333201322018412')
	}
	Function Test-ANSourceExist([int]$n){
	    return (Test-ANWordExist $Global:ANXML.ArkNights.base.rect.source."s$n".$Global:ANR.x $Global:ANXML.ArkNights.base.rect.source."s$n".$Global:ANR.y $Global:ANXML.ArkNights.base.rect.source."s$n".$Global:ANR.w $Global:ANXML.ArkNights.base.rect.source."s$n".$Global:ANR.h)
	}
	If( !$AlreadyInBasePage ){
		# 1 <-------------------------- 尝试进入基建
		If( ! (Test-ANHomePage ) ){ # 不在首页
			adb_server shell input tap $Global:ANXML.ArkNights.menu.dropdownhouse.$Global:ANR.x $Global:ANXML.ArkNights.menu.dropdownhouse.$Global:ANR.y ; sleep 1 # 点击小房子图标
			adb_server shell input tap $Global:ANXML.ArkNights.menu.base.$Global:ANR.x $Global:ANXML.ArkNights.menu.base.$Global:ANR.y ; sleep 6 # 点击 基建 图标
		}else{
			# 2 <------------------------- 从首页点击基建进入, 等待6秒加载
			adb_server shell input tap $Global:ANXML.ArkNights.base.enter.$Global:ANR.x $Global:ANXML.ArkNights.base.enter.$Global:ANR.y ; sleep 6
		}
	}
	
	# 3 <-------------------------  进入了基建, 点击右上角,这个位置默认是"小铃铛"的图标,小概率会是"警告"的图标
	adb_server shell input tap $Global:ANXML.ArkNights.base.notice.first.$Global:ANR.x $Global:ANXML.ArkNights.base.notice.first.$Global:ANR.y ; sleep 1
	
	# 截取模拟器部分屏幕
	Get-ANPartScreenshot $Global:ANXML.ArkNights.base.rect.main.$Global:ANR.x $Global:ANXML.ArkNights.base.rect.main.$Global:ANR.y $Global:ANXML.ArkNights.base.rect.main.$Global:ANR.w $Global:ANXML.ArkNights.base.rect.main.$Global:ANR.h 
	# 4 <------------------------- 所以我们要检测下 在点击右上角位置后 是否左下角3个图标都没有"点击全部收获"的文字,目前没看到有第四个的,
	If( ($s1 =Test-ANSourceExist 1) -or ($s2 =Test-ANSourceExist 2) -or ($s3 =Test-ANSourceExist 3) ){
		# <------------------------- 在发现有资源可收获的情况下查看是否有订单交付
		$order=Test-ANOrderExist
	}else{
		<#  
			4.1 <------------------------- 当发现3个图标都没有收集的文字
			那么可能有2种情况
			1. 没有物资可以收集, 我们要检测下是否有订单可以收集,如果没有订单, 那么
			2. 可能第3步点击的图标是"警告"的图标, 我们需要再点击一下"警告"的图标下面的"小铃铛"图标
		#>
		# 4.2 <------------------------- 检测下是否有订单可以收集 # 检测 "订单交付" 字段
		If( $order=Test-ANOrderExist ){ 
		}else{
			# 4.3 没有订单, 猜测上次点的是"警告"的图标, 尝试点击下面的"小铃铛"图标
			adb_server shell input tap $Global:ANXML.ArkNights.base.notice.second.$Global:ANR.x $Global:ANXML.ArkNights.base.notice.second.$Global:ANR.y ; sleep 1 # 点之后依旧检测左下角 "点击全部收取" 汉字
			Get-ANPartScreenshot $Global:ANXML.ArkNights.base.rect.main.$Global:ANR.x $Global:ANXML.ArkNights.base.rect.main.$Global:ANR.y $Global:ANXML.ArkNights.base.rect.main.$Global:ANR.w $Global:ANXML.ArkNights.base.rect.main.$Global:ANR.h 
			If( ($s1 =Test-ANSourceExist 1) -or ($s2 =Test-ANSourceExist 2) -or ($s3 =Test-ANSourceExist 3) ){
				# <------------------------- 在发现有资源可收获的情况下查看是否有订单交付
				$order=Test-ANOrderExist
			}else{
				# 4.2 <------------------------- 当发现3个图标都没有"点击全部收获"的文字
				If( ! ($order=Test-ANOrderExist  )){ # 再接着检测 "订单交付" 字段
					return "No found to be collect source or order" #没有检测到要收集的资源或者订单
				}
			}
		}
	}
	# 5 <------------------------- 开始收集物资,根据出现"点击全部收获"字样出现的位置,进行分支选择, $s2 和 $s3 可能因为 $s1为true而不执行
	If( $s1 ){ # 第一个图标有物资要收集
		$p = 1 # 第一个图标位置
		adb_server shell input tap $Global:ANXML.ArkNights.base.rect.clickget."p$p".$Global:ANR.x $Global:ANXML.ArkNights.base.rect.clickget."p$p".$Global:ANR.y ; sleep 2
		If( $s2 -or ($s2 =Test-ANSourceExist 2 ) ){ # 第二个图标也有物资,只不过点了第一个图标后,原来的第2个图标现在在第一个图标的位置
			adb_server shell input tap $Global:ANXML.ArkNights.base.rect.clickget."p$p".$Global:ANR.x $Global:ANXML.ArkNights.base.rect.clickget."p$p".$Global:ANR.y ; sleep 2
		}else{
			$p = 2 # 第二个图标位置
		}
		If( $s3 -or ($s3 =Test-ANSourceExist 3 )){
			adb_server shell input tap $Global:ANXML.ArkNights.base.rect.clickget."p$p".$Global:ANR.x $Global:ANXML.ArkNights.base.rect.clickget."p$p".$Global:ANR.y ; sleep 2
		}
	}else{
		If( $s2 -or ($s2 =Test-ANSourceExist 2 )){ # 第一个图标没有物资, 第二个图标有物资, 因此点击第二个图标位置
			$p = 2 # 第二个图标位置
			adb_server shell input tap $Global:ANXML.ArkNights.base.rect.clickget."p$p".$Global:ANR.x $Global:ANXML.ArkNights.base.rect.clickget."p$p".$Global:ANR.y ; sleep 2
		}else{
			$p = 3 # 第三个图标位置
		}
		If( $s3 -or ($s3 =Test-ANSourceExist 3)){
			adb_server shell input tap $Global:ANXML.ArkNights.base.rect.clickget."p$p".$Global:ANR.x $Global:ANXML.ArkNights.base.rect.clickget."p$p".$Global:ANR.y ; sleep 2
		}
	}
	If( $order ){
		# 6 <------------------------- 进入贸易站
		1..2  | %{ adb_server shell input tap $Global:ANXML.ArkNights.base.order.enter.$Global:ANR.x $Global:ANXML.ArkNights.base.order.enter.$Global:ANR.y ; sleep -Milliseconds 1500 }
		
		adb_server shell input tap $Global:ANXML.ArkNights.base.order.list.$Global:ANR.x $Global:ANXML.ArkNights.base.order.list.$Global:ANR.y ; sleep -Milliseconds 2000 # 7 <-------------------------  进入订单列表
		
		# 8 <-------------------------  查看订单个数
		New-ANScreenShot # 截取模拟器截图
		Test-ANWordExist $Global:ANXML.ArkNights.base.order.amount.$Global:ANR.x $Global:ANXML.ArkNights.base.order.amount.$Global:ANR.y $Global:ANXML.ArkNights.base.order.amount.$Global:ANR.w $Global:ANXML.ArkNights.base.order.amount.$Global:ANR.h 'anhn' '111' | out-null
		
		If( ($order_list_amount = cat "$($env:TEMP)\ocrword.txt" -Encoding UTF8 -Raw) -imatch "^\d{1,2}/"){ # 获取订单个数 # 10/11
			$order_list_amount = $order_list_amount.Split('/')[0]
		}else{
			$order_list_amount = 11 # 使用默认数量 11
		}
		
		$to_left = $Global:ANXML.ArkNights.base.order.clickget.$Global:ANR.x
		$to_top = $Global:ANXML.ArkNights.base.order.clickget.$Global:ANR.y
		
		1 .. $order_list_amount|%{adb_server shell input tap $to_left $to_top ; sleep 1 } # 9 <--------  收取订单
		
		If( $UseDrone ){ # 10 <--------  使用无人机
			adb_server shell input tap $Global:ANXML.ArkNights.base.order.drone.cancel.$Global:ANR.x $Global:ANXML.ArkNights.base.order.drone.cancel.$Global:ANR.y; sleep 1
			
			1..3|%{
				adb_server shell input tap $to_left $to_top ; sleep 1 # 点击无人协助
				adb_server shell input tap $Global:ANXML.ArkNights.base.order.drone.clickmost.$Global:ANR.x $Global:ANXML.ArkNights.base.order.drone.clickmost.$Global:ANR.y; sleep 1 # 点击最多
				adb_server shell input tap $Global:ANXML.ArkNights.base.order.drone.confirm.$Global:ANR.x $Global:ANXML.ArkNights.base.order.drone.confirm.$Global:ANR.y; sleep 2 # 点击确认
				adb_server shell input tap $to_left $to_top ; sleep 1 # 点击收取
			}
			adb_server shell input tap $Global:ANXML.ArkNights.base.order.drone.cancel.$Global:ANR.x $Global:ANXML.ArkNights.base.order.drone.cancel.$Global:ANR.y; sleep 1
		}
	
		1..2  | %{ adb_server shell input tap 140 65 ; sleep 1 } # 11 <------------------------- 离开贸易站
	}
}
# SIG # Begin signature block
# MIIFmwYJKoZIhvcNAQcCoIIFjDCCBYgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUdvPj9Nl+ZTNiIGQOk2MJatF/
# ZOegggMwMIIDLDCCAhigAwIBAgIQ5nEzTE66NLBPoLYxG+E3AzAJBgUrDgMCHQUA
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFPBGTVp46xLf
# XePc4OrBPwpFqscvMA0GCSqGSIb3DQEBAQUABIIBABG4+1BvWzYn2iNgP4hpNbG9
# Whp0s3bDPJMOUF6nJeiBEX9mhW10trDPJWqIrOo2pdRj4sHB5FeHsyrdyN5R0an4
# 0IM8ZRr/aZwzCy+2k8RxJNarNK+UtkOx5v4Gcthc8kyqZ1PZVJsmgss/8KZRRxTo
# V0zzpX/71xgk/zTbZfyoM+nqlpNFUb9GG9dQVbFYeIUU52y5XlBmJwKAW6sY9rfq
# FIcyQzakF8OjYuyFkym1oFaCYt44BWiH3SfWy9DseEJYD+69jhWq1jRPG8DRdfLU
# 3V1vWg0g7NErbOEZrAqezy83CkkW3RFkBqur77qgGdumz7++awfw2aV1vQe+GCM=
# SIG # End signature block
