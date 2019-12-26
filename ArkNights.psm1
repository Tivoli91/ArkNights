# 判断tesseract有没有添加到环境变量里
$env:Path.split(';') | %{
	If(test-path "$_\NemuPlayer.exe" ){
		$found_lanuch=$true
	}
	If( test-path "$_\adb_server.exe" ){
		$found_android_debug=$true
	}
}
If( !$found_lanuch -or $found_android_debug){
	If(!$found_lanuch  ){
		write-warning "Please add the full path of MUMU simulator `"NemuPlayer.exe`" to environment path before using this module."
	}
	If(!$found_android_debug ){
		write-warning "Please add the full path of MUMU simulator `"adb_server.exe`" to environment path before using this module."
	}
	return
}

[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
ls "$PSScriptRoot\*.ps1" -Exclude "Install-ThisModule.ps1"|%{. $_.fullname}
$Global:ANXML = [xml](cat "$PSScriptRoot\ArkNightsConfig.xml" -Encoding UTF8)

#region internal functions

Function Get-ANPartScreenshot(){
	[CmdletBinding()]param(
	    [int]$to_left_distance=0,
        [int]$to_top_distance=1315,
        [int]$image_width=2560,
        [int]$image_height=100,
		[string]$new_img_file="$($env:TEMP)\ocr.jpg"
	)
	New-ANScreenShot
	New-CropImage $to_left_distance $to_top_distance $image_width $image_height -new_img_file $new_img_file
}
Function Test-ANWordExist(){
	[CmdletBinding()]param(
		[Parameter(Mandatory=$True)]
		[int]$to_left_distance,
		[int]$to_top_distance=0,
		[int]$image_width=120,
		[int]$image_height=35,
		[string]$training_data='ans',
		[string]$check_data='2885720987', #2885720987  点击   2084037096 全部
		[string]$source_image = "$($env:TEMP)\ocr.jpg"
	)
	New-CropImage $to_left_distance $to_top_distance $image_width $image_height $source_image "$($env:TEMP)\ocr1.jpg"
	return (Test-OCRWord "$($env:TEMP)\ocr1.jpg" $training_data $check_data) 
}
Function Enter-ANCombatPage(){
    # 1 <-------------------------- 尝试进入作战界面
	If( ! (Test-ANHomePage ) ){ # 不在首页
		adb_server shell input tap $Global:ANXML.ArkNights.menu.dropdownhouse.$Global:ANR.x $Global:ANXML.ArkNights.menu.dropdownhouse.$Global:ANR.y ; sleep 1 # 点击小房子图标
		adb_server shell input tap $Global:ANXML.ArkNights.menu.combat.$Global:ANR.x $Global:ANXML.ArkNights.menu.combat.$Global:ANR.y ; sleep 5 # 点击 作战 图标
	}else{
		# 2 <------------------------- 从首页点击作战进入, 等待2秒加载
		adb_server shell input tap $Global:ANXML.ArkNights.combat.enter.$Global:ANR.x $Global:ANXML.ArkNights.combat.enter.$Global:ANR.y ; sleep 2
	}
}
Function Get-ReasonCount(){
	Get-ANPartScreenshot $Global:ANXML.ArkNights.combat.reason.$Global:ANR.x $Global:ANXML.ArkNights.combat.reason.$Global:ANR.y $Global:ANXML.ArkNights.combat.reason.$Global:ANR.w $Global:ANXML.ArkNights.combat.reason.$Global:ANR.h # 截取 "好友"人数数字
	Test-OCRWord "$($env:TEMP)\ocr.jpg" 'anhn' '-1'|out-null #  使用OCR 获取理智数字
	If( ($reasons = cat "$($env:TEMP)\ocrword.txt" -Encoding UTF8 -Raw) -imatch "^\d{1,3}/"){ # 获取到理智个数 # 35/128
		write-host "reasons $reasons"
		return $reasons.trim().Split('/') # 返回剩余理智 和总共理智
	}else{
		throw "Not found reason number!"
	}
}
Function Add-Reasons(){
	adb_server shell input tap $Global:ANXML.ArkNights.combat.start.$Global:ANR.x $Global:ANXML.ArkNights.combat.start.$Global:ANR.y ; sleep 1 # 点击"开始行动"，弹出使用"应急理智合剂"/"源石" 界面
	adb_server shell input tap $Global:ANXML.ArkNights.combat.reason.add.$Global:ANR.x $Global:ANXML.ArkNights.combat.reason.add.$Global:ANR.y ; sleep 2 # 点击“√”，增加理智
	[int]$reasons,[int]$total=Get-ReasonCount # 获取当前理智数字，最大理智数
	return $reasons
}
Function Start-ANTaskLoopWithReasonCheck(){
    [CmdletBinding()]param(
        [int]$level_x,
        [int]$level_y,
		[int]$single_consume_reason_count,
		[int]$times,
        [boolean]$AutoAddReason
    )
	
	adb_server shell input tap $level_x $level_y ; sleep 1 # 选择难度
	
	[int]$reasons,[int]$total=Get-ReasonCount # 获取当前理智数字，最大理智数

	If( $reasons -lt $single_consume_reason_count ){
		If( !$AutoAddReason ){
			write-warning "Not have enough reasons for combat" ; return
		}else{ # 吃石头补充理智
			If( ($reasons = Add-Reasons) -lt $single_consume_reason_count ){
				write-warning "Not have enough reasons for combat after trying to add reasons" ; return
			}
		}
	}
	$total_loop_cnt=0 #用来记录一共刷了多少次
	$loop_cnt = [math]::Truncate($reasons/$single_consume_reason_count) # 当前理智可以刷关卡的次数
	
	$previous_loop_cnt=0
	# 开始循环刷关
	If( $loop_cnt -ge $times ){ # 现有理智可以刷的次数>=目标次数，使用目标次数作为循环次数,不需要喝药剂/吃石头
		Start-ANTaskLoop 1 $times 150 #$level_x $level_y
	}else{
		Do{
			Start-ANTaskLoop ($previous_loop_cnt + 1) ($previous_loop_cnt + $loop_cnt) 150 #$level_x $level_y
			$previous_loop_cnt = $loop_cnt
			If( ($total_loop_cnt+=$loop_cnt) -ge $times ){ break}
			# 此时理智用完
			If( $AutoAddReason ){ # 如果需要自动补充理智
				If( ($reasons = Add-Reasons) -lt $single_consume_reason_count ){
					write-warning "Not have enough reasons for combat after trying to add reasons" ; break
				}
			}else{
				write-warning "Not have enough reasons for combat after $loop_cnt times combat" ; break
			}
			$left_loop_cnt=$times - $loop_cnt
			$loop_cnt = [math]::Truncate($reasons/$single_consume_reason_count) # 当前理智可以刷关卡的次数
			
			If( $loop_cnt -gt $left_loop_cnt){ # 如果当前理智可以刷关卡的次数超过剩余要打的次数
				$loop_cnt = $left_loop_cnt # 使用剩余要打的次数 作为循环次数
			}
		}While( $total_loop_cnt -lt $times )
	}
}

#endregion internal functions

Export-ModuleMember -Function * -Cmdlet *

# SIG # Begin signature block
# MIIFmwYJKoZIhvcNAQcCoIIFjDCCBYgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUbloAYiLwP/k/Ms0NJFpMHy7J
# /zagggMwMIIDLDCCAhigAwIBAgIQ5nEzTE66NLBPoLYxG+E3AzAJBgUrDgMCHQUA
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFAJI1QObaZcK
# NhfL9JCMhvdNpoRMMA0GCSqGSIb3DQEBAQUABIIBADBYmqOCwK8CAf1Ivv5IirR3
# olCxo1Dmoy5fZSst4e7gGLBzai9dpktbdSVvKv1xRCct+D/AV4p9bvmgT2ShjNVZ
# bO1j51LsZ2M7y+IO6irXYBmf33qd6MPN9rAyI11qGK11fhQrzLhjRnGy1YSVstUN
# 00rkcs1F0SznXz/gdEapWyxfyma4bBFODLmeQH1JIJHQPZsgXh0jzxQ4odQxqGmI
# L8QeIpBRaTd9WZqv/N1+mi6oOoWh8/Y+GvFIMU4n/mSas+vsKZBoA1/EiYgz/Tvw
# lePMqInJydC3bZG+OQibDQPHfiMQiVgwS258PPqkYA+Rm7fmkzCG+MTExlQ5Dcw=
# SIG # End signature block
