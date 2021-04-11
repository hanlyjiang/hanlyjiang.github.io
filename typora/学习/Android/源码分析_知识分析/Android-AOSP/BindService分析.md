---

title: 'Android bindService流程'
date: 2020-03-20 10:18:50
tags: [Android,WebView,Vue]
published: true
hideInList: false
feature: 
isTop: false
---

## 整体流程预览

在Activity中调用bindService，实际上是 Context.bindService ，所以我们的开始的地方是Context.bindService，调用序列如下：

> 每个大的方框中上面的是调用的方法，下面的是源码所在的文件，部分文件的路径从frameworks开始，部分由于路径太长做了省略，实际上大部分在frameworks中。




<svg width="625px" height="425px" viewBox="0 0 625 425" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <g id="Android源码分析" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
        <g id="bindService流程分析备份" transform="translate(-98.000000, -85.000000)">
            <g id="架构图/模块-源码" transform="translate(122.000000, 124.000000)">
                <rect id="矩形" stroke="#979797" stroke-width="0.669456067" fill="#E4E4E4" x="0.334728033" y="0.334728033" width="229.405661" height="25.3305439" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="67.177475" y="11">Context.bindService</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="25.5312824" y="23.3877551">frameworks/base/core/java/android/content/Context.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份" transform="translate(122.000000, 162.000000)">
                <rect id="矩形" stroke="#979797" stroke-width="0.669456067" fill="#E4E4E4" x="0.334728033" y="0.334728033" width="229.405661" height="25.3305439" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="56.3758014" y="11">ContextImpl.bindService</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="24.523751" y="23.3877551">frameworks/base/core/java/android/app/ContextImpl.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-2" transform="translate(122.000000, 201.000000)">
                <rect id="矩形" stroke="#979797" stroke-width="0.669456067" fill="#E4E4E4" x="0.334728033" y="0.334728033" width="229.405661" height="25.3305439" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="35.0817428" y="11">ContextImpl.bindServiceCommon</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="24.523751" y="23.3877551">frameworks/base/core/java/android/app/ContextImpl.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-3" transform="translate(122.000000, 239.000000)">
                <rect id="矩形" stroke="#979797" stroke-width="0.669456067" fill="#E4E4E4" x="0.334728033" y="0.334728033" width="229.405661" height="25.3305439" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="26.9511989" y="11">IActivityManager.bindIsolatedService</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="61.7354666" y="23.3877551">android/app/IActivityManager.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-4" transform="translate(428.000000, 124.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="10.835383" y="11">ActivityManagerService.bindIsolatedService</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="33.7957176" y="23.3877551">com/android/server/am/ActivityManagerService.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-5" transform="translate(428.000000, 162.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="34.6552993" y="11">ActiveServices.bindServiceLocked</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="47.5865126" y="23.3877551">com/android/server/am/ActiveServices.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-16" transform="translate(428.000000, 239.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="19.1486884" y="11">IApplicationThread.scheduleBindService</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="57.7019938" y="23.3877551">android/app/IApplicationThread.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-17" transform="translate(428.000000, 285.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFED99" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="78.9632491" y="11">Binder.transact</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="104.925425" y="23.3877551">binder</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-18" transform="translate(364.000000, 124.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFED99" x="0.5" y="0.5" width="48.2300469" height="140" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="7.74941678" y="11">Binder.</tspan>
                    <tspan x="5.09234565" y="25">transact</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="14.5028896" y="91.4489796">binder</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-18" transform="translate(364.000000, 327.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFED99" x="0.5" y="0.5" width="48.2300469" height="140" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="7.74941678" y="11">Binder.</tspan>
                    <tspan x="5.09234565" y="25">transact</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="14.5028896" y="91.4489796">binder</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-10" transform="translate(427.000000, 327.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFBBA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="20.74668" y="11">ApplicationThread.scheduleBindService</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="21.4409058" y="23.3877551">frameworks/base/core/java/android/app/ActivityThread.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-12" transform="translate(427.000000, 366.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFBBA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="33.2260106" y="11">ActivityThread#handleBindService</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="21.4409058" y="23.3877551">frameworks/base/core/java/android/app/ActivityThread.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-19" transform="translate(427.000000, 404.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFBBA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="48.4748809" y="11">IBinder = Service.onBinder()</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="80.1254248" y="23.3877551">自定义的Service实现类</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-20" transform="translate(427.000000, 442.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFBBA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="37.3498599" y="11">IActivityManager#publishService</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="61.7354666" y="23.3877551">android/app/IActivityManager.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-21" transform="translate(122.000000, 327.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="21.6558014" y="11">ActivityManagerService#publishService</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="61.7354666" y="23.3877551">android/app/IActivityManager.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-23" transform="translate(122.000000, 366.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="26.4872658" y="11">ActiveServices#publishServiceLocked</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="47.5865126" y="23.3877551">com/android/server/am/ActiveServices.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-8" transform="translate(428.000000, 201.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="9.12492271" y="11">ActiveServices.requestServiceBindingLocked</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="47.5865126" y="23.3877551">com/android/server/am/ActiveServices.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-13" transform="translate(293.000000, 85.000000)">
                <rect id="矩形" stroke="#979797" stroke-width="0.669456067" fill="#E4E4E4" x="0.334728033" y="0.334728033" width="57.6028444" height="25.3305439" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="4.7070289" y="11">APP-client</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="16.1955644" y="23.3877551">APP进程</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-14" transform="translate(664.000000, 85.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="57.2723005" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="2.28895358" y="11">AMS-server</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="4.60727991" y="23.3877551">system_process</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-14" transform="translate(293.000000, 483.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="57.2723005" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="2.28895358" y="11">AMS-server</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="4.60727991" y="23.3877551">system_process</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-15" transform="translate(664.000000, 484.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFBBA2" x="0.5" y="0.5" width="57.2723005" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="3.26368162" y="11">APP:server</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="4.19221715" y="23.3877551">APP Service进程</tspan>
                </text>
            </g>
            <path id="直线-16" d="M648.958513,91.3054393 C649.115942,91.3054393 649.271209,91.3429319 649.412018,91.4149479 L649.412018,91.4149479 L664.383659,99.0721148 C664.884587,99.3283119 665.087628,99.9513781 664.837164,100.463772 C664.739039,100.664514 664.579909,100.827287 664.383659,100.927658 L664.383659,100.927658 L649.412018,108.584825 C648.91109,108.841022 648.301967,108.633333 648.051503,108.120939 C647.981098,107.976907 647.944444,107.818086 647.944444,107.657053 L647.944444,107.657053 L647.944,101.338 L351,101.338912 C350.260539,101.338912 349.661088,100.739461 349.661088,100 C349.661088,99.3040369 350.19209,98.732096 350.871054,98.667217 L351,98.6610879 L647.944,98.661 L647.944444,92.3427195 C647.944444,91.8080371 648.339941,91.3678422 648.848019,91.3115259 Z" fill-opacity="0.56105479" fill="#C9C9C9" fill-rule="nonzero"></path>
            <path id="直线-16备份-2" d="M366.041487,488.305439 C366.601542,488.305439 367.055556,488.769845 367.055556,489.342719 L367.055556,489.342719 L367.055,495.661 L664,495.661088 C664.739461,495.661088 665.338912,496.260539 665.338912,497 C665.338912,497.695963 664.80791,498.267904 664.128946,498.332783 L664,498.338912 L367.055,498.338 L367.055556,504.657053 C367.055556,504.777828 367.034938,504.897358 366.994927,505.010339 L366.948497,505.120939 C366.698033,505.633333 366.08891,505.841022 365.587982,505.584825 L365.587982,505.584825 L350.616341,497.927658 C350.420091,497.827287 350.260961,497.664514 350.162836,497.463772 C349.912372,496.951378 350.115413,496.328312 350.616341,496.072115 L350.616341,496.072115 L365.587982,488.414948 C365.728791,488.342932 365.884058,488.305439 366.041487,488.305439 Z" fill-opacity="0.56105479" fill="#C9C9C9" fill-rule="nonzero"></path>
            <path id="直线-16备份" d="M696.5,110.661088 C697.195963,110.661088 697.767904,111.19209 697.832783,111.871054 L697.838912,112 L697.838,467.944 L704.157281,467.944444 C704.691963,467.944444 705.132158,468.339941 705.188474,468.848019 L705.194561,468.958513 C705.194561,469.115942 705.157068,469.271209 705.085052,469.412018 L705.085052,469.412018 L697.427885,484.383659 C697.171688,484.884587 696.548622,485.087628 696.036228,484.837164 C695.835486,484.739039 695.672713,484.579909 695.572342,484.383659 L695.572342,484.383659 L687.915175,469.412018 C687.658978,468.91109 687.866667,468.301967 688.379061,468.051503 C688.523093,467.981098 688.681914,467.944444 688.842947,467.944444 L688.842947,467.944444 L695.161,467.944 L695.161088,112 C695.161088,111.260539 695.760539,110.661088 696.5,110.661088 Z" fill-opacity="0.56105479" fill="#C9C9C9" fill-rule="nonzero"></path>
            <path id="直线" d="M235.834728,150.007377 L235.834,156.046 L239.17364,156.046784 L235.5,163.046784 L231.82636,156.046784 L235.165,156.046 L235.165272,150.007377 L235.834728,150.007377 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-2" d="M235.834728,188.007377 L235.834,194.046 L239.17364,194.046784 L235.5,201.046784 L231.82636,194.046784 L235.165,194.046 L235.165272,188.007377 L235.834728,188.007377 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-3" d="M235.834728,226.007377 L235.834,232.046 L239.17364,232.046784 L235.5,239.046784 L231.82636,232.046784 L235.165,232.046 L235.165272,226.007377 L235.834728,226.007377 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-17" d="M358.063889,246.82636 L365.063889,250.5 L358.063889,254.17364 L358.063,250.834 L351.990272,250.834728 L351.990272,250.165272 L358.063,250.165 L358.063889,246.82636 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-4" d="M422.04798,132.82636 L429.04798,136.5 L422.04798,140.17364 L422.047,136.834 L414.006181,136.834728 L414.006181,136.165272 L422.047,136.165 L422.04798,132.82636 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-5" d="M542.834728,150.007377 L542.834,156.046 L546.17364,156.046784 L542.5,163.046784 L538.82636,156.046784 L542.165,156.046 L542.165272,150.007377 L542.834728,150.007377 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-6" d="M542.834728,188.007377 L542.834,194.046 L546.17364,194.046784 L542.5,201.046784 L538.82636,194.046784 L542.165,194.046 L542.165272,188.007377 L542.834728,188.007377 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-7" d="M542.834728,226.007377 L542.834,232.046 L546.17364,232.046784 L542.5,239.046784 L538.82636,232.046784 L542.165,232.046 L542.165272,226.007377 L542.834728,226.007377 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-8" d="M542.834728,263.998605 L542.834,277.055 L546.17364,277.055556 L542.5,284.055556 L538.82636,277.055556 L542.165,277.055 L542.165272,263.998605 L542.834728,263.998605 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-9" d="M542.834728,309.998605 L542.834,321.055 L546.17364,321.055556 L542.5,328.055556 L538.82636,321.055556 L542.165,321.055 L542.165272,309.998605 L542.834728,309.998605 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-10" d="M542.834728,353.007377 L542.834,359.046 L546.17364,359.046784 L542.5,366.046784 L538.82636,359.046784 L542.165,359.046 L542.165272,353.007377 L542.834728,353.007377 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-18" d="M542.834728,392.007377 L542.834,398.046 L546.17364,398.046784 L542.5,405.046784 L538.82636,398.046784 L542.165,398.046 L542.165272,392.007377 L542.834728,392.007377 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-11" d="M542.834728,430.007377 L542.834,436.046 L546.17364,436.046784 L542.5,443.046784 L538.82636,436.046784 L542.165,436.046 L542.165272,430.007377 L542.834728,430.007377 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-19" d="M419.944444,451.82636 L419.944,455.165 L427.001395,455.165272 L427.001395,455.834728 L419.944,455.834 L419.944444,459.17364 L412.944444,455.5 L419.944444,451.82636 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-20" d="M358.936111,336.82636 L358.936,340.165 L365.009728,340.165272 L365.009728,340.834728 L358.936,340.834 L358.936111,344.17364 L351.936111,340.5 L358.936111,336.82636 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-12" d="M235.834728,353.007377 L235.834,359.046 L239.17364,359.046784 L235.5,366.046784 L231.82636,359.046784 L235.165,359.046 L235.165272,353.007377 L235.834728,353.007377 Z" fill="#979797" fill-rule="nonzero"></path>
            <g id="序号" transform="translate(98.000000, 222.000000)">
                <circle id="椭圆形" stroke="#888888" fill-opacity="0.5" fill="#E4E4E4" cx="10" cy="10" r="9.5"></circle>
                <text id="1" font-family="NotoSansCJKsc-Black, Noto Sans CJK SC" font-size="10" font-weight="800" letter-spacing="0.110000004" fill="#020202" fill-opacity="0.88378138">
                    <tspan x="6.9" y="14">1</tspan>
                </text>
            </g>
            <g id="序号备份" transform="translate(660.000000, 222.000000)">
                <circle id="椭圆形" stroke="#888888" fill-opacity="0.5" fill="#E4E4E4" cx="10" cy="10" r="9.5"></circle>
                <text id="2" font-family="NotoSansCJKsc-Black, Noto Sans CJK SC" font-size="10" font-weight="800" letter-spacing="0.110000004" fill="#020202" fill-opacity="0.88378138">
                    <tspan x="6.9" y="14">2</tspan>
                </text>
            </g>
        </g>
    </g>
</svg>



上面的流程只要我们一路跟踪可以得出此序列，不过这里我们有一些==问题==需要解答：

1. bindServiceCommon到IActivityManager的调用中，是如何获取到ActivityManagerService的？
2. AMS如何获取到ApplicatoinThread的？
   * ApplicatoinThread的用途？ApplicationThread运行的进程是哪个？
3. 进程何时创建？
4. ServiceConnection 的回调方法何时使用？



## 总结

### APP进程中如何获取AMS？

> 说明：
>
> * 第一次先逐项查看各个小节，最后再看此处的总结；
>
> * 后续直接查看总结来快速获取结论；

==总结：==

* APP进程中通过 `ServiceManager.getService(Context.ACTIVITY_SERVICE)` 获取的ActivityManagerService的客户端操作代理对象（Proxy）。
* 该对象位于APP进程中，可以使用此对象（通过Binder进程间通信）来要求（位于system_process中）的ActivityManagerService进行对应的服务操作； 

具体查看如下代码：

#### ContextImpl.bindServiceCommon

我们看 `ContextImpl.bindServiceCommon` 方法的实现，可以看到是调用了 ActivityManager.getService() 获取的；

`frameworks/base/core/java/android/app/ContextImpl.java`: 

```java
private boolean bindServiceCommon(Intent service, ServiceConnection conn, int flags,
            String instanceName, Handler handler, Executor executor, UserHandle user) {
        // Keep this in sync with DevicePolicyManager.bindDeviceAdminServiceAsUser.
        IServiceConnection sd;
        
        if (executor != null) {
            sd = mPackageInfo.getServiceDispatcher(conn, getOuterContext(), executor, flags);
        } else {
            sd = mPackageInfo.getServiceDispatcher(conn, getOuterContext(), handler, flags);
        }
	    //
        int res = ActivityManager.getService().bindIsolatedService(
            mMainThread.getApplicationThread(), getActivityToken(), service,
            service.resolveTypeIfNeeded(getContentResolver()),
            sd, flags, instanceName, getOpPackageName(), user.getIdentifier());

}
```

#### `ActivityManager.getService()`

如下代码，getService实际上是从ServiceManager获取一个ActivityService的Binder远程服务接口对象，并且这个会被设置为单例模式；

`frameworks/base/core/java/android/app/ActivityManager.java`:

```java
private static final Singleton<IActivityManager> IActivityManagerSingleton =
    new Singleton<IActivityManager>() {
    @Override
    protected IActivityManager create() {
        // 直接通过 ServiceManager.getService 获取一个IBinder对象
        final IBinder b = ServiceManager.getService(Context.ACTIVITY_SERVICE);
        final IActivityManager am = IActivityManager.Stub.asInterface(b);
        return am;
    }
};

public static IActivityManager getService() {
    // 直接从IActivityManagerSingleton获取实例
    return IActivityManagerSingleton.get();
}
```

### AMS如何获取到ApplicatoinThread？

首先，AMS实际上位于系统进程（system_process)，而ApplicationThread则位于我们的APP进程，那么为什么需要这个跨进程的操作呢？

* Service的创建需要经过系统的管理，比方说鉴权及其他管理需要；
* 而开发者定义的Service的实例的创建逻辑也还是需要开发者来实现，Service对应的类也应该只加载在开发者自己的进程之中，Service使用方实际上还是开发者自己，所以服务的真实实例的创建过程要在应用的进程中；

那么，系统进程（中的AMS）如何获取ApplicationThread呢？

首先我们需要了解ApplicationThread是什么？

#### 总结

* 启动服务的时候，如果服务没有创建，则执行 com.android.server.am.ActiveServices#bindServiceLocked 来创建服务；
* 创建服务的时候，如果对应的进程不存在，则通过AMS来创建一个进程，然后将其记录到AMS中；

#### requestServiceBindingLocked 中的 ServiceRecord

下面的方法中，我们可以看到

```java
// frameworks/base/services/core/java/com/android/server/am/ActiveServices.java
// com.android.server.am.ActiveServices#requestServiceBindingLocked
private final boolean requestServiceBindingLocked(ServiceRecord r, IntentBindRecord i,
            boolean execInFg, boolean rebind) throws TransactionTooLargeException {
        if (r.app == null || r.app.thread == null) {
            // If service is not currently running, can't yet bind.
            return false;
        }
        r.app.thread.scheduleBindService(r, i.intent.getIntent(), rebind,
                                         r.app.getReportedProcState());
        return true;
    }

// frameworks/base/services/core/java/com/android/server/am/ServiceRecord.java
ProcessRecord app;          // where this service is running or null.

// frameworks/base/services/core/java/com/android/server/am/ProcessRecord.java
IApplicationThread thread;  // the actual proc...  may be null only if
                            // 'persistent' is true (in which case we
                            // are in the process of launching the app)
```

其中 `ServiceRecord.app` 的类型为 `ProcessRecord` ，  `ServiceRecord.app.thread` 的类型为 `IApplicationThread`。

现在我们看下 ServiceRecord是何时构造的

首先，根据方法的调用层次，我们可以看到：

* `ActiveServices.bindServiceLocked` 方法中，参数中没有ServiceRecord，有的是IApplicationThread及一个IBinder。
* `ActiveServices.requestServiceBindingLocked` 方法中，则变成了ServiceRecord类型。

所以，我们先看下 `ActiveServices.requestServiceBindingLocked` 方法如何构造。

![image-20210410215833909](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210410215833.png)

> 提示：上述调用层次可以在IDEA中选中`ActiveServices.requestServiceBindingLocked`方法，然后通过“**Navigate｜Call Hierarchy**”（快捷键为==ctrl+opt+H==）弹出。

#### ActiveServices.requestServiceBindingLocked : 获取 ServiceRecord

```java
    int bindServiceLocked(IApplicationThread caller, IBinder token, Intent service,
            String resolvedType, final IServiceConnection connection, int flags,
            String instanceName, String callingPackage, final int userId)
            throws TransactionTooLargeException {
        final int callingPid = Binder.getCallingPid();
        final int callingUid = Binder.getCallingUid();
        // 这里构造了ProcessRecord
        final ProcessRecord callerApp = mAm.getRecordForAppLocked(caller);

        final boolean callerFg = callerApp.setSchedGroup != ProcessList.SCHED_GROUP_BACKGROUND;
        final boolean isBindExternal = (flags & Context.BIND_EXTERNAL_SERVICE) != 0;
        final boolean allowInstant = (flags & Context.BIND_ALLOW_INSTANT) != 0;

        // 将IApplicationThread及IBinder放入到ServiceRecord中的过程在retrieveServiceLocked中
        ServiceLookupResult res =
            retrieveServiceLocked(service, instanceName, resolvedType, callingPackage,
                    callingPid, callingUid, userId, true,
                    callerFg, isBindExternal, allowInstant);
        // 此处获取ServiceRecord，故在上面
        ServiceRecord s = res.record;
        if (s.app != null && b.intent.received) {
            requestServiceBindingLocked(s, b.intent, callerFg, true);
        } else if (!b.intent.requested) {
            requestServiceBindingLocked(s, b.intent, callerFg, false);
        }
        return 1;
    }
```

到这里，我们可以发现ServiceRecord是通过`retrieveServiceLocked`方法获取到的`ServiceLookupResult`获取到的。

==粗略看了下这个`retrieveServiceLocked`方法，其中逻辑比较多，我们这里转换下思路，直接查找 `ServiceRecord.app` 的赋值操作==。

#### `ServiceRecord.app` 的赋值

我们可以找到ServiceRecord.app（ProcessRecord）的赋值操作的调用方法为：`com.android.server.am.ActiveServices#realStartServiceLocked`

```java
private final void realStartServiceLocked(ServiceRecord r,
            ProcessRecord app, boolean execInFg) throws RemoteException {
        if (app.thread == null) {
            throw new RemoteException();
        }
    	// 在此处赋值
        r.setProcess(app);
	    // ...
}
```

查看 realStartServiceLocked 的调用序列：

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210410224824.png" alt="image-20210410224824691" style="zoom:50%;" />

也就是又回到了我们的 `bindServiceLocked` 方法，其中有一段逻辑是，如果需要创建服务，就执行`bringUpServiceLocked`方法。

```java
// com.android.server.am.ActiveServices#bindServiceLocked   
int bindServiceLocked(IApplicationThread caller, IBinder token, Intent service,
            String resolvedType, final IServiceConnection connection, int flags,
            String instanceName, String callingPackage, final int userId)
            throws TransactionTooLargeException {   
        // ... 
			if ((flags&Context.BIND_AUTO_CREATE) != 0) {
                s.lastActivity = SystemClock.uptimeMillis();
                if (bringUpServiceLocked(s, service.getFlags(), callerFg, false,
                        permissionsReviewRequired) != null) {
                    return 0;
                }
            }
        // ... 
    }
```



> 提示：我们可以通过如下IDEA操作来查找赋值操作
>
> 1. 选中成员（这里是 app）；
>
> 2. ==Ctrl+B== 或者 ==Command+鼠标单击==，弹出使用列表弹窗；
>
> 3. 然后在弹窗中设置仅查看write访问操作的；然后我们可以找到对应的赋值代码行；
>
>    <img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210410223230.png" alt="image-20210410223230694" style="zoom:50%;" />
>
> 4. 通过勾选其中的方法图标，我们可以显示赋值的代码行所在的方法（这里是setProcess）；
>
>    <img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210410223820.png" alt="image-20210410223820657" style="zoom:50%;" />
>
> 5. 然后我们继续在方法上执行上述操作，可以获取到更加上一步的赋值调用在哪；
>
>    <img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210410224023.png" alt="image-20210410224023641" style="zoom:50%;" />

#### ActiveServices#bringUpServiceLocked

##### **总结：**

1. **bringUpServiceLocked(ServiceRecord r,...)** 第一个参数为ServiceRecord，其中的app属性可存储一个进程记录； 
2. 如传入的ServiceRecord参数中表明服务已经启动过，`r.app(ProcessRecord)` 不为null，且`r.app.thread(IApplicationThread)`也不为null，则不创建，直接更新参数；
3. 结下来，则分为两种情况，1）服务为声明单独的进程，则可直接在当前进程中启动；2）服务声明了单独的进程，则需要先启动进程，然后再启动服务；
4. **非单独进程**：
   * 进程记录获取：通过AMS直接查询，并未创建，因为进程已经存在了，具体代码为 `app = mAm.getProcessRecordLocked(procName, r.appInfo.uid, false)`
   * 服务启动：使用 `realStartServiceLocked(r, app, execInFg);` 方法启动
5. **单独进程**：
   * 进程记录获取： 通过AMS.mAm.startProcessLocked 方法启动一个新的进程； 
     * `app=mAm.startProcessLocked(procName, r.appInfo, true, intentFlags,
                           hostingRecord, ZYGOTE_POLICY_FLAG_EMPTY, false, isolated, false)`
   * 服务启动：未在此方法中直接调用 `realStartServiceLocked`

这里我们可以看到，在**单独进程**的服务启动流程中，并没有即时调用`realStartServiceLocked`来启动服务，那么这里就又个问题，独立进程情况下服务何时启动？

6. **单独进程服务启动：** 将待启动的服务加入到`mPendingServices(ArrayList<ServiceRecord>)`，在启动进程后再从此列表中读取需要启动的服务，然后启动；

##### **问题结论：**

来到这个方法时我们有两个问题：

1. 进程记录如何获取？

   * 通过AMS的 `startProcessLocked` 方法创建（非独立进程的也应该是通过此方法创建，只是创建时机不是这里）

2. 服务如何启动？

   * 通过 `realStartServiceLocked` 方法启动（独立进程的应该也是此方法启动，会等到进程启动之后再启动）

   * > `realStartServiceLocked` 中通过 `IApplicationThread` 执行 `scheduleCreateService` 来启动服务，最终调用 `android.app.ActivityThread.ApplicationThread#scheduleCreateService`来启动；

     

##### **具体代码：**

* bringUpServiceLocked方法分析：

```java
// com.android.server.am.ActiveServices#bringUpServiceLocked
// frameworks/base/services/core/java/com/android/server/am/ActiveServices.java
private String bringUpServiceLocked(ServiceRecord r, int intentFlags, boolean execInFg,
            boolean whileRestarting, boolean permissionsReviewRequired)
            throws TransactionTooLargeException {
        // 已经存在进程记录，并且进程记录中的IApplicationThread已经存在，则不创建服务，仅发送参数
        if (r.app != null && r.app.thread != null) {
            sendServiceArgsLocked(r, execInFg, false);
            return null;
        }
        final boolean isolated = (r.serviceInfo.flags&ServiceInfo.FLAG_ISOLATED_PROCESS) != 0;
        final String procName = r.processName;
        HostingRecord hostingRecord = new HostingRecord("service", r.instanceName);
        ProcessRecord app;
		// 非独立的进程，则直接获取当前启动进程的进程信息
        if (!isolated) {
            app = mAm.getProcessRecordLocked(procName, r.appInfo.uid, false);
             if (app != null && app.thread != null) {
                try {
                    app.addPackage(r.appInfo.packageName, r.appInfo.longVersionCode, mAm.mProcessStats);
                    // 非独立进程中，直接启动服务
                    realStartServiceLocked(r, app, execInFg);
                    // 调用启动方法后直接返回
                    return null;
                } catch (TransactionTooLargeException e) {
                    throw e;
                } catch (RemoteException e) {
                    Slog.w(TAG, "Exception when starting service " + r.shortInstanceName, e);
                }

                // If a dead object exception was thrown -- fall through to
                // restart the application.
            }
        } else {
            // 独立进程则先尝试使用之前保存的
            app = r.isolatedProc;
        }

        // 之前没有启动对应的进程，则开始创建，启动了，则无需进行赋值操作，因为ServiceRecord中已经有了
        if (app == null && !permissionsReviewRequired) {
            if ((app=mAm.startProcessLocked(procName, r.appInfo, true, intentFlags,
                    hostingRecord, ZYGOTE_POLICY_FLAG_EMPTY, false, isolated, false)) == null) {
                String msg = "Unable to launch app "
                        + r.appInfo.packageName + "/"
                        + r.appInfo.uid + " for service "
                        + r.intent.getIntent() + ": process is bad";
                Slog.w(TAG, msg);
                bringDownServiceLocked(r);
                // 进程启动失败，返回错误消息
                return msg;
            }
            if (isolated) {
                // 独立进程，缓存进程信息到传入的ServiceRecord参数中，以便后续直接使用
                r.isolatedProc = app;
            }
        }
        // 将服务记录加入的mPendingServices中，由于非独立进程创建后已经直接返回，所以这里适用于独立进程的
        if (!mPendingServices.contains(r)) {
            mPendingServices.add(r);
        }
	    // 创建成功或者之前已经又了缓存，则返回null
        return null;
    }
```

* 独立进程何时启动服务？

  一般来说，封装较好的代码会保证入口统一，如果非独立进程情况下服务的启动使用的是 `realStartServiceLocked` 方法来启动服务，那么独立进程情况下，服务的启动也应该使用此方法，所以我们查看 `realStartServiceLocked` 方法的调用层次，如下：

  **图片版本:**

  ![image-20210411112439961](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210411112440.png)

  **详细调用序列:**

  * `ActiveServices.attachApplicationLocked`(ProcessRecord, String)  (com.android.server.am)
    * ActivityManagerService.attachApplicationLocked(IApplicationThread, int, int, long)  (com.android.server.am)
      * ActivityManagerService.attachApplication(IApplicationThread, long)  (com.android.server.am)
  * `ActiveServices.bringUpServiceLocked`(ServiceRecord, int, boolean, boolean, boolean)  (com.android.server.am)
    * ActiveServices.startServiceInnerLocked(ServiceMap, Intent, ServiceRecord, boolean, boolean)  (com.android.server.am)
    * ActiveServices.bindServiceLocked(IApplicationThread, IBinder, Intent, String, IServiceConnection, int, String, ...)  (com.android.server.am)
    * ActiveServices.performServiceRestartLocked(ServiceRecord)  (com.android.server.am)

  也就是调用了 `ActiveServices.attachApplicationLocked` ,最终是通过AMS的`ActivityManagerService.attachApplication`来触发的;也就是只要找到`mAm.startProcessLocked`到`ActivityManagerService.attachApplication`的调用序列即可证明此猜想;

  我们可以找到如下调用序列，即最终实际上是从ActivityThread的main函数进入的，所以做出以下猜想：**进程启动后，创建ActivityThread时，如果有需要创建的服务，就启动服务；**

  <img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210411114715.png" alt="image-20210411114715216" style="zoom:50%;" />

  我们再看`attachApplicationLocked` 的逻辑，可以发现，会检查`mPendingServices`中是否有待启动的服务，然后逐一处理，如果有需要启动的服务，则会调用`realStartServiceLocked(sr, proc, sr.createdFromFg)`来启动服务。

  ```java
  boolean attachApplicationLocked(ProcessRecord proc, String processName)
              throws RemoteException {
          boolean didSomething = false;
          // Collect any services that are waiting for this process to come up.
          if (mPendingServices.size() > 0) {
              ServiceRecord sr = null;
              try {
                  for (int i=0; i<mPendingServices.size(); i++) {
                      sr = mPendingServices.get(i);
                      // 排除非独立Service
                      if (proc != sr.isolatedProc && (proc.uid != sr.appInfo.uid
                              || !processName.equals(sr.processName))) {
                          continue;
                      }
  
                      mPendingServices.remove(i);
                      i--;
                      proc.addPackage(sr.appInfo.packageName, sr.appInfo.longVersionCode,
                              mAm.mProcessStats);
                      // 启动服务
                      realStartServiceLocked(sr, proc, sr.createdFromFg);
                  }
              } catch (RemoteException e) {
                  Slog.w(TAG, "Exception in new application when starting service "
                          + sr.shortInstanceName, e);
                  throw e;
              }
          }
  }
  ```

## 详细流程分析

### ContextImpl.`bindService`

* `bindService` : (`frameworks/base/core/java/android/app/ContextImpl.java`)

  ```java
      @Override
      public boolean bindService(Intent service, ServiceConnection conn, int flags) {
          warnIfCallingFromSystemProcess();
          return bindServiceCommon(service, conn, flags, null, mMainThread.getHandler(), null,
                  getUser());
      }
  
      @Override
      public boolean bindService(
              Intent service, int flags, Executor executor, ServiceConnection conn) {
          warnIfCallingFromSystemProcess();
          return bindServiceCommon(service, conn, flags, null, null, executor, getUser());
      }
  
  ```

### ContextImpl.bindServiceCommon

* `bindServiceCommon`:  (`frameworks/base/core/java/android/app/ContextImpl.java`)

  ```java
  private boolean bindServiceCommon(Intent service, ServiceConnection conn, int flags,
              String instanceName, Handler handler, Executor executor, UserHandle user) {
          // Keep this in sync with DevicePolicyManager.bindDeviceAdminServiceAsUser.
          IServiceConnection sd;
          if (conn == null) {
              throw new IllegalArgumentException("connection is null");
          }
          if (handler != null && executor != null) {
              throw new IllegalArgumentException("Handler and Executor both supplied");
          }
          if (mPackageInfo != null) {
              if (executor != null) {
                  sd = mPackageInfo.getServiceDispatcher(conn, getOuterContext(), executor, flags);
              } else {
                  sd = mPackageInfo.getServiceDispatcher(conn, getOuterContext(), handler, flags);
              }
          } else {
              throw new RuntimeException("Not supported in system context");
          }
          validateServiceIntent(service);
          try {
              // WindowContext构造函数中的 WindowTokenClient
              IBinder token = getActivityToken();
              if (token == null && (flags&BIND_AUTO_CREATE) == 0 && mPackageInfo != null
                      && mPackageInfo.getApplicationInfo().targetSdkVersion
                      < android.os.Build.VERSION_CODES.ICE_CREAM_SANDWICH) {
                  flags |= BIND_WAIVE_PRIORITY;
              }
              service.prepareToLeaveProcess(this);
              int res = ActivityManager.getService().bindIsolatedService(
                  mMainThread.getApplicationThread(), getActivityToken(), service,
                  service.resolveTypeIfNeeded(getContentResolver()),
                  sd, flags, instanceName, getOpPackageName(), user.getIdentifier());
              if (res < 0) {
                  throw new SecurityException(
                          "Not allowed to bind to service " + service);
              }
              return res != 0;
          } catch (RemoteException e) {
              throw e.rethrowFromSystemServer();
          }
      }
  ```

### ActivityManagerService.bindIsolatedService

从这里开始，实际上位于AMS的Server端了，即我们的Activity所在的进程发送了一个启动服务的IPC请求给AMS（sysmte_server进程中）。

* ActivityManagerService.java : (frameworks/base/services/core/java/com/android/server/am/ActivityManagerService.java)

  ```java
  public int bindIsolatedService(IApplicationThread caller, IBinder token, Intent service,
              String resolvedType, IServiceConnection connection, int flags, String instanceName,
              String callingPackage, int userId) throws TransactionTooLargeException {
  		// .... 
          synchronized(this) {
              // 调用Binder接口
              return mServices.bindServiceLocked(caller, token, service,
                      resolvedType, connection, flags, instanceName, callingPackage, userId);
          }
      }
  ```

![image-20210409144356311](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210409144356.png)

### ActiveServices.bindServiceLocked

*  `ActiveServices.bindServiceLocked`: (`frameworks/base/services/core/java/com/android/server/am/ActiveServices.java`)

  * 这个方法有点长，我们截取重要部分

  ```java
  int bindServiceLocked(IApplicationThread caller, IBinder token, Intent service,
              String resolvedType, final IServiceConnection connection, int flags,
              String instanceName, String callingPackage, final int userId)
              throws TransactionTooLargeException {
      // 获取调用方的权限
          final int callingPid = Binder.getCallingPid();
          final int callingUid = Binder.getCallingUid();
          final ProcessRecord callerApp = mAm.getRecordForAppLocked(caller);
          if (callerApp == null) {
              throw new SecurityException(
                      "Unable to find app for caller " + caller
                      + " (pid=" + callingPid
                      + ") when binding service " + service);
          }
  
          ActivityServiceConnectionsHolder<ConnectionRecord> activity = null;
          if (token != null) {
              activity = mAm.mAtmInternal.getServiceConnectionsHolder(token);
              if (activity == null) {
                  Slog.w(TAG, "Binding with unknown activity: " + token);
                  return 0;
              }
          }
  
          int clientLabel = 0;
          PendingIntent clientIntent = null;
          final boolean isCallerSystem = callerApp.info.uid == Process.SYSTEM_UID;
         
  
          final boolean callerFg = callerApp.setSchedGroup != ProcessList.SCHED_GROUP_BACKGROUND;
          final boolean isBindExternal = (flags & Context.BIND_EXTERNAL_SERVICE) != 0;
          final boolean allowInstant = (flags & Context.BIND_ALLOW_INSTANT) != 0;
  
          ServiceLookupResult res =
              retrieveServiceLocked(service, instanceName, resolvedType, callingPackage,
                      callingPid, callingUid, userId, true,
                      callerFg, isBindExternal, allowInstant);
          if (res == null) {
              return 0;
          }
          if (res.record == null) {
              return -1;
          }
          ServiceRecord s = res.record;
  
          try {
              if (unscheduleServiceRestartLocked(s, callerApp.info.uid, false)) {
                  if (DEBUG_SERVICE) Slog.v(TAG_SERVICE, "BIND SERVICE WHILE RESTART PENDING: "
                          + s);
              }
  
              if ((flags&Context.BIND_AUTO_CREATE) != 0) {
                  s.lastActivity = SystemClock.uptimeMillis();
                  if (!s.hasAutoCreateConnections()) {
                      // This is the first binding, let the tracker know.
                      ServiceState stracker = s.getTracker();
                      if (stracker != null) {
                          stracker.setBound(true, mAm.mProcessStats.getMemFactorLocked(),
                                  s.lastActivity);
                      }
                  }
              }
  
              if ((flags & Context.BIND_RESTRICT_ASSOCIATIONS) != 0) {
                  mAm.requireAllowedAssociationsLocked(s.appInfo.packageName);
              }
  
              mAm.startAssociationLocked(callerApp.uid, callerApp.processName,
                      callerApp.getCurProcState(), s.appInfo.uid, s.appInfo.longVersionCode,
                      s.instanceName, s.processName);
              // Once the apps have become associated, if one of them is caller is ephemeral
              // the target app should now be able to see the calling app
              mAm.grantImplicitAccess(callerApp.userId, service,
                      callerApp.uid, UserHandle.getAppId(s.appInfo.uid));
  
              AppBindRecord b = s.retrieveAppBindingLocked(service, callerApp);
              ConnectionRecord c = new ConnectionRecord(b, activity,
                      connection, flags, clientLabel, clientIntent,
                      callerApp.uid, callerApp.processName, callingPackage);
  
              IBinder binder = connection.asBinder();
              s.addConnection(binder, c);
              b.connections.add(c);
              if (activity != null) {
                  activity.addConnection(c);
              }
              b.client.connections.add(c);
              if (s.app != null) {
                  updateServiceClientActivitiesLocked(s.app, c, true);
              }
              ArrayList<ConnectionRecord> clist = mServiceConnections.get(binder);
              if (clist == null) {
                  clist = new ArrayList<>();
                  mServiceConnections.put(binder, clist);
              }
              clist.add(c);
  
              if ((flags&Context.BIND_AUTO_CREATE) != 0) {
                  s.lastActivity = SystemClock.uptimeMillis();
                  if (bringUpServiceLocked(s, service.getFlags(), callerFg, false,
                          permissionsReviewRequired) != null) {
                      return 0;
                  }
              }
  
              if (s.app != null && b.intent.received) {
                  // Service is already running, so we can immediately
                  // publish the connection.
                  try {
                      c.conn.connected(s.name, b.intent.binder, false);
                  } catch (Exception e) {
                      Slog.w(TAG, "Failure sending service " + s.shortInstanceName
                              + " to connection " + c.conn.asBinder()
                              + " (in " + c.binding.client.processName + ")", e);
                  }
              } else if (!b.intent.requested) {
                  requestServiceBindingLocked(s, b.intent, callerFg, false);
              }
          } finally {
          }
          return 1;
      }
  ```
  
  ### ActiveServices.realStartServiceLocked
```java
 /**
     * Note the name of this method should not be confused with the started services concept.
     * The "start" here means bring up the instance in the client, and this method is called
     * from bindService() as well.
     */
    private final void realStartServiceLocked(ServiceRecord r,
            ProcessRecord app, boolean execInFg) throws RemoteException {
        if (app.thread == null) {
            throw new RemoteException();
        }
        r.setProcess(app);
        r.restartTime = r.lastActivity = SystemClock.uptimeMillis();
		// 创建服务
        final boolean newService = app.startService(r);
        bumpServiceExecutingLocked(r, execInFg, "create");
        mAm.updateLruProcessLocked(app, false, null);
        updateServiceForegroundLocked(r.app, /* oomAdj= */ false);
        mAm.updateOomAdjLocked(app, OomAdjuster.OOM_ADJ_REASON_START_SERVICE);

        boolean created = false;
        try {
            app.forceProcessStateUpTo(ActivityManager.PROCESS_STATE_SERVICE);
            // 创建服务
            app.thread.scheduleCreateService(r, r.serviceInfo,
                    mAm.compatibilityInfoForPackage(r.serviceInfo.applicationInfo),
                    app.getReportedProcState());
            r.postNotification();
            created = true;
        } catch (DeadObjectException e) {
            Slog.w(TAG, "Application dead when creating service " + r);
            mAm.appDiedLocked(app, "Died when creating service");
            throw e;
        } finally {
            // 
        }

        // 绑定服务
        requestServiceBindingsLocked(r, execInFg);

        updateServiceClientActivitiesLocked(app, null, true);

        if (newService && created) {
            app.addBoundClientUidsOfNewService(r);
        }

        // If the service is in the started state, and there are no
        // pending arguments, then fake up one so its onStartCommand() will
        // be called.
        if (r.startRequested && r.callStart && r.pendingStarts.size() == 0) {
            r.pendingStarts.add(new ServiceRecord.StartItem(r, false, r.makeNextStartId(),
                    null, null, 0));
        }
        sendServiceArgsLocked(r, execInFg, true);
    }
```



### ActivityManagerService.attachApplicationLocked

```java
    @GuardedBy("this")
    private boolean attachApplicationLocked(@NonNull IApplicationThread thread,
            int pid, int callingUid, long startSeq) {
     	   
        
    }
```

### ApplicationThread.handleCreateService

`frameworks/base/core/java/android/app/ActivityThread.java`

```java
 @UnsupportedAppUsage
    private void handleCreateService(CreateServiceData data) {
        // If we are getting ready to gc after going to the background, well
        // we are back active so skip it.
        unscheduleGcIdler();

        LoadedApk packageInfo = getPackageInfoNoCheck(
                data.info.applicationInfo, data.compatInfo);
        Service service = null;
        try {
            if (localLOGV) Slog.v(TAG, "Creating service " + data.info.name);
			// 创建上下文对象
            ContextImpl context = ContextImpl.createAppContext(this, packageInfo);
            // 创建Application
            Application app = packageInfo.makeApplication(false, mInstrumentation);
            // 获取对应的类加载器
            java.lang.ClassLoader cl = packageInfo.getClassLoader();
            // 创建Service实例
            service = packageInfo.getAppFactory()
                    .instantiateService(cl, data.info.name, data.intent);
            // Service resources must be initialized with the same loaders as the application
            // context.
            context.getResources().addLoaders(
                    app.getResources().getLoaders().toArray(new ResourcesLoader[0]));

            context.setOuterContext(service);
            service.attach(context, this, data.info.name, data.token, app,
                    ActivityManager.getService());
            // 调用onCreate回调
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



### frameworks/base/core/java/android/app/ActivityThread.java

# BBinder相关

BBinder 何时创建，如何设置到parcel的数据结构中？

## BBinder

* BBinder : `frameworks/native/include/binder/Binder.h`

  ```cpp
  class BBinder : public IBinder
  {
  public:
                          BBinder();
  
      virtual const String16& getInterfaceDescriptor() const;
      virtual bool        isBinderAlive() const;
      virtual status_t    pingBinder();
      virtual status_t    dump(int fd, const Vector<String16>& args);
  
      // NOLINTNEXTLINE(google-default-arguments)
      virtual status_t    transact(   uint32_t code,
                                      const Parcel& data,
                                      Parcel* reply,
                                      uint32_t flags = 0) final;
      virtual BBinder*    localBinder();
      
  }
  ```

## JavaBBinder

* JavaBBinder : `frameworks/base/core/jni/android_util_Binder.cpp`

  ```cpp
  class JavaBBinderHolder;
  
  class JavaBBinder : public BBinder
  {
  public:
      JavaBBinder(JNIEnv* env, jobject /* Java Binder */ object)
          : mVM(jnienv_to_javavm(env)), mObject(env->NewGlobalRef(object))
      {
          ALOGV("Creating JavaBBinder %p\n", this);
          gNumLocalRefsCreated.fetch_add(1, std::memory_order_relaxed);
          gcIfManyNewRefs(env);
      }
  
      bool    checkSubclass(const void* subclassID) const
      {
          return subclassID == &gBinderOffsets;
      }
  
      jobject object() const
      {
          return mObject;
      }
  ```

## JavaBBinderHolder

* JavaBBinderHolder :`frameworks/base/core/jni/android_util_Binder.cpp`

  ```cpp
  class JavaBBinderHolder
  {
  public:
      sp<JavaBBinder> get(JNIEnv* env, jobject obj)
      {
          AutoMutex _l(mLock);
          sp<JavaBBinder> b = mBinder.promote();
          if (b == NULL) {
              // 注意这里构造的 JavaBBinder
              b = new JavaBBinder(env, obj);
              if (mVintf) {
                  ::android::internal::Stability::markVintf(b.get());
              }
              if (mExtension != nullptr) {
                  b.get()->setExtension(mExtension);
              }
              mBinder = b;
              ALOGV("Creating JavaBinder %p (refs %p) for Object %p, weakCount=%" PRId32 "\n",
                   b.get(), b->getWeakRefs(), obj, b->getWeakRefs()->getWeakCount());
          }
  
          return b;
      }
  
  }
  ```

## JavaBBinderHolder 的初始化

* frameworks/base/core/jni/android_util_Binder.cpp

  ```java
  static const JNINativeMethod gBinderMethods[] = {
      { "getNativeBBinderHolder", "()J", (void*)android_os_Binder_getNativeBBinderHolder },
  };
  
  
  static jlong android_os_Binder_getNativeBBinderHolder(JNIEnv* env, jobject clazz)
  {
      JavaBBinderHolder* jbh = new JavaBBinderHolder();
      return (jlong) jbh;
  }
  ```

* Binder.java 构造函数: (`frameworks/base/core/java/android/os/Binder.java`)

  ```java
     /**
       * Constructor for creating a raw Binder object (token) along with a descriptor.
       *
       * The descriptor of binder objects usually specifies the interface they are implementing.
       * In case of binder tokens, no interface is implemented, and the descriptor can be used
       * as a sort of tag to help identify the binder token. This will help identify remote
       * references to these objects more easily when debugging.
       *
       * @param descriptor Used to identify the creator of this token, for example the class name.
       * Instead of creating multiple tokens with the same descriptor, consider adding a suffix to
       * help identify them.
       */
      public Binder(@Nullable String descriptor)  {
          // 获取Native的BBinder对象的指针
          mObject = getNativeBBinderHolder();
          NoImagePreloadHolder.sRegistry.registerNativeAllocation(this, mObject);
          // ...
          mDescriptor = descriptor;
      }
  
  
      private static native long getNativeBBinderHolder();
  ```

* 实际上，CPP中使用的 `gBinderOffsets.mObject` 就是上面分配的 `NativeBBinderHolder`

  ```java
  // (frameworks/base/core/jni/android_util_Binder.cpp)
  static struct bindernative_offsets_t
  {
      // Class state.
      jclass mClass;
      jmethodID mExecTransact;
      jmethodID mGetInterfaceDescriptor;
  
      // Object state.
      jfieldID mObject;
  
  } gBinderOffsets;
  ```

* 发现一个函数 ibinderForJavaObject ：(frameworks/base/core/jni/android_util_Binder.cpp)

  ```cpp
  sp<IBinder> ibinderForJavaObject(JNIEnv* env, jobject obj)
  {
      if (obj == NULL) return NULL;
  
      // Instance of Binder?
      if (env->IsInstanceOf(obj, gBinderOffsets.mClass)) {
          JavaBBinderHolder* jbh = (JavaBBinderHolder*)
              env->GetLongField(obj, gBinderOffsets.mObject);
          return jbh->get(env, obj);
      }
  
      // Instance of BinderProxy?
      if (env->IsInstanceOf(obj, gBinderProxyOffsets.mClass)) {
          return getBPNativeData(env, obj)->mObject;
      }
  
      ALOGW("ibinderForJavaObject: %p is not a Binder object", obj);
      return NULL;
  }
  ```

  

