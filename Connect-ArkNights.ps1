Function Connect-ArkNights(){
	If( !(ps NemuPlayer -ea 4) ){
		Try{
			# 请把木木模拟器启动程序NemuPlayer.exe 添加到环境变量里面
			start NemuPlayer -ea 1 # 启动木木模拟器
			sleep 60
		}Catch{
			throw $_
		}
	}
	# check exit base warning
	If( $Global:ANXML.ArkNights.base.exitwarning -inotmatch "false" ){
		write-warning (cat "$PSScriptRoot\ExitBaseWarning" -Encoding UTF8)
		read-host " "
		$Global:ANXML.ArkNights.base.exitwarning = "false"
		$Global:ANXML.Save("$PSScriptRoot\ArkNightsConfig.xml")
	}
	$connect_result = adb_server connect '127.0.0.1:7555'
	If($connect_result -like "*connected to 127.0.0.1:7555*" ){
		# try to get simulator resolution
		Try{
			$Global:ANR = Switch -regex (((adb_server shell wm size) -join "").Split(':')[-1]){ # ANR = ArkNights Resolution
			    "1920x1080"{ 'r1080' ; break}
			    "2560x1440"{ 'r2k' ; break}
			    default{
					throw "Unsupported resolution so far:$_"
					return
				}
			}
			$connect_result
		}Catch{
			throw $_
		}
	}else{
		throw $connect_result
	}
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
