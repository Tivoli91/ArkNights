Function Start-ANFriendVisit(){
	[CmdletBinding()]param(
	    [int]$an_friends_count,
		[switch]$AlreadyInFriendsPage,
	    [switch]$UpdateFriendsCount
	)
	Function Update-ANFriendCount([int]$number){
		$Global:ANXML.ArkNights.friends.amount.number = $number
		$Global:ANXML.save("$PSScriptRoot\ArkNightsConfig.xml")
		$Global:ANXML = [xml](cat "$PSScriptRoot\ArkNightsConfig.xml" -Encoding UTF8)
	}
	If( !$an_friends_count ){ # 尝试从XML文件获取好于个数
		$an_friends_count = $Global:ANXML.ArkNights.friends.amount.number
	}
	If( !$AlreadyInFriendsPage ){
		If( ! (Test-ANHomePage ) ){ # 不在首页
			$word = Switch($Global:ANR){
				"r1080"{'49704850' ; break}
				"r2k"{'102101121'}
			}
			
			If( Test-ANWordExist $Global:ANXML.ArkNights.friends.receptionroom.$Global:ANR.x $Global:ANXML.ArkNights.friends.receptionroom.$Global:ANR.y $Global:ANXML.ArkNights.friends.receptionroom.$Global:ANR.w $Global:ANXML.ArkNights.friends.receptionroom.$Global:ANR.h 'eng' $word ){ # 通过楼层判断是不是在 会客室 1F02
				# 判断是不是在 会客室  '202502345823460' Test-OCRWord 1058 133 890 73 'chi_sim' '202502345823460'
				adb_server shell input tap $Global:ANXML.ArkNights.friends.receptionroom.enter.$Global:ANR.x $Global:ANXML.ArkNights.friends.receptionroom.enter.$Global:ANR.y ; sleep 3 # 点击好友
			}else{
				adb_server shell input tap $Global:ANXML.ArkNights.menu.dropdownhouse.$Global:ANR.x $Global:ANXML.ArkNights.menu.dropdownhouse.$Global:ANR.y ; sleep 1 # 点击小房子图标
				adb_server shell input tap $Global:ANXML.ArkNights.menu.friends.$Global:ANR.x $Global:ANXML.ArkNights.menu.friends.$Global:ANR.y ; sleep 5 # 从上端菜单进入
			}
		}else{
			# <------------------------- 从首页点击好友进入
			adb_server shell input tap $Global:ANXML.ArkNights.friends.enter.$Global:ANR.x $Global:ANXML.ArkNights.friends.enter.$Global:ANR.y ; sleep 2
		}
	}
	
	write-host "Starting to visit $an_friends_count friends"
	adb_server shell input tap 200 380  ; sleep 2 # 点击好友列表
	
	If( !$an_friends_count ){ # 尝试从XML文件获取好于个数
		If( [string]::IsNullOrWhiteSpace($an_friends_count ) ){ # 未从XML获取到，使用OCR获取
			Get-ANPartScreenshot $Global:ANXML.ArkNights.friends.amount.$Global:ANR.x $Global:ANXML.ArkNights.friends.amount.$Global:ANR.y $Global:ANXML.ArkNights.friends.amount.$Global:ANR.w $Global:ANXML.ArkNights.friends.amount.$Global:ANR.h # 截取 "好友"人数数字
			Test-OCRWord "$($env:TEMP)\ocr.jpg" 'anhn' '123456'|out-null #  使用OCR 获取好友个数数字
			
			If( ($an_friends = cat "$($env:TEMP)\ocrword.txt" -Encoding UTF8 -Raw) -imatch "^\d{1,2}/"){ # 获取到好友个数 # 4/50
				$an_friends_count = $an_friends.Split('/')[0]
				Update-ANFriendCount
			}else{
				write-warning "Not found friends number!"  ; return
			}
		}
	}
	
	If( $an_friends_count -gt 0 ){
		If( $UpdateFriendsCount ){
			Update-ANFriendCount
		}
		adb_server shell input tap $Global:ANXML.ArkNights.friends.firstfriend.$Global:ANR.x $Global:ANXML.ArkNights.friends.firstfriend.$Global:ANR.y ; sleep 5 # 点击第一个好友, 进入会客室
		If( $an_friends_count -gt 1 ){
			2 .. $an_friends_count | %{
				adb_server shell input tap $Global:ANXML.ArkNights.friends.next.$Global:ANR.x $Global:ANXML.ArkNights.friends.next.$Global:ANR.y ; sleep 6 # 在会客室依次点击"访问下位"
			}
		}
	}
}
# SIG # Begin signature block
# MIIFmwYJKoZIhvcNAQcCoIIFjDCCBYgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU614iuEDrobVjwFjSHsK3pG/o
# +/+gggMwMIIDLDCCAhigAwIBAgIQ5nEzTE66NLBPoLYxG+E3AzAJBgUrDgMCHQUA
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFCK5gIT+JcfH
# NWkHsh3E+o7f2ANhMA0GCSqGSIb3DQEBAQUABIIBAIwJG8fIDMXJG2+TAfmKv0OH
# 5uXxBuhqdAgF2brRjVg2H8D+DGZLUIiz2zIgCwgfchMiZf9bbTNAIIMBvSIojDZL
# tUrgG9ssahmawgrxevWUTZ7unPMNazVFFG4QbuB8V1v/Q03RWCoM40gxODxhcnl5
# FNfuuoy974hz5KsGTdi4TuBCpz6gZVat84bjh/js6DzE4O+cRQMmMrAYw02XtvHU
# CTngKWruFIi7mTbcByqfsoe8xi0pTFXzkz4wBx/8ih8K7AXmY81sb1yWy2/DnJDi
# TAo1aBKtpzyAcL71RCkfpmx+Z+mKNmA3tHsmnttDW8KFICV4TqPOOyz6yB4IN10=
# SIG # End signature block
