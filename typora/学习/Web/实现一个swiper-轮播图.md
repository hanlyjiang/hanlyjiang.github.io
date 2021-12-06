# 实现一个swiper-轮播图

* [swiper/src at master · nolimits4web/swiper (github.com)](https://github.com/nolimits4web/swiper/tree/master/src)
* [vue-awesome-swiper | Homepage | Surmon's projects](https://github.surmon.me/vue-awesome-swiper/)



考虑实现路线中的问题：

1. **如何才能在一行中放置？**

   **正常的文档流是什么样的？**

2. **如何处理事件？**
3. **如何响应事件，滑动内容？**

1. 问题

   1. 为什么width 不起作用？

      ```html
      <template>
        <div class="hello">
          <p>name</p>
          <div class="card_container">
            <div class="card" v-for="item in itemLists" :key="item.id">
                <img :src="item.img"/>
                <p>111122 {{ item.title }}</p>
            </div>
          </div>
        </div>
      </template>
      
      <style scoped>
      div {
        width: 100%;
        background-color: #2c3e50;
      }
      
      .card_container {
        display: flex;
        overflow-x: scroll;
        width: 100%;
        background-color: burlywood;
      }
      
      .card {
        background-color: aquamarine;
        border-radius: 18px;
        width: 640px;
        margin: 16px;
        padding: 16px;
        /*display: block;*/
        /*display: inline-block;*/
      }
      
      img {
        width: 84px;
        height: 84px;
      }
      
      p {
        font-size: 24px;
        color: #2c3e50;
      }
      </style>
      

​	card 上面设置的width不起作用。再给image和text套一层div，设置在div上面就不受影响，这是为什么？





## 问题记录

### 固定宽度，禁止缩放

`width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=0;`

```html
<meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=0;">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=0;">

    <link rel="icon" href="<%= BASE_URL %>favicon.ico">
    <title><%= htmlWebpackPlugin.options.title %></title>
</head>
```

## VUE

### vue在WebStorm中的支持

[Vue.js | WebStorm (jetbrains.com)](https://www.jetbrains.com/help/webstorm/vue-js.html#ws_vue_nuxt_aware_coding_assistance)

# NPM 

## 基本概念

### 包和模块

* **包-package**： 由一个 `package.json` 文件描述的文件或目录。

  * 必须包含一个`package.json` 文件用于发布包到 npm registry

  * 程序包可以不受作用域限制，也可以限定为用户或组织，作用域内包可以是专用的，也可以是公共的。

  * 包格式

    1. a) 一个目录，包含一个通过 `package.json` 描述的程序
    2. b) 包含(a)的gzip压缩包(a)
    3. c) 指向 (b) 的 URL
    4. d) (c) 作为 `<name>@<version>` 发布到registry
    5. e) 指向 (d) 的 `<name>@<tag>` 
    6. f)  （e）拥有一个 latest 的tag，则可写为 `<name>` 
    7. g)  clone下来是（a）的结构的git地址

    

* **模块-module**：在 `node_modules` 目录中的，可以被Node.js 的 `require` 函数加载的目录。

  * **要求必须为下面一种：**

    * 目录：`package.json` 文件包含一个 `main` 配置字段。
    * 一个JavaScript文件。

  * 只有拥有 `package.json` 的模块才是一个package

  * 加载

    * ```js
      var req = require('request')
      ```

    * 其中 req 指向 request 模块

### 安装方式

1. **locally**
2. **golbally**： [‎通过全局安装‎](https://docs.npmjs.com/cli/install)‎包，可以将包中的代码用作本地计算机上的一组工具



## 命令操作

* npm 命令帮助： [CLI commands | npm Docs (npmjs.com)](https://docs.npmjs.com/cli/v8/commands)

### 基础操作

#### 搜索包：

  * [npms.io](https://npms.io/)

#### 安装

> [npm-install | npm Docs (npmjs.com)](https://docs.npmjs.com/cli/v8/commands/npm-install)

**语法：**

```shell
npm install (with no args, in package dir)
npm install [<@scope>/]<name>
npm install [<@scope>/]<name>@<tag>
npm install [<@scope>/]<name>@<version>
npm install [<@scope>/]<name>@<version range>
npm install <alias>@npm:<name>
npm install <git-host>:<git-user>/<repo-name>
npm install <git repo url>
npm install <tarball file>
npm install <tarball url>
npm install <folder>
aliases: npm i, npm add
common options: [-P|--save-prod|-D|--save-dev|-O|--save-optional|--save-peer] [-E|--save-exact] [-B|--save-bundle] [--no-save] [--dry-run]
```

**示例：**

```shell
# 安装无作用域包
npm install <package_name>
# 下载安装有作用域的公共的包
npm install @scope/package-name

# 安装指定tag（版本）
npm install example-package@beta
```

**`save` ：** 

将安装的包保存到 pacakges.json 中作为依赖。

**辅助命令：**

* 查看全局安装包

  ```shell
  npm -g list
  ```

* 卸载

  ```shell
  npm -g uninstall xxx/xxx@x.x.x
  ```



### npm 修改全局安装路径

> [Resolving EACCES permissions errors when installing packages globally | npm Docs (npmjs.com)](https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally)

```shell
npm config list
# 查看配置，其中有无 prefix

# 设置
npm config set prefix $USER_HOME/.npm_global
# 确认
npm config list
```

添加到PATH，将如下内容添加到bashrc文件中。

```shell
export NPM_GLOBAL_PATH=$USER_HOME/.npm_global
export PATH=$NPM_GLOBAL_PATH/bin:$PATH
```

输出如下：

```shell
; "user" config from /Users/hanlyjiang/.npmrc

npm_config_prefix = "~/.bin/npm" 
registry = "https://repo.huaweicloud.com/repository/npm/" 

; node bin location = /usr/local/bin/node
; cwd = /Users/hanlyjiang/Wksp/learn/web/vue-awesome-swiper
; HOME = /Users/hanlyjiang
; Run `npm config ls -l` to show all defaults.
```

再次安装：

```shell
npm install -g  @vue/cli-service-global
```



# 源码分析

* [一步步解读Swiper源码 - 掘金 (juejin.cn)](https://juejin.cn/post/6965743195078524941)



## 依赖的模块解析

### Dependencies

```json
  "dependencies": {
    "dom7": "^4.0.1",
    "ssr-window": "^4.0.1"
  }
```

#### dom7

[dom7 - npm (npmjs.com)](https://www.npmjs.com/package/dom7)

提供部分兼容jQuery的DOM操作的API

#### ssr-window

> SSR： Server-Side-Rendering 服务端渲染。
>
> 是指由**服务侧**完成页面的 HTML 结构拼接的页面处理技术，发送到浏览器，然后为其绑定状态与事件，成为完全可交互页面的过程

Better handling for and object in SSR environment.`window``document`

This library doesn't implement the DOM (like JSDOM), it just patches (or creates and objects) to avoid them to fail (throw errors) during server-side rendering.`window``document`



### devDependencies

```json
"devDependencies": {
      "autoprefixer": "^10.2.6",
}
```

* `autoprefixer` : PostCSS 插件
* `clean-css`: css 优化
* `codelyzer`: A set of tslint rules for static code analysis of Angular TypeScript projects.
* `concurrently`: Run multiple commands concurrently. Like `npm run watch-js & npm run watch-less` but better.
* `exec-sh`： Execute shell command forwarding all stdio streams.



### rollup

#### 特性

[概览 | rollup.js 中文文档 | rollup.js 中文网 (rollupjs.com)](https://www.rollupjs.com/)

Rollup 是一个 JavaScript 模块打包器，可以将小块代码编译成大块复杂的代码，例如 library 或应用程序。

* **Rollup 对代码模块使用新的标准化格式，这些标准都包含在 JavaScript 的 ES6 版本中，而不是以前的特殊解决方案，如 CommonJS 和 AMD**。ES6 模块可以使你自由、无缝地使用你最喜爱的 library 中那些最有用独立函数，而你的项目不必携带其他未使用的代码。ES6 模块最终还是要由浏览器原生实现，但当前 Rollup 可以使你提前体验。

* Rollup 还静态分析代码中的 import，并将排除任何未实际使用的代码。这允许您架构于现有工具和模块之上，而不会增加额外的依赖或使项目的大小膨胀。

* 因为 Rollup 只引入最基本最精简代码，所以可以生成轻量、快速，以及低复杂度的 library 和应用程序。因为这种基于显式的 `import` 和 `export` 语句的方式，它远比「在编译后的输出代码中，简单地运行自动 minifier 检测未使用的变量」更有效。



#### 配置文件

`rollup.config.js`





## node 基础用法

### 命令行用法

* [用法与示例 | Node.js API 文档 (nodejs.cn)](http://nodejs.cn/api/synopsis.html)



**用法：**

```shell
node [options] [V8 options] [script.js | -e "script" | - ] [arguments]
```



### require(id)

[CommonJS 模块 | Node.js API 文档 (nodejs.cn)](http://nodejs.cn/api/modules.html#requireid)

- `id` [](http://url.nodejs.cn/9Tw2bK) 模块名称或路径
- 返回: [](http://url.nodejs.cn/6sTGdS) 导出的模块内容

用于导入模块、`JSON` 和本地文件。 模块可以从 `node_modules` 导入。 可以使用相对路径（例如 `./`、`./foo`、`./bar/baz`、`../foo`）导入本地模块和 JSON 文件，该路径将根据 [`__dirname`](http://nodejs.cn/api/modules.html#__dirname)（如果有定义）命名的目录或当前工作目录进行解析。 POSIX 风格的相对路径以独立于操作系统的方式解析，这意味着上面的示例将在 Windows 上以与在 Unix 系统上相同的方式工作。

```js
// 使用相对于 `__dirname` 或当前工作目录的路径导入本地模块。
//（在 Windows 上，这将解析为 .\path\myLocalModule。）
const myLocalModule = require('./path/myLocalModule');

// 导入 JSON 文件：
const jsonData = require('./path/filename.json');

// 从 node_modules 或 Node.js 内置模块导入模块：
const crypto = require('crypto');
```



## d.ts

> * [介绍 · 声明文件 · TypeScript中文网 · TypeScript——JavaScript的超集 (tslang.cn)](https://www.tslang.cn/docs/handbook/declaration-files/introduction.html)
> * [编写.d.ts文件 | TypeScript手册中文版 (gitbooks.io)](https://oyyd.gitbooks.io/typescript-handbook-zh/content/gitbook/writing_.d.ts_files.html)
>
> * [如何编写一个d.ts文件 - SegmentFault 思否](https://segmentfault.com/a/1190000009247663)

当我们要使用一个外部JavaScript库或是新的API时，我们需要用一个声明文件（.d.ts）来描述这个库的结构.



### 问题：

1. 怎么应用到编辑器里面？

   > **.d.ts文件放到哪里**
   >
   > 经常有人问写出来的d.ts文件（A.d.ts）文件放到哪个目录里，如果是模块化的话那就放到和源码（A.js）文件同一个目录下，如果是全局变量的话理论上放到哪里都可以————当然除非你在tsconfig.json 文件里面特殊配置过。

2. Vue 组件定义
   * [defineComponent | Vue3 (vue3js.cn)](https://vue3js.cn/global/defineComponent.html)





## Vue 相关

* [h() | Vue3 (vue3js.cn)](https://vue3js.cn/global/h.html)
* [Setup | Vue.js (vuejs.org)](https://v3.cn.vuejs.org/guide/composition-api-setup.html)

### setup

setup方法是用于实现**[组合式API](https://v3.cn.vuejs.org/guide/composition-api-introduction.html#%E4%BB%80%E4%B9%88%E6%98%AF%E7%BB%84%E5%90%88%E5%BC%8F-api)**的，**是使用组合式API的入口**。

#### 组合式API是什么？

组合式API是用于解决大型组件（多个组件共同作用）中的逻辑关注点分离问题的。

> ![](https://gitee.com/hanlyjiang/image-repo/raw/master/image/202112061739735.png)
>
> 这是一个大型组件的示例，其中**逻辑关注点**按颜色进行分组。
>
> 这种碎片化使得理解和维护复杂组件变得困难。选项的分离掩盖了潜在的逻辑问题。此外，在处理单个逻辑关注点时，我们必须不断地“跳转”相关代码的选项块。
>
> 如果能够**将同一个逻辑关注点相关代码收集在一起**会更好。而这正是组合式 API 使我们能够做到的。

总结： **用于解决大型组件中的逻辑关注点碎片化的问题，将同一关注点的相关代码收集在一起。**

> **Swiper 为什么使用这个？**
>
> Swiper中可以加载很多其他的组件一起配合使用。

### setup 函数

#### 调用时机

* **setup 组件实例尚未被创建时执行。**
* `setup` 的调用发生在 `data` property、`computed` property 或 `methods` 被解析之前，所以它们无法在 `setup` 中被获取。

* 此时可以访问：props，attrs，slots，emit

* 无法访问：data，computed，methods，refs（模板ref）
* **返回：** `setup` 返回的所有内容都暴露给组件的其余部分 (计算属性、方法、生命周期钩子等等) 以及组件的模板



#### swiper中的调用方式如下：

```js
setup(props, { slots: originalSlots, emit }) {
}
```

#### setup 函数详解

> 以下解释来源于官方文档 [Setup | Vue.js (vuejs.org)](https://v3.cn.vuejs.org/guide/composition-api-setup.html#context)

使用 `setup` 函数时，它将接收两个参数：

1. `props`:

   * `setup` 函数中的第一个参数是 `props`,`setup` 函数中的 `props` 是响应式的，当传入新的 prop 时，它将被更新。
   * 但是，因为 `props` 是响应式的，**不能使用 ES6 解构**，它会消除 prop 的响应性。

2. `context` 

   * 传递给 `setup` 函数的第二个参数是 `context`。`context` 是一个普通 JavaScript 对象，暴露了其它可能在 `setup` 中有用的值

   * ```vue
     export default {
       setup(props, context) {
         // Attribute (非响应式对象，等同于 $attrs)
         console.log(context.attrs)
     
         // 插槽 (非响应式对象，等同于 $slots)
         console.log(context.slots)
     
         // 触发事件 (方法，等同于 $emit)
         console.log(context.emit)
     
         // 暴露公共 property (函数)
         console.log(context.expose)
       }
     }
     ```

3. 结合模版使用

   如果 `setup` 返回一个对象，那么该对象的 property 以及传递给 `setup` 的 `props` 参数中的 property 就都可以在模板中访问到：