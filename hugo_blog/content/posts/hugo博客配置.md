+++
date = '2025-11-01T22:39:13+08:00'
draft = false
title = 'Hugo博客配置'
+++

## 安装
此部分省略，可直接使用 AI 提供；

## 配置中文

### 基础配置
```yaml
# 配置语言
languageCode: zh-cn
defaultContentLanguage: zh-cn
# 所有语言都放入独立子目录 false
defaultContentLanguageInSubdir: false
```
> 注意: 这里的语言是 zh-cn，但是 PaperMod 主题的多语言配置中对应的是 zh.yaml 文件

### 多语言翻译文件

经过基础配置，部分界面已经是中文了，但是像阅读时间这种还是英文的，这里将 PaperMod 的主题中的文件拷贝过来；

```SHELL
cp themes/PaperMod/i18n/zh.yaml i18n/zh-cn.yaml

hugo server -D
```


## 参考
- https://blog.rzlnb.top/
- https://www.yuweihung.com/posts/2021/papermod-lang-zh/
- https://github.com/adityatelange/hugo-PaperMod?tab=readme-ov-file
- https://github.com/adityatelange/hugo-PaperMod/wiki/Features