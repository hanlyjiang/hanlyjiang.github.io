# 细节记录

## Build phases中Embed Frameworks的配置

如果是framework，配置之后，构建时生成的Products/xxx.framework中会包含一个Frameworks的目录，其中包含嵌入的framework文件；

不包含时生成的framework：

```shell
.
├── HJSangForVPN
├── Info.plist
└── _CodeSignature
    ├── CodeDirectory
    ├── CodeRequirements
    ├── CodeRequirements-1
    ├── CodeResources
    └── CodeSignature

包含时：(可以看到多了一个Frameworks的目录)

```shell
.
├── Frameworks
│   └── SangforSDK.framework
├── HJSangForVPN
├── Info.plist
└── _CodeSignature
    ├── CodeDirectory
    ├── CodeRequirements
    ├── CodeRequirements-1
    ├── CodeResources
    └── CodeSignature
```

