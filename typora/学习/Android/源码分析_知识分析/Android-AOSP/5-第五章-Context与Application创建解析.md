# Context分析



本文分析Android Application的创建过程及Context的创建，还有Application/Activity/Service各组件中的Context的差别之处；

<!-- more -->

## 分析大纲

* Context的创建，Context是什么？
* Application的创建，Applicatoin和Context的关联
* Activity的创建，Activity和Context的关联
* Service的创建，Service和Context的关联

## Context的创建&Context是什么

我们从什么地方开始呢？

我们之前分析Service的启动时，绘制过下面的调用流程，如下图所示：

system_process 进程中通知zygote进程启动了我们的APP进程，然后执行ActivitThread的main方法，故我们从这里开始，主要的关注点在于Context的创建。


<svg width="684px" height="711px" viewBox="0 0 684 711" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <g id="2-Context&amp;Application" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
        <g id="Context的创建-查找入口点" transform="translate(-254.000000, -94.000000)">
            <g id="编组" transform="translate(39.000000, 28.000000)">
                <g transform="translate(217.000000, 115.000000)" id="架构图/模块-源码备份-25">
                    <rect id="矩形" fill="#D5FFA2" x="0" y="0" width="299.399061" height="34" rx="6.9623431"></rect>
                    <text id="方法过程" font-family="NotoSansCJKsc-Medium, Noto Sans CJK SC" font-size="12.1841004" font-weight="400" letter-spacing="0.134025104" fill="#232323" fill-opacity="0.88378138">
                        <tspan x="18.476769" y="14">ActivityManagerService#startProcessLocked</tspan>
                    </text>
                    <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="8.70292887" font-weight="300" letter-spacing="0.0957322235" fill="#151515" fill-opacity="0.88378138">
                        <tspan x="44.0851371" y="30.122449">com/android/server/am/ActivityManagerService.java</tspan>
                    </text>
                </g>
                <g transform="translate(546.000000, 115.000000)" id="架构图/模块-源码备份-37">
                    <rect id="矩形" fill="#D5FFA2" x="0" y="0" width="299.399061" height="34" rx="6.9623431"></rect>
                    <text id="方法过程" font-family="NotoSansCJKsc-Medium, Noto Sans CJK SC" font-size="12.1841004" font-weight="400" letter-spacing="0.134025104" fill="#232323" fill-opacity="0.88378138">
                        <tspan x="18.476769" y="14">ActivityManagerService#startProcessLocked</tspan>
                    </text>
                    <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="8.70292887" font-weight="300" letter-spacing="0.0957322235" fill="#151515" fill-opacity="0.88378138">
                        <tspan x="37.0705764" y="30.122449">startProcessLocked(hostingRecord, entryPoint) 带入口点</tspan>
                    </text>
                </g>
                <g transform="translate(524.000000, 171.000000)" id="架构图/模块-源码备份-38">
                    <rect id="矩形" fill="#D5FFA2" x="0" y="0" width="174.816901" height="34" rx="6.9623431"></rect>
                    <text id="方法过程" font-family="NotoSansCJKsc-Medium, Noto Sans CJK SC" font-size="12.1841004" font-weight="400" letter-spacing="0.134025104" fill="#232323" fill-opacity="0.88378138">
                        <tspan x="13.7433796" y="14">ProcessList#startProcess</tspan>
                    </text>
                    <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="8.70292887" font-weight="300" letter-spacing="0.0957322235" fill="#151515" fill-opacity="0.88378138">
                        <tspan x="14.2951452" y="30.122449">带入口类 android.app.ActivityThread</tspan>
                    </text>
                </g>
                <g transform="translate(715.000000, 171.000000)" id="架构图/模块-源码备份-49">
                    <rect id="矩形" fill="#D5FFA2" x="0" y="0" width="183.859155" height="34" rx="6.9623431"></rect>
                    <text id="方法过程" font-family="NotoSansCJKsc-Medium, Noto Sans CJK SC" font-size="12.1841004" font-weight="400" letter-spacing="0.134025104" fill="#232323" fill-opacity="0.88378138">
                        <tspan x="5.3980963" y="14">handleProcessStartedLocked</tspan>
                    </text>
                    <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="8.70292887" font-weight="300" letter-spacing="0.0957322235" fill="#151515" fill-opacity="0.88378138">
                        <tspan x="29.1292427" y="30.122449">记录ProcessRecord（通过PID）</tspan>
                    </text>
                </g>
                <g transform="translate(546.000000, 227.000000)" id="架构图/模块-源码备份-39">
                    <rect id="矩形" fill="#D5FFA2" x="0" y="0" width="299.399061" height="34" rx="6.9623431"></rect>
                    <text id="方法过程" font-family="NotoSansCJKsc-Medium, Noto Sans CJK SC" font-size="12.1841004" font-weight="400" letter-spacing="0.134025104" fill="#232323" fill-opacity="0.88378138">
                        <tspan x="26.4451707" y="14">android.os.ZygoteProcess#startViaZygote</tspan>
                    </text>
                    <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="8.70292887" font-weight="300" letter-spacing="0.0957322235" fill="#151515" fill-opacity="0.88378138">
                        <tspan x="76.586225" y="30.122449">带入口类 android.app.ActivityThread</tspan>
                    </text>
                </g>
                <g transform="translate(546.000000, 283.000000)" id="架构图/模块-源码备份-40">
                    <rect id="矩形" fill="#D5FFA2" x="0" y="0" width="299.399061" height="34" rx="6.9623431"></rect>
                    <text id="方法过程" font-family="NotoSansCJKsc-Medium, Noto Sans CJK SC" font-size="12.1841004" font-weight="400" letter-spacing="0.134025104" fill="#232323" fill-opacity="0.88378138">
                        <tspan x="15.3576393" y="14">ZygoteProcess#zygoteSendArgsAndGetResult</tspan>
                    </text>
                    <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="8.70292887" font-weight="300" letter-spacing="0.0957322235" fill="#151515" fill-opacity="0.88378138">
                        <tspan x="76.586225" y="30.122449">带入口类 android.app.ActivityThread</tspan>
                    </text>
                </g>
                <g transform="translate(546.000000, 345.000000)" id="架构图/模块-源码备份-41">
                    <rect id="矩形" fill="#FFED99" x="0" y="0" width="299.399061" height="34" rx="6.9623431"></rect>
                    <text id="方法过程" font-family="NotoSansCJKsc-Medium, Noto Sans CJK SC" font-size="12.1841004" font-weight="400" letter-spacing="0.134025104" fill="#232323" fill-opacity="0.88378138">
                        <tspan x="130.26589" y="14">zygote</tspan>
                    </text>
                    <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="8.70292887" font-weight="300" letter-spacing="0.0957322235" fill="#151515" fill-opacity="0.88378138">
                        <tspan x="110.270911" y="30.122449">zygote创建新的进程</tspan>
                    </text>
                </g>
                <g transform="translate(546.000000, 401.000000)" id="架构图/模块-源码备份-42">
                    <rect id="矩形" fill="#FFBBA2" x="0" y="0" width="299.399061" height="34" rx="6.9623431"></rect>
                    <text id="方法过程" font-family="NotoSansCJKsc-Medium, Noto Sans CJK SC" font-size="12.1841004" font-weight="400" letter-spacing="0.134025104" fill="#232323" fill-opacity="0.88378138">
                        <tspan x="83.393656" y="14">ActivityThread#main()</tspan>
                    </text>
                    <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="8.70292887" font-weight="300" letter-spacing="0.0957322235" fill="#151515" fill-opacity="0.88378138">
                        <tspan x="101.306895" y="30.122449">进程创建后执行入口函数</tspan>
                    </text>
                </g>
                <g transform="translate(546.000000, 456.000000)" id="架构图/模块-源码备份-44">
                    <rect id="矩形" fill="#FFBBA2" x="0" y="0" width="299.399061" height="34" rx="6.9623431"></rect>
                    <text id="方法过程" font-family="NotoSansCJKsc-Medium, Noto Sans CJK SC" font-size="12.1841004" font-weight="400" letter-spacing="0.134025104" fill="#232323" fill-opacity="0.88378138">
                        <tspan x="84.1307941" y="14">ActivityThread#attach</tspan>
                    </text>
                    <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="8.70292887" font-weight="300" letter-spacing="0.0957322235" fill="#151515" fill-opacity="0.88378138">
                        <tspan x="134.190911" y="30.122449">module</tspan>
                    </text>
                </g>
                <g transform="translate(217.000000, 175.000000)" id="架构图/模块-源码备份-26">
                    <rect id="矩形" fill="#D5FFA2" x="0" y="0" width="299.399061" height="34" rx="6.9623431"></rect>
                    <text id="方法过程" font-family="NotoSansCJKsc-Medium, Noto Sans CJK SC" font-size="12.1841004" font-weight="400" letter-spacing="0.134025104" fill="#232323" fill-opacity="0.88378138">
                        <tspan x="50.3381916" y="14">ProcessList#startProcessLocked()</tspan>
                    </text>
                    <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="8.70292887" font-weight="300" letter-spacing="0.0957322235" fill="#151515" fill-opacity="0.88378138">
                        <tspan x="67.9050534" y="30.122449">com/android/server/am/ProcessList.java</tspan>
                    </text>
                </g>
                <g transform="translate(215.000000, 230.000000)" id="架构图/模块-源码备份-11">
                    <rect id="矩形" fill="#D5FFA2" x="0" y="0" width="299.399061" height="34" rx="6.9623431"></rect>
                    <text id="方法过程" font-family="NotoSansCJKsc-Medium, Noto Sans CJK SC" font-size="12.1841004" font-weight="400" letter-spacing="0.134025104" fill="#232323" fill-opacity="0.88378138">
                        <tspan x="35.3456561" y="14">ProcessList#newProcessRecordLocked</tspan>
                    </text>
                    <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="8.70292887" font-weight="300" letter-spacing="0.0957322235" fill="#151515" fill-opacity="0.88378138">
                        <tspan x="67.9050534" y="30.122449">com/android/server/am/ProcessList.java</tspan>
                    </text>
                </g>
                <g transform="translate(215.000000, 280.000000)" id="架构图/模块-源码备份-27">
                    <rect id="矩形" fill="#D5FFA2" x="0" y="0" width="299.399061" height="34" rx="6.9623431"></rect>
                    <text id="方法过程" font-family="NotoSansCJKsc-Medium, Noto Sans CJK SC" font-size="12.1841004" font-weight="400" letter-spacing="0.134025104" fill="#232323" fill-opacity="0.88378138">
                        <tspan x="35.3456561" y="14">ProcessList#newProcessRecordLocked</tspan>
                    </text>
                    <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="8.70292887" font-weight="300" letter-spacing="0.0957322235" fill="#151515" fill-opacity="0.88378138">
                        <tspan x="69.8066434" y="30.122449">new ProcessRecord(ams, info, proc, uid)</tspan>
                    </text>
                </g>
                <g transform="translate(215.000000, 66.000000)" id="架构图/模块-源码备份-9">
                    <rect id="矩形" fill="#D5FFA2" x="0" y="0" width="299.399061" height="34" rx="6.9623431"></rect>
                    <text id="方法过程" font-family="NotoSansCJKsc-Medium, Noto Sans CJK SC" font-size="12.1841004" font-weight="400" letter-spacing="0.134025104" fill="#232323" fill-opacity="0.88378138">
                        <tspan x="36.2533715" y="14">ActiveServices#bringUpServiceLocked</tspan>
                    </text>
                    <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="8.70292887" font-weight="300" letter-spacing="0.0957322235" fill="#151515" fill-opacity="0.88378138">
                        <tspan x="62.0131706" y="30.122449">com/android/server/am/ActiveServices.java</tspan>
                    </text>
                </g>
                <path id="直线-7备份" d="M365.935146,98.012222 L365.935,106.997 L369.675732,106.997076 L365.5,114.997076 L361.324268,106.997076 L365.064,106.997 L365.064854,98.012222 L365.935146,98.012222 Z" fill="#979797" fill-rule="nonzero"></path>
                <path id="直线-8备份" d="M365.935146,147.998187 L365.935,166.011 L369.675732,166.011111 L365.5,174.011111 L361.324268,166.011111 L365.064,166.011 L365.064854,147.998187 L365.935146,147.998187 Z" fill="#979797" fill-rule="nonzero"></path>
                <path id="直线-9备份" d="M365.935146,206.990779 L365.935,222.018 L369.675732,222.018519 L365.5,230.018519 L361.324268,222.018519 L365.064,222.018 L365.064854,206.990779 L365.935146,206.990779 Z" fill="#979797" fill-rule="nonzero"></path>
                <path id="直线-10备份" d="M365.935146,263.012222 L365.935,271.997 L369.675732,271.997076 L365.5,279.997076 L361.324268,271.997076 L365.064,271.997 L365.064854,263.012222 L365.935146,263.012222 Z" fill="#979797" fill-rule="nonzero"></path>
                <line x1="514.66" y1="132.5" x2="546.34" y2="132.5" id="直线-23" stroke="#979797" stroke-width="1.3" stroke-linecap="square"></line>
                <path id="直线-13" d="M645.15,148.007895 L645.15,161.953 L649.75,161.953216 L644.5,172.953216 L639.25,161.953216 L643.85,161.953 L643.85,148.007895 L645.15,148.007895 Z" fill="#979797" fill-rule="nonzero"></path>
                <path id="直线-14" d="M664.15,203.988889 L664.15,215.972 L668.75,215.972222 L663.5,226.972222 L658.25,215.972222 L662.85,215.972 L662.85,203.988889 L664.15,203.988889 Z" fill="#979797" fill-rule="nonzero"></path>
                <path id="直线-14备份" d="M797.15,147.988889 L797.15,159.972 L801.75,159.972222 L796.5,170.972222 L791.25,159.972222 L795.85,159.972 L795.85,147.988889 L797.15,147.988889 Z" fill="#979797" fill-rule="nonzero"></path>
                <path id="直线-15" d="M695.15,260.988889 L695.15,272.972 L699.75,272.972222 L694.5,283.972222 L689.25,272.972222 L693.85,272.972 L693.85,260.988889 L695.15,260.988889 Z" fill="#979797" fill-rule="nonzero"></path>
                <path id="直线-24" d="M695.15,317.002174 L695.15,335.958 L699.75,335.958937 L694.5,346.958937 L689.25,335.958937 L693.85,335.958 L693.85,317.002174 L695.15,317.002174 Z" fill="#979797" fill-rule="nonzero"></path>
                <text id="socket" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="10.4" font-weight="300" letter-spacing="0.114399999" fill="#020202" fill-opacity="0.88378138">
                    <tspan x="698.4208" y="332">socket</tspan>
                </text>
                <path id="直线-25" d="M695.15,378.988889 L695.15,390.972 L699.75,390.972222 L694.5,401.972222 L689.25,390.972222 L693.85,390.972 L693.85,378.988889 L695.15,378.988889 Z" fill="#979797" fill-rule="nonzero"></path>
                <line x1="864.5" y1="201.649733" x2="864.5" y2="686.350267" id="直线-26" stroke="#979797" stroke-width="1.3" stroke-linecap="square" stroke-dasharray="3.9"></line>
                <g transform="translate(546.000000, 514.000000)" id="架构图/模块-源码备份-45">
                    <rect id="矩形" fill="#FFBBA2" x="0" y="0" width="299.399061" height="34" rx="6.9623431"></rect>
                    <text id="方法过程" font-family="NotoSansCJKsc-Medium, Noto Sans CJK SC" font-size="12.1841004" font-weight="400" letter-spacing="0.134025104" fill="#232323" fill-opacity="0.88378138">
                        <tspan x="43.4298067" y="14">IActivityManager#attachApplication</tspan>
                    </text>
                    <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="8.70292887" font-weight="300" letter-spacing="0.0957322235" fill="#151515" fill-opacity="0.88378138">
                        <tspan x="134.190911" y="30.122449">module</tspan>
                    </text>
                </g>
                <path id="直线-27" d="M695.15,433.988889 L695.15,445.972 L699.75,445.972222 L694.5,456.972222 L689.25,445.972222 L693.85,445.972 L693.85,433.988889 L695.15,433.988889 Z" fill="#979797" fill-rule="nonzero"></path>
                <path id="直线-28" d="M695.15,490 L695.15,504.961 L699.75,504.961111 L694.5,515.961111 L689.25,504.961111 L693.85,504.961 L693.85,490 L695.15,490 Z" fill="#979797" fill-rule="nonzero"></path>
                <g transform="translate(546.000000, 627.000000)" id="架构图/模块-源码备份-46">
                    <rect id="矩形" fill="#D5FFA2" x="0" y="0" width="299.399061" height="34" rx="6.9623431"></rect>
                    <text id="方法过程" font-family="NotoSansCJKsc-Medium, Noto Sans CJK SC" font-size="12.1841004" font-weight="400" letter-spacing="0.134025104" fill="#232323" fill-opacity="0.88378138">
                        <tspan x="23.6367356" y="14">ActivityManagerService#attachApplication</tspan>
                    </text>
                    <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="8.70292887" font-weight="300" letter-spacing="0.0957322235" fill="#151515" fill-opacity="0.88378138">
                        <tspan x="134.190911" y="30.122449">module</tspan>
                    </text>
                </g>
                <g transform="translate(510.000000, 687.000000)" id="架构图/模块-源码备份-47">
                    <rect id="矩形" fill="#D5FFA2" x="0" y="0" width="369.7277" height="34" rx="6.9623431"></rect>
                    <text id="方法过程" font-family="NotoSansCJKsc-Medium, Noto Sans CJK SC" font-size="12.1841004" font-weight="400" letter-spacing="0.134025104" fill="#232323" fill-opacity="0.88378138">
                        <tspan x="37.5641678" y="14">ActivityManagerService#attachApplicationLocked</tspan>
                    </text>
                    <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="8.70292887" font-weight="300" letter-spacing="0.0957322235" fill="#151515" fill-opacity="0.88378138">
                        <tspan x="113.952385" y="30.122449">获取之前缓存的ProcessRecord(app)</tspan>
                    </text>
                </g>
                <g transform="translate(510.000000, 743.000000)" id="架构图/模块-源码备份-50">
                    <rect id="矩形" fill="#D5FFA2" x="0" y="0" width="369.7277" height="34" rx="6.9623431"></rect>
                    <text id="方法过程" font-family="NotoSansCJKsc-Medium, Noto Sans CJK SC" font-size="12.1841004" font-weight="400" letter-spacing="0.134025104" fill="#232323" fill-opacity="0.88378138">
                        <tspan x="103.236469" y="14">ProcessRecord#makeActive</tspan>
                    </text>
                    <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="8.70292887" font-weight="300" letter-spacing="0.0957322235" fill="#151515" fill-opacity="0.88378138">
                        <tspan x="67.8834312" y="30.122449">app.makeActive(thread, mProcessStats) ; thread = _thread;</tspan>
                    </text>
                </g>
                <g transform="translate(546.000000, 568.000000)" id="架构图/模块-源码备份-36">
                    <rect id="矩形" fill="#FFED99" x="0" y="0" width="299.399061" height="34" rx="6.9623431"></rect>
                    <text id="方法过程" font-family="NotoSansCJKsc-Medium, Noto Sans CJK SC" font-size="12.1841004" font-weight="400" letter-spacing="0.134025104" fill="#232323" fill-opacity="0.88378138">
                        <tspan x="125.203397" y="14">transact</tspan>
                    </text>
                    <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="8.70292887" font-weight="300" letter-spacing="0.0957322235" fill="#151515" fill-opacity="0.88378138">
                        <tspan x="136.553756" y="30.122449">binder</tspan>
                    </text>
                </g>
                <path id="直线-29" d="M695.15,546.997059 L695.15,557.964 L699.75,557.964052 L694.5,568.964052 L689.25,557.964052 L693.85,557.964 L693.85,546.997059 L695.15,546.997059 Z" fill="#979797" fill-rule="nonzero"></path>
                <path id="直线-30" d="M695.15,600.992857 L695.15,616.968 L699.75,616.968254 L694.5,627.968254 L689.25,616.968254 L693.85,616.968 L693.85,600.992857 L695.15,600.992857 Z" fill="#979797" fill-rule="nonzero"></path>
                <path id="直线-31" d="M695.15,660.992857 L695.15,676.968 L699.75,676.968254 L694.5,687.968254 L689.25,676.968254 L693.85,676.968 L693.85,660.992857 L695.15,660.992857 Z" fill="#979797" fill-rule="nonzero"></path>
                <path id="直线-32" d="M695.15,720.988889 L695.15,732.972 L699.75,732.972222 L694.5,743.972222 L689.25,732.972222 L693.85,732.972 L693.85,720.988889 L695.15,720.988889 Z" fill="#979797" fill-rule="nonzero"></path>
            </g>
        </g>
    </g>
