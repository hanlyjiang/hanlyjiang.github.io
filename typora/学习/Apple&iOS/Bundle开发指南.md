# Bundle开发指南

> 

## 介绍

Bundles 是macOS和iOS中用于封装代码和资源的基础技术。Bundles通过提供所需资源的已知位置，同时减轻了创建复合二进制文件的需求，从而简化了开发人员的体验。 相反，Bundles使用目录和文件来提供一种更自然的组织类型，也可以在开发过程中和部署之后轻松地对其进行修改。

为了支持Bundle软件，Cocoa和Core Foundation均提供了用于访问Bundle软件内容的编程接口。 由于捆绑包使用有组织的结构，因此所有开发人员都必须了解Bundle的基本组织原则，这一点很重要。 本文档为您提供了基础，以帮助您理解Bundle的工作方式以及在开发过程中如何使用它们访问资源文件。 



**主要内容：**

* 关于Bundles：介绍Bundles和软件包的概念以及系统如何使用它们。 
* [Bundles结构](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html)：描述了标准Bundles类型的结构和内容。 
* 访问Bundles的内容：向您展示如何使用Cocoa和Core Foundation界面来获取有关Bundles及其内容的信息。
*  文档包：描述了文档包的概念（与Bundles软件松散相关）以及如何使用它们。 



# 关于Bundles

捆绑包是在macOS和iOS中交付软件的便捷方式。 捆绑包为最终用户提供了简化的界面，同时为开发提供了支持。 本章介绍了捆绑软件，并讨论了捆绑软件在macOS和iOS中的作用。



## Bundles and Packages 

尽管有时有时将包和包互换使用，但它们实际上代表了截然不同的概念：

* _Package(软件包)_：是Finder呈现给用户的任何目录，就好像它是单个文件一样。 
* _Bundle(捆绑包)_: 是具有标准化层次结构的目录，其中包含可执行代码和该代码使用的资源。 

软件包提供了使macOS易于使用的基本抽象之一。 如果您查看计算机上的应用程序或插件，则实际查看的是目录。 软件包目录中包含使应用程序或插件运行所需的代码和资源文件。 但是，当您与包目录交互时，Finder会将其视为单个文件。 此行为可防止临时用户进行可能会对软件包内容产生不利影响的更改。 例如，它防止用户重新排列或删除可能阻止应用程序正常运行的资源或代码模块。 

> 注意：即使默认情况下将程序包视为不透明文件，用户仍然可以查看和修改其内容。 程序包目录的上下文菜单上是“显示程序包内容”命令。 选择此命令将显示一个新的Finder窗口，该窗口设置为软件包目录的顶层。 用户可以使用此窗口导航包的目录结构，并进行更改，就好像它是常规目录层次结构一样。 

虽然的软件包可以改善用户体验，但软件包更适合于帮助开发人员打包其代码并帮助操作系统访问该代码。Bundle定义了用于组织与您的软件相关联的代码和资源的基本结构。 这种结构的存在还有助于促进重要的功能，例如本地化。 Bundle的确切结构取决于您是要创建应用程序，框架还是插件。 它还取决于其他因素，例如目标平台和插件的类型。 

有时将包和包视为可互换的原因是，许多类型的bundle也是Package。 例如，应用程序和可装入Bundle是Package，因为它们通常被系统视为不透明目录。 但是，并非所有Bundle都是Package，反之亦然。 



### 系统如何识别Bundle和Package

如果满足以下任一条件，则Finder会将目录视为软件包： 

