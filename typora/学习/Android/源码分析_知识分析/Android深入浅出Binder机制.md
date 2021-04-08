文章来源：[Android深入浅出之Binder机制](https://www.cnblogs.com/innost/archive/2011/01/09/1931456.html)



`main_mediaserver.cpp`:

```cpp

/*
**
** Copyright 2008, The Android Open Source Project
**
** Licensed under the Apache License, Version 2.0 (the "License");
** you may not use this file except in compliance with the License.
** You may obtain a copy of the License at
**
**     http://www.apache.org/licenses/LICENSE-2.0
**
** Unless required by applicable law or agreed to in writing, software
** distributed under the License is distributed on an "AS IS" BASIS,
** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
** See the License for the specific language governing permissions and
** limitations under the License.
*/
#define LOG_TAG "mediaserver"
//#define LOG_NDEBUG 0
#include <fcntl.h>
#include <sys/prctl.h>
#include <sys/wait.h>
#include <binder/IPCThreadState.h>
#include <binder/ProcessState.h>
#include <binder/IServiceManager.h>
#include <cutils/properties.h>
#include <utils/Log.h>
#include "RegisterExtensions.h"
// from LOCAL_C_INCLUDES
#include "AudioFlinger.h"
#include "CameraService.h"
#include "MediaLogService.h"
#include "MediaPlayerService.h"
#include "AudioPolicyService.h"
using namespace android;
int main(int argc, char** argv)
{
    signal(SIGPIPE, SIG_IGN);
    char value[PROPERTY_VALUE_MAX];
    bool doLog = (property_get("ro.test_harness", value, "0") > 0) && (atoi(value) == 1);
    pid_t childPid;
    // FIXME The advantage of making the process containing media.log service the parent process of
    // the process that contains all the other real services, is that it allows us to collect more
    // detailed information such as signal numbers, stop and continue, resource usage, etc.
    // But it is also more complex.  Consider replacing this by independent processes, and using
    // binder on death notification instead.
    if (doLog && (childPid = fork()) != 0) {
        // media.log service
        //prctl(PR_SET_NAME, (unsigned long) "media.log", 0, 0, 0);
        // unfortunately ps ignores PR_SET_NAME for the main thread, so use this ugly hack
        strcpy(argv[0], "media.log");
        sp<ProcessState> proc(ProcessState::self());
        MediaLogService::instantiate();
        ProcessState::self()->startThreadPool();
        // ...
    } else {
        // all other services
        if (doLog) {
            prctl(PR_SET_PDEATHSIG, SIGKILL);   // if parent media.log dies before me, kill me also
            setpgid(0, 0);                      // but if I die first, don't kill my parent
        }
        sp<ProcessState> proc(ProcessState::self());
        sp<IServiceManager> sm = defaultServiceManager();
        ALOGI("ServiceManager: %p", sm.get());
        AudioFlinger::instantiate();
        MediaPlayerService::instantiate();
        CameraService::instantiate();
        AudioPolicyService::instantiate();
        registerExtensions();
        ProcessState::self()->startThreadPool();
        IPCThreadState::self()->joinThreadPool();
    }
}
```

* `sp<ProcessState> proc(ProcessState::self());`
  * //BIDNER_VM_SIZE定义为(`1*1024*1024`) - (`4096 *2`) 1M-8K
  * 打开 `/dev/binder` 设备，这样的话就相当于和内核binder机制有了交互的通道
  * 映射fd到内存，设备的fd传进去后，估计这块内存是和binder设备共享的

* `sp<IServiceManager> sm = defaultServiceManager();`
  * 返回的实际是BpServiceManager，它的remote对象是BpBinder，传入的那个handle参数是0。
  * Bp 表示BinderProxy
* ` MediaPlayerService::instantiate();`
  * MediaPlayerService 实例化后，调用BpServiceManager的addService函数
  * addService来说，看来ServiceManager把信息加入到自己维护的一个服务列表中了

