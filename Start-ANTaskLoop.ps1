Function Start-ANTaskLoop(){
	[CmdletBinding()]param(
	    [int]$start_cnt=1,
	    [int]$end_cnt,
	    [int]$sleep,
	    [int]$ignore_x=$Global:ANXML.ArkNights.combat.ignorelevelup.$Global:ANR.x,
	    [int]$ignore_y=$Global:ANXML.ArkNights.combat.ignorelevelup.$Global:ANR.y
	)
    
	If(!(Test-ANDelegate)){
		# 发现“代理指挥”没有勾选✔，尝试点击 “代理指挥”
		adb_server shell input tap $Global:ANXML.ArkNights.combat.start.delegate.$Global:ANR.x $Global:ANXML.ArkNights.combat.start.delegate.$Global:ANR.y
		# 再次检测“代理指挥”有没有被勾选， 如果没有通关过，这里是锁上的
		If(!(Test-ANDelegate)){
			throw "无法代理指挥，请确保你已三星通过此关"
		}
	}
	$x,$y=$Global:ANXML.ArkNights.combat.start.$Global:ANR.x,$Global:ANXML.ArkNights.combat.start.$Global:ANR.y
	$start_cnt .. $end_cnt|%{
		write-host "loop count $_"
		adb_server shell input tap $x $y ; sleep 2 # 点击 开始行动， 进入编队页面
		adb_server shell input tap $x $y ; sleep $sleep # 点击 开始行动， 正式开始作战
		1..5 | %{adb_server shell input tap $ignore_x $ignore_y ; sleep 1} # 点击空白处， 跳过作战胜利界面， 或者升级界面
	}
}

# SIG # Begin signature block
# MIIFmwYJKoZIhvcNAQcCoIIFjDCCBYgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUlHdFfO7iV8cbEkJXIg4Qiok+
# w1ygggMwMIIDLDCCAhigAwIBAgIQ5nEzTE66NLBPoLYxG+E3AzAJBgUrDgMCHQUA
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFLKr9TdbTiPO
# EZPZJaAJIuh9OghEMA0GCSqGSIb3DQEBAQUABIIBAB8sOtxT1Erldra/ifqf5MUJ
# cqRBSfOZiX/tCmrLP2isnR2gbIKHQdSPhxVyw6bRTUhIRttMAz9I98wSazKGr9vM
# KIxm2kvjx5X8qa0//6DXGzVlu7vxvZjWrDB/ZCLkSm0uXZfKxi7aJ3agMzAlpZvR
# KgAdox6qi8XYARz0qzM1buMMy3nlYhkbytP2rbtnHRcxcmb0P3QvleIHhkBFEaMw
# 3bPTw/lp1kLBxBjCgOlCzNoLn/lfpsyCstZxrD7Wqlpvbiq7tnMRKi4vE1hvf2OF
# C972qBvRwlvCJVbeyWUDAhoCJ5PvbnneAPqlq51ehCgrtQHg/bbkL0tJ+S8Vo1Y=
# SIG # End signature block
