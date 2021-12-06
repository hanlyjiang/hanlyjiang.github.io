**编译命令拷贝：**

```shell
Using board 'uno' from platform in folder: /Users/hanlyjiang/Library/Arduino15/packages/arduino/hardware/avr/1.8.3
Using core 'arduino' from platform in folder: /Users/hanlyjiang/Library/Arduino15/packages/arduino/hardware/avr/1.8.3
Detecting libraries used...

export TOOL_BIN=/Users/hanlyjiang/Library/Arduino15/packages/arduino/tools/avr-gcc/7.3.0-atmel3.6.1-arduino7/
export WORK_DIR=/private/var/folders/3k/ktm92s8s047f5_y80v1gxmn40000gn/T/arduino-sketch-99FD42B7D70A026C0E3DA3278CC1F59E/
$TOOL_BIN/bin/avr-g++ 
-c  # 编译和汇编，但是不链接
-g  # 使用-g, -f, -m, -O, -W，--param开始的选项自动传递给avr-g++ 启动的子进程
-Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -flto -w 
-x c++ # 指定输入文件语言
-E -CC -mmcu=atmega328p -DF_CPU=16000000L -DARDUINO=10607 -DARDUINO_AVR_UNO -DARDUINO_ARCH_AVR -I/Users/hanlyjiang/Library/Arduino15/packages/arduino/hardware/avr/1.8.3/cores/arduino 
-I/Users/hanlyjiang/Library/Arduino15/packages/arduino/hardware/avr/1.8.3/variants/standard 
$WORK_DIR/sketch/Blink.ino.cpp 
-o /dev/null # 输出文件

Generating function prototypes...
$TOOL_BIN/bin/avr-g++ -c 
-g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -flto -w 
-x c++ 
-E -CC -mmcu=atmega328p -DF_CPU=16000000L -DARDUINO=10607 -DARDUINO_AVR_UNO -DARDUINO_ARCH_AVR 
-I/Users/hanlyjiang/Library/Arduino15/packages/arduino/hardware/avr/1.8.3/cores/arduino 
-I/Users/hanlyjiang/Library/Arduino15/packages/arduino/hardware/avr/1.8.3/variants/standard 
$WORK_DIR/sketch/Blink.ino.cpp 
-o $WORK_DIR/preproc/ctags_target_for_gcc_minus_e.cpp

/Users/hanlyjiang/Library/Arduino15/packages/builtin/tools/ctags/5.8-arduino11/ctags -u --language-force=c++ -f - --c++-kinds=svpf --fields=KSTtzns --line-directives $WORK_DIR/preproc/ctags_target_for_gcc_minus_e.cpp

Compiling sketch...
$TOOL_BIN/bin/avr-g++ -c -g -Os -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=atmega328p -DF_CPU=16000000L -DARDUINO=10607 -DARDUINO_AVR_UNO -DARDUINO_ARCH_AVR -I/Users/hanlyjiang/Library/Arduino15/packages/arduino/hardware/avr/1.8.3/cores/arduino -I/Users/hanlyjiang/Library/Arduino15/packages/arduino/hardware/avr/1.8.3/variants/standard $WORK_DIR/sketch/Blink.ino.cpp -o $WORK_DIR/sketch/Blink.ino.cpp.o
Compiling libraries...
Compiling core...
Using precompiled core: /private/var/folders/3k/ktm92s8s047f5_y80v1gxmn40000gn/T/arduino-core-cache/core_arduino_avr_uno_59708261af760a8ad9a56ff4a0616dba.a

Linking everything together...

$TOOL_BIN/bin/avr-gcc 
-Os -g -flto -fuse-linker-plugin -Wl,--gc-sections -mmcu=atmega328p \
-o $WORK_DIR/Blink.ino.elf \
$WORK_DIR/sketch/Blink.ino.cpp.o \
$WORK_DIR/../arduino-core-cache/core_arduino_avr_uno_59708261af760a8ad9a56ff4a0616dba.a -L$WORK_DIR \
-lm $TOOL_BIN/bin/avr-objcopy \
-O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0 $WORK_DIR/Blink.ino.elf $WORK_DIR/Blink.ino.eep


$TOOL_BIN/bin/avr-objcopy \
-O ihex -R .eeprom $WORK_DIR/Blink.ino.elf $WORK_DIR/Blink.ino.hex


$TOOL_BIN/bin/avr-size -A $WORK_DIR/Blink.ino.elf
Sketch uses 924 bytes (2%) of program storage space. Maximum is 32256 bytes.
Global variables use 9 bytes (0%) of dynamic memory, leaving 2039 bytes for local variables. Maximum is 2048 bytes.

--------------------------
Compilation complete.

```

`$TOOL_BIN/bin/avr-size` 输出：

```shell
$TOOL_BIN/bin/avr-size -A $WORK_DIR/Blink.ino.elf
/private/var/folders/3k/ktm92s8s047f5_y80v1gxmn40000gn/T/arduino-sketch-99FD42B7D70A026C0E3DA3278CC1F59E//Blink.ino.elf  :
section                     size      addr
.data                          0   8388864
.text                        924         0
.bss                           9   8388864
.comment                      17         0
.note.gnu.avr.deviceinfo      64         0
.debug_aranges               104         0
.debug_info                 3579         0
.debug_abbrev               2043         0
.debug_line                 1337         0
.debug_frame                 180         0
.debug_str                  1130         0
.debug_loc                  1167         0
.debug_ranges                 48         0
Total                      10602
```