Function Start-ANReceptionRoom(){
    # [CmdletBinding()]param(
        # [Parameter(Mandatory=$True)]
        # [string]$,
        # [Parameter(Mandatory=$False)]
        # [string]$
    # )
	
	If( ! (Test-ANHomePage ) ){ # 不在首页
		adb_server shell input tap 535 70 ; sleep 1 # click house icon
		adb_server shell input tap 1360 150 ; sleep 5 # 从上端菜单进入
    }else{
		# 2 <------------------------- 从首页点击基建进入, 等待5秒加载
		adb_server shell input tap 2041 1244 ; sleep 5
	}
	adb_server shell input tap 2400 400 ; sleep 5
	adb_server shell input tap 950 1300 ; sleep 1
	
	$img_file="$($env:TEMP)\ocr.jpg"
	New-ANScreenShot $img_file # 截取整个模拟器屏幕
	New-CropImage $img_file 1415 980 100 25 # 2K parameter, 截取 "PLEASE" 单词
}
<#
New-CropImage d:\temp\test.png 725 375 120 150  #  1
New-CropImage d:\temp\test.png 1120 520 95 150  #  2
New-CropImage d:\temp\test.png 1520 335 120 150 #  3
New-CropImage d:\temp\test.png 1950 430 120 150 #  4
New-CropImage d:\temp\test.png 1280 955 120 140 # 5
New-CropImage d:\temp\test.png 1695 835 120 150 #  6
New-CropImage d:\temp\test.png 825 880 120 150  # 7


#New-ANScreenShot d:\temp\test.png
New-CropImage d:\temp\test.png 2430 490 85 40 d:\temp\test1.png ;ii d:\temp\test1.png
#New-CropImage d:\temp\test.png 785 1315 120 35 d:\temp\test2.png ; ii d:\temp\test2.png
#New-CropImage d:\temp\test.png 1125 1315 120 35 d:\temp\test3.png ; ii d:\temp\test3.png

Test-OCRWord d:\temp\test2.png eng '123456' ; cat "$($env:TEMP)\ocrword.txt" -Encoding UTF8
#Test-OCRWord d:\temp\test2.png ans '123456' ; cat "$($env:TEMP)\ocrword.txt" -Encoding UTF8
#Test-OCRWord d:\temp\test3.png ans '123456' ; cat "$($env:TEMP)\ocrword.txt" -Encoding UTF8
#Test-OCRWord d:\temp\test.jpg eng '123456' ; cat "$($env:TEMP)\ocrword.txt" -Encoding UTF8



rmo ArkNights ; ipmo ArkNights




Out-Image D:\temp\test.jpg
Test-OCRWord d:\temp\test.jpg eng '123456' ; cat "$($env:TEMP)\ocrword.txt" -Encoding UTF8



Start-ANHR
Start-ANFriendVisit
Start-ANSourceCollect


Start-ANTaskLoop 4 150
Start-ANTaskCollect
Start-ANLogin


#>
# SIG # Begin signature block
# MIIFmwYJKoZIhvcNAQcCoIIFjDCCBYgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUvQ1UTkk+YIRiZdtMyu3+q/lh
# ceygggMwMIIDLDCCAhigAwIBAgIQ5nEzTE66NLBPoLYxG+E3AzAJBgUrDgMCHQUA
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFGgpmrWMUCib
# 6KL4M/uoVy1k333RMA0GCSqGSIb3DQEBAQUABIIBABMmN/3iZ6rqZDOTIXt7uZFZ
# U7I6fZGq+/LDu73u2mauOjp4Ch8rGnVgzLATeNhBaLt960GAz0vTNpG324Or6Oa0
# LiUBAul9nPscjOAU/QlBWw4Xi/Ss3XyrLEjZ8KhvXWVFqUvwtDuUznldntJFLpca
# H+gRsVssJgYVc+XMeDkaYV18NZUrHqO5Yvv6pMZhpN1gPTHd8ZcNl9LVxlFgXC5I
# ROvbe519B+oJD5CC9B4sueLlLGN/glPqZFT2ZzY5dpbXNOza4xPFM92lvdAqdFnV
# ebehKZ+OUU9FDFfwz104pz3uohFtBwx63yHaxGmx9fXQyPbx1hieUSVy0HNP8Tc=
# SIG # End signature block