* 该目录具有已知的文件扩展名：`.app`，`.bundle`，`.framework`，`.plugin`，`.kext`等。 
* 该目录具有一个扩展，其他一些应用程序则声称该扩展表示包的类型。 请参阅[文档包](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/DocumentPackages/DocumentPackages.html#//apple_ref/doc/uid/10000123i-CH106-SW1)。
* 该目录设置了其软件包位。 

指定软件包的首选方法是给软件包目录一个已知的文件扩展名。 在大多数情况下，Xcode通过提供应用正确扩展名的模板来为您解决这一问题。 您要做的就是创建适当类型的Xcode项目。 

大多数捆绑包也是包装。 例如，应用程序和插件通常由Finder呈现为单个文件。 但是，并非所有捆绑软件类型都适用。 特别是，框架是一种类型的捆绑软件，出于链接和运行时使用的目的，它被视为单个单元，但是框架目录是透明的，因此开发人员可以查看头文件和它们包含的其他资源。 



### 关于捆绑包显示名称 

显示名称使用户可以控制包和软件包在Finder中的显示方式，而不会破坏依赖它们的客户端。用户可以随意重命名文件，而重命名应用程序或框架可能会导致按名称引用该应用程序或框架的相关代码模块中断。因此，当用户更改捆绑软件的名称时，该更改只是表面上的。 Finder不会在文件系统中更改捆绑软件名称，而是将单独的字符串（称为显示名称）与捆绑软件相关联，然后显示该字符串。 

显示名称仅用于呈现给用户。您从不使用显示名称来打开或访问代码中的目录，但在向用户显示目录名称时会使用显示名称。默认情况下，捆绑商品的显示名称与捆绑商品名称本身相同。但是，在以下情况下，系统可能会更改默认显示名称： 如果捆绑包是应用程序，则在大多数情况下Finder隐藏.app扩展名。 

如果捆绑软件支持本地化的显示名称（并且用户尚未显式更改捆绑软件名称），则Finder会显示与用户当前语言设置相匹配的名称。 尽管Finder大多数时候都为应用程序隐藏.app扩展名，但可以显示它以防止混淆。例如，如果用户更改应用程序的名称，而新名称包含另一个文件扩展名，则Finder将显示.app。扩展名，以明确说明捆绑软件是一个应用程序。例如，如果要将.mov扩展名添加到Chess应用程序中，则Finder将显示Chess.mov.app，以防止用户认为Chess.mov是QuickTime文件。 

有关显示名称和指定本地化捆绑软件名称的更多信息，请参见[文件系统概述](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFileSystem/BPFileSystem.html#//apple_ref/doc/uid/10000185i)。 

### 捆绑包的优势

捆绑包为开发人员提供以下优势：

- 因为包是文件系统中的目录层次结构，所以包仅包含文件。因此，您可以像打开其他类型的文件一样使用所有相同的基于文件的界面来打开包资源。
- 捆绑软件目录结构使支持多个本地化变得容易。您可以轻松添加新的本地化资源或删除不需要的资源。
  捆绑包可以驻留在许多不同格式的卷上，包括多种分叉格式（例如HFS，HFS +和AFP）以及单叉格式（例如UFS，SMB和NFS）。
- 用户只需在Finder中拖动捆绑包即可安装，重新定位和删除捆绑包。
  捆绑包也是软件包，因此被视为不透明文件，不易受到用户意外修改（例如删除，修改或重命名关键资源）的影响。
- 捆绑软件可以支持多种芯片架构（PowerPC，Intel）和不同的地址空间要求（32位/ 64位）。它还可以支持包含特殊的可执行文件（例如，针对一组特定的矢量指令进行了优化的库）。
- 大多数（但不是全部）可执行代码可以捆绑在一起。应用程序，框架（共享库）和插件均支持捆绑软件模型。静态库，动态库，shell脚本和UNIX命令行工具不使用捆绑软件结构。
- 捆绑的应用程序可以直接从服务器运行。无需在本地系统上安装特殊的共享库，扩展名和资源。



## Types of Bundles

尽管所有捆绑软件都支持相同的基本功能，但是定义和创建捆绑软件以定义其预期用途的方式有所不同：

- **Application-应用程序**-应用程序捆绑包管理与可启动过程关联的代码和资源。该捆绑软件的确切结构取决于您所针对的平台（iOS或macOS）。有关应用程序捆绑包的结构的信息，请参阅应用程序捆绑包。
- **Frameworks-框架**-框架捆绑包管理动态共享库及其相关资源，例如头文件。应用程序可以链接到一个或多个框架以利用它们包含的代码。有关框架束的结构的信息，请参阅[框架束的剖析](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html#//apple_ref/doc/uid/10000123i-CH101-SW28)。
- **插件**-macOS支持许多系统功能的插件。插件是应用程序动态加载自定义代码模块的一种方式。以下列表列出了您可能要开发的一些关键插件类型：
  * **自定义插件**是您为自己的目的定义的插件。请参见[可加载捆绑包的剖析](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html#//apple_ref/doc/uid/10000123i-CH101-SW32)。
  * **Image Unit插件**为Core Image技术添加了自定义图像处理行为。请参阅[图像单元教程](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/ImageUnitTutorial/Introduction/Introduction.html#//apple_ref/doc/uid/TP40004531)。
  * **Interface Builder插件**包含要集成到Interface Builder的库窗口中的自定义对象。
  * **“首选项窗格”**插件定义了要集成到“系统首选项”应用程序中的自定义首选项；请参阅[“首选项窗格编程指南”](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/PreferencePanes/PreferencePanes.html#//apple_ref/doc/uid/10000110i)。
  * **Quartz Composer插件**为Quartz Composer应用程序定义了自定义补丁。请参见《 [Quartz Composer自定义补丁程序编程指南](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/QuartzComposer_Patch_PlugIn_ProgGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40004787)》。
  * **Quick Look插件**支持使用Quick Look显示自定义文档类型。请参阅[《快速外观编程指南》](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/Quicklook_Programming_Guide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40005020)。
  * **Spotlight插件**支持对自定义文档类型进行索引，以便用户可以搜索这些文档。请参阅[《 Spotlight Importer编程指南》](https://developer.apple.com/library/archive/documentation/Carbon/Conceptual/MDImporters/MDImporters.html#//apple_ref/doc/uid/TP40001267)。
  * **WebKit插件**扩展了普通Web浏览器支持的内容类型。
  * **Widgets-窗口小部件**将新的基于HTML的应用程序添加到仪表板。

尽管文档格式可以利用捆绑结构来组织其内容，但是从最纯粹的意义上来说，通常不将文档视为捆绑。被实现为目录并且被视为不透明类型的文档，无论其内部格式如何，都被视为文档包。有关文档包的更多信息，请参见[文档包](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/DocumentPackages/DocumentPackages.html#//apple_ref/doc/uid/10000123i-CH106-SW1)。



## 创建Bundle 

在大多数情况下，您不会手动创建捆绑包或软件包。当您创建新的Xcode项目（或将目标添加到现有项目）时，Xcode会在需要时自动创建所需的包结构。例如，应用程序，框架和可装入包目标都具有关联的包结构。当您构建任何这些目标时，Xcode都会自动为您创建相应的捆绑软件。

>  注意：某些Xcode目标（例如Shell工具和静态库）不会导致创建包或包。这是正常现象，无需专门为这些目标类型创建捆绑包。为这些目标生成的结果二进制文件应照原样使用。

如果使用make文件（而不是Xcode）来构建项目，则创建捆绑包是没有魔术的。捆绑包只是文件系统中的目录，具有明确定义的结构，并且在捆绑包目录名称的末尾添加了特定的文件扩展名。只要您创建顶级捆绑软件目录并适当地构造捆绑软件的内容，就可以使用用于访问捆绑软件的编程支持来访问这些内容。有关如何构造捆绑软件目录的更多信息，请参见[捆绑软件结构](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html#//apple_ref/doc/uid/10000123i-CH101-SW1)。



## 程序包访问软件包的支持

引用捆绑软件或捆绑在一起的程序可以利用Cocoa和Core Foundation中的接口来访问捆绑软件的内容。 使用这些接口，您可以找到捆绑软件资源，获取有关捆绑软件配置的信息，并加载可执行代码。 在Objective-C应用程序中，您可以使用[NSBundle](https://developer.apple.com/library/archive/documentation/LegacyTechnologies/WebObjects/WebObjects_3.5/Reference/Frameworks/ObjC/Foundation/Classes/NSBundle/Description.html#//apple_ref/occ/cl/NSBundle)类来获取和管理捆绑软件信息。 对于基于C的应用程序，可以使用与[CFBundleRef](https://developer.apple.com/documentation/corefoundation/cfbundle)不透明类型关联的功能来管理包。

> 注意：与许多其他Core Foundation和Cocoa类型不同，NSBundle和CFBundleRef不是免费的桥接数据类型，并且不能互换使用。 但是，您可以从任何一个对象中提取束路径信息，然后使用它来创建另一个。

有关如何使用Cocoa和Core Foundation中的编程支持来访问捆绑软件的信息，请参阅[访问捆绑软件的内容](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/AccessingaBundlesContents/AccessingaBundlesContents.html#//apple_ref/doc/uid/10000123i-CH104-SW1)。



## 捆绑软件使用指南

捆绑软件是macOS和iOS中软件的首选组织机制。捆绑结构使您可以对可执行代码和资源进行分组，以在一个地方以一种有组织的方式来支持该代码。以下准则提供了有关如何使用捆绑软件的一些其他建议：

- 捆绑软件中始终包含一个信息属性列表（Info.plist）文件。确保包括推荐用于捆绑类型的密钥。有关可包含在此文件中的所有键的列表，请参阅“[运行时配置准则](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPRuntimeConfig/000-Introduction/introduction.html#//apple_ref/doc/uid/10000170i)”。
- 如果没有特定资源文件就无法运行应用程序，请将该文件包含在应用程序包中。应用程序应始终包括它们需要操作的所有图像，字符串文件，可本地化的资源和插件。同样，非关键资源应尽可能存储在应用程序捆绑包中，但如有需要，可以将其放置在捆绑包外部。有关应用程序捆绑包结构的更多信息，请参见[应用程序捆绑包](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html#//apple_ref/doc/uid/10000123i-CH101-SW13)。
- 如果打算从捆绑软件中加载C++代码，则可能希望将打算加载的符号标记为外部“ C”。 NSBundle或Core Foundation CFBundleRef函数都不了解C++名称转换约定，因此以这种方式标记符号可以使以后识别它们变得容易得多。
- 您不能使用NSBundle类加载代码片段管理器（CFM）代码。如果需要加载基于CFM的代码，则必须使用CFBundleRef或CFPlugInRef不透明类型的函数。您可以使用此技术从Mach-O可执行文件加载基于CFM的插件。
- 您应该始终使用`NSBundle`类（与CFBundleRef透明类型关联的功能相反）来加载任何包含Java代码的包。
- 加载包含Objective-C代码的捆绑软件时，您可以使用`NSBundle`类或与macOS v10.5及更高版本中的`CFBundleRef`不透明类型相关联的函数，但是每种行为都有差异。如果您使用Core Foundation函数来加载插件或其他可加载的包（与框架或动态共享库相对），则这些函数将私下加载该包并立即绑定其符号；如果您使用NSBundle，则该捆绑包会全局加载，并且其符号会延迟绑定。此外，使用`NSBundle`类加载的包会导致生成[`NSBundleDidLoadNotification`](https://developer.apple.com/documentation/foundation/bundle/1416137-didloadnotification)通知，而使用Core Foundation函数加载的包则不会。





# Bundle 结构

捆绑包的结构可能会有所不同，具体取决于捆绑包的类型和目标平台。 以下各节描述了macOS和iOS中最常用的捆绑包结构。

> 注意：尽管捆绑包是打包可执行代码的一种方式，但它们并不是唯一受支持的方式。 UNIX Shell脚本和命令行工具不使用捆绑软件结构，静态和动态共享库也不使用。



## Application Bundles

应用程序捆绑包是开发人员创建的最常见的捆绑包类型之一。 应用程序捆绑包存储应用程序成功运行所需的所有内容。 尽管应用程序捆绑包的具体结构取决于您要开发的平台，但是在两个平台上使用捆绑包的方式都是相同的。 本章描述了iOS和macOS中应用程序捆绑包的结构。

### Application Bundle 有些什么文件?

表2-1总结了您可能在应用程序捆绑包中找到的文件类型。 这些文件的确切位置因平台而异，并且可能根本不支持某些资源。 有关示例和更多详细信息，请参阅本章中特定于平台的捆绑包部分。

| File             | Description                                                  |
| :--------------- | :----------------------------------------------------------- |
| `Info.plist`file | （必需）*信息属性列表*文件是一个结构化文件，其中包含应用程序的配置信息。 系统依靠此文件的存在来标识有关您的应用程序和任何相关文件的相关信息。 |
| Executable       | （必需）每个应用程序必须具有一个可执行文件。该文件包含应用程序的主入口点和静态链接到应用程序目标的任何代码。 |
| Resource files   | 资源是驻留在应用程序的可执行文件之外的数据文件。资源通常由图像，图标，声音，nib文件，字符串文件，配置文件和数据文件（以及其他文件）组成。大多数资源文件可以针对特定语言或地区进行本地化，也可以由所有本地化共享。资源文件在分发包目录结构中的位置取决于您是开发iOS还是Mac应用程序。 |
| 其他支持的文件   | Mac应用程序可以嵌入其他高级资源，例如专用框架，插件，文档模板以及其他对应用程序必不可少的自定义数据资源。尽管可以在iOS应用程序捆绑包中包含自定义数据资源，但不能包含自定义框架或插件。 |

Mac应用程序可以嵌入其他高级资源，例如专用框架，插件，文档模板以及其他对应用程序必不可少的自定义数据资源。尽管可以在iOS应用程序捆绑包中包含自定义数据资源，但不能包含自定义框架或插件。

### iOS应用程序包的剖析

Xcode提供的项目模板完成了为iPhone或iPad应用程序设置捆绑包所需的大部分工作。但是，了解捆绑软件的结构可以帮助您决定应在何处放置自己的自定义文件。 iOS应用程序的捆绑结构更适合于移动设备的需求。它使用相对扁平的结构，几乎没有多余的目录，以节省磁盘空间并简化对文件的访问。

#### iOS应用程序Bundle结构

典型的iOS应用程序捆绑包在顶层捆绑包目录中包含应用程序可执行文件和应用程序使用的任何资源（例如，应用程序图标，其他图像和本地化内容）。清单2-1显示了一个名为MyApp的简单iPhone应用程序的结构。子目录中唯一需要的文件是需要本地化的文件。但是，您可以在自己的应用程序中创建其他子目录来组织资源和其他相关文件。

**Listing 2-1** iOS应用程序Bundle结构

| `MyApp.app`             |
| ----------------------- |
| `   MyApp`              |
| `   MyAppIcon.png`      |
| `   MySearchIcon.png`   |
| `   Info.plist`         |
| `   Default.png`        |
| `   MainWindow.nib`     |
| `   Settings.bundle`    |
| `   MySettingsIcon.png` |
| `   iTunesArtwork`      |
| `   en.lproj`           |
| `      MyImage.png`     |
| `   fr.lproj`           |
| `      MyImage.png`     |

表2-2描述了[清单2-1](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html#//apple_ref/doc/uid/10000123i-CH101-SW12)。尽管该应用程序本身仅用于演示目的，但其中包含的许多文件代表iOS扫描应用程序捆绑包时查找的特定文件。您自己的捆绑软件将包含部分或全部这些文件，具体取决于您支持的功能。

| File                                                         | 描述                                                         |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| `MyApp`                                                      | （必填）包含您应用程序代码的可执行文件。该文件的名称与您的应用程序名称相同，但后缀为`.app`。 |
| 应用图标(`MyAppIcon.png`, `MySearchIcon.png`, and `MySettingsIcon.png`) | （必需/推荐）应用程序图标在特定时间用于表示应用程序。例如，主屏幕，搜索结果和“设置”应用程序中会显示不同大小的应用程序图标。并非所有图标都是必需的，但大多数都是推荐的。有关应用程序图标的信息，请参阅[应用程序图标和启动图像](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html#//apple_ref/doc/uid/10000123i-CH101-SW16)。 |
| `Info.plist`                                                 | （必需）此文件包含应用程序的配置信息，例如其捆绑软件ID，版本号和显示名称。请参阅[信息属性列表文件](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html#//apple_ref/doc/uid/10000123i-CH101-SW5) 了解更多信息。 |
| 启动图片(`Default.png`)                                      | （推荐）一个或多个图像，以特定的方向显示应用程序的初始界面。系统使用提供的启动图像之一作为临时背景，直到您的应用程序加载其窗口和用户界面。如果您的应用程序不提供任何启动图像，则在应用程序启动时会显示黑色背景。有关应用程序图标的信息，请参阅[应用程序图标和启动图像](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html#//apple_ref/doc/uid/10000123i-CH101-SW16)。 |
| `MainWindow.nib`                                             | （推荐）应用程序的主nib文件包含在应用程序启动时加载的默认接口对象。通常，此nib文件包含应用程序的主窗口对象和应用程序委托对象的实例。然后可以从其他nib文件中加载其他接口对象，或者由应用程序以编程方式创建其他接口对象。 （可以通过向`Info.plist`文件中的`NSMainNibFile`键分配不同的值来更改主笔尖文件的名称。请参阅[信息属性列表文件](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html#//apple_ref/doc/uid/10000123i-CH101-SW5) 了解更多) |
| `Settings.bundle`                                            | “设置”捆绑包是一种特殊类型的插件，其中包含要添加到“设置”应用程序中的所有特定于应用程序的首选项。该捆绑软件包含属性列表和其他资源文件，用于配置和显示您的首选项。 |
| 自定义资源文件                                               | 非本地化的资源放置在顶级目录中，本地化的资源放置在应用程序捆绑包的特定于语言的子目录中。资源包括nib文件，图像，声音文件，配置文件，字符串文件以及应用程序所需的任何其他自定义数据文件。有关资源的更多信息，请参见[iOS应用程序中的资源](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html#//apple_ref/doc/uid/10000123i-CH101-SW8)。 |

> **Note:** iOS应用程序捆绑包不能包含名为“Resources”的自定义文件夹。

iOS应用程序应进行国际化，并为其支持的每种语言提供一个language.lproj文件夹。除了提供应用程序自定义资源的本地化版本外，您还可以通过将具有相同名称的文件放置在特定于语言的项目目录中来本地化启动映像。但是，即使提供本地化版本，也应始终在应用程序捆绑包的顶层包含这些文件的默认版本。默认版本用于无法使用特定本地化的情况。有关本地化资源的更多信息，请参见[捆绑中的本地化资](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html#//apple_ref/doc/uid/20001119-105003)源。

#### The Information Property List File

每个iOS应用程序都必须具有一个信息属性列表（Info.plist）文件，其中包含该应用程序的配置信息。当您创建一个新的iOS应用程序项目时，Xcode会自动创建此文件并为您设置一些关键属性的值。表2-3列出了应明确设置的一些其他键。 （默认情况下，Xcode会掩盖实际的键名，因此Xcode显示的字符串也会在括号中列出，其中使用了一个。通过在编辑器中按住Control键并单击“信息属性列表”键，然后选择“显示”，可以查看所有键的真实键名。出现的上下文菜单中的“原始键/值”。）



**Table 2-3** `Info.plist`必填的key 

| Key                                                         | Value                                                        |
| :---------------------------------------------------------- | :----------------------------------------------------------- |
| `CFBundleDisplayName` (Bundle display name)                 | 捆绑软件显示名称是显示在应用程序图标下方的名称。该值应针对所有受支持的语言进行本地化。 |
| `CFBundleIdentifier` (Bundle identifier)                    | 捆绑包标识符字符串标识您的系统应用程序。该字符串必须是仅包含字母数字（`A`-`Z`，`a`-`z`，`0`-`9`），连字符（`-`）和句点的统一类型标识符（UTI）。 （`.`）个字符。该字符串也应为反向DNS格式。例如，如果您公司的域名为`Ajax.com`，并且创建了一个名为Hello的应用程序，则可以将字符串“ com.Ajax.Hello`”分配为应用程序的捆绑标识符。束标识符用于验证应用程序签名。 |
| `CFBundleVersion` (Bundle version)                          | 捆绑软件版本字符串指定捆绑软件的内部版本号。该值是一个单调增加的字符串，由一个或多个句点分隔的整数组成。此值无法本地化。 |
| `CFBundleIconFiles`                                         | 字符串数组，其中包含用于应用程序的各种图标的图像的文件名。尽管从技术上讲不是必需的，但强烈建议您使用它。 iOS 3.2及更高版本支持此键。 |
| `LSRequiresIPhoneOS` (Application requires iOS environment) | 一个布尔值，指示捆绑软件是否只能在iOS上运行。 Xcode自动添加此密钥并将其值设置为true。您不应该更改此键的值。 |
| `UIRequiredDeviceCapabilities`                              | 告诉iTunes和App Store的密钥，应用程序必须具备与设备相关的功能才能运行。 iTunes和移动App Store使用此列表来防止客户在不支持所列功能的设备上安装应用程序。此键的值可以是数组或字典。如果使用数组，则给定键的存在表示需要相应的功能。如果使用字典，则必须为每个键指定一个布尔值，以指示是否需要该功能。在这两种情况下，不包含键都表示该功能不是必需的。有关要包含在字典中的键的列表，请参阅 [信息属性列表键参考](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Introduction/Introduction.html#//apple_ref/doc/uid/TP40009247)。 iOS 3.0及更高版本支持此键。 |

除了上表中的键之外，表2-4还列出了iOS应用程序常用的一些键。尽管不需要这些键，但是大多数键都提供了一种在启动时调整应用程序配置的方法。提供这些密钥可以帮助确保系统正确显示您的应用程序。

**Table 2-4** `Info.plist` 文件中一般还需要包括的key 

| Para                                      | Para                                                         |
| :---------------------------------------- | :----------------------------------------------------------- |
| `NSMainNibFile` (Main nib file base name) | 一个字符串，用于标识应用程序的主要nib文件的名称。如果要使用除为项目创建的默认文件之外的其他文件，请将该文件的名称与此密钥关联。 nib文件的名称不应包含`.nib`文件扩展名。 |
| `UIStatusBarStyle`                        | 一个字符串，用于标识应用程序启动时状态栏的样式。该值基于在`UIApplication.h`头文件中声明的`UIStatusBarStyle`常量。默认样式是“ UIStatusBarStyleDefault”。完成启动后，应用程序可以更改此初始状态栏样式。如果您未指定此键，iOS将显示默认状态栏。 |
| `UIStatusBarHidden`                       | 一个布尔值，该值确定应用程序启动时状态栏是否最初处于隐藏状态。将其设置为true以隐藏状态栏。默认值为“ false”。 |
| `UIInterfaceOrientation`                  | 一个字符串，用于标识应用程序用户界面的初始方向。该值基于在UIApplication.h头文件中声明的UIInterfaceOrientation常量。默认样式是“ UIInterfaceOrientationPortrait”。 |
| `UIPrerenderedIcon`                       | 一个布尔值，指示应用程序图标是否已经包含光泽和斜角效果。默认值为“ false”。如果您不希望系统将这些效果添加到作品中，请将其设置为“ true”。 |
| `UIRequiresPersistentWiFi`                | 一个布尔值，通知系统该应用程序使用Wi-Fi网络进行通信。长时间使用Wi-Fi的应用程序必须将此密钥设置为` true`；否则，在30分钟后，设备会关闭Wi-Fi连接以节省电量。设置此标志还可以使系统知道在有Wi-Fi可用但当前未使用Wi-Fi时应显示网络选择对话框。默认值为` false`。即使此属性的值为` true`，该键在设备空闲（即屏幕锁定）时也不起作用。在此期间，该应用程序被视为处于非活动状态，尽管它可以在某些级别运行，但没有Wi-Fi连接。 |
| `UILaunchImageFile`                       | 一个字符串，其中包含应用程序的启动图像使用的基本文件名。如果您未指定此键，则假定基本名称为字符串`Default`。 |

#### Application Icon and Launch Images

应用程序图标和启动图像是每个应用程序中都必须存在的标准图形。每个应用程序都必须指定一个图标，以显示在设备的主屏幕和App Store中。应用程序可以指定几个不同的图标以用于不同的情况。例如，应用程序可以提供应用程序图标的小版本，以便在显示搜索结果时使用。启动图像向您的应用程序启动的用户提供视觉反馈。

用于表示图标和启动图像的图像文件必须全部位于软件包的根目录中。您如何识别系统上的这些图像可能会有所不同，但是建议的指定应用程序图标的方法是使用CFBundleIconFiles键。有关如何在应用程序中指定图标和启动图像的详细信息，请参阅iOS版[《应用程序编程指南》](https://developer.apple.com/library/archive/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40007072)中的“[高级应用程序技巧](https://developer.apple.com/library/archive/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/PerformanceTips/PerformanceTips.html#//apple_ref/doc/uid/TP40007072-CH7)”中有关这些项目的讨论。

> 注意：除了捆绑包顶层的图标和启动图像外，您还可以在应用程序特定于语言的项目子目录中包含启动图像的本地化版本。有关在应用程序中包括本地化资源的更多信息，请参见捆绑中的本地化资源。

#### Resources in an iOS Application

在iOS应用程序中，非本地化资源以及应用程序的可执行文件和Info.plist文件位于捆绑目录的顶层。大多数iOS应用程序在此级别上至少包含一些文件，包括应用程序的图标，启动图像以及一个或多个nib文件。尽管您应该将大多数非本地化的资源放置在此顶级目录中，但是您也可以创建子目录来组织您的资源文件。本地化资源必须放置在一个或多个特定于语言的子目录中，在捆绑包中的本地化资源中对此进行了详细讨论。

清单2-2显示了一个包含本地化和非本地化资源的虚构应用程序。非本地化的资源包括Hand.png，MainWindow.nib，MyAppViewController.nib和WaterSounds目录的内容。本地化的资源包括en.lproj和jp.lproj目录中的所有内容。

清单2-2带有本地化和非本地化资源的iOS应用程序

```
MyApp.app/
   Info.plist
   MyApp
   Default.png
   Icon.png
   Hand.png
   MainWindow.nib
   MyAppViewController.nib
   WaterSounds/
      Water1.aiff
      Water2.aiff
   en.lproj/
      CustomView.nib
      bird.png
      Bye.txt
      Localizable.strings
   jp.lproj/
      CustomView.nib
      bird.png
      Bye.txt
      Localizable.strings

有关在应用程序捆绑包中查找资源文件的信息，请参阅[访问捆绑包的目录](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/AccessingaBundlesContents/AccessingaBundlesContents.html#//apple_ref/doc/uid/10000123i-CH104-SW1)。有关如何加载资源文件并在程序中使用它们的信息，请参见《[资源编程指南](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/LoadingResources/Introduction/Introduction.html#//apple_ref/doc/uid/10000051i)》。

### macOS应用程序捆绑的剖析

Xcode提供的项目模板完成了开发过程中设置Mac应用程序捆绑包所需的大部分工作。但是，了解捆绑软件的结构可以帮助您决定应在何处放置自己的自定义文件。 macOS捆绑软件使用高度组织的结构，使捆绑软件加载代码更轻松地查找捆绑软件中的资源和其他重要文件。分层性质还有助于系统将诸如应用程序之类的代码束与其他应用程序用来实现文档类型的目录包区分开。

#### The Structure of a macOS Application Bundle

Mac应用程序捆绑包的基本结构非常简单。捆绑软件的顶层是一个名为Contents的目录。该目录包含所有内容，包括资源，可执行代码，专用框架，专用插件和应用程序所需的支持文件。虽然目录目录似乎是多余的，但它将捆绑软件标识为现代样式的捆绑软件，并将其与早期版本的Mac OS中的文档和旧式捆绑软件类型分开。

清单2-3显示了典型应用程序捆绑包的高层结构，包括您最可能在Contents目录中找到的直接文件和目录。这种结构代表了每个Mac应用程序的核心。

清单2-3 Mac应用程序的基本结构

```shell
MyApp.app/
   Contents/
      Info.plist
      MacOS/
      Resources/
```

表2-5 Contents目录的子目录

| Directory       | Description                                                  |
| :-------------- | :----------------------------------------------------------- |
| `MacOS`         | （必需）包含应用程序的独立可执行代码。通常，此目录仅包含一个二进制文件，其中包含应用程序的主入口点和静态链接的代码。但是，您也可以在此目录中放置其他独立的可执行文件（例如命令行工具）。 |
| `Resources`     | 包含应用程序的所有资源文件。此目录的此内容进一步组织起来以区分本地化资源和非本地化资源。有关此目录的结构的更多信息，请参见[参考资料目录](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html#//apple_ref/doc/uid/20001119-110730) |
| `Frameworks`    | 包含可执行文件使用的所有私有共享库和框架。此目录中的框架已修订锁定到应用程序，并且不能被操作系统可用的任何其他（甚至是较新的）版本取代。换句话说，此目录中包含的框架优先于在操作系统其他部分中找到的任何其他类似命名的框架。<br/>有关如何向应用程序捆绑包添加私有框架的信息，请参见 *[Framework Programming Guide](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Frameworks.html#//apple_ref/doc/uid/10000183i)*. |
| `PlugIns`       | 包含可扩展的捆绑包，这些捆绑包扩展了应用程序的基本功能。您使用此目录包含必须被加载到应用程序的进程空间中才能使用的代码模块。您不会使用该目录存储独立的可执行文件。 |
| `SharedSupport` | 包含不会影响应用程序运行能力的其他非关键资源。您可能会使用此目录来包含您的应用程序希望出现的文档模板，剪贴画和教程之类的内容，但是这些内容不会影响您的应用程序的运行能力。 |

这些年来，应用程序捆绑软件有了长足的发展，但总体目标却是相同的。捆绑软件组织使应用程序更容易找到其资源，同时使用户更难以干扰这些资源。因为Finder将大多数捆绑软件视为不透明实体，所以临时用户很难移动或删除应用程序可能需要的资源。

#### 信息属性列表文件

为了使Finder能够识别应用程序包，您需要包括一个信息属性列表（Info.plist）文件。该文件包含XML属性列表数据，这些数据标识捆绑软件的配置。对于最小的捆绑软件，此文件将包含很少的信息，很可能只是捆绑软件的名称和标识符。对于更复杂的捆绑软件，Info.plist文件包含更多信息。

> 重要说明：捆绑包资源使用区分大小写的搜索进行定位。因此，您的信息属性列表文件的名称必须以大写的“ I”开头。

表2-6列出了应始终包含在Info.plist文件中的键。创建新项目时，Xcode会自动提供所有这些键。 （默认情况下，Xcode会掩盖实际的键名，因此Xcode显示的字符串也会列在括号中。您可以通过按住Control键并在编辑器中单击Information Property List键并选择Show Raw Keys / Values来查看所有键的真实键名。从出现的上下文菜单中。）

表2-6 Info.plist文件中的预期键

| Key                                              | Description                                                  |
| :----------------------------------------------- | :----------------------------------------------------------- |
| `CFBundleName` (Bundle name)                     | 捆绑软件的简称。该键的值通常是您的应用程序的名称。创建新项目时，默认情况下，Xcode设置此键的值。 |
| `CFBundleDisplayName`(Bundle display name)       | 您的应用程序名称的本地化版本。通常，您在每个特定于语言的资源目录中的“ InfoPlist.strings”文件中都包含此键的本地化值。 |
| `CFBundleIdentifier`(Bundle identifier)          | 标识您的系统应用程序的字符串。该字符串必须是仅包含字母数字（`A`-`Z`，`a`-`z`，`0`-`9`），连字符（`-`）和句点的统一类型标识符（UTI）。 （`.`）个字符。该字符串也应为反向DNS格式。例如，如果您公司的域名为`Ajax.com`，并且创建了一个名为Hello的应用程序，则可以将字符串“ com.Ajax.Hello`”分配为应用程序的捆绑标识符。束标识符用于验证应用程序签名。 |
| `CFBundleVersion`(Bundle version)                | 指定捆绑软件内部版本号的字符串。该值是一个单调增加的字符串，由一个或多个句点分隔的整数组成。该值可以对应于应用程序的发行版本或未发行版本。此值无法本地化。 |
| `CFBundlePackageType`(Bundle OS Type code)       | 这是捆绑的类型。对于应用程序，此键的值始终是四个字符的字符串APPL。 |
| `CFBundleSignature`(Bundle creator OS Type code) | 捆绑软件的创建者代码。这是捆绑软件专用的四个字符的字符串。例如，TextEdit应用程序的签名是“ ttxt”。 |
| `CFBundleExecutable`(Executable file)            | 主可执行文件的名称。这是用户启动您的应用程序时执行的代码。 Xcode通常在构建时自动设置此键的值。 |

表2-7列出了还应考虑包含在Info.plist文件中的键。

表2-7 Info.plist文件的推荐键

| Key                                                         | Description                                                  |
| :---------------------------------------------------------- | :----------------------------------------------------------- |
| `CFBundleDocumentTypes`(Document types)                     | 应用程序支持的文档类型。此类型由字典数组组成，每个字典都提供有关特定文档类型的信息。 |
| `CFBundleShortVersionString`(Bundle versions string, short) | 应用程序的发行版本。该键的值是一个由三个句点分隔的整数组成的字符串。 |
| `LSMinimumSystemVersion`(Minimum system version)            | 该应用程序运行所需的最低macOS版本。此密钥的值是形式为`n . n . n` *的字符串，其中每个* n 是一个数字，代表所需的macOS的主要或次要版本号。例如，值10.1.5将代表macOS v10.1.5。 |
| `NSHumanReadableCopyright`(Copyright (human-readable))      | 该应用程序的版权声明。这是人类可读的字符串，可以通过在特定于语言的项目目录中的“ InfoPlist.strings”文件中包含key来进行本地化。 |
| `NSMainNibFile` (Main nib file base name)                   | 启动应用程序时加载的nib文件（不带`.nib`文件扩展名）。主nib文件是Interface Builder归档文件，其中包含启动时所需的对象（主窗口，应用程序委托等）。 |
| `NSPrincipalClass` (Principal class)                        | 动态加载的Objective-C代码的入口点。对于应用程序捆绑包，这几乎始终是NSApplication类或自定义子类。 |

您放入Info.plist文件中的确切信息取决于捆绑软件的需求，可以根据需要进行本地化。有关此文件的更多信息，请参见“[运行时配置准则](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPRuntimeConfig/000-Introduction/introduction.html#//apple_ref/doc/uid/10000170i)”。

#### The Resources Directory

在资源目录中，您可以放置所有图像，声音，nib文件，字符串资源，图标文件，数据文件和配置文件等。该目录的内容进一步细分为可以**存储本地化**和**非本地化资源文件**的区域。非本地化的资源位于“Resources”目录本身的顶层或您定义的自定义子目录中。本地化资源位于称为特定于语言的项目目录的单独子目录中，这些子目录的命名与特定本地化一致。

查看资源目录的组织方式的最佳方法是看一个示例。清单2-4显示了一个包含本地化和非本地化资源的虚构应用程序。非本地化的资源包括Hand.tiff，MyApp.icns和WaterSounds目录的内容。本地化的资源包括en.lproj和jp.lproj目录或其子目录中的所有内容。

清单2-4具有本地化和非本地化资源的Mac应用程序

```shell
MyApp.app/
   Contents/
      Info.plist
      MacOS/
         MyApp
      Resources/
         Hand.tiff
         MyApp.icns
         WaterSounds/
            Water1.aiff
            Water2.aiff
         en.lproj/
            MyApp.nib
            bird.tiff
            Bye.txt
            InfoPlist.strings
            Localizable.strings
            CitySounds/
               city1.aiff
               city2.aiff
         jp.lproj/
            MyApp.nib
            bird.tiff
            Bye.txt
            InfoPlist.strings
            Localizable.strings
            CitySounds/
               city1.aiff
               city2.aiff
```

每个特定于语言的项目目录都应包含一组相同的资源文件，并且任何单个资源文件的名称在所有本地化中都必须相同。换句话说，仅给定文件的内容应从一种本地化更改为另一种本地化。当您在代码中请求资源文件时，仅指定所需文件的名称。捆绑软件加载代码使用用户当前的语言首选项来决定要在哪个目录中搜索您所请求的文件。

有关在应用程序捆绑包中查找资源文件的信息，请参阅[访问捆绑包的目录](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/AccessingaBundlesContents/AccessingaBundlesContents.html#//apple_ref/doc/uid/10000123i-CH104-SW1)。有关如何加载资源文件并在程序中使用它们的信息，请参见[《资源编程指南》](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/LoadingResources/Introduction/Introduction.html#//apple_ref/doc/uid/10000051i)。

##### The Application Icon File

顶级资源目录中的一种特殊资源是应用程序图标文件。按照惯例，该文件使用捆绑包的名称和.icns的扩展名；图像格式可以是任何受支持的类型，但是如果未指定扩展名，则系统将采用.icns。

##### Localizing the Information Property List

由于应用程序的Info.plist文件中的某些键包含用户可见的字符串，因此macOS提供了一种机制，用于指定这些字符串的本地化版本。在每个特定于语言的项目目录中，您可以包括一个InfoPlist.strings文件，该文件指定适当的本地化。该文件是一个字符串文件（不是属性列表），其条目包括要本地化的Info.plist键和适当的翻译。例如，在TextEdit应用程序中，此文件的德语本地化包含以下字符串：

```objective-c
CFBundleDisplayName = "TextEdit";
NSHumanReadableCopyright = "Copyright © 1995-2009 Apple Inc.\nAlle Rechte vorbehalten.";
```

### Creating an Application Bundle

创建应用程序包的最简单方法是使用 Xcode。所有新的应用程序项目都包括一个适当配置的应用程序目标，该目标定义了构建应用程序捆绑包所需的规则，包括要编译哪些源文件、要复制到捆绑包中的资源文件等。新项目还包括预配置的 Info.plist 文件，通常还包括其他几个文件，以帮助您快速启动。您可以使用项目窗口根据需要添加任何自定义文件，并使用信息或检查器窗口配置这些文件。例如，您可能会使用"Info"窗口来指定捆绑包内资源文件的自定义位置。

有关如何在 Xcode 中配置目标的信息，请参阅 [XCode构建系统指南](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/XcodeBuildSystem/000-Introduction/Introduction.html#//apple_ref/doc/uid/TP40006904)。

## Framework Bundles

框架是一个分层目录，它封装了动态共享库和支持该库所需的资源文件。框架比典型的动态共享库具有一些优势，因为它们为框架的所有相关资源提供了单一位置。例如，大多数框架包括定义框架导出的符号的标头文件。将这些文件与共享库及其资源进行分组，便于安装和卸载框架并定位框架资源。

就像动态共享库一样，框架提供了一种将常用代码分解到可由多个应用程序共享的中心位置的方法。无论使用这些资源的流程数量多少，框架代码和资源的一个副本在任何给定时间都位于内存中。然后，与框架相连的应用程序共享包含框架的内存。此行为可减少系统的记忆足迹，并有助于提高性能。

> 注意：仅共享框架的代码和只读资源。如果框架定义可写变量，则每个应用程序都会获得这些变量的自有副本，以防止其影响其他应用程序。

虽然您可以创建自己的框架，但大多数开发人员在框架方面的经验来自将它们包含在他们的项目中。框架是 macOS 如何为您的应用程序提供许多关键功能。macOS 提供的公开可用框架位于 `/System/Library/Frameworks` 目录中。在 iOS 中，公共框架位于相应的 iOS SDK 目录的`System/Library/Frameworks`目录中。有关将框架添加到 Xcode 项目的信息，请参阅 [Xcode 构建系统指南](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/XcodeBuildSystem/000-Introduction/Introduction.html#//apple_ref/doc/uid/TP40006904)。

> 注意：iOS不支持创建自定义框架。

有关框架和框架捆绑包的详细信息，请参阅[框架编程指南](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Frameworks.html#//apple_ref/doc/uid/10000183i)。

### 框架捆绑包的解剖

框架捆绑包的结构不同于应用程序和插件所使用的结构。框架结构基于 macOS 之前的捆绑格式，支持将多个版本的框架代码和资源包含在框架捆绑包中。此类型的捆绑包称为版本捆绑包。支持多个版本的框架允许旧应用程序继续运行，即使框架共享库继续发展。捆绑包的版本子目录包含单个框架修订，而捆绑目录顶部的符号链接指向最新修订。

系统通过目录名称上的`.framework`扩展识别框架捆绑包。系统还使用框架资源目录内的信息.plist文件来收集有关框架配置的信息。列表 2-5 显示了框架捆绑包的基本结构。列表中的箭头（->）表示指向特定文件和子标题的符号链接。这些象征性链接为访问最新版本的框架提供了便利。

列出 2-5 一个简单的框架包

```shell
MyFramework.framework/
   MyFramework  -> Versions/Current/MyFramework
   Resources    -> Versions/Current/Resources
   Versions/
      A/
         MyFramework
         Headers/
            MyHeader.h
         Resources/
            English.lproj/
               InfoPlist.strings
            Info.plist
      Current  -> A
```

框架不需要包含标题目录，但这样做允许您包括定义框架导出符号的标头文件。框架可以在标准目录和自定义目录中存储其他资源文件。

### Creating a Framework Bundle

如果您正在为 macOS 开发软件，您可以创建自己的自定义框架并私下使用它们，或者将其用于其他应用程序。您可以使用单独的 Xcode 项目创建新框架，也可以通过将框架目标添加到现有项目。

有关如何创建框架的信息，请参阅[框架编程指南](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Frameworks.html#//apple_ref/doc/uid/10000183i)。



## 可加载捆绑包

插件和其他类型的可加载捆绑包为您动态扩展应用程序的行为提供了一种方法。可加载的捆绑包包括可执行代码和支持存储在捆绑目录中的代码所需的任何资源。您可以使用可加载捆绑包将代码懒洋洋地加载到您的应用程序中，或者允许其他开发人员扩展应用程序的基本行为。

>  **注：**iOS 不支持创建和使用可加载捆绑包。



### 可加载捆绑包的解剖

可加载捆绑包基于与应用程序捆绑包相同的结构。捆绑包的顶层是单个`Contents`目录。本`Contents`目录内有几个子目录用于存储可执行代码和资源。`Contents`目录还包含捆绑包的`Info.plist`文件，其中包含有关捆绑包配置的信息。

与可执行应用程序不同，可加载捆绑包通常没有作为主要`main`切入点的功能。相反，加载捆绑包的应用程序负责定义预期的切入点。例如，捆绑包可以定义具有特定名称的函数，也可以期望在其`Info.plist`文件中包含识别要使用的特定函数或类别的信息。此选项留给定义可加载捆绑包格式的应用程序开发人员。

列表 2-6显示可加载捆绑包的布局。可加载捆绑包的顶层目录可以有任何扩展，但常见的扩展包括`.bundle`和`.plugin`。macOS 始终将带有这些扩展的捆绑包视为包，默认情况下隐藏其内容。



**列表 2-6**简单的可加载捆绑包

```
MyLoadableBundle.bundle
   Contents/
      Info.plist
      MacOS/
         MyLoadableBundle
      Resources/
         Lizard.jpg
         MyLoadableBundle.icns
         en.lproj/
            MyLoadableBundle.nib
            InfoPlist.strings
         jp.lproj/
            MyLoadableBundle.nib
            InfoPlist.strings
```



除了目录和目录之外，可加载的捆绑包还可能包含其他目录，例如，和 -由完整的应用程序包支持的所有功能。`MacOS``Resources``Frameworks``PlugIns``SharedFrameworks``SharedSupport`

可加载捆绑包的基本结构相同，无论捆绑包在实现中使用哪种语言。有关可加载捆绑包结构的更多信息，请参阅*[代码加载编程主题](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/LoadingCode/LoadingCode.html#//apple_ref/doc/uid/10000052i)*。



### 创建可加载捆绑包

如果您正在为 macOS 开发软件，您可以创建自己的自定义可加载捆绑包并将它们集成到您的应用程序中。如果其他应用程序导出插件 API，您还可以开发针对这些 API 的捆绑包。Xcode 包括使用 C 或目标 C 实现捆绑包的模板项目，具体取决于预期的目标应用程序。

有关如何使用目标 C 设计可加载捆绑包的更多信息，请参阅*[代码加载编程主题](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/LoadingCode/LoadingCode.html#//apple_ref/doc/uid/10000052i)*。有关如何使用 C 语言设计可加载捆绑包的信息，请参阅*[插电式编程主题](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFPlugIns/CFPlugIns.html#//apple_ref/doc/uid/10000128i)*。



## 捆绑包中的本地化资源

在 macOS 捆绑包的目录（或 iOS 应用程序捆绑包的顶级目录中），您可以创建一个或多个特定于语言的项目子目录来存储语言和区域特定的资源。每个目录的名称基于所需本地化的语言和区域，然后是扩展。要指定语言和区域，请使用以下格式：`Resources``.lproj`

- *语言*``*_区域*`。lproj`

目录名称的*语言*部分是符合 ISO 639 公约的两个字母代码。区域*部分*也是两个字母的代码，但它符合ISO 3166公约指定特定区域。虽然目录名称的区域部分完全是可选的，但它可以是调整您针对世界特定地区的本地化的有用方法。例如，您可以使用单个目录来支持所有讲英语的国家。但是，为英国（）、澳大利亚 （）和美国 （） 提供单独的本地化，您可以为每个国家/地区定制内容。`en.lproj``en_GB.lproj``en_AU.lproj``en_US.lproj`



**注：**对于向后兼容性，类和函数还支持几个通用语言的可读目录名称，包括 "，"和其他语言。虽然支持人可读名称，但 ISO 名称是首选。`NSBundle``CFBundleRef``English.lproj``German.lproj``Japanese.lproj`



如果您的大多数资源文件对于给定语言的所有区域都是相同的，则可以将仅语言资源目录与一个或多个特定区域目录进行组合。提供这两种类型的目录可减轻为所支持的每个区域复制每个资源文件的需要。相反，您只能自定义特定区域所需的文件子集。在查找捆绑包中的资源时，捆绑加载代码首先查看任何特定区域的目录，然后是语言特定目录。如果两个本地化目录都不包含资源，则捆绑加载代码会查找适当的非本地化资源。



**重要：**不要将代码存储在文件夹中，因为系统不会加载或执行存储在文件夹中的代码。要了解有关代码和其他类型的数据应存储在应用包中的更多信息，请参阅*[macOS 代码深度签名](https://developer.apple.com/library/archive/technotes/tn2206/_index.html#//apple_ref/doc/uid/DTS40007919)*。`lproj``lproj`



列表 2-7显示了包含语言和区域特定资源文件的 Mac 应用的潜在结构。（在 iOS 应用程序中，目录的内容将处于捆绑目录的顶层。请注意，特定区域目录仅包含目录中文件的子集。如果找不到特定区域版本的资源，则捆绑包将查看特定于语言的目录（在此例中）以查找资源。特定于语言的目录应始终包含任何特定于语言的资源文件的完整副本。`Resources``en.lproj``en.lproj`







# 访问Bundle的内容



## 定位并打开Bundles

### 获取Main Bundle

### 通过路径获取Bundle



### 获取已知目录中的Bundles



### 通过标识符获取Bundles



### 搜索相关联的Bundles



## 获取 Bundle Resources 的引用

如果您拥有了Bundle对象的引用，则可以使用该对象确定捆绑包内的资源位置。Cocoa和Core Foundation都提供了不同的方式在捆绑包内定位资源。此外，您应该了解这些框架如何在捆绑包中查找资源文件，以确保在构建时间将文件放置在正确的位置。

### Bundle 搜索模式

只要你使用 [NSBundle](https://developer.apple.com/library/archive/documentation/LegacyTechnologies/WebObjects/WebObjects_3.5/Reference/Frameworks/ObjC/Foundation/Classes/NSBundle/Description.html#//apple_ref/occ/cl/NSBundle) 对象或者 [CFBundleRef](https://developer.apple.com/documentation/corefoundation/cfbundle)透明类型来定位资源，你的bundle代码永远都不需要关心资源是如何从Bundle中获取的。NSBundle 和 CFBundleRef 都根据可用的用户设置和捆绑配置自动检索到适当的语言特定资源。但是，您仍必须将所有这些特定于语言的资源放入您的捆绑包中，因此了解它们是如何检索的非常重要。

捆绑编程接口遵循特定的搜索算法，以查找捆绑包中的资源。全局资源最优先，其次是区域（region）和语言资源。在考虑区域和语言特定资源时，算法同时考虑捆绑包Info.plist 文件中当前用户的设置和开发区域信息。

首先，捆绑包确定整个应用程序使用的本地化。如果首选语言存在 .lproj 文件夹，则使用该本地化。否则，捆绑包会搜索与下一个首选语言匹配的 .lproj 文件夹，等等，直到找到。如果没有首选语言的本地化，则捆绑包会选择开发语言本地化。

然后，捆绑包按以下顺序搜索资源：

* 全球（非本地化）资源
* 区域特定的本地化资源（基于用户的区域偏好）
* 特定于语言的本地化资源（基于用户的语言偏好）
* 开发语言资源（如捆绑包Info.plist文件中的 `CFBundleDevelopmentRegion`所指定的）。

> 重要提示：捆绑接口在搜索捆绑目录中的资源文件时会考虑大小写。这种对大小写敏感的搜索甚至发生在大小写不敏感的文件系统（如 HFS+）上。

由于Global资源优先于特定于语言特定的资源，因此绝不应同时存在特定资源的全球化和本地化版本。如果存在资源的Global版本，则永远不会返回同一资源的语言特定版本。这种优先级的原因是性能。如果首先搜索本地化资源，则捆绑程序可能会在发现全球资源之前，在几个本地化资源目录中不必要地搜索。

###  iOS中的设备相关资源

在 iOS 4.0 及以后，仅可在特定类型的设备上将单个资源文件标记为可用。此功能简化了您为通用应用程序编写的代码。与其创建单独的代码路径来加载 iPhone 资源文件的一个版本和 iPad 的不同版本的文件，您可以让捆绑加载程序选择正确的文件。您所要做的就是正确命名您的资源文件。

要将资源文件与特定设备关联，请在其文件名中添加自定义修改器字符串。包含此修饰符字符串可产生具有以下格式的文件名：

`<basename><device>.<filename_extension>`

`<basename>`串表示资源文件的原始名称。它还表示您从代码访问文件时使用的名称。同样，`<filename_extension>`串是用于识别文件类型的标准文件名扩展。`<device>`串是一个对案例敏感的字符串，可以是以下值之一：

* `~ipad`-资源仅应加载在iPad设备上。
* `~iphone`-资源应仅加载在iPhone或iPod触摸设备上。

您可以将设备修饰符应用到任何类型的资源文件中。例如，假设您有一个名为 MyImage 的图像.png。要指定 iPad 和 iPhone 图像的不同版本，您将创建包含"MyImage~ipad.png 和 MyImage~iphone 名称的资源文件.png并将它们都包含在捆绑包中。要加载图像，您将继续在代码中将资源称为 MyImage .png并让系统选择相应的版本，如上所示：

`UIImage* anImage = [UIImage imageNamed:@"MyImage.png"];`
在 iPhone 或 iPod 触摸设备上，系统加载 `MyImage~iphone.png`资源文件，而在 iPad 上加载 `MyImage~ipad.png` 资源文件。如果找不到特定于设备的资源版本，系统将返回到查找具有原始文件名的资源，在上一个示例中，该资源将是名为 `MyImage.png`的图像。



### 获取资源路径

为了在捆绑中定位资源文件，您需要知道文件的名称、类型或两者的组合。文件名扩展用于识别文件的类型;因此，您的资源文件必须包含适当的扩展。如果您使用捆绑包中的自定义子方向来组织资源文件，则可以通过提供包含所需文件的子方向的名称来加快搜索速度。

即使您没有捆绑对象，您仍然可以在您知道的路径目录中搜索资源。Core Foundation和Cocoa仅使用基于路径的信息为搜索文件提供 API。（例如，在Cocoa中，您可以使用 [NSFileManager](https://developer.apple.com/documentation/foundation/filemanager) 对象列举目录的内容并测试文件的存在。但是，如果您计划检索多个资源文件，则使用捆绑对象总是更快。捆绑对象在进行时缓存搜索信息，因此后续搜索通常更快。

#### 使用 Cocoa 来查找资源