</svg>

> **ThreadLocal简要解释:**
>
> * ThreadLocal相当于一个线程级别的变量，在线程作用域内可用。相当于动态地往线程类中加属性。
> * ThreadLocal只是一组操作接口而已，用途是往Thread的一个Map类型的属性中插入或取出变量，方便我们操作；每个线程中的该变量需要自行单独设置值。
> * 网上很多文章开头就说是解决多线程访问共享变量的并发问题，实在是误导了方向；
>
> 可参考： [**开门见山ThreadLocal**](http://www.threadlocal.cn/)
>
> 错误的误导： 
>
> * [ThreadLocal作用、场景、原理](https://www.jianshu.com/p/6fc3bba12f38)
> * [ThreadLocal 超深度源码解读，为什么要注意内存泄漏？不要道听途说，源码底下见真知！](https://xie.infoq.cn/article/d991763f6b9ff03da198d0a0a)

### 入口：android.app.ActivityThread#main

总体流程：


<svg width="663px" height="580px" viewBox="0 0 663 580" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <g id="2-Context&amp;Application" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
        <g id="ActivityThread#main" transform="translate(-33.000000, -29.000000)">
            <g id="标题组件" transform="translate(33.000000, 29.000000)">
                <g id="标题边框">
                    <path d="M320,0.5 C322.071068,0.5 323.946068,1.33946609 325.303301,2.69669914 C326.660534,4.05393219 327.5,5.92893219 327.5,8 L327.5,8 L327.5,429 C327.5,431.071068 326.660534,432.946068 325.303301,434.303301 C323.946068,435.660534 322.071068,436.5 320,436.5 L320,436.5 L8,436.5 C5.92893219,436.5 4.05393219,435.660534 2.69669914,434.303301 C1.33946609,432.946068 0.5,431.071068 0.5,429 L0.5,429 L0.5,8 C0.5,5.92893219 1.33946609,4.05393219 2.69669914,2.69669914 C4.05393219,1.33946609 5.92893219,0.5 8,0.5 L8,0.5 Z" stroke="#FF9500"></path>
                    <path d="M8,0 L320,0 C324.418278,-8.11624501e-16 328,3.581722 328,8 L328,30 L328,30 L0,30 L0,8 C-5.41083001e-16,3.581722 3.581722,8.11624501e-16 8,0 Z" id="标题" fill="#FF9500"></path>
                </g>
                <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                    <tspan x="104.438" y="20">ActivityThread#main()</tspan>
                </text>
            </g>
            <g id="Looper" transform="translate(53.000000, 81.000000)">
                <g id="消息循环">
                    <g id="标题边框">
                        <path d="M281,0.5 C283.071068,0.5 284.946068,1.33946609 286.303301,2.69669914 C287.660534,4.05393219 288.5,5.92893219 288.5,8 L288.5,8 L288.5,160 C288.5,162.071068 287.660534,163.946068 286.303301,165.303301 C284.946068,166.660534 283.071068,167.5 281,167.5 L281,167.5 L8,167.5 C5.92893219,167.5 4.05393219,166.660534 2.69669914,165.303301 C1.33946609,163.946068 0.5,162.071068 0.5,160 L0.5,160 L0.5,8 C0.5,5.92893219 1.33946609,4.05393219 2.69669914,2.69669914 C4.05393219,1.33946609 5.92893219,0.5 8,0.5 L8,0.5 Z" stroke="#FF9500"></path>
                        <path d="M8,0 L281,0 C285.418278,-8.11624501e-16 289,3.581722 289,8 L289,30 L289,30 L0,30 L0,8 C-5.41083001e-16,3.581722 3.581722,8.11624501e-16 8,0 Z" id="标题" fill="#FF9500"></path>
                    </g>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="97.652" y="20">进入消息队列循环</tspan>
                    </text>
                </g>
                <g id="循环" transform="translate(45.000000, 52.000000)">
                    <rect id="矩形备份" fill="#34C759" x="0" y="0" width="199" height="30" rx="8"></rect>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="21.644" y="19">Looper.prepareMainLooper()</tspan>
                    </text>
                </g>
                <g id="循环备份" transform="translate(45.000000, 108.000000)">
                    <rect id="矩形备份" fill="#34C759" x="0" y="0" width="199" height="30" rx="8"></rect>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="22.388" y="19">进入消息循环：Looper.loop()</tspan>
                    </text>
                </g>
            </g>
            <g id="ActivityThread" transform="translate(53.000000, 268.000000)">
                <g id="消息循环备份">
                    <g id="标题边框">
                        <path d="M281,0.5 C283.071068,0.5 284.946068,1.33946609 286.303301,2.69669914 C287.660534,4.05393219 288.5,5.92893219 288.5,8 L288.5,8 L288.5,160 C288.5,162.071068 287.660534,163.946068 286.303301,165.303301 C284.946068,166.660534 283.071068,167.5 281,167.5 L281,167.5 L8,167.5 C5.92893219,167.5 4.05393219,166.660534 2.69669914,165.303301 C1.33946609,163.946068 0.5,162.071068 0.5,160 L0.5,160 L0.5,8 C0.5,5.92893219 1.33946609,4.05393219 2.69669914,2.69669914 C4.05393219,1.33946609 5.92893219,0.5 8,0.5 L8,0.5 Z" stroke="#FF9500"></path>
                        <path d="M8,0 L281,0 C285.418278,-8.11624501e-16 289,3.581722 289,8 L289,30 L289,30 L0,30 L0,8 C-5.41083001e-16,3.581722 3.581722,8.11624501e-16 8,0 Z" id="标题" fill="#FF9500"></path>
                    </g>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="87.83" y="20">初始化ActivityThread</tspan>
                    </text>
                </g>
                <g id="循环备份-2" transform="translate(45.000000, 52.000000)">
                    <rect id="矩形备份" fill="#5E5CE6" x="0" y="0" width="199" height="30" rx="8"></rect>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="14.438" y="19">构造对象：new ActivityThread()</tspan>
                    </text>
                </g>
                <g id="循环备份-3" transform="translate(45.000000, 108.000000)">
                    <rect id="矩形备份" fill="#5E5CE6" x="0" y="0" width="199" height="30" rx="8"></rect>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="38.012" y="19">ActivityThread.attach()</tspan>
                    </text>
                </g>
            </g>
            <g id="ActivityThread()" transform="translate(407.000000, 29.000000)">
                <g id="消息循环备份-2">
                    <g id="标题边框">
                        <path d="M281,0.5 C283.071068,0.5 284.946068,1.33946609 286.303301,2.69669914 C287.660534,4.05393219 288.5,5.92893219 288.5,8 L288.5,8 L288.5,288 C288.5,290.071068 287.660534,291.946068 286.303301,293.303301 C284.946068,294.660534 283.071068,295.5 281,295.5 L281,295.5 L8,295.5 C5.92893219,295.5 4.05393219,294.660534 2.69669914,293.303301 C1.33946609,291.946068 0.5,290.071068 0.5,288 L0.5,288 L0.5,8 C0.5,5.92893219 1.33946609,4.05393219 2.69669914,2.69669914 C4.05393219,1.33946609 5.92893219,0.5 8,0.5 L8,0.5 Z" stroke="#FF9500"></path>
                        <path d="M8,0 L281,0 C285.418278,-8.11624501e-16 289,3.581722 289,8 L289,30 L289,30 L0,30 L0,8 C-5.41083001e-16,3.581722 3.581722,8.11624501e-16 8,0 Z" id="标题" fill="#FF9500"></path>
                    </g>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="88.718" y="20">new ActivityThread()</tspan>
                    </text>
                </g>
                <g id="循环备份-2" transform="translate(45.000000, 50.000000)">
                    <rect id="矩形备份" fill="#FF375F" x="0" y="0" width="199" height="30" rx="8"></rect>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="8.864" y="19">初始化mResourcesManager-单例</tspan>
                    </text>
                </g>
                <g id="循环备份-4" transform="translate(45.000000, 97.000000)">
                    <rect id="矩形备份" fill="#FF375F" x="0" y="0" width="199" height="30" rx="8"></rect>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="9.71" y="19">mAppThread:ApplicationThread()</tspan>
                    </text>
                </g>
                <g id="循环备份-5" transform="translate(45.000000, 144.000000)">
                    <rect id="矩形备份" fill="#FF375F" x="0" y="0" width="199" height="30" rx="8"></rect>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="20.156" y="19">mLooper: Looper.myLooper()</tspan>
                    </text>
                </g>
                <g id="循环备份-6" transform="translate(45.000000, 191.000000)">
                    <rect id="矩形备份" fill="#FF375F" x="0" y="0" width="199" height="30" rx="8"></rect>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="58.922" y="19">handler:mH:H()</tspan>
                    </text>
                </g>
                <g id="循环备份-7" transform="translate(45.000000, 238.000000)">
                    <rect id="矩形备份" fill="#FF375F" x="0" y="0" width="199" height="30" rx="8"></rect>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="41.054" y="19">HandlerExecutor(mH)</tspan>
                    </text>
                </g>
            </g>
            <g id="ActivityThread#attach" transform="translate(407.000000, 363.000000)">
                <g id="消息循环备份-2">
                    <g id="标题边框">
                        <path d="M281,0.5 C283.071068,0.5 284.946068,1.33946609 286.303301,2.69669914 C287.660534,4.05393219 288.5,5.92893219 288.5,8 L288.5,8 L288.5,238 C288.5,240.071068 287.660534,241.946068 286.303301,243.303301 C284.946068,244.660534 283.071068,245.5 281,245.5 L281,245.5 L8,245.5 C5.92893219,245.5 4.05393219,244.660534 2.69669914,243.303301 C1.33946609,241.946068 0.5,240.071068 0.5,238 L0.5,238 L0.5,8 C0.5,5.92893219 1.33946609,4.05393219 2.69669914,2.69669914 C4.05393219,1.33946609 5.92893219,0.5 8,0.5 L8,0.5 Z" stroke="#FF9500"></path>
                        <path d="M8,0 L281,0 C285.418278,-8.11624501e-16 289,3.581722 289,8 L289,30 L289,30 L0,30 L0,8 C-5.41083001e-16,3.581722 3.581722,8.11624501e-16 8,0 Z" id="标题" fill="#FF9500"></path>
                    </g>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="84.77" y="20">ActivityThread#attach</tspan>
                    </text>
                </g>
                <g id="循环备份-2" transform="translate(45.000000, 50.000000)">
                    <rect id="矩形备份" fill="#FF375F" x="0" y="0" width="199" height="30" rx="8"></rect>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="10.16" y="19">RuntimeInit.setApplicationObject</tspan>
                    </text>
                </g>
                <g id="循环备份-4" transform="translate(45.000000, 97.000000)">
                    <rect id="矩形备份" fill="#FF375F" x="0" y="0" width="199" height="30" rx="8"></rect>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="33.554" y="19">AMS.attachApplication()</tspan>
                    </text>
                </g>
                <g id="循环备份-5" transform="translate(45.000000, 144.000000)">
                    <rect id="矩形备份" fill="#FF375F" x="0" y="0" width="199" height="30" rx="8"></rect>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="19.562" y="19">BinderInternal.addGcWatcher</tspan>
                    </text>
                </g>
                <g id="循环备份-6" transform="translate(45.000000, 191.000000)">
                    <rect id="矩形备份" fill="#FF375F" x="0" y="0" width="199" height="30" rx="8"></rect>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="8.75" y="19">ViewRootImpl.addConfigCallback</tspan>
                    </text>
                </g>
            </g>
            <path id="newActivityThread" d="M303.86738,330.856054 C303.984711,331.355287 303.705613,331.855069 303.234682,332.025088 L303.122693,332.058319 L299.228789,332.973476 C298.691153,333.099833 298.152881,332.766425 298.026524,332.228789 C297.909193,331.729556 298.188291,331.229774 298.659222,331.059755 L298.771211,331.026524 L302.665115,330.111367 C303.202751,329.98501 303.741023,330.318418 303.86738,330.856054 Z M311.655188,329.025739 C311.772519,329.524973 311.493421,330.024755 311.02249,330.194774 L310.910501,330.228005 L307.016597,331.143162 C306.478961,331.269519 305.940689,330.936111 305.814332,330.398475 C305.697,329.899242 305.976099,329.399459 306.44703,329.229441 L306.559018,329.19621 L310.452922,328.281053 C310.990558,328.154696 311.528831,328.488103 311.655188,329.025739 Z M319.442995,327.195425 C319.560327,327.694658 319.281229,328.194441 318.810297,328.364459 L318.698309,328.39769 L314.804405,329.312847 C314.266769,329.439204 313.728496,329.105797 313.60214,328.568161 C313.484808,328.068927 313.763906,327.569145 314.234838,327.399126 L314.346826,327.365895 L318.24073,326.450738 C318.778366,326.324382 319.316639,326.657789 319.442995,327.195425 Z M327.230803,325.365111 C327.348134,325.864344 327.069036,326.364126 326.598105,326.534145 L326.486116,326.567376 L322.592213,327.482533 C322.054577,327.60889 321.516304,327.275482 321.389947,326.737846 C321.272616,326.238613 321.551714,325.738831 322.022645,325.568812 L322.134634,325.535581 L326.028538,324.620424 C326.566174,324.494067 327.104446,324.827475 327.230803,325.365111 Z M335.018611,323.534797 C335.135942,324.03403 334.856844,324.533812 334.385913,324.703831 L334.273924,324.737062 L330.38002,325.652219 C329.842384,325.778576 329.304112,325.445168 329.177755,324.907532 C329.060424,324.408299 329.339522,323.908517 329.810453,323.738498 L329.922442,323.705267 L333.816346,322.79011 C334.353982,322.663753 334.892254,322.997161 335.018611,323.534797 Z M342.806419,321.704482 C342.92375,322.203716 342.644652,322.703498 342.173721,322.873517 L342.061732,322.906748 L338.167828,323.821905 C337.630192,323.948261 337.09192,323.614854 336.965563,323.077218 C336.848231,322.577985 337.12733,322.078202 337.598261,321.908184 L337.71025,321.874953 L341.604153,320.959796 C342.141789,320.833439 342.680062,321.166846 342.806419,321.704482 Z M350.594226,319.874168 C350.711558,320.373401 350.43246,320.873184 349.961528,321.043202 L349.84954,321.076433 L345.955636,321.99159 C345.418,322.117947 344.879727,321.78454 344.753371,321.246904 C344.636039,320.74767 344.915137,320.247888 345.386069,320.077869 L345.498057,320.044638 L349.391961,319.129481 C349.929597,319.003124 350.46787,319.336532 350.594226,319.874168 Z M358.382034,318.043854 C358.499366,318.543087 358.220267,319.042869 357.749336,319.212888 L357.637347,319.246119 L353.743444,320.161276 C353.205808,320.287633 352.667535,319.954225 352.541178,319.416589 C352.423847,318.917356 352.702945,318.417574 353.173876,318.247555 L353.285865,318.214324 L357.179769,317.299167 C357.717405,317.17281 358.255677,317.506218 358.382034,318.043854 Z M366.169842,316.213539 C366.287173,316.712773 366.008075,317.212555 365.537144,317.382574 L365.425155,317.415805 L361.531251,318.330962 C360.993615,318.457319 360.455343,318.123911 360.328986,317.586275 C360.211655,317.087042 360.490753,316.58726 360.961684,316.417241 L361.073673,316.38401 L364.967577,315.468853 C365.505213,315.342496 366.043485,315.675904 366.169842,316.213539 Z M373.95765,314.383225 C374.074981,314.882459 373.795883,315.382241 373.324952,315.552259 L373.212963,315.58549 L369.319059,316.500648 C368.781423,316.627004 368.243151,316.293597 368.116794,315.755961 C367.999463,315.256728 368.278561,314.756945 368.749492,314.586927 L368.861481,314.553696 L372.755384,313.638539 C373.29302,313.512182 373.831293,313.845589 373.95765,314.383225 Z M393.839924,302.519706 C393.966133,302.490044 394.097515,302.490174 394.223664,302.520085 L394.223664,302.520085 L407.636659,305.700486 C408.085437,305.806898 408.36298,306.256968 408.256569,306.705746 C408.21488,306.881565 408.11729,307.03912 407.978447,307.154762 L407.978447,307.154762 L397.38633,315.976917 C397.031934,316.272093 396.505352,316.224085 396.210176,315.869689 C396.127203,315.77007 396.068564,315.652501 396.038902,315.526292 L396.038902,315.526292 L394.857,310.498 L392.682482,311.009705 C392.144846,311.136062 391.606574,310.802654 391.480217,310.265018 C391.362886,309.765785 391.641984,309.266002 392.112915,309.095984 L392.224904,309.062753 L394.399,308.551 L393.218025,303.523736 C393.120619,303.109285 393.350372,302.694382 393.739436,302.550007 Z M381.745457,312.552911 C381.862789,313.052144 381.583691,313.551927 381.112759,313.721945 L381.000771,313.755176 L377.106867,314.670333 C376.569231,314.79669 376.030958,314.463283 375.904602,313.925647 C375.78727,313.426413 376.066368,312.926631 376.5373,312.756612 L376.649288,312.723381 L380.543192,311.808224 C381.080828,311.681867 381.619101,312.015275 381.745457,312.552911 Z M389.533265,310.722597 C389.650597,311.22183 389.371498,311.721612 388.900567,311.891631 L388.788579,311.924862 L384.894675,312.840019 C384.357039,312.966376 383.818766,312.632968 383.692409,312.095332 C383.575078,311.596099 383.854176,311.096317 384.325107,310.926298 L384.437096,310.893067 L388.331,309.97791 C388.868636,309.851553 389.406908,310.184961 389.533265,310.722597 Z" fill="#FF9500" fill-rule="nonzero"></path>
            <path id="newActivityThread备份" d="M303.974266,391.493362 C304.02623,392.003558 303.685005,392.463171 303.196079,392.571033 L303.08074,392.589543 L299.101328,392.994853 C298.551885,393.050815 298.061109,392.65077 298.005147,392.101328 C297.953182,391.591131 298.294407,391.131519 298.783333,391.023657 L298.898672,391.005147 L302.878085,390.599836 C303.427527,390.543875 303.918304,390.94392 303.974266,391.493362 Z M311.93309,390.682741 C311.985055,391.192937 311.64383,391.65255 311.154904,391.760411 L311.039565,391.778922 L307.060153,392.184232 C306.51071,392.240194 306.019933,391.840149 305.963972,391.290707 C305.912007,390.78051 306.253232,390.320898 306.742158,390.213036 L306.857497,390.194526 L310.83691,389.789215 C311.386352,389.733254 311.877129,390.133299 311.93309,390.682741 Z M319.891915,389.87212 C319.94388,390.382316 319.602655,390.841928 319.113729,390.94979 L318.99839,390.9683 L315.018977,391.373611 C314.469535,391.429573 313.978758,391.029528 313.922797,390.480086 C313.870832,389.969889 314.212057,389.510277 314.700983,389.402415 L314.816322,389.383905 L318.795735,388.978594 C319.345177,388.922633 319.835954,389.322678 319.891915,389.87212 Z M327.85074,389.061499 C327.902705,389.571695 327.56148,390.031307 327.072554,390.139169 L326.957215,390.157679 L322.977802,390.56299 C322.42836,390.618952 321.937583,390.218907 321.881622,389.669464 C321.829657,389.159268 322.170882,388.699656 322.659808,388.591794 L322.775147,388.573284 L326.754559,388.167973 C327.304002,388.112011 327.794778,388.512056 327.85074,389.061499 Z M335.809565,388.250878 C335.86153,388.761074 335.520305,389.220686 335.031379,389.328548 L334.91604,389.347058 L330.936627,389.752369 C330.387185,389.808331 329.896408,389.408286 329.840446,388.858843 C329.788482,388.348647 330.129707,387.889035 330.618633,387.781173 L330.733972,387.762663 L334.713384,387.357352 C335.262827,387.30139 335.753603,387.701435 335.809565,388.250878 Z M393.967355,375.291184 C394.096335,375.278048 394.226603,375.295121 394.347841,375.341053 L394.347841,375.341053 L407.238632,380.224789 C407.669938,380.388191 407.887117,380.870297 407.723715,381.301603 C407.659698,381.470578 407.542603,381.61423 407.390006,381.711 L407.390006,381.711 L395.748542,389.093391 C395.359037,389.340394 394.843044,389.224874 394.596041,388.835368 C394.526609,388.72588 394.483623,388.601729 394.470486,388.472749 L394.470486,388.472749 L393.920543,383.083337 C393.697202,382.921973 393.541161,382.669557 393.511045,382.373875 C393.480893,382.077835 393.583123,381.798826 393.769775,381.595685 L393.221158,376.206622 C393.174423,375.747774 393.508507,375.337919 393.967355,375.291184 Z M343.76839,387.440257 C343.820354,387.950453 343.479129,388.410065 342.990204,388.517927 L342.874864,388.536437 L338.895452,388.941748 C338.34601,388.99771 337.855233,388.597665 337.799271,388.048222 C337.747307,387.538026 338.088532,387.078414 338.577458,386.970552 L338.692797,386.952042 L342.672209,386.546731 C343.221651,386.490769 343.712428,386.890814 343.76839,387.440257 Z M351.727215,386.629636 C351.779179,387.139832 351.437954,387.599444 350.949029,387.707306 L350.833689,387.725816 L346.854277,388.131127 C346.304835,388.187088 345.814058,387.787044 345.758096,387.237601 C345.706132,386.727405 346.047357,386.267793 346.536282,386.159931 L346.651622,386.141421 L350.631034,385.73611 C351.180476,385.680148 351.671253,386.080193 351.727215,386.629636 Z M359.68604,385.819014 C359.738004,386.329211 359.396779,386.788823 358.907853,386.896685 L358.792514,386.915195 L354.813102,387.320506 C354.26366,387.376467 353.772883,386.976422 353.716921,386.42698 C353.664957,385.916784 354.006182,385.457172 354.495107,385.34931 L354.610447,385.3308 L358.589859,384.925489 C359.139301,384.869527 359.630078,385.269572 359.68604,385.819014 Z M367.644865,385.008393 C367.696829,385.51859 367.355604,385.978202 366.866678,386.086064 L366.751339,386.104574 L362.771927,386.509885 C362.222484,386.565846 361.731708,386.165801 361.675746,385.616359 C361.623782,385.106163 361.965007,384.64655 362.453932,384.538689 L362.569271,384.520178 L366.548684,384.114868 C367.098126,384.058906 367.588903,384.458951 367.644865,385.008393 Z M375.603689,384.197772 C375.655654,384.707969 375.314429,385.167581 374.825503,385.275443 L374.710164,385.293953 L370.730752,385.699264 C370.181309,385.755225 369.690533,385.35518 369.634571,384.805738 C369.582606,384.295542 369.923831,383.835929 370.412757,383.728067 L370.528096,383.709557 L374.507509,383.304247 C375.056951,383.248285 375.547728,383.64833 375.603689,384.197772 Z M383.562514,383.387151 C383.614479,383.897348 383.273254,384.35696 382.784328,384.464822 L382.668989,384.483332 L378.689576,384.888643 C378.140134,384.944604 377.649357,384.544559 377.593396,383.995117 C377.541431,383.484921 377.882656,383.025308 378.371582,382.917446 L378.486921,382.898936 L382.466334,382.493626 C383.015776,382.437664 383.506553,382.837709 383.562514,383.387151 Z M391.521339,382.57653 C391.573304,383.086727 391.232079,383.546339 390.743153,383.654201 L390.627814,383.672711 L386.648401,384.078022 C386.098959,384.133983 385.608182,383.733938 385.552221,383.184496 C385.500256,382.6743 385.841481,382.214687 386.330407,382.106825 L386.445746,382.088315 L390.425159,381.683005 C390.974601,381.627043 391.465378,382.027088 391.521339,382.57653 Z" fill="#FF9500" fill-rule="nonzero"></path>
        </g>
    </g>
</svg>
**总结：**

1. ActivityThread为进程创建之后的入口，zygote进程创建了我们的APP进程，然后执行ActivityThread#main 函数；
2. ActivityThread#main函数中主要完成如下事情：
   1. 构建消息循环（包括构建Looper，准备Looper，进行消息循环）
   2. 构造ActivityThread对象，构造ActivityThread对象的实例时，会
      1. 构建ApplicationThread的实例及用于处理消息的Handler；
      2. 构建ResourceManager实例
   3. ApplicationThread用于AMS与我们的APP进程通信；
3. attachApplication，构造Application对象；

> ❓ApplicationThread 如何注册到AMS？



入口 main() 代码如下：

```java
// android.app.ActivityThread#main
public static void main(String[] args) {
        // Call per-process mainline module initialization.
        initializeMainlineModules();
        Process.setArgV0("<pre-initialized>");

    	// 初始化当前主线程的Looper，主线程和
        Looper.prepareMainLooper();

        // Find the value for {@link #PROC_START_SEQ_IDENT} if provided on the command line.
        // It will be in the format "seq=114"
        long startSeq = 0;
        if (args != null) {
            for (int i = args.length - 1; i >= 0; --i) {
                if (args[i] != null && args[i].startsWith(PROC_START_SEQ_IDENT)) {
                    startSeq = Long.parseLong(
                            args[i].substring(PROC_START_SEQ_IDENT.length()));
                }
            }
        }
        ActivityThread thread = new ActivityThread();
        thread.attach(false, startSeq);

        if (sMainThreadHandler == null) {
            sMainThreadHandler = thread.getHandler();
        }

        if (false) {
            Looper.myLooper().setMessageLogging(new
                    LogPrinter(Log.DEBUG, "ActivityThread"));
        }

        // End of event ActivityThreadMain.
        Trace.traceEnd(Trace.TRACE_TAG_ACTIVITY_MANAGER);
        Looper.loop();

        throw new RuntimeException("Main thread loop unexpectedly exited");
    }

```

### 进入消息队列循环：Looper初始化与消息循环

主线程的初始化就是调用了 `Looper.prepareMainLooper()` 函数来构造一个主线程的Looper对象，存储与线程变量 `sThreadLocal` 中。

由于直接在ActivityThread中调用了 `Looper.loop()` 函数进入了死循环，所以我们认为ActivityThread就是当前应用的主线程，虽然它不是集成与Thread类，但是它是进程内默认线程执行的入口方法，且在此方法中进入了消息循环；

<svg width="289px" height="168px" viewBox="0 0 289 168" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <g id="2-Context&amp;Application" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
        <g id="ActivityThread#main" transform="translate(-53.000000, -81.000000)">
            <g id="Looper" transform="translate(53.000000, 81.000000)">
                <g id="消息循环">
                    <g id="标题边框">
                        <path d="M281,0.5 C283.071068,0.5 284.946068,1.33946609 286.303301,2.69669914 C287.660534,4.05393219 288.5,5.92893219 288.5,8 L288.5,8 L288.5,160 C288.5,162.071068 287.660534,163.946068 286.303301,165.303301 C284.946068,166.660534 283.071068,167.5 281,167.5 L281,167.5 L8,167.5 C5.92893219,167.5 4.05393219,166.660534 2.69669914,165.303301 C1.33946609,163.946068 0.5,162.071068 0.5,160 L0.5,160 L0.5,8 C0.5,5.92893219 1.33946609,4.05393219 2.69669914,2.69669914 C4.05393219,1.33946609 5.92893219,0.5 8,0.5 L8,0.5 Z" stroke="#FF9500"></path>
                        <path d="M8,0 L281,0 C285.418278,-8.11624501e-16 289,3.581722 289,8 L289,30 L289,30 L0,30 L0,8 C-5.41083001e-16,3.581722 3.581722,8.11624501e-16 8,0 Z" id="标题" fill="#FF9500"></path>
                    </g>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="97.652" y="20">进入消息队列循环</tspan>
                    </text>
                </g>
                <g id="循环" transform="translate(45.000000, 52.000000)">
                    <rect id="矩形备份" fill="#34C759" x="0" y="0" width="199" height="30" rx="8"></rect>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="21.644" y="19">Looper.prepareMainLooper()</tspan>
                    </text>
                </g>
                <g id="循环备份" transform="translate(45.000000, 108.000000)">
                    <rect id="矩形备份" fill="#34C759" x="0" y="0" width="199" height="30" rx="8"></rect>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="22.388" y="19">进入消息循环：Looper.loop()</tspan>
                    </text>
                </g>
            </g>
        </g>
    </g>
</svg>

#### 初始化：主线程和其他线程Looper初始化的区别

从下面的代码中，我们可以看到，区别有亮点：

1. 私有的方法 prepare 有个参数quitAllowed，最终会传递给Looper，这个参数在主线程初始化时设置为true，而其他线程则为false；
2. 主线程的使用 sMainLooper 静态变量记住了对应的Looper对象，也就是说，我们通过`Looper.sMainLooper`就可以直接获取到主线程的Looper（当然，这里设置了private）；

```java
// frameworks/base/core/java/android/os/Looper.java    
	private static Looper sMainLooper;  // guarded by Looper.class    
	// 其他线程的Looper初始化
	public static void prepare() {
        // quitAllowed设置为true
        prepare(true);
    }

	// 真正的初始化方法
    private static void prepare(boolean quitAllowed) {
        if (sThreadLocal.get() != null) {
            throw new RuntimeException("Only one Looper may be created per thread");
        }
        // 就是将线程局部变量设置值为Looper对象（一个线程只能有一个Looper对象）
        sThreadLocal.set(new Looper(quitAllowed));
    }

	// 主线程的Looper初始化
    public static void prepareMainLooper() {
        // 主线程quitAllowed设置为false
        prepare(false);
        synchronized (Looper.class) {
            if (sMainLooper != null) {
                throw new IllegalStateException("The main Looper has already been prepared.");
            }
            // 这里的myLooper函数实际上就是将上面prepare设置的Looper对象取出来，将下方
            sMainLooper = myLooper();
        }
    }

    public static @Nullable Looper myLooper() {
        return sThreadLocal.get();
    }
```

#### 消息循环

从源码可以看出，消息循环中的动作很简单，就是尝试从Looper关联的消息队列中去取消息：

* 如果没有取到消息，则说明消息队列正在退出，会弹出循环；
* 如果取到消息，则从消息中取出一个Handler，然后调用该Handler的dispatchMessage来处理消息；

联想到我们对Handler的用法，Handler既负责往消息队列中发送消息，又负责处理消息，这后半部分就很明显了。



下面为 `android.os.Looper#loop` 的代码：

```java
// android.os.Looper#loop
 public static void loop() {
        // 获取当前线程的Looper
        final Looper me = myLooper();
     // 如Looper为空，这表示没有初始化。
        if (me == null) {
            throw new RuntimeException("No Looper; Looper.prepare() wasn't called on this thread.");
        }
		// 标识我们已经在Loop中了
        me.mInLoop = true;
	    // 获取消息队列
        final MessageQueue queue = me.mQueue;

        // Make sure the identity of this thread is that of the local process,
        // and keep track of what that identity token actually is.
        Binder.clearCallingIdentity();
        final long ident = Binder.clearCallingIdentity();
        for (;;) {
            // 进入无限循环了
            // 从消息队列中取出一个消息
            Message msg = queue.next(); // might block
            if (msg == null) {
                // 没有消息则表示消息队列正在退出
                return;
            }

            //使用final 保证处理事务的过程中，观察者不会变化，sObserver用于收集Looper运行状态信息
            // 下方我们删除对应的调用
            final Observer observer = sObserver;

            final long traceTag = me.mTraceTag;
            long slowDispatchThresholdMs = me.mSlowDispatchThresholdMs;
            long slowDeliveryThresholdMs = me.mSlowDeliveryThresholdMs;
            if (thresholdOverride > 0) {
                slowDispatchThresholdMs = thresholdOverride;
                slowDeliveryThresholdMs = thresholdOverride;
            }
            long origWorkSource = ThreadLocalWorkSource.setUid(msg.workSourceUid);
            try {
                // 消息中携带了Handler自身，Handler可以发送消息，也自行处理消息。
                msg.target.dispatchMessage(msg);
            } catch (Exception exception) {
                throw exception;
            } finally {
                ThreadLocalWorkSource.restore(origWorkSource);
            }
            // Make sure that during the course of dispatching the
            // identity of the thread wasn't corrupted.
            final long newIdent = Binder.clearCallingIdentity();
            if (ident != newIdent) {
                Log.wtf(TAG, "Thread identity changed from 0x"
                        + Long.toHexString(ident) + " to 0x"
                        + Long.toHexString(newIdent) + " while dispatching to "
                        + msg.target.getClass().getName() + " "
                        + msg.callback + " what=" + msg.what);
            }
            // 回收消息，就是将Message的各成员变量的值恢复成初始值，方便后续复用。
            msg.recycleUnchecked();
        }
    }
```



### 初始化ActivityThread-构造对象实例

初始化ActivityThread的动作包含两个：

```java
        ActivityThread thread = new ActivityThread();
        thread.attach(false, startSeq);
```

1. 构造ActivityThread的对象实例；

   <svg width="289px" height="296px" viewBox="0 0 289 296" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
       <g id="2-Context&amp;Application" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
           <g id="ActivityThread#main" transform="translate(-468.000000, -123.000000)">
               <g id="ActivityThread()" transform="translate(468.000000, 123.000000)">
                   <g id="消息循环备份-2">
                       <g id="标题边框">
                           <path d="M281,0.5 C283.071068,0.5 284.946068,1.33946609 286.303301,2.69669914 C287.660534,4.05393219 288.5,5.92893219 288.5,8 L288.5,8 L288.5,288 C288.5,290.071068 287.660534,291.946068 286.303301,293.303301 C284.946068,294.660534 283.071068,295.5 281,295.5 L281,295.5 L8,295.5 C5.92893219,295.5 4.05393219,294.660534 2.69669914,293.303301 C1.33946609,291.946068 0.5,290.071068 0.5,288 L0.5,288 L0.5,8 C0.5,5.92893219 1.33946609,4.05393219 2.69669914,2.69669914 C4.05393219,1.33946609 5.92893219,0.5 8,0.5 L8,0.5 Z" stroke="#FF9500"></path>
                           <path d="M8,0 L281,0 C285.418278,-8.11624501e-16 289,3.581722 289,8 L289,30 L289,30 L0,30 L0,8 C-5.41083001e-16,3.581722 3.581722,8.11624501e-16 8,0 Z" id="标题" fill="#FF9500"></path>
                       </g>
                       <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                           <tspan x="88.718" y="20">new ActivityThread()</tspan>
                       </text>
                   </g>
                   <g id="循环备份-2" transform="translate(45.000000, 50.000000)">
                       <rect id="矩形备份" fill="#FF375F" x="0" y="0" width="199" height="30" rx="8"></rect>
                       <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                           <tspan x="8.864" y="19">初始化mResourcesManager-单例</tspan>
                       </text>
                   </g>
                   <g id="循环备份-4" transform="translate(45.000000, 97.000000)">
                       <rect id="矩形备份" fill="#FF375F" x="0" y="0" width="199" height="30" rx="8"></rect>
                       <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                           <tspan x="9.71" y="19">mAppThread:ApplicationThread()</tspan>
                       </text>
                   </g>
                   <g id="循环备份-5" transform="translate(45.000000, 144.000000)">
                       <rect id="矩形备份" fill="#FF375F" x="0" y="0" width="199" height="30" rx="8"></rect>
                       <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                           <tspan x="20.156" y="19">mLooper: Looper.myLooper()</tspan>
                       </text>
                   </g>
                   <g id="循环备份-6" transform="translate(45.000000, 191.000000)">
                       <rect id="矩形备份" fill="#FF375F" x="0" y="0" width="199" height="30" rx="8"></rect>
                       <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                           <tspan x="58.922" y="19">handler:mH:H()</tspan>
                       </text>
                   </g>
                   <g id="循环备份-7" transform="translate(45.000000, 238.000000)">
                       <rect id="矩形备份" fill="#FF375F" x="0" y="0" width="199" height="30" rx="8"></rect>
                       <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                           <tspan x="41.054" y="19">HandlerExecutor(mH)</tspan>
                       </text>
                   </g>
               </g>
           </g>
       </g>
   </svg>

2. 调用其attach方法；

这一小节我们仅分析构造ActivityThread对象过程中可能执行的代码，attach的流程放到下一个小节；

构造ActivityThread对象过程中的赋值mLooper的方法就是调用 `Looper.myLooper()`，也就是我们之前分析过的，取出当前线程变量中的Looper对象，所以我们后面不再分析该成员变量的赋值操作；

#### 初始化ResourceManager

初始化逻辑位于ActivityThread的构造函数中，其构造函数只有一行代码：

```java
// android.app.ActivityThread#ActivityThread    
ActivityThread() {
        mResourcesManager = ResourcesManager.getInstance();
}
```

而 `ResourceMananger` 则是一个单例对象：

```java
// android.app.ResourcesManager#getInstance  
	@UnsupportedAppUsage
    public static ResourcesManager getInstance() {
        synchronized (ResourcesManager.class) {
            if (sResourcesManager == null) {
                sResourcesManager = new ResourcesManager();
            }
            return sResourcesManager;
        }
    }
```

> 这里我们暂不展开分析ResourceManager，从名称及其成员分析应该是对app中的资源文件进行管理的。如：
>
> * 提供了getResources方法可返回一个Resources对象（对-是我们经常用的那个类）
> * getConfiguration() 方法返回一个Configuration对象（对-是我们经常用的那个类）
> * getAdjustedDisplay() 方法返回了一个Display类的对象（对-是我们经常用的那个类）；

#### 构造ApplicationThread对象

在成员变量中，声明了一个`final`的 `mAppThread`的对象，其类型为`ApplicationThread`，并且在声明时就直接初始化了。

```java
// ActivityThread.java    
final ApplicationThread mAppThread = new ApplicationThread();
```

ApplicationThread继承了 `IApplicationThread.Stub` 类，且没有自定义的构造函数，所以这里只是构造了对象但是不会有其他动作；

```java
private class ApplicationThread extends IApplicationThread.Stub {
    
}
```

从继承 `IApplicationThread.Stub` 这里我们可以推断ApplicationThread是作为Binder进程间通信的一个服务端的具体实现存在的。也就是说我们主要关注的应该是其中的接口实现。这里我们也暂时不展开分析。

#### Handler初始化

ActivityThread中有个H类型的变量，这个H是Activity的一个内部类，继承了Handler。接下来又将这个handler作为构造函数参数构造了一个HandlerExecutor对象。这小节我们分析这两个变量的作用。

```java
    final H mH = new H();
    final Executor mExecutor = new HandlerExecutor(mH);
```
这个H的代码比较多，实际上做的事情就是定义了各种类型的消息的常量值，然后在handleMessage中根据对应的消息来调用对应的方法处理消息；
```java
// android.app.ActivityThread.H
class H extends Handler {
        public static final int BIND_APPLICATION        = 110;
        @UnsupportedAppUsage
        public static final int EXIT_APPLICATION        = 111;
        // 省略若干代码 ... 
        public void handleMessage(Message msg) {
            if (DEBUG_MESSAGES) Slog.v(TAG, ">>> handling: " + codeToString(msg.what));
            switch (msg.what) {
                case BIND_APPLICATION:
                    Trace.traceBegin(Trace.TRACE_TAG_ACTIVITY_MANAGER, "bindApplication");
                    AppBindData data = (AppBindData)msg.obj;
                    handleBindApplication(data);
                    Trace.traceEnd(Trace.TRACE_TAG_ACTIVITY_MANAGER);
                    break;
                case EXIT_APPLICATION:
                    if (mInitialApplication != null) {
                        mInitialApplication.onTerminate();
                    }
                    Looper.myLooper().quit();
                    break;
                // 省略若干代码 ... 
            }
            Object obj = msg.obj;
            if (obj instanceof SomeArgs) {
                ((SomeArgs) obj).recycle();
            }
            if (DEBUG_MESSAGES) Slog.v(TAG, "<<< done: " + codeToString(msg.what));
        }
    }
```

那么这个 HandlerExecutor 又是什么作用呢？实际上代码也比较简单，注释也写的很清楚，就是作为一个适配器，(执行execute方法)将对应的（Runnable）消息转发给指定的Handler（通过post方法）来处理；

```java
// android.os.HandlerExecutor
/**
 * An adapter {@link Executor} that posts all executed tasks onto the given
 * {@link Handler}.
 *
 * @hide
 */
public class HandlerExecutor implements Executor {
    private final Handler mHandler;

    public HandlerExecutor(@NonNull Handler handler) {
        mHandler = Preconditions.checkNotNull(handler);
    }

    @Override
    public void execute(Runnable command) {
        if (!mHandler.post(command)) {
            throw new RejectedExecutionException(mHandler + " is shutting down");
        }
    }
}
```

实际上就是为了隐藏Handler，如下为Activity定义的get方法，可见`getHandler`是包级访问权限的，而	`getExecutor`是public访问权限的。

```java
// android.app.ActivityThread#getHandler   
	@UnsupportedAppUsage
    final Handler getHandler() {
        return mH;
    }
// android.app.ActivityThread#getExecutor
    public Executor getExecutor() {
        return mExecutor;
    }
```

### 初始化ActivityThread-attach

前面说过我们初始化ActivityThread的有两个步骤：

```java
        ActivityThread thread = new ActivityThread();
        thread.attach(false, startSeq);
```

上一节我们分析了构造流程，现在我们看下attach方法调用时做了些什么，我们还是先贴出一张全局的图。

<svg width="289px" height="246px" viewBox="0 0 289 246" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <g id="2-Context&amp;Application" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
        <g id="ActivityThread#main" transform="translate(-407.000000, -363.000000)">
            <g id="ActivityThread#attach" transform="translate(407.000000, 363.000000)">
                <g id="消息循环备份-2">
                    <g id="标题边框">
                        <path d="M281,0.5 C283.071068,0.5 284.946068,1.33946609 286.303301,2.69669914 C287.660534,4.05393219 288.5,5.92893219 288.5,8 L288.5,8 L288.5,238 C288.5,240.071068 287.660534,241.946068 286.303301,243.303301 C284.946068,244.660534 283.071068,245.5 281,245.5 L281,245.5 L8,245.5 C5.92893219,245.5 4.05393219,244.660534 2.69669914,243.303301 C1.33946609,241.946068 0.5,240.071068 0.5,238 L0.5,238 L0.5,8 C0.5,5.92893219 1.33946609,4.05393219 2.69669914,2.69669914 C4.05393219,1.33946609 5.92893219,0.5 8,0.5 L8,0.5 Z" stroke="#FF9500"></path>
                        <path d="M8,0 L281,0 C285.418278,-8.11624501e-16 289,3.581722 289,8 L289,30 L289,30 L0,30 L0,8 C-5.41083001e-16,3.581722 3.581722,8.11624501e-16 8,0 Z" id="标题" fill="#FF9500"></path>
                    </g>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="84.77" y="20">ActivityThread#attach</tspan>
                    </text>
                </g>
                <g id="循环备份-2" transform="translate(45.000000, 50.000000)">
                    <rect id="矩形备份" fill="#FF375F" x="0" y="0" width="199" height="30" rx="8"></rect>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="10.16" y="19">RuntimeInit.setApplicationObject</tspan>
                    </text>
                </g>
                <g id="循环备份-4" transform="translate(45.000000, 97.000000)">
                    <rect id="矩形备份" fill="#FF375F" x="0" y="0" width="199" height="30" rx="8"></rect>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="33.554" y="19">AMS.attachApplication()</tspan>
                    </text>
                </g>
                <g id="循环备份-5" transform="translate(45.000000, 144.000000)">
                    <rect id="矩形备份" fill="#FF375F" x="0" y="0" width="199" height="30" rx="8"></rect>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="19.562" y="19">BinderInternal.addGcWatcher</tspan>
                    </text>
                </g>
                <g id="循环备份-6" transform="translate(45.000000, 191.000000)">
                    <rect id="矩形备份" fill="#FF375F" x="0" y="0" width="199" height="30" rx="8"></rect>
                    <text id="标题" font-family="PingFangSC-Semibold, PingFang SC" font-size="12" font-weight="500" letter-spacing="-0.288" fill="#FFFFFF">
                        <tspan x="8.75" y="19">ViewRootImpl.addConfigCallback</tspan>
                    </text>
                </g>
            </g>
        </g>
    </g>
</svg>

> addGcWatcher及ViewRootImpl.addConfigCallback两个流程暂不分析，我们主要关注Context如何创建。

#### attach方法的两个入口

我们发现，实际上这个attach方法有两个调用入口：

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210415161725.png" alt="image-20210415161725502" style="zoom:100%;" />

一个是在`systemMain`方法中，另外就是我们正在分析的`main`方法中。其区别在于调用时传递的参数不同，两个参数分别为： 1） `system`； 2） `startSeq`； 其中system很清楚，应是用来标识是否为系统进程启动，而启动序列则需要根据后面的代码进行分析；

* `systemMain`方法是系统进程（system_process）启动时执行的方法，其参数设置为system-true，启动序列号-0；
* `main` 方法为普通的应用进程启动时执行的方法，其中system被设置为false，就是说我们不是系统进程，启动序列号则是从main方法启动时的参数中读取出来的。

#### 普通应用 attach 流程

由于我们的应用是一个普通应用，所以我们暂不关注为系统应用时（system=true)所执行的操作。

```java
// android.app.ActivityThread#attach
@UnsupportedAppUsage
    private void attach(boolean system, long startSeq) {
        sCurrentActivityThread = this;
        mSystemThread = system;
        if (!system) {
            android.ddm.DdmHandleAppName.setAppName("<pre-initialized>",
                                                    UserHandle.myUserId());
            // 
            RuntimeInit.setApplicationObject(mAppThread.asBinder());
            final IActivityManager mgr = ActivityManager.getService();
            try {
                mgr.attachApplication(mAppThread, startSeq);
            } catch (RemoteException ex) {
                throw ex.rethrowFromSystemServer();
            }
            // 监测是否接近heap内存使用限制
            BinderInternal.addGcWatcher(new Runnable() {
                @Override public void run() {
                    if (!mSomeActivitiesChanged) {
                        return;
                    }
                    Runtime runtime = Runtime.getRuntime();
                    long dalvikMax = runtime.maxMemory();
                    long dalvikUsed = runtime.totalMemory() - runtime.freeMemory();
                    // 如使用大于3/4，则通知AMS释放一些Activity
                    if (dalvikUsed > ((3*dalvikMax)/4)) {
                        if (DEBUG_MEMORY_TRIM) Slog.d(TAG, "Dalvik max=" + (dalvikMax/1024)
                                + " total=" + (runtime.totalMemory()/1024)
                                + " used=" + (dalvikUsed/1024));
                        mSomeActivitiesChanged = false;
                        try {
                            ActivityTaskManager.getService().releaseSomeActivities(mAppThread);
                        } catch (RemoteException e) {
                            throw e.rethrowFromSystemServer();
                        }
                    }
                }
            });
        } else {
            // 系统应用执行逻辑已省略
        }

        ViewRootImpl.ConfigChangedCallback configChangedCallback
                = (Configuration globalConfig) -> {
            synchronized (mResourcesManager) {
                // TODO (b/135719017): Temporary log for debugging IME service.
                if (Build.IS_DEBUGGABLE && mHasImeComponent) {
                    Log.d(TAG, "ViewRootImpl.ConfigChangedCallback for IME, "
                            + "config=" + globalConfig);
                }

                // We need to apply this change to the resources immediately, because upon returning
                // the view hierarchy will be informed about it.
                if (mResourcesManager.applyConfigurationToResourcesLocked(globalConfig,
                        null /* compat */,
                        mInitialApplication.getResources().getDisplayAdjustments())) {
                    updateLocaleListFromAppContext(mInitialApplication.getApplicationContext(),
                            mResourcesManager.getConfiguration().getLocales());

                    // This actually changed the resources! Tell everyone about it.
                    if (mPendingConfiguration == null
                            || mPendingConfiguration.isOtherSeqNewer(globalConfig)) {
                        mPendingConfiguration = globalConfig;
                        sendMessage(H.CONFIGURATION_CHANGED, globalConfig);
                    }
                }
            }
        };
        ViewRootImpl.addConfigCallback(configChangedCallback);
    }
```



#### RuntimeInit.setApplicationObject

Runtime初始化过程中的异常处理，有时需要ApplicationThread对象，所以设置过去。

```java
RuntimeInit.setApplicationObject(mAppThread.asBinder());
```



#### AMS.attachApplication

实际上重点在于`attachApplication`

```java
mgr.attachApplication(mAppThread, startSeq)
```

经过binder驱动之后，会走到system_process进程的AMS中的`attachApplication`方法中：

```java
// com.android.server.am.ActivityManagerService#attachApplication
    @Override
    public final void attachApplication(IApplicationThread thread, long startSeq) {
        if (thread == null) {
            throw new SecurityException("Invalid application interface");
        }
        synchronized (this) {
            // 获取IPC调用的Pid，Uid（即进程信息）
            int callingPid = Binder.getCallingPid();
            final int callingUid = Binder.getCallingUid();
            final long origId = Binder.clearCallingIdentity();
            // 调用了一个同步方法
            attachApplicationLocked(thread, callingPid, callingUid, startSeq);
            Binder.restoreCallingIdentity(origId);
        }
    }
```

接下来这个attachApplicationLocked方法比较长，我们省略部分：

```java
//  com.android.server.am.ActivityManagerService#attachApplicationLocked
    @GuardedBy("this")
    private boolean attachApplicationLocked(@NonNull IApplicationThread thread,
            int pid, int callingUid, long startSeq) {

        // Find the application record that is being attached...  either via
        // the pid if we are running in multiple processes, or just pull the
        // next app record if we are emulating process with anonymous threads.
        // 创建一个ProcessRecord变量
        ProcessRecord app;
        long startTime = SystemClock.uptimeMillis();
        long bindApplicationTimeMillis;
        // 不是自己的PID且大于0
        if (pid != MY_PID && pid >= 0) {
            synchronized (mPidsSelfLocked) {
                // 尝试从PidMap中取出当前进程记录
                app = mPidsSelfLocked.get(pid);
            }
            if (app != null && (app.startUid != callingUid || app.startSeq != startSeq)) {
                // 找到的进程记录和我们需要的不符合
                app = null;
            }
        } else {
            app = null;
        }
		// 上面的总结下来就是尝试去PidMap中去找一个线程的ProcessRecord，找不到匹配的就还是null
        
        // It's possible that process called attachApplication before we got a chance to
        // update the internal state.
        if (app == null && startSeq > 0) {
            // 尝试去pendingStart的进程列表中去查找
            final ProcessRecord pending = mProcessList.mPendingStarts.get(startSeq);
            if (pending != null && pending.startUid == callingUid && pending.startSeq == startSeq
                    && mProcessList.handleProcessStartedLocked(pending, pid, pending
                            .isUsingWrapper(),
                            startSeq, true)) {
                app = pending;
            }
        }

        if (app == null) {
            // 如果还是没有办法找到，就退出了
            EventLogTags.writeAmDropProcess(pid);
            // 但是进程ID>0，说明可能被分配过，但是没有记录，所以将进程杀掉
            if (pid > 0 && pid != MY_PID) {
                killProcessQuiet(pid);
                //TODO: killProcessGroup(app.info.uid, pid);
                mProcessList.noteAppKill(app, ApplicationExitInfo.REASON_INITIALIZATION_FAILURE,
                        ApplicationExitInfo.SUBREASON_UNKNOWN, "attach failed");
            } else {
                try {
                    thread.scheduleExit();
                } catch (Exception e) {
                    // Ignore exceptions.
                }
            }
            // 进程获取有误，就退出了
            return false;
        }

        try {
            mAtmInternal.preBindApplication(app.getWindowProcessController());
            final ActiveInstrumentation instr2 = app.getActiveInstrumentation();
            final ProviderInfoList providerList = ProviderInfoList.fromList(providers);
            if (app.isolatedEntryPoint != null) {
                // This is an isolated process which should just call an entry point instead of
                // being bound to an application.
                thread.runIsolatedEntryPoint(app.isolatedEntryPoint, app.isolatedEntryPointArgs);
            } else if (instr2 != null) {
                thread.bindApplication(processName, appInfo, providerList,
                        instr2.mClass,
                        profilerInfo, instr2.mArguments,
                        instr2.mWatcher,
                        instr2.mUiAutomationConnection, testMode,
                        mBinderTransactionTrackingEnabled, enableTrackAllocation,
                        isRestrictedBackupMode || !normalMode, app.isPersistent(),
                        new Configuration(app.getWindowProcessController().getConfiguration()),
                        app.compat, getCommonServicesLocked(app.isolated),
                        mCoreSettingsObserver.getCoreSettingsLocked(),
                        buildSerial, autofillOptions, contentCaptureOptions,
                        app.mDisabledCompatChanges);
            } else {
                thread.bindApplication(processName, appInfo, providerList, null, profilerInfo,
                        null, null, null, testMode,
                        mBinderTransactionTrackingEnabled, enableTrackAllocation,
                        isRestrictedBackupMode || !normalMode, app.isPersistent(),
                        new Configuration(app.getWindowProcessController().getConfiguration()),
                        app.compat, getCommonServicesLocked(app.isolated),
                        mCoreSettingsObserver.getCoreSettingsLocked(),
                        buildSerial, autofillOptions, contentCaptureOptions,
                        app.mDisabledCompatChanges);
            }
            // Make app active after binding application or client may be running requests (e.g
            // starting activities) before it is ready.
            app.makeActive(thread, mProcessStats);
            checkTime(startTime, "attachApplicationLocked: immediately after bindApplication");
            mProcessList.updateLruProcessLocked(app, false, null);
            checkTime(startTime, "attachApplicationLocked: after updateLruProcessLocked");
            app.lastRequestedGc = app.lastLowMemory = SystemClock.uptimeMillis();
        } catch (Exception e) {
            return false;
        }

        // Remove this record from the list of starting applications.
        mPersistentStartingProcesses.remove(app);
        if (DEBUG_PROCESSES && mProcessesOnHold.contains(app)) Slog.v(TAG_PROCESSES,
                "Attach application locked removing on hold: " + app);
        mProcessesOnHold.remove(app);
        return true;
    }
```

实际上核心逻辑是调用了如下两句：

```java
 thread.bindApplication(processName, appInfo, providerList, null, profilerInfo,...)
 app.makeActive(thread, mProcessStats); 
```

thread.bindApplication 实际上就是调用了进程的ApplicationThread的对应的bindApplication方法。

```java
// android.app.ActivityThread.ApplicationThread#bindApplication
 @Override
        public final void bindApplication(String processName, ApplicationInfo appInfo,
                ProviderInfoList providerList, ComponentName instrumentationName,
                ProfilerInfo profilerInfo, Bundle instrumentationArgs,
                IInstrumentationWatcher instrumentationWatcher,
                IUiAutomationConnection instrumentationUiConnection, int debugMode,
                boolean enableBinderTracking, boolean trackAllocation,
                boolean isRestrictedBackupMode, boolean persistent, Configuration config,
                CompatibilityInfo compatInfo, Map services, Bundle coreSettings,
                String buildSerial, AutofillOptions autofillOptions,
                ContentCaptureOptions contentCaptureOptions, long[] disabledCompatChanges) {
            if (services != null) {
                // Setup the service cache in the ServiceManager
                ServiceManager.initServiceCache(services);
            }

            setCoreSettings(coreSettings);
			// 构造了一个AppBindData的数据对象，将接收的参数组织起来
            AppBindData data = new AppBindData();
            data.processName = processName;
            data.appInfo = appInfo;
            data.providers = providerList.getList();
            data.instrumentationName = instrumentationName;
            data.instrumentationArgs = instrumentationArgs;
            data.instrumentationWatcher = instrumentationWatcher;
            data.instrumentationUiAutomationConnection = instrumentationUiConnection;
            data.debugMode = debugMode;
            data.enableBinderTracking = enableBinderTracking;
            data.trackAllocation = trackAllocation;
            data.restrictedBackupMode = isRestrictedBackupMode;
            data.persistent = persistent;
            data.config = config;
            data.compatInfo = compatInfo;
            data.initProfilerInfo = profilerInfo;
            data.buildSerial = buildSerial;
            data.autofillOptions = autofillOptions;
            data.contentCaptureOptions = contentCaptureOptions;
            data.disabledCompatChanges = disabledCompatChanges;
            // 使用Handler来分发消息
            sendMessage(H.BIND_APPLICATION, data);
        }

 	public void handleMessage(Message msg) {
            if (DEBUG_MESSAGES) Slog.v(TAG, ">>> handling: " + codeToString(msg.what));
            switch (msg.what) {
                case BIND_APPLICATION:
                    Trace.traceBegin(Trace.TRACE_TAG_ACTIVITY_MANAGER, "bindApplication");
                    AppBindData data = (AppBindData)msg.obj;
                    handleBindApplication(data);
                    Trace.traceEnd(Trace.TRACE_TAG_ACTIVITY_MANAGER);
                    break;
            }
```

也就是调用了handleBinderApplication，这个方法也是超级长：

```java
   @UnsupportedAppUsage
    private void handleBindApplication(AppBindData data) {
        AppCompatCallbacks.install(data.disabledCompatChanges);
        mBoundApplication = data;

		//  设置进程名称
        Process.setArgV0(data.processName);
        android.ddm.DdmHandleAppName.setAppName(data.processName,
                                                data.appInfo.packageName,
                                                UserHandle.myUserId());
        // 设置进程的包名
        VMRuntime.setProcessPackageName(data.appInfo.packageName);

        // Pass data directory path to ART. This is used for caching information and
        // should be set before any application code is loaded.
        // 设置进程的数据目录
        VMRuntime.setProcessDataDirectory(data.appInfo.dataDir);

        // 创建ContextImpl了，不过这个appContext并没有与Application进行关联
        final ContextImpl appContext = ContextImpl.createAppContext(this, data.info);
        updateLocaleListFromAppContext(appContext,
                mResourcesManager.getConfiguration().getLocales());
        // Allow disk access during application and provider setup. This could
        // block processing ordered broadcasts, but later processing would
        // probably end up doing the same disk access.
        // 开始创建Application了
        Application app;
        // If the app is being launched for full backup or restore, bring it up in
        // a restricted environment with the base application class.
        // data.info 是一个LoadedApk类型的对象
        app = data.info.makeApplication(data.restrictedBackupMode, null);
        mInitialApplication = app;
    }
```

创建ContextImpl:

```java
    static ContextImpl createAppContext(ActivityThread mainThread, LoadedApk packageInfo,
            String opPackageName) {
        if (packageInfo == null) throw new IllegalArgumentException("packageInfo");
        ContextImpl context = new ContextImpl(null, mainThread, packageInfo, null, null, null, null,
                0, null, opPackageName);
        context.setResources(packageInfo.getResources());
        context.mIsSystemOrSystemUiContext = isSystemOrSystemUI(context);
        return context;
    }
```

可以看到createAppContext的Context包含了一些什么：

1. ActivityThread
2. 包名
3. Resource



**LoadedApk#makeApplication**：

关联逻辑为下面的代码，完成了ContextImpl的创建，完成了Application的创建，然后将它们互相关联起来；Application的mBase指向ContextImpl，ContextImpl的mOuterContext指向Application。

```java
// 创建APP的Context
ContextImpl appContext = ContextImpl.createAppContext(mActivityThread, this);
// 通过mActivityThread.mInstrumentation创建Application对象
// 这里会调用application的attachBaseContext方法来将Application.mBase指向appContext
app = mActivityThread.mInstrumentation.newApplication(
    cl, appClass, appContext);
// 关联Application到appContext
appContext.setOuterContext(app);
// 将Application记录到ActivityThread
mActivityThread.mAllApplications.add(app);
mApplication = app;
```

以下为更加全面一点的代码：

```java
 // android.app.LoadedApk#makeApplication
    public Application makeApplication(boolean forceDefaultAppClass,
            Instrumentation instrumentation) {
        if (mApplication != null) {
            return mApplication;
        }

        Application app = null;
		// 获取Application的类名（manifest中定义）
        String appClass = mApplicationInfo.className;
        if (forceDefaultAppClass || (appClass == null)) {
            // 如果没有自定义，则使用系统的默认Application类
            appClass = "android.app.Application";
        }

        try {
            // 获取类加载器
            final java.lang.ClassLoader cl = getClassLoader();
            // 系统应用
            if (!mPackageName.equals("android")) {
                Trace.traceBegin(Trace.TRACE_TAG_ACTIVITY_MANAGER,
                        "initializeJavaContextClassLoader");
                initializeJavaContextClassLoader();
                Trace.traceEnd(Trace.TRACE_TAG_ACTIVITY_MANAGER);
            }

            // Rewrite the R 'constants' for all library apks.
            SparseArray<String> packageIdentifiers = getAssets().getAssignedPackageIdentifiers(
                    false, false);
            for (int i = 0, n = packageIdentifiers.size(); i < n; i++) {
                final int id = packageIdentifiers.keyAt(i);
                if (id == 0x01 || id == 0x7f) {
                    continue;
                }

                rewriteRValues(cl, packageIdentifiers.valueAt(i), id);
            }
			// 创建APp的Context
            ContextImpl appContext = ContextImpl.createAppContext(mActivityThread, this);
            // The network security config needs to be aware of multiple
            // applications in the same process to handle discrepancies
            NetworkSecurityConfigProvider.handleNewApplication(appContext);
            // 通过mActivityThread.mInstrumentation创建Application对象
            // 这里会调用application的attachBaseContext方法来将Application（ContextWrapper）中的mBase指向这里创建的appContext
            app = mActivityThread.mInstrumentation.newApplication(
                    cl, appClass, appContext);
            // 关联Application到appContext
            appContext.setOuterContext(app);
        } catch (Exception e) {
            // 
        }
        // 将Application记录到ActivityThread
        mActivityThread.mAllApplications.add(app);
        mApplication = app;

        if (instrumentation != null) {
            try {
                instrumentation.callApplicationOnCreate(app);
            } catch (Exception e) {
            }
        }
        return app;
    }
```

#### 小结

看到这里，我们已经了解到了Context如何创建，Application如何创建。

1. Application的Context对象通过 `ContextImpl.createAppContext` 方法创建，传入了ActivityThread对象。Context中会记录ActivityThread，packageInfo（类型为LoadedApk）及包名。
2. Application的创建通过`mActivityThread.mInstrumentation.newApplication`来完成，通过manifest中的类名（如未指定，使用系统默认的android.app.Application类）来实例化一个对象。
3. 将application与appContext关联；
4. 将appContext与Application关联；



## Application的创建，Applicatoin和Context的关联

见上个小节



## Activity的创建，Activity和Context的关联

有了上个小节的经验，我们直接查看ContextImpl类中的`createActivityContext`方法：

```java
// android.app.ContextImpl#createActivityContext
    static ContextImpl createActivityContext(ActivityThread mainThread,
            LoadedApk packageInfo, ActivityInfo activityInfo, IBinder activityToken, int displayId,
            Configuration overrideConfiguration) {
        if (packageInfo == null) throw new IllegalArgumentException("packageInfo");

        String[] splitDirs = packageInfo.getSplitResDirs();
        ClassLoader classLoader = packageInfo.getClassLoader();

        if (packageInfo.getApplicationInfo().requestsIsolatedSplitLoading()) {
            Trace.traceBegin(Trace.TRACE_TAG_RESOURCES, "SplitDependencies");
            try {
                classLoader = packageInfo.getSplitClassLoader(activityInfo.splitName);
                splitDirs = packageInfo.getSplitPaths(activityInfo.splitName);
            } catch (NameNotFoundException e) {
                // Nothing above us can handle a NameNotFoundException, better crash.
                throw new RuntimeException(e);
            } finally {
                Trace.traceEnd(Trace.TRACE_TAG_RESOURCES);
            }
        }

        ContextImpl context = new ContextImpl(null, mainThread, packageInfo, null,
                activityInfo.splitName, activityToken, null, 0, classLoader, null);
        // 标记为UIContext
        context.mIsUiContext = true;
        // 标记为与Display关联
        context.mIsAssociatedWithDisplay = true;
        // 
        context.mIsSystemOrSystemUiContext = isSystemOrSystemUI(context);
		// 获取displayId，以便后面生成Display对象
        // Clamp display ID to DEFAULT_DISPLAY if it is INVALID_DISPLAY.
        displayId = (displayId != Display.INVALID_DISPLAY) ? displayId : Display.DEFAULT_DISPLAY;

        final CompatibilityInfo compatInfo = (displayId == Display.DEFAULT_DISPLAY)
                ? packageInfo.getCompatibilityInfo()
                : CompatibilityInfo.DEFAULT_COMPATIBILITY_INFO;

        final ResourcesManager resourcesManager = ResourcesManager.getInstance();

        // Create the base resources for which all configuration contexts for this Activity
        // will be rebased upon.
        context.setResources(resourcesManager.createBaseTokenResources(activityToken,
                packageInfo.getResDir(),
                splitDirs,
                packageInfo.getOverlayDirs(),
                packageInfo.getApplicationInfo().sharedLibraryFiles,
                displayId,
                overrideConfiguration,
                compatInfo,
                classLoader,
                packageInfo.getApplication() == null ? null
                        : packageInfo.getApplication().getResources().getLoaders()));
        // 设置Display对象
        context.mDisplay = resourcesManager.getAdjustedDisplay(displayId,
                context.getResources());
        return context;
    }
```

我们根据这个方法也可以找到创建Activity对象的地方：

```java
// android.app.ActivityThread#performLaunchActivity
/**  Core implementation of activity launch. */
    private Activity performLaunchActivity(ActivityClientRecord r, Intent customIntent) {
        ActivityInfo aInfo = r.activityInfo;
        if (r.packageInfo == null) {
            r.packageInfo = getPackageInfo(aInfo.applicationInfo, r.compatInfo,
                    Context.CONTEXT_INCLUDE_CODE);
        }

        ComponentName component = r.intent.getComponent();
        if (component == null) {
            component = r.intent.resolveActivity(
                mInitialApplication.getPackageManager());
            r.intent.setComponent(component);
        }

        if (r.activityInfo.targetActivity != null) {
            component = new ComponentName(r.activityInfo.packageName,
                    r.activityInfo.targetActivity);
        }
		// createBaseContextForActivity 最后会调用上面的createActivityContext
        ContextImpl appContext = createBaseContextForActivity(r);
        Activity activity = null;
        try {
            java.lang.ClassLoader cl = appContext.getClassLoader();
            activity = mInstrumentation.newActivity(
                    cl, component.getClassName(), r.intent);
            r.intent.setExtrasClassLoader(cl);
            r.intent.prepareToEnterProcess();
            if (r.state != null) {
                r.state.setClassLoader(cl);
            }
        } catch (Exception e) {
            
        }

        try {
            Application app = r.packageInfo.makeApplication(false, mInstrumentation);
            if (activity != null) {
                CharSequence title = r.activityInfo.loadLabel(appContext.getPackageManager());
                Configuration config = new Configuration(mCompatConfiguration);
                if (r.overrideConfig != null) {
                    config.updateFrom(r.overrideConfig);
                }
                Window window = null;
                if (r.mPendingRemoveWindow != null && r.mPreserveWindow) {
                    window = r.mPendingRemoveWindow;
                    r.mPendingRemoveWindow = null;
                    r.mPendingRemoveWindowManager = null;
                }

                // Activity resources must be initialized with the same loaders as the
                // application context.
                appContext.getResources().addLoaders(
                        app.getResources().getLoaders().toArray(new ResourcesLoader[0]));

                appContext.setOuterContext(activity);
                // attach时，会将appContext设置为ContextWrapper中的mBase
                activity.attach(appContext, this, getInstrumentation(), r.token,
                        r.ident, app, r.intent, r.activityInfo, title, r.parent,
                        r.embeddedID, r.lastNonConfigurationInstances, config,
                        r.referrer, r.voiceInteractor, window, r.configCallback,
                        r.assistToken);

                if (customIntent != null) {
                    activity.mIntent = customIntent;
                }
                r.lastNonConfigurationInstances = null;
                checkAndBlockForNetworkAccess();
                activity.mStartedActivity = false;
                int theme = r.activityInfo.getThemeResource();
                if (theme != 0) {
                    activity.setTheme(theme);
                }

                activity.mCalled = false;
                if (r.isPersistable()) {
                    mInstrumentation.callActivityOnCreate(activity, r.state, r.persistentState);
                } else {
                    mInstrumentation.callActivityOnCreate(activity, r.state);
                }
                if (!activity.mCalled) {
                    throw new SuperNotCalledException(
                        "Activity " + r.intent.getComponent().toShortString() +
                        " did not call through to super.onCreate()");
                }
                r.activity = activity;
                mLastReportedWindowingMode.put(activity.getActivityToken(),
                        config.windowConfiguration.getWindowingMode());
            }
            r.setState(ON_CREATE);

            // updatePendingActivityConfiguration() reads from mActivities to update
            // ActivityClientRecord which runs in a different thread. Protect modifications to
            // mActivities to avoid race.
            synchronized (mResourcesManager) {
                mActivities.put(r.token, r);
            }

        } catch (SuperNotCalledException e) {
            throw e;

        } catch (Exception e) {
            if (!mInstrumentation.onException(activity, e)) {
                throw new RuntimeException(
                    "Unable to start activity " + component
                    + ": " + e.toString(), e);
            }
        }

        return activity;
    }
```



### 与Application的Context的差异

1. 构造差异
   * 多了 activityInfo.splitName, activityToken, classLoader，等参数
2. resource的创建方式有差别；
   * Activity： 
   * Application： 
3. 多了一些和UI及Display有关的属性；

## Service的创建，Service和Context的关联

在之前的章节中，我们分析bindService的启动时，曾分析过Service的启动流程，最终是通过ActivityThread的handleCreateService来完成服务的创建的，这里我们直接将此方法的源码贴出来。

可以看到：

1. Service的Context的创建调用的方法和Application的一样，同样都是使用 `ContextImpl.createAppContext` 来创建的；
2. 不过Service的Context多添加了一个Loaders到context的Resources中；

```java
// android/app/ActivityThread.java
// android.app.ActivityThread#handleCreateService

final ArrayMap<IBinder, Service> mServices = new ArrayMap<>();
private void handleCreateService(CreateServiceData data) {
    // If we are getting ready to gc after going to the background, well
    // we are back active so skip it.
    unscheduleGcIdler();
    LoadedApk packageInfo = getPackageInfoNoCheck(
        data.info.applicationInfo, data.compatInfo);
    Service service = null;
    try {
        if (localLOGV) Slog.v(TAG, "Creating service " + data.info.name);
		// 使用ContextImpl.createAppContext
        ContextImpl context = ContextImpl.createAppContext(this, packageInfo);
        Application app = packageInfo.makeApplication(false, mInstrumentation);
        java.lang.ClassLoader cl = packageInfo.getClassLoader();
        // 创建对应的Service实例
        service = packageInfo.getAppFactory()
                .instantiateService(cl, data.info.name, data.intent);
        // Service resources must be initialized with the same loaders as the application
        // context.
        context.getResources().addLoaders(
                app.getResources().getLoaders().toArray(new ResourcesLoader[0]));

        context.setOuterContext(service);
        service.attach(context, this, data.info.name, data.token, app,
                ActivityManager.getService());
        service.onCreate();
        mServices.put(data.token, service);
        try {
            ActivityManager.getService().serviceDoneExecuting(
                    data.token, SERVICE_DONE_EXECUTING_ANON, 0, 0);
        } catch (RemoteException e) {
            throw e.rethrowFromSystemServer();
        }
    } catch (Exception e) {
        if (!mInstrumentation.onException(service, e)) {
            throw new RuntimeException(
                "Unable to create service " + data.info.name
                + ": " + e.toString(), e);
        }
    }
}
```

`addLoaders`:

```java
// android.content.res.Resources#addLoaders  
/**
     * Adds a loader to the list of loaders. If the loader is already present in the list, the list
     * will not be modified.
     *
     * <p>This should only be called from the UI thread to avoid lock contention when propagating
     * loader changes.
     *
     * @param loaders the loaders to add
     */
    public void addLoaders(@NonNull ResourcesLoader... loaders) {
        synchronized (mUpdateLock) {
            checkCallbacksRegistered();
            final List<ResourcesLoader> newLoaders =
                    new ArrayList<>(mResourcesImpl.getAssets().getLoaders());
            final ArraySet<ResourcesLoader> loaderSet = new ArraySet<>(newLoaders);

            for (int i = 0; i < loaders.length; i++) {
                final ResourcesLoader loader = loaders[i];
                if (!loaderSet.contains(loader)) {
                    newLoaders.add(loader);
                }
            }

            if (loaderSet.size() == newLoaders.size()) {
                return;
            }

            mCallbacks.onLoadersChanged(this, newLoaders);
            for (int i = loaderSet.size(), n = newLoaders.size(); i < n; i++) {
                newLoaders.get(i).registerOnProvidersChangedCallback(this, mCallbacks);
            }
        }
    }
```

## Receiver的Context

Receiver的Context来源于Application的Context，然后包装了一层，限制了几个接口，主要是限制了注册Receiver和绑定Service；

```java
 @UnsupportedAppUsage(maxTargetSdk = Build.VERSION_CODES.P, trackingBug = 115609023)
    private void handleReceiver(ReceiverData data) {
        String component = data.intent.getComponent().getClassName();
        LoadedApk packageInfo = getPackageInfoNoCheck(
                data.info.applicationInfo, data.compatInfo);
        IActivityManager mgr = ActivityManager.getService();
        Application app;
        BroadcastReceiver receiver;
        ContextImpl context;
        try {
            app = packageInfo.makeApplication(false, mInstrumentation);
            context = (ContextImpl) app.getBaseContext();
            if (data.info.splitName != null) {
                context = (ContextImpl) context.createContextForSplit(data.info.splitName);
            }
            java.lang.ClassLoader cl = context.getClassLoader();
            data.intent.setExtrasClassLoader(cl);
            data.intent.prepareToEnterProcess();
            data.setExtrasClassLoader(cl);
            receiver = packageInfo.getAppFactory()
                    .instantiateReceiver(cl, data.info.name, data.intent);
        } catch (Exception e) {
            data.sendFinished(mgr);
        }

        try {
            sCurrentBroadcastIntent.set(data.intent);
            receiver.setPendingResult(data);
            receiver.onReceive(context.getReceiverRestrictedContext(),
                    data.intent);
        } catch (Exception e) {
            
        } finally {
            sCurrentBroadcastIntent.set(null);
        }

        if (receiver.getPendingResult() != null) {
            data.finish();
        }
    }
```

`getReceiverRestrictedContext`: 

限制之处在于不允许注册Receiver，不允许bind服务；

```java
// android.app.ContextImpl#getReceiverRestrictedContext
    @UnsupportedAppUsage
    final Context getReceiverRestrictedContext() {
        if (mReceiverRestrictedContext != null) {
            return mReceiverRestrictedContext;
        }
        return mReceiverRestrictedContext = new ReceiverRestrictedContext(getOuterContext());
    }

// android.app.ReceiverRestrictedContext
class ReceiverRestrictedContext extends ContextWrapper {
    @UnsupportedAppUsage
    ReceiverRestrictedContext(Context base) {
        super(base);
    }

    @Override
    public Intent registerReceiver(BroadcastReceiver receiver, IntentFilter filter) {
        return registerReceiver(receiver, filter, null, null);
    }

    @Override
    public Intent registerReceiver(BroadcastReceiver receiver, IntentFilter filter,
            String broadcastPermission, Handler scheduler) {
        if (receiver == null) {
            // Allow retrieving current sticky broadcast; this is safe since we
            // aren't actually registering a receiver.
            return super.registerReceiver(null, filter, broadcastPermission, scheduler);
        } else {
            throw new ReceiverCallNotAllowedException(
                    "BroadcastReceiver components are not allowed to register to receive intents");
        }
    }

    @Override
    public Intent registerReceiverForAllUsers(BroadcastReceiver receiver, IntentFilter filter,
            String broadcastPermission, Handler scheduler) {
        return registerReceiverAsUser(
                receiver, UserHandle.ALL, filter, broadcastPermission, scheduler);
    }

    @Override
    public Intent registerReceiverAsUser(BroadcastReceiver receiver, UserHandle user,
            IntentFilter filter, String broadcastPermission, Handler scheduler) {
        if (receiver == null) {
            // Allow retrieving current sticky broadcast; this is safe since we
            // aren't actually registering a receiver.
            return super.registerReceiverAsUser(null, user, filter, broadcastPermission, scheduler);
        } else {
            throw new ReceiverCallNotAllowedException(
                    "BroadcastReceiver components are not allowed to register to receive intents");
        }
    }

    @Override
    public boolean bindService(Intent service, ServiceConnection conn, int flags) {
        throw new ReceiverCallNotAllowedException(
                "BroadcastReceiver components are not allowed to bind to services");
    }

    @Override
    public boolean bindService(
          Intent service, int flags, Executor executor, ServiceConnection conn) {
        throw new ReceiverCallNotAllowedException(
            "BroadcastReceiver components are not allowed to bind to services");
    }

    @Override
    public boolean bindIsolatedService(Intent service, int flags, String instanceName,
            Executor executor, ServiceConnection conn) {
        throw new ReceiverCallNotAllowedException(
            "BroadcastReceiver components are not allowed to bind to services");
    }
}
    
```



## 总结（待补充）

### 代码共同之处

1. Application,Service,Activity都会调用setOutContext来关联对应的实例对象到context

   ```java
   appContext.setOuterContext(app);
   context.setOuterContext(service);
   appContext.setOuterContext(activity);
   ```

2. 调用对应组件的attach方法，将context设置为baseContext，就是赋值给ContextWrapper中的mBase；

3. 都会设置resource，不过设置的resource有区别

   ```java
   // Application的Context（及Service的）
   // android.app.ContextImpl#createApplicationContext
   c.setResources(createResources(mToken, pi, null, displayId, null,
                       getDisplayAdjustments(displayId).getCompatibilityInfo(), null));
   
   // Activity的Context
   // android.app.ContextImpl#createActivityContext
   context.setResources(resourcesManager.createBaseTokenResources(activityToken,
                   packageInfo.getResDir(),
                   splitDirs,
                   packageInfo.getOverlayDirs(),
                   packageInfo.getApplicationInfo().sharedLibraryFiles,
                   displayId,
                   overrideConfiguration,
                   compatInfo,
                   classLoader,
                   packageInfo.getApplication() == null ? null
                           : packageInfo.getApplication().getResources().getLoaders()));
   
   // Service
   // android.app.ContextImpl#createApplicationContext
   c.setResources(createResources(mToken, pi, null, displayId, null,
                       getDisplayAdjustments(displayId).getCompatibilityInfo(), null));
   // android.app.ActivityThread#handleCreateService
   context.getResources().addLoaders(
                       app.getResources().getLoaders().toArray(new ResourcesLoader[0]));
   ```

   

4. Service和Activity都有调用addLoaders

   ```java
   appContext.getResources().addLoaders(app.getResources().getLoaders().toArray(new ResourcesLoader[0]));
   ```

## 使用角度看

### Context类图

* `Context`是一个抽象类，基本上所有方法都是抽象的，没有具体的成员变量，只包含一些常量的定义；
* 具体的实现放在`ContextImpl`中;
* `ContextWrapper`是对`Context`的包装，构造时需要传递一个Context对象作为mBase，所有方法都代理给实际的mBase对象；
* `ContextThemeWrapper` 则基于`ContextWrapper`提供了布局相关的属性，如 `mTheme` 及 `mInflater` 
* `Service`及`Application`继承至`ContextWrapper` ，`Activity`继承了`ContextThemeWrapper`

![image-20210420152731372](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210420152731.png)





## 待补充

比较底层的ContextImpl的实例构建差异；

