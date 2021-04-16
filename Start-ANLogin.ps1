Function Start-ANLogin([switch]$SkipLoginPageCheck){
	If( !$SkipLoginPageCheck ){
		If( !(Test-ANLoginPage) ){
			throw "Not in login main page!"
		}
	}
	
	# 读取本地加密密码
	If( [string]::IsNullOrWhiteSpace( ($cred=cat "$PSScriptRoot\cred" -raw -ea 4) )){
		$sec = Read-Host "Please enter your ArkNights password, it will be encrypted in `"$PSScriptRoot\cred`"" -AsSecureString
		If( $sec.Length -eq 0 -or !$sec ){
			throw "You haven't provided the ArkNights password! Please run the current function again and make sure you provide the ArkNights password!"
		}else{
			Try{
				$cred = $sec| ConvertFrom-SecureString
				$cred | Out-File -FilePath "$PSScriptRoot\cred" -Encoding utf8 -Force -NoNewline
			}Catch{
				throw $_
			}
		}
	}
	
	If( Test-ANWordExist $Global:ANXML.ArkNights.login.check.$Global:ANR.x $Global:ANXML.ArkNights.login.check.$Global:ANR.y $Global:ANXML.ArkNights.login.check.$Global:ANR.w $Global:ANXML.ArkNights.login.check.$Global:ANR.h 'chi_sim' '36134214953164929702' ){
		adb_server shell input tap $Global:ANXML.ArkNights.login.accountmanage.$Global:ANR.x $Global:ANXML.ArkNights.login.accountmanage.$Global:ANR.y ; sleep 2 # 账号管理
	}
	adb_server shell input tap $Global:ANXML.ArkNights.login.accountlogin.$Global:ANR.x $Global:ANXML.ArkNights.login.accountlogin.$Global:ANR.y     ; sleep 2 # 账号登录
	
	adb_server shell input tap $Global:ANXML.ArkNights.login.password.$Global:ANR.x $Global:ANXML.ArkNights.login.password.$Global:ANR.y             ; sleep 2 # 密码输入框
	Try{
		
		adb_server shell input text ([Runtime.InteropServices.Marshal]::PtrToStringAuto( [Runtime.InteropServices.Marshal]::SecureStringToBSTR((ConvertTo-SecureString $cred))))  # 输入密码
	}Catch{
		throw $_
	}
	1..2|%{ # 多点一次 防止失败
		adb_server shell input tap $Global:ANXML.ArkNights.login.loginclick.$Global:ANR.x $Global:ANXML.ArkNights.login.loginclick.$Global:ANR.y ; sleep 1 # 登录
		adb_server shell input tap $Global:ANXML.ArkNights.login.loginclick.$Global:ANR.x $Global:ANXML.ArkNights.login.loginclick.$Global:ANR.y ; sleep 1 # 登录
	}
	1..15|%{ 
		sleep -Milliseconds 500 ; adb_server shell input tap $Global:ANXML.ArkNights.login.activity.$Global:ANR.x $Global:ANXML.ArkNights.login.activity.$Global:ANR.y # 每日登陆活动,领取等弹窗
	}
}
# SIG # Begin signature block
# MIIFmwYJKoZIhvcNAQcCoIIFjDCCBYgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUIW2jf2W/eTRXSoPQ5gSi9bDL
# vDqgggMwMIIDLDCCAhigAwIBAgIQ5nEzTE66NLBPoLYxG+E3AzAJBgUrDgMCHQUA
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFPvodmZ5LgFT
# Aj5+x8/2e44x2MdaMA0GCSqGSIb3DQEBAQUABIIBAIrsb55+2qrn+896sA4Mh8xF
# KsAWNub1JMTAC83nIxDRv0wJvsX4pJAau169apQPPzAB42Z4W3Ec2QZf6dUp1cSc
# XUOa7j4GVVab9xAbc2Am40xRxPZQceoQeSQrIiNBUn/n0bmcImKk69wzmEzMMV2a
# EPp/A/bvPzOWwufj1WuqCLgXnYmbPMtHqVvun2mR0/lYVUfZEsLHEoHHtr4clMf5
# Q1VVt420LX4MBoKUj8VI4xVgkuuW56eEWRjYm9NYvZ5LlVlhSxHGi8prGCoqVPSl
# kB0V9cn5VYaIHGLEY7VhG9fXTxh9XmNKT6F63z8V+6SgzCRe+DZ/CkRlZRtuxPA=
# SIG # End signature block
