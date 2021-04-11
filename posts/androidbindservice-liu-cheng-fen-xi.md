---
title: '[Android]bindService流程分析'
date: 2021-04-10 20:23:53
tags: []
published: true
hideInList: false
feature: 
isTop: false
---



本文分析bindService的流程，首先我们通过阅读源码获取一个主线的调用地图，然后提出若干问题，包括：APP进程中如何获取AMS，AMS如何启动APP-service的进程，AMS中如何获取ApplicationThread并与之通讯，Service的启动及绑定流程；然后再通过源码一一解答。最后再整体总结梳理一下整体流程；

<!-- more -->



**预先知识：**

* Binder通信机制

## 整体分析与总结

### 主线地图与问题提出

我们从bindService一路跟踪，初步绘制了如下的调用序列图，我们可以以下面的图作为一个主线地图，避免走失，然后根据具体问题进行细节分析。

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


从上图中，我们提出如下问题：

1. bindServiceCommon到IActivityManager的调用中，是如何获取到ActivityManagerService的？
2. AMS中如何获取ApplicationThread并与之通讯？
   * ApplicatoinThread的用途？ApplicationThread运行的进程是哪个？
3. 进程如何启动-即AMS如何创建APP:server进程？
4. Service如何启动？
5. Service如何绑定？
   * ServiceConnection 的回调方法何时使用？

### 问题解答汇总

我们将相关问题的结论提前到此小节，便于后续从比较抽象的层次上来进行复习及预览；

#### APP进程如何获取AMS？

* APP进程中通过 `ServiceManager.getService(Context.ACTIVITY_SERVICE)` 获取的ActivityManagerService的客户端操作代理对象（Proxy）。

  > 该对象位于APP进程中，可以使用此对象（通过Binder进程间通信）来要求（位于system_process中）的ActivityManagerService进行对应的服务操作； 

#### AMS如何获取ApplicationThread？

* APP进程在binderSerice时，将自己进程中的ApplicationThread取出，通过Binde机制传递给AMS进程；

  ```java
  ActivityManager.getService().bindIsolatedService(
              mMainThread.getApplicationThread(), getActivityToken(), service,
              service.resolveTypeIfNeeded(getContentResolver()),
              sd, flags, instanceName, getOpPackageName(), user.getIdentifier());
  ```

#### 服务如何绑定？服务如何启动？进程如何启动？

* 进程启动：
  * 在系统进程中，通过AMS的`startProcessLocked`方法启动进程，
* 服务启动：
  * 
* 服务绑定：
  * 

### 整体流程总结

## 详细分析解答问题

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

### AMS如何获取到 ApplicatoinThread？

首先，AMS实际上位于系统进程（system_process)，而ApplicationThread则位于我们的APP进程，那么为什么需要这个跨进程的操作呢？

* Service的创建需要经过系统的管理，比方说鉴权及其他管理需要；
* 而开发者定义的Service的实例的创建逻辑也还是需要开发者来实现，Service对应的类也应该只加载在开发者自己的进程之中，Service使用方实际上还是开发者自己，所以服务的真实实例的创建过程要在应用的进程中；

那么，系统进程（中的AMS）如何获取ApplicationThread呢？

#### ApplicationThread的来源？

查看 **ContextImpl.bindServiceCommon** 的代码，可以看到，是在调用AMS的bindService方法时，将自己进程中的ApplicationThread及ActivityToken取出传递给了AMS服务；

