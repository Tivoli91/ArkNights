Function Start-ANHR(){
	[CmdletBinding()]param(
	    [Parameter(Mandatory=$False)]
	    [switch]$AlreadyInHRPage # 点击立即招募
	)
	If( !$AlreadyInHRPage ){
		# 1 <-------------------------- 尝试进入任务界面
		If( ! (Test-ANHomePage ) ){ # 不在首页
			# <-------------------------- 1.1 从上方任务栏进入
			adb_server shell input tap $Global:ANXML.ArkNights.menu.dropdownhouse.$Global:ANR.x $Global:ANXML.ArkNights.menu.dropdownhouse.$Global:ANR.y ; sleep 1 # 点击小房子图标
			adb_server shell input tap $Global:ANXML.ArkNights.menu.hr.$Global:ANR.x $Global:ANXML.ArkNights.menu.hr.$Global:ANR.y ; sleep 5 # 点击 公开招募 图标
		}else{
			# <-------------------------- 1.2 从首页进入任务
			adb_server shell input tap $Global:ANXML.ArkNights.hr.enter.$Global:ANR.x $Global:ANXML.ArkNights.hr.enter.$Global:ANR.y  ; sleep 1
		}

	}
	Get-ANPartScreenshot $Global:ANXML.ArkNights.hr.rect.main.$Global:ANR.x $Global:ANXML.ArkNights.hr.rect.main.$Global:ANR.y $Global:ANXML.ArkNights.hr.rect.main.$Global:ANR.w $Global:ANXML.ArkNights.hr.rect.main.$Global:ANR.h # 截取模拟器部分屏幕
	# 3 <-------------------------- 人力办公室满级后 一共有4个职位
	$recruit_permit_amount = $null ; $is_recruit_permit_amount_checked=$false
	1..4 | %{
		<#
			$x,$y,$w,$h 是要点击"聘用候选人"矩形的左上角坐标和长宽
			$cx,$cy  是要点击"聘用候选人"和"开始招募干员" 中心的坐标, c = center
		#>
		$x,$y,$w,$h,$cx,$cy = $Global:ANXML.ArkNights.hr.rect."h$_".$Global:ANR.x,$Global:ANXML.ArkNights.hr.rect."h$_".$Global:ANR.y,$Global:ANXML.ArkNights.hr.rect."h$_".$Global:ANR.w,$Global:ANXML.ArkNights.hr.rect."h$_".$Global:ANR.h,$Global:ANXML.ArkNights.hr.rect."h$_".$Global:ANR.cx,$Global:ANXML.ArkNights.hr.rect."h$_".$Global:ANR.cy
		
		# 4 <-------------------------- 如果当前"可以招聘"时间已到,那就可以招聘
		If( Test-ANWordExist $x $y $w $h 'anh' '328562999220505368732015412' ){
			adb_server.exe shell input tap $cx $cy ; sleep 1 # 点击聘用候选人
			1..8 | %{  # 点击 "skip"
				adb_server.exe shell input tap $Global:ANXML.ArkNights.hr.skip.$Global:ANR.x $Global:ANXML.ArkNights.hr.skip.$Global:ANR.y ; sleep -Milliseconds 500  
			}
			
			# 第一次招募干员的时候 检测还剩多少 招聘许可书
			If( !$is_recruit_permit_amount_checked -or $recruit_permit_amount -gt 0){
				adb_server.exe shell input tap $cx $cy ; sleep 1 # 点击 "开始招募干员"
				# 后期考虑OCR识别高资干员选项
				New-ANScreenShot "$($env:TEMP)\ocr_hr.jpg"
				Test-ANWordExist $Global:ANXML.ArkNights.hr.rect.recruitpermitamount.$Global:ANR.x $Global:ANXML.ArkNights.hr.rect.recruitpermitamount.$Global:ANR.y $Global:ANXML.ArkNights.hr.rect.recruitpermitamount.$Global:ANR.w $Global:ANXML.ArkNights.hr.rect.recruitpermitamount.$Global:ANR.h 'anhn' '123' "$($env:TEMP)\ocr_hr.jpg"|out-null
				If( ($recruit_permit_amount = cat "$($env:TEMP)\ocrword.txt" -Encoding UTF8 -Raw) -imatch "^\d{1,2}/"){ # 获取招聘许可书个数 # example: 16/1
					$recruit_permit_amount = $recruit_permit_amount.Split('/')[0]
					$is_recruit_permit_amount_checked = $true
				}else{
					adb_server.exe shell input tap $Global:ANXML.ArkNights.hr.hirecancel.$Global:ANR.x $Global:ANXML.ArkNights.hr.hirecancel.$Global:ANR.y
					write-warning "Not found recruit permit amount!" ; return
				}
			}
			
			If( $recruit_permit_amount -gt 0 ){
				1..9 | %{ # 加到9个小时
					adb_server.exe shell input tap $Global:ANXML.ArkNights.hr.addtime.$Global:ANR.x $Global:ANXML.ArkNights.hr.addtime.$Global:ANR.y
				}
				adb_server.exe shell input tap $Global:ANXML.ArkNights.hr.hiretick.$Global:ANR.x $Global:ANXML.ArkNights.hr.hiretick.$Global:ANR.y ;  sleep 2 # 点击√开始招募
				$need_cancel = $false
				([int]$recruit_permit_amount)--  # 招聘许可书 数量减一
			}else{
				write-warning "No enough recruit permit"
				return
			}
		}
	}
}

# SIG # Begin signature block
# MIIFmwYJKoZIhvcNAQcCoIIFjDCCBYgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUKBDQMhUJUxrPFqCWjvRpEZ/+
# nG2gggMwMIIDLDCCAhigAwIBAgIQ5nEzTE66NLBPoLYxG+E3AzAJBgUrDgMCHQUA
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFFKWhDM+1ao8
# 6WEpEkP7KNK9Eq2mMA0GCSqGSIb3DQEBAQUABIIBALbfpaeH79R5UpzPGQa3e5QJ
# xlxVB9dU0jzfJQEYjuyG9PScibf1LwWjFDfWfnuayuCF/Q/6h5oQvHFzk1usZpd8
# sSdtNC+fyj+1yAF/+BWhdQ/PsNq3wc4Jn55oaU/fRdGKQCNlsNgkzhoIpwom2pZX
# aPhfEOm2SCq4lCMpceFuoY+qpZekdpAJ6VNzF2mHjNfde2OnhuVdHtDCyUL3fbuG
# H3eeIxQ7BpDLdUipopC/t7Xe/aCmujAZtaBKwsbIr9E16M+mS8ysqeSf7u3+xafD
# 1fwA6frKPsPIwg+7m67R5AJUdoeOgFJ/9r5dId2AyW7RdX45HTaIkXqlgeEaQS8=
# SIG # End signature block
