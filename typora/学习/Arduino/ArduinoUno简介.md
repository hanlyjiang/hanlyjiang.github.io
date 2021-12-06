# Arduino UNO 简介

## 资料

* [如何在arduino中添加多个自定义类文件-百度经验 (baidu.com)](https://jingyan.baidu.com/article/c910274b9f4862cd361d2dd3.html)
* [VSCode — PlatformIO latest documentation](https://docs.platformio.org/en/latest//integration/ide/vscode.html#quick-start)
* [Arduino - CLion Plugin | Marketplace (jetbrains.com)](https://plugins.jetbrains.com/plugin/7889-arduino)
* [Gravity: 人体热释电红外传感器-其他传感器-DFRobot创客商城](https://www.dfrobot.com.cn/goods-286.html)





![image-20211127231136712](https://gitee.com/hanlyjiang/image-repo/raw/master/image/202111272311786.png)

## 芯片-ATmega328P

* 8-bit AVR Microcontroller with 32K Bytes In-System Programmable Flash
* 高级 RISC（精简指令集计算机（RISC:Reduced Instruction Set Computing））
  * 131 个指令- 大部分只有一个时钟周期
  * 32x8通用目的寄存器
  * 纯静态操作
  * 在 16MHz 时吞吐量高达 16MIPS（Million Instructions Per Second 每秒百万条指令）
  * 片上2周期乘法器
* 高耐久性非易失性（non-volatile）存储器段
  * 32K字节系统内自可编程闪存
  * 1 KB EEPROM（电可擦只读存储器（Electrically Erasable Programmable Read - Only Memory））
  * 2KB 静态随机存储器（Static Random Access Memory）
* 外围设备
  * 两个 8 位定时器/计数器，具有单独的预分频器和比较模式
  * 一个 16 位定时器/计数器，具有单独的预分频器、比较模式和捕获模式
  * 带独立振荡器（oscillator）的实时计数器
  * 6 个 PWM 通道
  * 8 通道 10 位 ADC，采用 TQFP 和 QFN/MLF 封装
  * 可编程串行 USART（通用同步异步收发机（Universal Synchronous Asynchronous Receiver Transmitter））
  * Master/slave SPI serial interface
  * 面向字节的2线串行接口（兼容飞利浦I2C）
  * 可编程看门狗定时器，具有独立的片内振荡器
  * 片上模拟比较器
  * 引脚更换时中断和唤醒

## 引脚

<span style="color:red;">TQFP和MLF区别是什么？</span>

![image-20211124143659720](https://gitee.com/hanlyjiang/image-repo/raw/master/image/202111241436758.png)

![image-20211124172256595](https://gitee.com/hanlyjiang/image-repo/raw/master/image/202111241722629-board.png)

### VCC

### GND

### Port B (PB7:0) XTAL1/XTAL2/TOSC1/TOSC2

* Port B is an 8-bit bi-directional I/O port with internal pull-up resistors (selected for each bit).

### PortC（PC5:0）

* Port C is a 7-bit bi-directional I/O port with internal pull-up resistors (selected for each bit). 

### PC6/RESET

### PortD(PD7:0)

* Port D is an 8-bit bi-directional I/O port with internal pull-up resistors (selected for each bit).

### AVCC

### AREF

### ADC7:6 (TQFP and QFN/MLF Package Only)

In the TQFP and QFN/MLF package, ADC7:6 serve as analog inputs to the A/D converter. These pins are powered from the analog supply and serve as 10-bit ADC channels.



## Block Diagram

# ![image-20211124175044492](https://gitee.com/hanlyjiang/image-repo/raw/master/image/202111241750531.png) 

# 其他介绍

* 键盘是否单个按键的组合？
  * 不能
* ![image-20211125113906577](https://gitee.com/hanlyjiang/image-repo/raw/master/image/202111251139652.png)