```java
// frameworks/base/core/java/android/app/ContextImpl.java
final @NonNull ActivityThread mMainThread;
private final @Nullable IBinder mToken;

public IBinder getActivityToken() {
    return mToken;
}

private boolean bindServiceCommon(Intent service, ServiceConnection conn, int flags,
            String instanceName, Handler handler, Executor executor, UserHandle user) {
        // Keep this in sync with DevicePolicyManager.bindDeviceAdminServiceAsUser.
        IServiceConnection sd;
        try {
            service.prepareToLeaveProcess(this);
            // 调用时传递了ApplicationThread和IBinder
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

> 这里我们暂不考虑ApplicationThread由何处而来，每个进程中都对应一个ActivityThread，ActivityThread中有一个ApplicationThread对象。

#### ApplicationThread在bind流程中的使用

我们发现，最终是使用 `ApplicationThread`的 `requestServiceBindingLocked` 方法来绑定服务的。不过这里使用的时候是经过了几次成员变量操作符（`r.app.thread.scheduleBindService`），我们先梳理一下ServiceRecord类同ApplicationThread的关系；

```java
// frameworks/base/services/core/java/com/android/server/am/ActiveServices.java
// com.android.server.am.ActiveServices#requestServiceBindingLocked
private final boolean requestServiceBindingLocked(ServiceRecord r, IntentBindRecord i,
            boolean execInFg, boolean rebind) throws TransactionTooLargeException {
        if (r.app == null || r.app.thread == null) {
            // If service is not currently running, can't yet bind.
            return false;
        }
	    // 调用ApplicationThread的绑定方法来进行绑定
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

其中 `ServiceRecord.app` 的类型为 `ProcessRecord` ，`ServiceRecord.app.thread` 的类型为 `IApplicationThread`，我们梳理下对应的几个类的关系，如下图：


<svg width="730px" height="473px" viewBox="0 0 730 473" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <g id="Android源码分析" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
        <g id="ServiceRecord类图" transform="translate(-38.000000, -20.000000)">
            <g id="类" transform="translate(41.000000, 22.000000)">
                <g id="编组" transform="translate(0.663121, -1.869103)">
                    <path d="M182.673759,0.5 C183.364115,0.5 183.989115,0.779822031 184.441526,1.23223305 C184.893937,1.68464406 185.173759,2.30964406 185.173759,3 L185.173759,3 L185.173759,27.8255814 L0.5,27.8255814 L0.5,3 C0.5,2.30964406 0.779822031,1.68464406 1.23223305,1.23223305 C1.68464406,0.779822031 2.30964406,0.5 3,0.5 L3,0.5 Z" id="矩形" stroke="#979797" fill="#F2F2F2"></path>
                    <text id="类名" font-family="NotoSansCJKsc-Black, Noto Sans CJK SC" font-size="14" font-weight="800" letter-spacing="0.154000005" fill="#020202" fill-opacity="0.88378138">
                        <tspan x="41.574" y="16.3255814">ServiceRecord</tspan>
                    </text>
                </g>
                <g id="属性" transform="translate(0.663121, 22.288571)">
                    <rect id="矩形" stroke="#979797" fill="#E0E0E0" x="0.5" y="0.5" width="184.756391" height="46.2285714"></rect>
                    <text font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="12" font-weight="300" letter-spacing="0.132000005" fill="#020202" fill-opacity="0.88378138">
                        <tspan x="9.36631979" y="14.7457143">app:ProcessRecord </tspan>
                        <tspan x="9.36631979" y="32.7457143">isolatedProc: ProcessRecord </tspan>
                    </text>
                </g>
                <g id="方法" transform="translate(0.663121, 67.942857)">
                    <path d="M185.256391,0.5 L185.256391,43.2285714 C185.256391,44.1950697 184.86464,45.0700697 184.231264,45.7034452 C183.597889,46.3368206 182.722889,46.7285714 181.756391,46.7285714 L181.756391,46.7285714 L4,46.7285714 C3.03350169,46.7285714 2.15850169,46.3368206 1.52512627,45.7034452 C0.891750844,45.0700697 0.5,44.1950697 0.5,43.2285714 L0.5,43.2285714 L0.5,0.5 L185.256391,0.5 Z" id="矩形备份" stroke="#979797" fill="#E0E0E0"></path>
                    <text font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="12" font-weight="300" letter-spacing="0.132000005" fill="#020202" fill-opacity="0.88378138">
                        <tspan x="9.36631979" y="15.74">+ setProcess(ProcessRecord) </tspan>
                    </text>
                </g>
            </g>
            <g id="类备份" transform="translate(41.000000, 193.000000)">
                <g id="编组" transform="translate(0.663121, -1.869103)">
                    <path d="M182.673759,0.5 C183.364115,0.5 183.989115,0.779822031 184.441526,1.23223305 C184.893937,1.68464406 185.173759,2.30964406 185.173759,3 L185.173759,3 L185.173759,27.8255814 L0.5,27.8255814 L0.5,3 C0.5,2.30964406 0.779822031,1.68464406 1.23223305,1.23223305 C1.68464406,0.779822031 2.30964406,0.5 3,0.5 L3,0.5 Z" id="矩形" stroke="#979797" fill="#F2F2F2"></path>
                    <text id="类名" font-family="NotoSansCJKsc-Black, Noto Sans CJK SC" font-size="14" font-weight="800" letter-spacing="0.154000005" fill="#020202" fill-opacity="0.88378138">
                        <tspan x="40.426" y="16.3255814">ProcessRecord</tspan>
                    </text>
                </g>
                <g id="属性" transform="translate(0.663121, 22.288571)">
                    <rect id="矩形" stroke="#979797" fill="#E0E0E0" x="0.5" y="0.5" width="184.756391" height="46.2285714"></rect>
                    <text font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="12" font-weight="300" letter-spacing="0.132000005" fill="#020202" fill-opacity="0.88378138">
                        <tspan x="9.36631979" y="14.7457143">thread:IApplicationThread </tspan>
                        <tspan x="9.36631979" y="32.7457143">pid: int  </tspan>
                    </text>
                </g>
                <g id="方法" transform="translate(0.663121, 67.942857)">
                    <path d="M185.256391,0.5 L185.256391,43.2285714 C185.256391,44.1950697 184.86464,45.0700697 184.231264,45.7034452 C183.597889,46.3368206 182.722889,46.7285714 181.756391,46.7285714 L181.756391,46.7285714 L4,46.7285714 C3.03350169,46.7285714 2.15850169,46.3368206 1.52512627,45.7034452 C0.891750844,45.0700697 0.5,44.1950697 0.5,43.2285714 L0.5,43.2285714 L0.5,0.5 L185.256391,0.5 Z" id="矩形备份" stroke="#979797" fill="#E0E0E0"></path>
                    <text font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="12" font-weight="300" letter-spacing="0.132000005"></text>
                </g>
            </g>
            <g id="类备份-2" transform="translate(326.000000, 84.000000)">
                <g id="编组" transform="translate(1.570922, 0.886379)">
                    <path d="M436.858156,0.5 C437.548512,0.5 438.173512,0.779822031 438.625923,1.23223305 C439.078334,1.68464406 439.358156,2.30964406 439.358156,3 L439.358156,3 L439.358156,27.8255814 L0.5,27.8255814 L0.5,3 C0.5,2.30964406 0.779822031,1.68464406 1.23223305,1.23223305 C1.68464406,0.779822031 2.30964406,0.5 3,0.5 L3,0.5 Z" id="矩形" stroke="#979797" fill="#F2F2F2"></path>
                    <text id="类名" font-family="NotoSansCJKsc-Black, Noto Sans CJK SC" font-size="14" font-weight="800" letter-spacing="0.154000005" fill="#020202" fill-opacity="0.88378138">
                        <tspan x="152.123" y="16.3255814">IApplicationThread</tspan>
                    </text>
                </g>
                <g id="属性" transform="translate(1.570922, 27.284286)">
                    <rect id="矩形" stroke="#979797" fill="#E0E0E0" x="0.5" y="0.5" width="439.05391" height="56.8142857"></rect>
                    <text font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="12" font-weight="300" letter-spacing="0.132000005" fill="#020202" fill-opacity="0.88378138">
                        <tspan x="22.1886613" y="14.9128571">thread:IApplicationThread </tspan>
                        <tspan x="22.1886613" y="32.9128571">pid: int  </tspan>
                    </text>
                </g>
                <g id="方法" transform="translate(1.570922, 83.171429)">
                    <path d="M439.55391,0.5 L439.55391,53.8142857 C439.55391,54.780784 439.162159,55.655784 438.528783,56.2891594 C437.895408,56.9225349 437.020408,57.3142857 436.05391,57.3142857 L436.05391,57.3142857 L4,57.3142857 C3.03350169,57.3142857 2.15850169,56.9225349 1.52512627,56.2891594 C0.891750844,55.655784 0.5,54.780784 0.5,53.8142857 L0.5,53.8142857 L0.5,0.5 L439.55391,0.5 Z" id="矩形备份" stroke="#979797" fill="#E0E0E0"></path>
                    <text font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="12" font-weight="300" letter-spacing="0.132000005" fill="#020202" fill-opacity="0.88378138">
                        <tspan x="22.1886613" y="16.13">+ scheduleBindService(IBinder, Intent, boolean rebind, int processState)</tspan>
                        <tspan x="22.1886613" y="34.13">+ scheduleCreateService(IBinder, ServiceInfo info,… )</tspan>
                        <tspan x="22.1886613" y="52.13">+ bindApplication(…)</tspan>
                    </text>
                </g>
            </g>
            <g id="IApplicationThread.Stub" transform="translate(326.000000, 402.000000)">
                <g id="编组" transform="translate(0.946809, -4.518605)">
                    <path d="M262.106383,0.5 C262.796739,0.5 263.421739,0.779822031 263.87415,1.23223305 C264.326561,1.68464406 264.606383,2.30964406 264.606383,3 L264.606383,3 L264.606383,27.8255814 L0.5,27.8255814 L0.5,3 C0.5,2.30964406 0.779822031,1.68464406 1.23223305,1.23223305 C1.68464406,0.779822031 2.30964406,0.5 3,0.5 L3,0.5 Z" id="矩形" stroke="#979797" fill="#F2F2F2"></path>
                    <text id="类名" font-family="NotoSansCJKsc-Black, Noto Sans CJK SC" font-size="14" font-weight="800" letter-spacing="0.154000005" fill="#020202" fill-opacity="0.88378138">
                        <tspan x="66.65" y="16.3255814">ApplicationThread</tspan>
                    </text>
                </g>
                <g id="属性" transform="translate(0.946809, 17.485000)">
                    <rect id="矩形" stroke="#979797" fill="#E0E0E0" x="0.5" y="0.5" width="264.224365" height="36.05"></rect>
                    <text font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="12" font-weight="300" letter-spacing="0.132000005"></text>
                </g>
                <g id="方法" transform="translate(0.946809, 53.300000)">
                    <path d="M264.724365,0.5 L264.724365,33.05 C264.724365,34.0164983 264.332615,34.8914983 263.699239,35.5248737 C263.065864,36.1582492 262.190864,36.55 261.224365,36.55 L261.224365,36.55 L4,36.55 C3.03350169,36.55 2.15850169,36.1582492 1.52512627,35.5248737 C0.891750844,34.8914983 0.5,34.0164983 0.5,33.05 L0.5,33.05 L0.5,0.5 L264.724365,0.5 Z" id="矩形备份" stroke="#979797" fill="#E0E0E0"></path>
                    <text font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="12" font-weight="300" letter-spacing="0.132000005"></text>
                </g>
            </g>
            <g id="IApplicationThread.Stub备份-2" transform="translate(38.000000, 375.000000)">
                <g id="编组" transform="translate(0.673759, -4.518605)">
                    <path d="M185.652482,0.5 C186.342838,0.5 186.967838,0.779822031 187.420249,1.23223305 C187.87266,1.68464406 188.152482,2.30964406 188.152482,3 L188.152482,3 L188.152482,27.8255814 L0.5,27.8255814 L0.5,3 C0.5,2.30964406 0.779822031,1.68464406 1.23223305,1.23223305 C1.68464406,0.779822031 2.30964406,0.5 3,0.5 L3,0.5 Z" id="矩形" stroke="#979797" fill="#F2F2F2"></path>
                    <text id="类名" font-family="NotoSansCJKsc-Black, Noto Sans CJK SC" font-size="14" font-weight="800" letter-spacing="0.154000005" fill="#020202" fill-opacity="0.88378138">
                        <tspan x="41.408" y="16.3255814">ActivityThread</tspan>
                    </text>
                </g>
                <g id="属性" transform="translate(0.673759, 17.485000)">
                    <rect id="矩形" stroke="#979797" fill="#E0E0E0" x="0.5" y="0.5" width="187.73644" height="36.05"></rect>
                    <text font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="12" font-weight="300" letter-spacing="0.132000005" fill="#020202" fill-opacity="0.88378138">
                        <tspan x="9.5165816" y="14.585">mAppThread:ApplicationThread </tspan>
                    </text>
                </g>
                <g id="方法" transform="translate(0.673759, 53.300000)">
                    <path d="M188.23644,0.5 L188.23644,33.05 C188.23644,34.0164983 187.844689,34.8914983 187.211313,35.5248737 C186.577938,36.1582492 185.702938,36.55 184.73644,36.55 L184.73644,36.55 L4,36.55 C3.03350169,36.55 2.15850169,36.1582492 1.52512627,35.5248737 C0.891750844,34.8914983 0.5,34.0164983 0.5,33.05 L0.5,33.05 L0.5,0.5 L188.23644,0.5 Z" id="矩形备份" stroke="#979797" fill="#E0E0E0"></path>
                    <text font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="12" font-weight="300" letter-spacing="0.132000005"></text>
                </g>
            </g>
            <g id="IApplicationThread.Stub备份" transform="translate(326.000000, 268.000000)">
                <g id="编组" transform="translate(0.946809, -4.094684)">
                    <path d="M262.106383,0.5 C262.796739,0.5 263.421739,0.779822031 263.87415,1.23223305 C264.326561,1.68464406 264.606383,2.30964406 264.606383,3 L264.606383,3 L264.606383,27.8255814 L0.5,27.8255814 L0.5,3 C0.5,2.30964406 0.779822031,1.68464406 1.23223305,1.23223305 C1.68464406,0.779822031 2.30964406,0.5 3,0.5 L3,0.5 Z" id="矩形" stroke="#979797" fill="#F2F2F2"></path>
                    <text id="类名" font-family="NotoSansCJKsc-Black, Noto Sans CJK SC" font-size="14" font-weight="800" letter-spacing="0.154000005" fill="#020202" fill-opacity="0.88378138">
                        <tspan x="44.7399999" y="16.3255814">IApplicationThread.Stub</tspan>
                    </text>
                </g>
                <g id="属性" transform="translate(0.946809, 18.253571)">
                    <rect id="矩形" stroke="#979797" fill="#E0E0E0" x="0.5" y="0.5" width="264.224365" height="37.6785714"></rect>
                    <text font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="12" font-weight="300" letter-spacing="0.132000005"></text>
                </g>
                <g id="方法" transform="translate(0.946809, 55.642857)">
                    <path d="M264.724365,0.5 L264.724365,34.6785714 C264.724365,35.6450697 264.332615,36.5200697 263.699239,37.1534452 C263.065864,37.7868206 262.190864,38.1785714 261.224365,38.1785714 L261.224365,38.1785714 L4,38.1785714 C3.03350169,38.1785714 2.15850169,37.7868206 1.52512627,37.1534452 C0.891750844,36.5200697 0.5,35.6450697 0.5,34.6785714 L0.5,34.6785714 L0.5,0.5 L264.724365,0.5 Z" id="矩形备份" stroke="#979797" fill="#E0E0E0"></path>
                    <text font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="12" font-weight="300" letter-spacing="0.132000005"></text>
                </g>
            </g>
            <g id="UML/线条/实现" transform="translate(455.000000, 225.500000)" stroke="#979797">
                <line x1="2.5" y1="38.8055556" x2="2.5" y2="7.30555556" id="直线-24" stroke-linecap="square" stroke-dasharray="2"></line>
                <path d="M2.5,-0.931966011 L5.69098301,5.45 L-0.690983006,5.45 L2.5,-0.931966011 Z" id="三角形"></path>
            </g>
            <g id="UML/线条/实现" transform="translate(455.000000, 363.000000)" stroke="#979797">
                <line x1="4.5" y1="34.8333333" x2="4.5" y2="8" id="直线-24" stroke-linecap="square"></line>
                <path d="M4.5,1.11803399 L7.69098301,7.5 L1.30901699,7.5 L4.5,1.11803399 Z" id="三角形"></path>
            </g>
            <g id="UML/线条/聚合" transform="translate(128.000000, 138.000000)">
                <path id="直线-24" d="M6.50883555,9.81274647 L7.5086821,9.83026412 L7.49992328,10.3301874 L6.85324563,47.2403042 L6.746,53.315 L10.4214873,47.041539 L10.6742143,46.6101122 L11.5370678,47.1155662 L11.2843409,47.546993 L6.64489019,55.466936 L6.19559777,56.2339169 L5.77344839,55.451668 L1.41428008,47.3740662 L1.17682105,46.9340512 L2.05685107,46.4591331 L2.2943101,46.8991481 L5.747,53.297 L5.85339907,47.2227865 L6.50007672,10.3126697 L6.50883555,9.81274647 Z" fill="#979797" fill-rule="nonzero"></path>
                <path d="M7.04493542,0.824414956 L10.6703645,5.5 L7.04493542,10.175585 L3.53698783,5.5 L7.04493542,0.824414956 Z" id="多边形" stroke="#979797"></path>
            </g>
            <g id="编组" transform="translate(272.810486, 148.720337)" fill="#979797">
                <g id="UML/线条/组合" transform="translate(4.500000, 49.000000) rotate(-90.000000) translate(-4.500000, -49.000000) ">
                    <path id="直线-24" d="M4.00288801,10.1257 L5.00287142,10.1314594 L4.99999171,10.6314511 L4.54315542,89.9498322 L4.507,96.035 L8.10875237,89.7196752 L8.35638881,89.2853065 L9.22512627,89.7805794 L8.97748982,90.2149481 L4.43148901,98.188898 L3.99124645,98.9611091 L3.55992793,98.1838782 L-0.893921989,90.1580935 L-1.13653865,89.7209011 L-0.262153947,89.2356678 L-0.0195372819,89.6728601 L3.507,96.027 L3.54317201,89.9440727 L4.00000829,10.6256917 L4.00288801,10.1257 Z" fill-rule="nonzero"></path>
                    <polygon id="多边形" stroke="#979797" points="4.5 0 8.76467693 5.5 4.5 11 0.373519229 5.5"></polygon>
                </g>
            </g>
            <g id="编组" transform="translate(272.810486, 366.720337)" fill="#979797">
                <g id="UML/线条/组合" transform="translate(4.500000, 49.000000) rotate(-90.000000) translate(-4.500000, -49.000000) ">
                    <path id="直线-24" d="M4.00288801,10.1257 L5.00287142,10.1314594 L4.99999171,10.6314511 L4.54315542,89.9498322 L4.507,96.035 L8.10875237,89.7196752 L8.35638881,89.2853065 L9.22512627,89.7805794 L8.97748982,90.2149481 L4.43148901,98.188898 L3.99124645,98.9611091 L3.55992793,98.1838782 L-0.893921989,90.1580935 L-1.13653865,89.7209011 L-0.262153947,89.2356678 L-0.0195372819,89.6728601 L3.507,96.027 L3.54317201,89.9440727 L4.00000829,10.6256917 L4.00288801,10.1257 Z" fill-rule="nonzero"></path>
                    <polygon id="多边形" stroke="#979797" points="4.5 0 8.76467693 5.5 4.5 11 0.373519229 5.5"></polygon>
                </g>
            </g>
        </g>
    </g>
</svg>

现在我们看下 ServiceRecord 是何时构造的，首先，根据方法的调用层次，我们可以看到：

* `ActiveServices.bindServiceLocked` 方法中，参数中没有ServiceRecord，有的是IApplicationThread及一个IBinder。
* `ActiveServices.requestServiceBindingLocked` 方法中，则变成了ServiceRecord类型。

![image-20210410215833909](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210410215833.png)

> 提示：上述调用层次可以在IDEA中选中`ActiveServices.requestServiceBindingLocked`方法，然后通过“**Navigate｜Call Hierarchy**”（快捷键为==ctrl+opt+H==）弹出。



所以，接下来我们看下 `ActiveServices.bindServiceLocked` 方法如何将`ApplicationThread`存入到`ServiceRecord`对象中。

##### ActiveServices.bindServiceLocked

```java
    int bindServiceLocked(IApplicationThread caller, IBinder token, Intent service,
            String resolvedType, final IServiceConnection connection, int flags,
            String instanceName, String callingPackage, final int userId)
            throws TransactionTooLargeException {
        final int callingPid = Binder.getCallingPid();
        final int callingUid = Binder.getCallingUid();
        // 这里获取了 ProcessRecord
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

##### `ServiceRecord.app` 的赋值

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

查看 `realStartServiceLocked` 的调用序列：

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210410224824.png" alt="image-20210410224824691" style="zoom:50%;" />

也就是又回到了我们的 `bindServiceLocked` 方法，其中有一段逻辑是，如果需要创建服务，就执行 `bringUpServiceLocked` 方法。

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

也就是说，在绑定服务的时候，如果服务没有创建，就先使用`bringUpServiceLocked`-`realStartServiceLocked` 进行创建，创建过程中会将ServiceRecord中的app赋值，然后存储起来；

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

### 服务如何绑定？服务如何启动？进程如何启动？

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



**总结：** 

1. 进程记录如何获取？

   * 通过AMS的 `startProcessLocked` 方法创建（非独立进程的也应该是通过此方法创建，只是创建时机不是这里）

2. 服务如何启动？

   * 通过 `realStartServiceLocked` 方法启动（独立进程的应该也是此方法启动，会等到进程启动之后再启动）

   * > `realStartServiceLocked` 中通过 `IApplicationThread` 执行 `scheduleCreateService` 来启动服务，最终调用 `android.app.ActivityThread.ApplicationThread#scheduleCreateService`来启动；

### 进程创建

> 问题：
>
> 1. 进程何时创建？- 已解决
> 2. ApplicationThread对象何时设置到ProcessRecord中? - 已解决
> 3. ActivityThread#main的入口点中，如何获取之前的结果？ - 已解决

下面为创建进程的调用序列，注意如下序列中只是创建了一个ProcessRecord的对象，对应于Linux上的进程创建我们再起文章进行分析，对于我们的Service来说，拿到ProcessRecord对象即可供我们来创建服务；


<svg width="526px" height="575px" viewBox="0 0 526 575" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <g id="Android源码分析" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
        <g id="bindService流程分析-加入启动流程" transform="translate(-736.000000, -169.000000)">
            <g id="架构图/模块-源码备份-25" transform="translate(737.000000, 235.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="10.5542114" y="11">ActivityManagerService#startProcessLocked</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="33.7957176" y="23.3877551">com/android/server/am/ActivityManagerService.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-37" transform="translate(990.000000, 235.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="10.5542114" y="11">ActivityManagerService#startProcessLocked</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="28.3999017" y="23.3877551">startProcessLocked(hostingRecord, entryPoint) 带入口点</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-38" transform="translate(973.000000, 278.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="133.629108" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="8.68091383" y="11">ProcessList#startProcess</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="11.0735497" y="23.3877551">带入口类 android.app.ActivityThread</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-49" transform="translate(1120.000000, 278.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="140.661972" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="2.2157558" y="11">handleProcessStartedLocked</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="22.5230361" y="23.3877551">记录ProcessRecord（通过PID）</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-39" transform="translate(990.000000, 321.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="17.0024123" y="11">android.os.ZygoteProcess#startViaZygote</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="58.7965544" y="23.3877551">带入口类 android.app.ActivityThread</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-40" transform="translate(990.000000, 364.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="8.41262146" y="11">ZygoteProcess#zygoteSendArgsAndGetResult</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="58.7965544" y="23.3877551">带入口类 android.app.ActivityThread</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-41" transform="translate(990.000000, 412.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFED99" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="99.5684373" y="11">zygote</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="84.7078515" y="23.3877551">zygote创建新的进程</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-42" transform="translate(990.000000, 455.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFBBA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="62.0929562" y="11">ActivityThread#main()</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="77.8124541" y="23.3877551">进程创建后执行入口函数</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-44" transform="translate(990.000000, 497.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFBBA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="62.7115336" y="11">ActivityThread#attach</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="103.107852" y="23.3877551">module</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-26" transform="translate(737.000000, 281.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="35.9721194" y="11">ProcessList#startProcessLocked()</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="52.1187301" y="23.3877551">com/android/server/am/ProcessList.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-11" transform="translate(736.000000, 323.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="24.3831654" y="11">ProcessList#newProcessRecordLocked</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="52.1187301" y="23.3877551">com/android/server/am/ProcessList.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-27" transform="translate(736.000000, 362.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="24.3831654" y="11">ProcessList#newProcessRecordLocked</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="53.5814917" y="23.3877551">new ProcessRecord(ams, info, proc, uid)</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-9" transform="translate(736.000000, 197.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="24.9173913" y="11">ActiveServices#bringUpServiceLocked</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="47.5865126" y="23.3877551">com/android/server/am/ActiveServices.java</tspan>
                </text>
            </g>
            <path id="直线-7备份" d="M851.834728,222.007377 L851.834,228.046 L855.17364,228.046784 L851.5,235.046784 L847.82636,228.046784 L851.165,228.046 L851.165272,222.007377 L851.834728,222.007377 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-8备份" d="M851.834728,259.998605 L851.834,273.055 L855.17364,273.055556 L851.5,280.055556 L847.82636,273.055556 L851.165,273.055 L851.165272,259.998605 L851.834728,259.998605 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-9备份" d="M851.834728,305.998605 L851.834,317.055 L855.17364,317.055556 L851.5,324.055556 L847.82636,317.055556 L851.165,317.055 L851.165272,305.998605 L851.834728,305.998605 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-10备份" d="M851.834728,349.007377 L851.834,355.046 L855.17364,355.046784 L851.5,362.046784 L847.82636,355.046784 L851.165,355.046 L851.165272,349.007377 L851.834728,349.007377 Z" fill="#979797" fill-rule="nonzero"></path>
            <text id="创建进程" font-family="NotoSansCJKsc-Black, Noto Sans CJK SC" font-size="14" font-weight="800" letter-spacing="0.154000005" fill="#020202" fill-opacity="0.88378138">
                <tspan x="966.692" y="181">创建进程</tspan>
            </text>
            <line x1="966.5" y1="248.5" x2="990.5" y2="248.5" id="直线-23" stroke="#979797" stroke-linecap="square"></line>
            <path id="直线-13" d="M1067,260 L1067,270 L1071,270 L1066.5,279 L1062,270 L1066,270 L1066,260 L1067,260 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-14" d="M1081,303 L1081,312 L1085,312 L1080.5,321 L1076,312 L1080,312 L1080,303 L1081,303 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-14备份" d="M1184,260 L1184,269 L1188,269 L1183.5,278 L1179,269 L1183,269 L1183,260 L1184,260 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-15" d="M1105,347 L1105,356 L1109,356 L1104.5,365 L1100,356 L1104,356 L1104,347 L1105,347 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-24" d="M1105,390 L1105,404 L1109,404 L1104.5,413 L1100,404 L1104,404 L1104,390 L1105,390 Z" fill="#979797" fill-rule="nonzero"></path>
            <text id="socket" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="8" font-weight="300" letter-spacing="0.088000003" fill="#020202" fill-opacity="0.88378138">
                <tspan x="1107.516" y="401">socket</tspan>
            </text>
            <path id="直线-25" d="M1105,438 L1105,447 L1109,447 L1104.5,456 L1100,447 L1104,447 L1104,438 L1105,438 Z" fill="#979797" fill-rule="nonzero"></path>
            <line x1="1235.5" y1="301.5" x2="1235.5" y2="674.5" id="直线-26" stroke="#979797" stroke-linecap="square" stroke-dasharray="3"></line>
            <g id="架构图/模块-源码备份-45" transform="translate(990.000000, 542.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFBBA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="30.362747" y="11">IActivityManager#attachApplication</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="103.107852" y="23.3877551">module</tspan>
                </text>
            </g>
            <path id="直线-27" d="M1105,480 L1105,489 L1109,489 L1104.5,498 L1100,489 L1104,489 L1104,480 L1105,480 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-28" d="M1105,523 L1105,534 L1109,534 L1104.5,543 L1100,534 L1104,534 L1104,523 L1105,523 Z" fill="#979797" fill-rule="nonzero"></path>
            <g id="架构图/模块-源码备份-46" transform="translate(990.000000, 629.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="14.6686884" y="11">ActivityManagerService#attachApplication</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="103.107852" y="23.3877551">module</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-47" transform="translate(963.000000, 675.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="283.328638" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="25.0095075" y="11">ActivityManagerService#attachApplicationLocked</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="87.6170389" y="23.3877551">获取之前缓存的ProcessRecord(app)</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-50" transform="translate(963.000000, 718.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="283.328638" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="77.3964531" y="11">ProcessRecord#makeActive</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="52.1793819" y="23.3877551">app.makeActive(thread, mProcessStats) ; thread = _thread;</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-36" transform="translate(990.000000, 583.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFED99" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="95.5148809" y="11">transact</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="104.925425" y="23.3877551">binder</tspan>
                </text>
            </g>
            <path id="直线-29" d="M1105,567 L1105,575 L1109,575 L1104.5,584 L1100,575 L1104,575 L1104,567 L1105,567 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-30" d="M1105,609 L1105,621 L1109,621 L1104.5,630 L1100,621 L1104,621 L1104,609 L1105,609 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-31" d="M1105,655 L1105,667 L1109,667 L1104.5,676 L1100,667 L1104,667 L1104,655 L1105,655 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-32" d="M1105,701 L1105,710 L1109,710 L1104.5,719 L1100,710 L1104,710 L1104,701 L1105,701 Z" fill="#979797" fill-rule="nonzero"></path>
        </g>
    </g>
</svg>


* 进程创建的执行位于AMS所在的系统进程之中；
* （AMS进程）首先，构建一个ProcessRecord记录，并将其记录到AMS中；
* （AMS进程）AMS通过socket通信，通知zygote来创建一个新的进程，同时指定入口点为 `android.app.ActivityThread` ;
* （APP进程）新的进程启动后，执行ActivityThread中的方法，执行通知AMS来attachApplication；
* （AMS进程）AMS中，通过PID获取之前存储的ProcessRecord，然后将ApplicationThread赋值给ProcessRecord的成员变量thread；
* 支持完成了关联；

#### 构造ProcessRecord实例

`com.android.server.am.ProcessList#startProcessLocked`，简化下来就两句：

* 构造ProcessRecord对象： `app = newProcessRecordLocked(info, processName, isolated, isolatedUid, hostingRecord)`
* 启动进程：`startProcessLocked(app, hostingRecord, zygotePolicyFlags, abiOverride)`

```java
// com.android.server.am.ProcessList#newProcessRecordLocked
// frameworks/base/services/core/java/com/android/server/am/ProcessList.java
final ProcessRecord startProcessLocked(String processName, ApplicationInfo info,
            boolean knownToBeDead, int intentFlags, HostingRecord hostingRecord,
            int zygotePolicyFlags, boolean allowWhileBooting, boolean isolated, int isolatedUid,
            boolean keepIfLarge, String abiOverride, String entryPoint, String[] entryPointArgs,
            Runnable crashHandler) {
        long startTime = SystemClock.uptimeMillis();
        ProcessRecord app;
        if (app == null) {
            // 构造ProcessRecord对象
            app = newProcessRecordLocked(info, processName, isolated, isolatedUid, hostingRecord);
            app.crashHandler = crashHandler;
            app.isolatedEntryPoint = entryPoint;
            app.isolatedEntryPointArgs = entryPointArgs;
        } else {
            // If this is a new package in the process, add the package to the list
            app.addPackage(info.packageName, info.longVersionCode, mService.mProcessStats);
        }
	    // 启动进程
        final boolean success =
                startProcessLocked(app, hostingRecord, zygotePolicyFlags, abiOverride);
        checkSlow(startTime, "startProcess: done starting proc!");
        return success ? app : null;
    }
```

#### 启动进程 

`startProcessLocked`: 启动了一个进程，并指定了入口点为 ==android.app.ActivityThread==，也就是进程启动后将会执行 ==android.app.ActivityThread==的main方法。

```java
// frameworks/base/services/core/java/com/android/server/am/ProcessList.java
// com.android.server.am.ProcessList#startProcessLocked(com.android.server.am.ProcessRecord, com.android.server.am.HostingRecord, int, boolean, boolean, boolean, java.lang.String)
boolean startProcessLocked(ProcessRecord app, HostingRecord hostingRecord,
            int zygotePolicyFlags, boolean disableHiddenApiChecks, boolean disableTestApiChecks,
            boolean mountExtStorageFull, String abiOverride) {
        if (app.pendingStart) {
            return true;
        }
        long startTime = SystemClock.uptimeMillis();
        try {
            try {
                final int userId = UserHandle.getUserId(app.uid);
                AppGlobals.getPackageManager().checkPackageStartable(app.info.packageName, userId);
            } catch (RemoteException e) {
                throw e.rethrowAsRuntimeException();
            }

            int uid = app.uid;
            int[] gids = null;
            // ... 
            
            app.mountMode = mountExternal;
            app.gids = gids;
            app.setRequiredAbi(requiredAbi);
            app.instructionSet = instructionSet;

            final String seInfo = app.info.seInfo
                    + (TextUtils.isEmpty(app.info.seInfoUser) ? "" : app.info.seInfoUser);
            // Start the process.  It will either succeed and return a result containing
            // the PID of the new process, or else throw a RuntimeException.
            // 指定入口点为ActivityThread，启动进程
            final String entryPoint = "android.app.ActivityThread";
            return startProcessLocked(hostingRecord, entryPoint, app, uid, gids,
                    runtimeFlags, zygotePolicyFlags, mountExternal, seInfo, requiredAbi,
                    instructionSet, invokeWith, startTime);
        } catch (RuntimeException e) {
            return false;
        }
    }


boolean startProcessLocked(HostingRecord hostingRecord, String entryPoint, ProcessRecord app,
            int uid, int[] gids, int runtimeFlags, int zygotePolicyFlags, int mountExternal,
            String seInfo, String requiredAbi, String instructionSet, String invokeWith,
            long startTime) {
        app.pendingStart = true;
        app.killedByAm = false;
        app.removed = false;
        app.killed = false;
        final long startSeq = app.startSeq = ++mProcStartSeqCounter;
        app.setStartParams(uid, hostingRecord, seInfo, startTime);
        app.setUsingWrapper(invokeWith != null
                || Zygote.getWrapProperty(app.processName) != null);
        mPendingStarts.put(startSeq, app);

        if (mService.mConstants.FLAG_PROCESS_START_ASYNC) {
            return true;
        } else {
            try {
                // 启动进程，并传入entrypoint
                final Process.ProcessStartResult startResult = startProcess(hostingRecord,
                        entryPoint, app,
                        uid, gids, runtimeFlags, zygotePolicyFlags, mountExternal, seInfo,
                        requiredAbi, instructionSet, invokeWith, startTime);
                // 做启动后的操作
                handleProcessStartedLocked(app, startResult.pid, startResult.usingWrapper,
                        startSeq, false);
            } catch (RuntimeException e) {
                
            }
            return app.pid > 0;
        }
    }
```

这里我们省略其他更加底层的步骤的分析，我们只需要知道到了这里之后，会启动一个进程，进程启动后会执行 ==android.app.ActivityThread#main== 方法；

#### 记录进程记录到AMS

`ProcessList#handleProcessStartedLocked(com.android.server.am.ProcessRecord, int, boolean, long, boolean)`

==这个地方有个关键的代码将之前创建的进程记录存储到了AMS的进程记录表中。==

```java
// com.android.server.am.ProcessList#handleProcessStartedLocked(com.android.server.am.ProcessRecord, int, boolean, long, boolean)
// frameworks/base/services/core/java/com/android/server/am/ProcessList.java
ActivityManagerService mService = null;
boolean handleProcessStartedLocked(ProcessRecord app, int pid, boolean usingWrapper,
            long expectedStartSeq, boolean procAttached) {
    // 将ProcessRecord 存储到AMS中
    mService.addPidLocked(app);
}
  
// frameworks/base/services/core/java/com/android/server/am/ActivityManagerService.java
void addPidLocked(ProcessRecord app) {
    synchronized (mPidsSelfLocked) {
        // 将进程记录添加到一个记录表中
        mPidsSelfLocked.doAddInternal(app);
    }
    synchronized (sActiveProcessInfoSelfLocked) {
        if (app.processInfo != null) {
            sActiveProcessInfoSelfLocked.put(app.pid, app.processInfo);
        } else {
            sActiveProcessInfoSelfLocked.remove(app.pid);
        }
    }
    mAtmInternal.onProcessMapped(app.pid, app.getWindowProcessController());
}
```
```java
// 完整代码
// com.android.server.am.ProcessList#handleProcessStartedLocked(com.android.server.am.ProcessRecord, int, boolean, long, boolean)
// frameworks/base/services/core/java/com/android/server/am/ProcessList.java
boolean handleProcessStartedLocked(ProcessRecord app, int pid, boolean usingWrapper,
            long expectedStartSeq, boolean procAttached) {
        mPendingStarts.remove(expectedStartSeq);
        final String reason = isProcStartValidLocked(app, expectedStartSeq);
        if (reason != null) {
            Slog.w(TAG_PROCESSES, app + " start not valid, killing pid=" +
                    pid
                    + ", " + reason);
            app.pendingStart = false;
            killProcessQuiet(pid);
            Process.killProcessGroup(app.uid, app.pid);
            noteAppKill(app, ApplicationExitInfo.REASON_OTHER,
                    ApplicationExitInfo.SUBREASON_INVALID_START, reason);
            return false;
        }
        mService.mBatteryStatsService.noteProcessStart(app.processName, app.info.uid);
        checkSlow(app.startTime, "startProcess: done updating battery stats");

        EventLog.writeEvent(EventLogTags.AM_PROC_START,
                UserHandle.getUserId(app.startUid), pid, app.startUid,
                app.processName, app.hostingRecord.getType(),
                app.hostingRecord.getName() != null ? app.hostingRecord.getName() : "");

        try {
            AppGlobals.getPackageManager().logAppProcessStartIfNeeded(app.processName, app.uid,
                    app.seInfo, app.info.sourceDir, pid);
        } catch (RemoteException ex) {
            // Ignore
        }

        Watchdog.getInstance().processStarted(app.processName, pid);

        checkSlow(app.startTime, "startProcess: building log message");
        StringBuilder buf = mStringBuilder;
        buf.setLength(0);
        buf.append("Start proc ");
        buf.append(pid);
        buf.append(':');
        buf.append(app.processName);
        buf.append('/');
        UserHandle.formatUid(buf, app.startUid);
        if (app.isolatedEntryPoint != null) {
            buf.append(" [");
            buf.append(app.isolatedEntryPoint);
            buf.append("]");
        }
        buf.append(" for ");
        buf.append(app.hostingRecord.getType());
        if (app.hostingRecord.getName() != null) {
            buf.append(" ");
            buf.append(app.hostingRecord.getName());
        }
        mService.reportUidInfoMessageLocked(TAG, buf.toString(), app.startUid);
        app.setPid(pid);
        app.setUsingWrapper(usingWrapper);
        app.pendingStart = false;
        checkSlow(app.startTime, "startProcess: starting to update pids map");
        ProcessRecord oldApp;
        synchronized (mService.mPidsSelfLocked) {
            oldApp = mService.mPidsSelfLocked.get(pid);
        }
        // If there is already an app occupying that pid that hasn't been cleaned up
        if (oldApp != null && !app.isolated) {
            // Clean up anything relating to this pid first
            Slog.wtf(TAG, "handleProcessStartedLocked process:" + app.processName
                    + " startSeq:" + app.startSeq
                    + " pid:" + pid
                    + " belongs to another existing app:" + oldApp.processName
                    + " startSeq:" + oldApp.startSeq);
            mService.cleanUpApplicationRecordLocked(oldApp, false, false, -1,
                    true /*replacingPid*/);
        }
    // 注意这里 
        mService.addPidLocked(app);
        synchronized (mService.mPidsSelfLocked) {
            if (!procAttached) {
                Message msg = mService.mHandler.obtainMessage(PROC_START_TIMEOUT_MSG);
                msg.obj = app;
                mService.mHandler.sendMessageDelayed(msg, usingWrapper
                        ? PROC_START_TIMEOUT_WITH_WRAPPER : PROC_START_TIMEOUT);
            }
        }
        checkSlow(app.startTime, "startProcess: done updating pids map");
        return true;
    }
```

#### 写入thread值到ProcessRecord

从上面的流程中，我们发现构造出来的ProcessRecord的thread（ApplicationThread）成员变量还是没有被赋值，那么这个thread何时被赋值呢？

> 查找`ProcessRecord`中`thread`赋值的入口：
>
> 1. 通过查找`thread`成员的赋值写入方法，可以确定起始点是，`com.android.server.am.ProcessRecord#makeActive` ，接下来查看调用这个方法的列表：
> 2. ![image-20210411172323572](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210411172323.png)
>
> 3. 这里我们显然选择 `com.android.server.am.ActivityManagerService#attachApplicationLocked`
>
> 4. `android.app.ActivityThread#attach`
>
> 5. 这里我们遇到两个选择：
>
>    <img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210411172524.png" alt="image-20210411172524831" style="zoom:50%;" />
>
> 6. 显然，应该选择第二个：`android.app.ActivityThread#main`
>
> 7. 这里我们却无法直接通过IDEA的调用层次功能找到任何调用方法，说明可能是通过反射来调用的，所以直接通过全局字符串搜索==android.app.ActivityThread==，可以找到在 `ProcessList.startProcessLocked` 中调用的。

通过上面的分析，这里我们从ActivityThread的main函数开始。

#####  ActivityThread#main

```java
    public static void main(String[] args) {
        Trace.traceBegin(Trace.TRACE_TAG_ACTIVITY_MANAGER, "ActivityThreadMain");

        // Install selective syscall interception
        AndroidOs.install();

        // CloseGuard defaults to true and can be quite spammy.  We
        // disable it here, but selectively enable it later (via
        // StrictMode) on debug builds, but using DropBox, not logs.
        CloseGuard.setEnabled(false);

        Environment.initForCurrentUser();

        // Make sure TrustedCertificateStore looks in the right place for CA certificates
        final File configDir = Environment.getUserConfigDirectory(UserHandle.myUserId());
        TrustedCertificateStore.setDefaultUserDirectory(configDir);

        // Call per-process mainline module initialization.
        initializeMainlineModules();

        Process.setArgV0("<pre-initialized>");

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
        // 直接构造一个ActivityThread对象
        ActivityThread thread = new ActivityThread();
        // 执行attach方法
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

##### ActivityThread#attach

```java
 private void attach(boolean system, long startSeq) {
        sCurrentActivityThread = this;
        mSystemThread = system;
        if (!system) {
            android.ddm.DdmHandleAppName.setAppName("<pre-initialized>",
                                                    UserHandle.myUserId());
            // 将当前ApplicationThread的Binder对象保存为一个静态成员
            RuntimeInit.setApplicationObject(mAppThread.asBinder());
            // 获取AMS
            final IActivityManager mgr = ActivityManager.getService();
            try {
                // 通知AMS来 attachApplication
                mgr.attachApplication(mAppThread, startSeq);
            } catch (RemoteException ex) {
                throw ex.rethrowFromSystemServer();
            }
        } else {
            
        }
}
```

##### **ActivityManagerService#attachApplication** & attachApplicationLocked

```java
    @Override
    public final void attachApplication(IApplicationThread thread, long startSeq) {
        if (thread == null) {
            throw new SecurityException("Invalid application interface");
        }
        synchronized (this) {
            int callingPid = Binder.getCallingPid();
            final int callingUid = Binder.getCallingUid();
            final long origId = Binder.clearCallingIdentity();
            attachApplicationLocked(thread, callingPid, callingUid, startSeq);
            Binder.restoreCallingIdentity(origId);
        }
    }

```
上面的方法只是调用了 attachApplicationLocked：

==有个关键的步骤是，从 AMS的进程记录表中根据PID取出一个 ProcessRecord: `app = mPidsSelfLocked.get(pid)`==

```java
private boolean attachApplicationLocked(@NonNull IApplicationThread thread,
            int pid, int callingUid, long startSeq) {
        // Find the application record that is being attached...  either via
        // the pid if we are running in multiple processes, or just pull the
        // next app record if we are emulating process with anonymous threads.
        ProcessRecord app;
        long startTime = SystemClock.uptimeMillis();
        long bindApplicationTimeMillis;
        if (pid != MY_PID && pid >= 0) {
            synchronized (mPidsSelfLocked) {
                // 从进程记录中获取
                app = mPidsSelfLocked.get(pid);
            }
        }
        // Make app active after binding application or client may be running requests (e.g
        // starting activities) before it is ready.
        // 关联thread到app（ProcessRecord）
        app.makeActive(thread, mProcessStats);
        return true;
    }
```

经过上面的步骤，即完成了ProcessRecord到进程的ApplicationThread的关联。

### 启动服务

从AMS中调用ApplicationThread的方法来在Service自己应该所属的进程中创建Service对象的实例。


<svg width="557px" height="390px" viewBox="0 0 557 390" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <g id="Android源码分析" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
        <g id="bindService流程分析-加入启动流程" transform="translate(-1415.000000, -205.000000)">
            <g id="架构图/模块-源码备份-52" transform="translate(1714.000000, 280.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFBBA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="62.0929562" y="11">ActivityThread#main()</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="77.8124541" y="23.3877551">进程创建后执行入口函数</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-57" transform="translate(1714.000000, 235.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFBBA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="74.0568056" y="11">独立进程的Service</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="101.501157" y="23.3877551">启动进程</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-53" transform="translate(1714.000000, 322.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFBBA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="62.7115336" y="11">ActivityThread#attach</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="113.886094" y="23.3877551">-</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-28" transform="translate(1416.000000, 316.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="13.5486884" y="11">IApplicationThread#scheduleCreateService</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="57.7019938" y="23.3877551">android/app/IApplicationThread.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-29" transform="translate(1416.000000, 362.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFED99" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="95.5148809" y="11">transact</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="104.925425" y="23.3877551">binder</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-29" transform="translate(1415.000000, 527.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFED99" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="95.5148809" y="11">transact</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="104.925425" y="23.3877551">binder</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-30" transform="translate(1415.000000, 404.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFBBA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="15.14668" y="11">ApplicationThread#scheduleCreateService</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="65.1496925" y="23.3877551">android/app/ActivityThread.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-31" transform="translate(1415.000000, 443.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFBBA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="28.8631654" y="11">ActivityThread#handleCreateService</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="65.1496925" y="23.3877551">android/app/ActivityThread.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-33" transform="translate(1416.000000, 485.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFBBA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="20.3389813" y="11">IActivityManager#serviceDoneExecuting</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="65.1496925" y="23.3877551">android/app/ActivityThread.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-34" transform="translate(1415.000000, 569.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="4.64492271" y="11">ActivityManagerService#serviceDoneExecuting</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="65.1496925" y="23.3877551">android/app/ActivityThread.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-32" transform="translate(1416.000000, 237.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="24.9173913" y="11">ActiveServices#bringUpServiceLocked</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="47.5865126" y="23.3877551">com/android/server/am/ActiveServices.java</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-43" transform="translate(1415.000000, 275.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="23.3147135" y="11">ActiveServices#realStartServiceLocked</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="47.5865126" y="23.3877551">com/android/server/am/ActiveServices.java</tspan>
                </text>
            </g>
            <path id="直线-7备份-2" d="M1531.83473,262.007377 L1531.834,268.046 L1535.17364,268.046784 L1531.5,275.046784 L1527.82636,268.046784 L1531.165,268.046 L1531.16527,262.007377 L1531.83473,262.007377 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-8备份-2" d="M1530.83473,340.998605 L1530.834,354.055 L1534.17364,354.055556 L1530.5,361.055556 L1526.82636,354.055556 L1530.165,354.055 L1530.16527,340.998605 L1530.83473,340.998605 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-9备份-2" d="M1530.83473,386.998605 L1530.834,398.055 L1534.17364,398.055556 L1530.5,405.055556 L1526.82636,398.055556 L1530.165,398.055 L1530.16527,386.998605 L1530.83473,386.998605 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-10备份-2" d="M1530.83473,430.007377 L1530.834,436.046 L1534.17364,436.046784 L1530.5,443.046784 L1526.82636,436.046784 L1530.165,436.046 L1530.16527,430.007377 L1530.83473,430.007377 Z" fill="#979797" fill-rule="nonzero"></path>
            <text id="启动服务" font-family="NotoSansCJKsc-Black, Noto Sans CJK SC" font-size="14" font-weight="800" letter-spacing="0.154000005" fill="#020202" fill-opacity="0.88378138">
                <tspan x="1503.692" y="217">启动服务</tspan>
            </text>
            <path id="直线-22" d="M1530,469 L1530,477 L1534,477 L1529.5,486 L1525,477 L1529,477 L1529,469 L1530,469 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-22备份" d="M1530,511 L1530,519 L1534,519 L1529.5,528 L1525,519 L1529,519 L1529,511 L1530,511 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-22备份-2" d="M1530,553 L1530,561 L1534,561 L1529.5,570 L1525,561 L1529,561 L1529,553 L1530,553 Z" fill="#979797" fill-rule="nonzero"></path>
            <g id="架构图/模块-源码备份-54" transform="translate(1714.000000, 367.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFBBA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="30.362747" y="11">IActivityManager#attachApplication</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="113.886094" y="23.3877551">-</tspan>
                </text>
            </g>
            <path id="直线-27备份" d="M1829,305 L1829,314 L1833,314 L1828.5,323 L1824,314 L1828,314 L1828,305 L1829,305 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-28备份" d="M1829,348 L1829,359 L1833,359 L1828.5,368 L1824,359 L1828,359 L1828,348 L1829,348 Z" fill="#979797" fill-rule="nonzero"></path>
            <g id="架构图/模块-源码备份-55" transform="translate(1714.000000, 454.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="14.6686884" y="11">ActivityManagerService#attachApplication</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="113.886094" y="23.3877551">-</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-48" transform="translate(1687.000000, 497.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="283.328638" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="25.0095075" y="11">ActivityManagerService#attachApplicationLocked</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="59.3894238" y="23.3877551">获取之前存储的 mPendingServices - 待启动的服务列表</tspan>
                </text>
            </g>
            <g id="架构图/模块-源码备份-29" transform="translate(1714.000000, 408.000000)">
                <rect id="矩形" stroke="#979797" fill="#FFED99" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="95.5148809" y="11">transact</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="104.925425" y="23.3877551">binder</tspan>
                </text>
            </g>
            <path id="直线-29备份" d="M1829,392 L1829,400 L1833,400 L1828.5,409 L1824,400 L1828,400 L1828,392 L1829,392 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-30备份" d="M1829,434 L1829,446 L1833,446 L1828.5,455 L1824,446 L1828,446 L1828,434 L1829,434 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-33" d="M1532,300 L1532,308 L1536,308 L1531.5,317 L1527,308 L1531,308 L1531,300 L1532,300 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-34" d="M1829,480 L1829,488 L1833,488 L1828.5,497 L1824,488 L1828,488 L1828,480 L1829,480 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-35" d="M1653.5,292.5 L1644.5,288 L1653.5,283.5 L1653.5,287.5 L1674.56431,287.5 L1674.564,509.5 L1687,509.5 L1687,510.5 L1673.56431,510.5 L1673.564,288.5 L1653.5,288.5 L1653.5,292.5 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-36" d="M1829,260 L1829,271 L1833,271 L1828.5,280 L1824,271 L1828,271 L1828,260 L1829,260 Z" fill="#979797" fill-rule="nonzero"></path>
        </g>
    </g>
</svg>

#### ActiveServices#bringUpServiceLocked

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

#### 独立进程何时启动服务？

* 一般来说，封装较好的代码会保证入口统一，如果非独立进程情况下服务的启动使用的是 `realStartServiceLocked` 方法来启动服务，那么独立进程情况下，服务的启动也应该使用此方法，所以我们查看 `realStartServiceLocked` 方法的调用层次，如下：

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
  // com.android.server.am.ActiveServices#attachApplicationLocked
  // frameworks/base/services/core/java/com/android/server/am/ActiveServices.java
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

#### ActivityThread#handleCreateService

在下方的`android.app.ActivityThread#handleCreateService`方法中：

1. 通过ClassLoader加载并实例化了对应的Service对象；
2. 将Service存储到ActivityThread中的一个ArrayMap中；

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



### 绑定服务


<svg width="232px" height="344px" viewBox="0 0 232 344" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <g id="Android源码分析" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
        <g id="bindService流程分析-加入启动流程" transform="translate(-427.000000, -124.000000)">
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
            <g id="架构图/模块-源码备份-8" transform="translate(428.000000, 201.000000)">
                <rect id="矩形" stroke="#979797" fill="#D5FFA2" x="0.5" y="0.5" width="229.075117" height="25" rx="5.35564854"></rect>
                <text id="方法过程" font-family="NotoSansCJKsc-Bold, Noto Sans CJK SC" font-size="9.37238494" font-weight="bold" letter-spacing="0.103096234" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="9.12492271" y="11">ActiveServices.requestServiceBindingLocked</tspan>
                </text>
                <text id="代码地址" font-family="NotoSansCJKsc-Light, Noto Sans CJK SC" font-size="6.69456067" font-weight="300" letter-spacing="0.073640172" fill="#151515" fill-opacity="0.88378138">
                    <tspan x="47.5865126" y="23.3877551">com/android/server/am/ActiveServices.java</tspan>
                </text>
            </g>
            <path id="直线-5" d="M542.834728,150.007377 L542.834,156.046 L546.17364,156.046784 L542.5,163.046784 L538.82636,156.046784 L542.165,156.046 L542.165272,150.007377 L542.834728,150.007377 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-6" d="M542.834728,188.007377 L542.834,194.046 L546.17364,194.046784 L542.5,201.046784 L538.82636,194.046784 L542.165,194.046 L542.165272,188.007377 L542.834728,188.007377 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-7" d="M542.834728,226.007377 L542.834,232.046 L546.17364,232.046784 L542.5,239.046784 L538.82636,232.046784 L542.165,232.046 L542.165272,226.007377 L542.834728,226.007377 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-8" d="M542.834728,263.998605 L542.834,277.055 L546.17364,277.055556 L542.5,284.055556 L538.82636,277.055556 L542.165,277.055 L542.165272,263.998605 L542.834728,263.998605 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-9" d="M542.834728,309.998605 L542.834,321.055 L546.17364,321.055556 L542.5,328.055556 L538.82636,321.055556 L542.165,321.055 L542.165272,309.998605 L542.834728,309.998605 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-10" d="M542.834728,353.007377 L542.834,359.046 L546.17364,359.046784 L542.5,366.046784 L538.82636,359.046784 L542.165,359.046 L542.165272,353.007377 L542.834728,353.007377 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-18" d="M542.834728,392.007377 L542.834,398.046 L546.17364,398.046784 L542.5,405.046784 L538.82636,398.046784 L542.165,398.046 L542.165272,392.007377 L542.834728,392.007377 Z" fill="#979797" fill-rule="nonzero"></path>
            <path id="直线-11" d="M542.834728,430.007377 L542.834,436.046 L546.17364,436.046784 L542.5,443.046784 L538.82636,436.046784 L542.165,436.046 L542.165272,430.007377 L542.834728,430.007377 Z" fill="#979797" fill-rule="nonzero"></path>
        </g>
    </g>
</svg>




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
