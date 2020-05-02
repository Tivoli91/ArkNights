# ArkNights Automation

欢迎使用明日方舟自动化脚本.

本脚本有以下依赖条件.
1. 基于[网易MuMu模拟器](http://mumu.163.com/)Windows版本开发,本脚本最初成型时所用版本为:2.2.23(X86)(1017144757) 桌面版启动器版本:2.3.4(请自行安装),后期都是在此版本之后基础上开发.
	- 添加模拟器运行程序NemuPlayer.exe所在文件夹路径到环境变量里面,一般在xxx\emulator\nemu\vmonitor\bin目录
	- 添加模拟器自带安卓调试程序adb_server.exe所在文件夹路径到环境变量里面,一般在xxx\emulator\nemu\EmulatorShell目录
	- 取消模拟器以管理员权限运行,这一步不做的话,你要以管理员权限运行脚本,否则会有一个确认弹窗,不好处理。
	![取消模拟器以管理员权限运行](http://ww1.sinaimg.cn/large/007tGxtGgy1gee8knxfv1j30ez0i274l.jpg)
2. 由于使用OCR,所以使用了[Tesseract5.0](https://github.com/UB-Mannheim/tesseract/wiki)(请自行安装),并且针对模拟器简单的训练了一些数据.(现在Tesseract版本已有更新，但是我本地并未更新，所以并没有这一块的最新测试结果，但是理论上来说新版本应该兼容旧版本，OCR的结果应该一致. )
![下载示例](http://ww1.sinaimg.cn/large/007tGxtGgy1ge1uk5waj2j30vg0r7413.jpg)
	- anh.traineddata 针对招聘干员汉字的识别
	- anhn.traineddata 针对招聘干员 招聘许可数量数字的识别
	- ans.traineddata 针对基建 收取资源/信赖值/订单 等汉字的识别
3. 由于涉及OCR和点击操作,目前只适配了**模拟器自身**1080(1920x1080)和2K(2560x1440)分辨率下的操作.
	- 添加Tesseract主程序tesseract.exe所在文件夹路径到环境变量里面，就在Tesseract主安装目录下
	- 将上面3个训练文件anh.traineddata,anhn.traineddata,ans.traineddata复制到Tesseract主安装目录下的tessdata文件夹
4. [OCRUtility](https://gitee.com/chaoyuew/powershell/tree/master/Modules/MyDeveloppedModule/OCRUtility)模块,针对Tesseract的一些调用和其他图像处理的封装
5. 基于Win10 64位 PowerShell 5.1.18362.145 开发, 未在低版本**Windows/PowerShell/MuMu模拟器/Tesseract**上测试,不保证低版本稳定性.
6. 参考[解决WindowsPowerShell中文显示问号及乱码问题](https://blog.csdn.net/weixin_43426860/article/details/83348284)

基本功能已经实现,但是还是有很多缺陷,个人觉得应该不算外挂,且用且珍惜,目前还在更新新的功能中...

UPDATE
- 05/02/2020
	1. 优化初始连接登录逻辑,加入OCR识别检测加载完成
	2. 添加重新登录逻辑
	3. 添加检测"代理指挥"勾选, 未勾选时自动勾选
- 04/24/2020--优化判断主界面逻辑,判断图像文件不为空并且存在
- 04/21/2020--随着官方更新后,优化基建订单一件收取功能
- 02/04/2020--优化干员招聘的循环判定逻辑,现在没有可招聘干员时,依旧会尝试招聘新的干员
- 01/26/2020
	- 更改启动安卓模拟器的等待逻辑
	- 优化登录主界面的判断
- 12/29/2019--更改关卡完场后继续下一次的点击位置
- 12/28/2019--修复模拟器判断bug
- 12/26/2019--优化招聘干员时,判断招聘许可数量的逻辑, 增加判断MuMu模拟器启动程序以及其自带安卓测试桥程序是否在系统环境变量里面
- 12/21/2019--补全芯片关卡一周每天对应活动关卡,抽取补充理智函数
- 12/14/2019--优化自动补充理智战斗循环逻辑
- 12/12/2019--重新截取任务领取页面尺寸大小
- 12/08/2019--优化自动补充理智逻辑,优化登录逻辑（判断登录页面）
- 12/07/2019--添加自动补充理智
- 11/24/2019--更新登录密码验证逻辑
- 11/21/2019--添加使用无人机协助

### 视频演示
- B站 [当懒惰的程序员遇到了明日方舟](https://www.bilibili.com/video/av78702134/)