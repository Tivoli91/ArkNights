Function Start-ANTaskCollect(){ # 建议在一天的后面再来跑这个函数
	[CmdletBinding()]param(
	    [Parameter(Mandatory=$False)]
	    [switch]$ForceGetWeekTask,
		[switch]$CollectMainTask,
		[switch]$AlreadyInTaskPage
	)
    Function New-TaskFinishLoop($x,$y){ 
		1 .. 40| %{ # 连续点击15次, 领取任务
			adb_server shell input tap $Global:ANXML.ArkNights.taskcollect.clickget.$Global:ANR.x $Global:ANXML.ArkNights.taskcollect.clickget.$Global:ANR.y ; sleep -Milliseconds (300..500|Get-Random)
		}
		return
		1..2 |%{adb_server shell input tap $x $y ; sleep -Milliseconds 500} # 多点一次, 防止上次卡在领取任务报酬的界面

		Get-ANPartScreenshot $Global:ANXML.ArkNights.taskcollect.rect.main.$Global:ANR.x $Global:ANXML.ArkNights.taskcollect.rect.main.$Global:ANR.y $Global:ANXML.ArkNights.taskcollect.rect.main.$Global:ANR.w $Global:ANXML.ArkNights.taskcollect.rect.main.$Global:ANR.h # 截取模拟器部分屏幕
		
		# 查询是否报酬完全领完, 即无法再领取新的任务
		If( ! (Test-ANWordExist $Global:ANXML.ArkNights.taskcollect.rect.taskfinish.$Global:ANR.x $Global:ANXML.ArkNights.taskcollect.rect.taskfinish.$Global:ANR.y $Global:ANXML.ArkNights.taskcollect.rect.taskfinish.$Global:ANR.w $Global:ANXML.ArkNights.taskcollect.rect.taskfinish.$Global:ANR.h 'eng' '807669658369')){ # <-PLEASE 807669658369
			$loop_cnt= 0 # 查询是否还有任务未领取
			Do{
				If( $loop_cnt++ -gt 0 ){
					Get-ANPartScreenshot $Global:ANXML.ArkNights.taskcollect.rect.main.$Global:ANR.x $Global:ANXML.ArkNights.taskcollect.rect.main.$Global:ANR.y $Global:ANXML.ArkNights.taskcollect.rect.main.$Global:ANR.w $Global:ANXML.ArkNights.taskcollect.rect.main.$Global:ANR.h # 截取模拟器部分屏幕
				}

				$found_uncollected_task = Test-ANWordExist $Global:ANXML.ArkNights.taskcollect.rect.gettask.$Global:ANR.x $Global:ANXML.ArkNights.taskcollect.rect.gettask.$Global:ANR.y $Global:ANXML.ArkNights.taskcollect.rect.gettask.$Global:ANR.w $Global:ANXML.ArkNights.taskcollect.rect.gettask.$Global:ANR.h 'chi_sim' '209873904621462' # 截取 "点击领取" 四个字

				If( $found_uncollected_task ){
					1 .. 15| %{ # 连续点击15次, 领取任务
						adb_server shell input tap $Global:ANXML.ArkNights.taskcollect.clickget.$Global:ANR.x $Global:ANXML.ArkNights.taskcollect.clickget.$Global:ANR.y ; sleep -Milliseconds (150..200|Get-Random)
					}
					1..5 | %{
						adb_server shell input tap 120 300 ; sleep -Milliseconds (50..150|Get-Random) # 点击空白防止卡在奖励界面
					}
					# 查看这次循环后是否任务全部领完
					$found_daily_finished = Test-ANWordExist $Global:ANXML.ArkNights.taskcollect.rect.taskfinish.$Global:ANR.x $Global:ANXML.ArkNights.taskcollect.rect.taskfinish.$Global:ANR.y $Global:ANXML.ArkNights.taskcollect.rect.taskfinish.$Global:ANR.w $Global:ANXML.ArkNights.taskcollect.rect.taskfinish.$Global:ANR.h 'eng' '807669658369' # <-PLEASE 807669658369 
				}
			}While( $found_uncollected_task -and !$found_daily_finished )

		}
    }

	# 1 <-------------------------- 尝试进入任务界面
	If( !$AlreadyInTaskPage ){
		If( ! (Test-ANHomePage ) ){ # 不在首页
			# <-------------------------- 1.1 从上方任务栏进入
			adb_server shell input tap $Global:ANXML.ArkNights.menu.dropdownhouse.$Global:ANR.x $Global:ANXML.ArkNights.menu.dropdownhouse.$Global:ANR.y ; sleep 1 # click dropdown house icon
			adb_server shell input tap $Global:ANXML.ArkNights.menu.task.$Global:ANR.x $Global:ANXML.ArkNights.menu.task.$Global:ANR.y ; sleep 5 # click task icon
		}else{
			# <-------------------------- 1.2 从首页进入任务
			adb_server shell input tap $Global:ANXML.ArkNights.taskcollect.enter.$Global:ANR.x $Global:ANXML.ArkNights.taskcollect.enter.$Global:ANR.y  ; sleep 1
		}
	}
	
	New-TaskFinishLoop $Global:ANXML.ArkNights.taskcollect.tasks.daily.$Global:ANR.x $Global:ANXML.ArkNights.taskcollect.tasks.daily.$Global:ANR.y #日常任务
	
	If($ForceGetWeekTask -or [int](Get-Date).DayOfWeek -eq 6 ){ # 考虑到国外周六是一周的最后一天, 因此这里默认周6收取"周常任务"报酬
		New-TaskFinishLoop $Global:ANXML.ArkNights.taskcollect.tasks.weekly.$Global:ANR.x $Global:ANXML.ArkNights.taskcollect.tasks.weekly.$Global:ANR.y #周常任务
	}
	<# 使用频率不高,暂时注释掉
	If( $CollectMainTask ){
		1..2 |%{adb_server shell input tap $Global:ANXML.ArkNights.taskcollect.tasks.main.$Global:ANR.x $Global:ANXML.ArkNights.taskcollect.tasks.main.$Global:ANR.y ; sleep -Milliseconds 500}
		New-TaskFinishLoop $Global:ANXML.ArkNights.taskcollect.tasks.main.$Global:ANR.x $Global:ANXML.ArkNights.taskcollect.tasks.main.$Global:ANR.y #主线任务
	}
	#>
}

