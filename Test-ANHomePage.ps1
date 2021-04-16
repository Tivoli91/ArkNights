Function Test-ANHomePage($image){
    # 使用OCR检测固定区域文本判断是不是在首页
	Try{
		If( [string]::IsNullOrWhiteSpace($image ) -or !(test-path $image)){
			Get-ANPartScreenshot $Global:ANXML.ArkNights.homepagecheck.$Global:ANR.x $Global:ANXML.ArkNights.homepagecheck.$Global:ANR.y $Global:ANXML.ArkNights.homepagecheck.$Global:ANR.w $Global:ANXML.ArkNights.homepagecheck.$Global:ANR.h -new_img_file "$($env:TEMP)\ocr1.jpg" # 截取模拟器部分屏幕
			$image = "$($env:TEMP)\ocr1.jpg"
		}
		return (Test-OCRWord $image 'chi_sim' '3253438431')  # 编队
	}Catch{
		throw $_
	}
}
# SIG # Begin signature block
# MIIFmwYJKoZIhvcNAQcCoIIFjDCCBYgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUmw3ddvvbevH9UZwXSaIMd2xz
# vJOgggMwMIIDLDCCAhigAwIBAgIQ5nEzTE66NLBPoLYxG+E3AzAJBgUrDgMCHQUA
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFIxaIS0Ulbhu
# 7pEY+2Ozatz+uEUTMA0GCSqGSIb3DQEBAQUABIIBAFzPWuliI/ydL8hWe7MOh1uG
# YoK5bx64u+nvnhEDfE/0OUEb2uOLdxRo2trdrYjGMQWwUoJtl6BruVCyGwgBBKGT
# GmJOkcjZGSnDUvbMgvmP7OB+6jbudAsQw2zxyo1M6LtRMgS4uEyOKK/IwHLy5Cqf
# gO5dxISU8NY+/fTMyjjW4RWxcePHZXDmja9+hI7XOu7MhS2fZhsmM0dNf9ddxB12
# s+sbZaH+1TlqP8ZJlt6qkM0k6FhRS3ZbRgtV91LACHFilDuttCHqMmE07KdTq2Uh
# rgbQ8H4BCkj5pSXwcZKV+cQ3cyvjmUuS9X6Of8ADcKI9M97brZoWc2mFLFedTlI=
# SIG # End signature block
