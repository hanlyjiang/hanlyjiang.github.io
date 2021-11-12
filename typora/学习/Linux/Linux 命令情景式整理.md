# Linux 命令整理

收集日常工作过程中使用到的命令，方便后续使用。通过具体的场景来进行输出。

## 删除所有目录的 `.DS_Store` 文件（`find`）

* 直接用法

    ```shell
    find . -type f -name ".DS_Store" -delete -print 
    ```

* 扩展函数

  ```shell
  function delete_ds_store(){
  	echo "删除当前目录及其子目录下的所有 .DS_Store 文件, 删除文件列表："
  	find . -type f -name ".DS_Store" -delete -print;
  }
  ```
  

## 压缩目录(过滤`.git`文件）

* 用法

    ```shell
    zip -r ${zipfilesName}.zip ${toZipDir}/ --exclude "*/.git/*" "*/.svn/*" "*./~*" "*/.DS_Store"
    ```

* 函数

    ```shell
    zipDir () {
        if test $# -eq 2
        then
            zipfilesName=$1
            toZipDir=$2
            echo 卸载设备：$toZipDir 到 $zipfilesName 应用...
            zip -r ${zipfilesName}.zip ${toZipDir}/ --exclude "*/.git/*" "*/.svn/*" "*./~*" "*/.DS_Store"
        elif test $# -eq 1
        then
            zipfilesName=$1
            toZipDir=./
            echo 卸载默认设备上的 $package 应用...
            zip -r ${zipfilesName}.zip ${toZipDir}/ --exclude "*/.git/*" "*/.svn/*" "*./~*" "*/.DS_Store"
        else
            echo "用法: zipDir {压缩文件名称} [待压缩目录-如不填，则当前目录]"
        fi
    }
    ```