# SIG # Begin signature block
# MIIFmwYJKoZIhvcNAQcCoIIFjDCCBYgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU0sSXxB1a+Qw0d/ZXh9Qof4do
# KqCgggMwMIIDLDCCAhigAwIBAgIQ5nEzTE66NLBPoLYxG+E3AzAJBgUrDgMCHQUA
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFJPlAN1OGSfW
# FRSYwueSX72/5T0xMA0GCSqGSIb3DQEBAQUABIIBAFKGGFSX9jJiKYG1jy4EYfGz
# Ao4G86+fFy7v6vmvuVEkQ2EZSIBT9R6Ht7r8tvJ90jfdVXOX+dB7xiXgfYKlydVP
# IIcwU5rJUE0MVz+usME3JRIK3WLAwKPjveXdoOm1Gilk+VzJWP5B9/hhCM8Os7ax
# So0gVwT/1dW7o2gvuVQ3sHCKxOcNBmTVLeSQqJ1OnQJuR/Ocx3jUoadB516WQ7dN
# +DZUsmpk2lo5N7iHNBh+0BrIpwkhvC1vsOF1d/1GIXLN4X80kH/Aa4JRyy4gkXwr
# F9myQnBNlHGhpftBfW/otZufxajh4BAtdrSHGG5bsqpR//cIBaA/jbpkrd17l2s=
# SIG # End signature block
