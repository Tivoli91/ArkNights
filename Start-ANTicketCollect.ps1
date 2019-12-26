Function Start-ANTicketCollect(){
    [CmdletBinding()]param(
        [ValidateSet("Exp","Purchase","Money","Skill","Carbon")]
		[string]$Ticket='Money',
		[ValidateSet("1","2","3","4","5")]
		[int]$level=5, # 难度系数 1~5 关
		[ValidateScript({$_ -gt 0})]
		[int]$times=4, # 刷票次数
		[switch]$AutoAddReason, # 是否自动使用源石补充理智
		[switch]$AlreadyInCombatPage,
		[switch]$SpecialOpen # 活动开放日，所有管卡常驻
    )
	If( !$AlreadyInCombatPage ){
		Enter-ANCombatPage
	}
	adb_server shell input tap 350 $Global:ANXML.ArkNights.combat.ticket.enter.$Global:ANR.y ; sleep 1 # 点击物资筹备
	
	$day = [int](Get-Date).DayOfWeek # 0 is Sunday
	
	$p=1
	$p = Switch($Ticket){ # 星期的天数不同，有的位置会变
	    "Purchase"{
			Switch -regex ($day){
			    "1|4|6|0"{2; break}
			    "2|3|5"{ If( $SpecialOpen ){4}else{-1} ; break }
			}
			break
		}
	    "Money"{
			Switch -regex ($day){
			    "1|3|5"{ If( $SpecialOpen ){5}else{-1} ; break }
			    "2|4"{3; break}
			    "6|0"{4; break}
			}
			break
		}
	    "Skill"{
			Switch -regex ($day){
			    "1|4"{If( $SpecialOpen ){4}else{-1}; break}
				"2|3|5"{2;break}
				"0"{3;break}
				"6"{If( $SpecialOpen ){5}else{-1}; break}
			}
			break
		}
	    "Carbon"{
			Switch -regex ($day){
			    "1|3|5|6"{3; break}
				"2|4|0"{If( $SpecialOpen ){5}else{-1}; break}
			}
			break
		}
	}
	If( $p -eq -1 ){
		write-warning "Today is not available for $Ticket collection" ; return
	}
	adb_server shell input tap $Global:ANXML.ArkNights.combat.ticket.position."p$p".$Global:ANR.x 800 ; sleep 2 # 进入要打的关卡
	
	[int]$single_consume_reason_count = ($level + 1) * 5 # 当前关卡一次需要消耗的理智
	
	Start-ANTaskLoopWithReasonCheck $Global:ANXML.ArkNights.combat.hardlevel."hl$level".$Global:ANR.x $Global:ANXML.ArkNights.combat.hardlevel."hl$level".$Global:ANR.y $single_consume_reason_count $times $AutoAddReason
}

# SIG # Begin signature block
# MIIFmwYJKoZIhvcNAQcCoIIFjDCCBYgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUh4xdw3biGvDtBP7Sm6D5Rg3U
# eCigggMwMIIDLDCCAhigAwIBAgIQ5nEzTE66NLBPoLYxG+E3AzAJBgUrDgMCHQUA
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFGC0Z0/DDDHP
# tzF4VrGZBoH4+Nf2MA0GCSqGSIb3DQEBAQUABIIBAEXNgTKXIvfwsXqkH9fUw3t9
# 9Jrcv8yI0uHob7KN9zsyssNQM3/O9jnJnOHC7jJpzm96JQFUCLmTTZ35sC1a4j4i
# aPmyr8rQQqIpX5USv4mqunOt/eTMePq2wttMM2iJC8o/Qp4NuzdkzeDdLoLn7LzF
# oFHJhA6SH1WtawQN5zKNO+aWycSyD1slRuLCl+xh9Ndcmj0i8lnQH9XaLljVhB8v
# KLA2CFmxIdifUnVjFcySIDCNo+hnMMi1BleGD0CdHaSWYLywtnD8musZlnd2Gtwv
# uGEJlvJf8wii1enV6/7ng2O7NY2rp8to8riyOS++KhqcR145AJzP4M4ooD4Oao0=
# SIG # End signature block
