# Flinkx的使用

## 基本使用

> 参考： [flinkx/quickstart.md at 1.10_release · DTStack/flinkx (github.com)](https://github.com/DTStack/flinkx/blob/1.10_release/docs/quickstart.md)

1. 下载代码

   ```shell
   git clone -b 1.11.0 git@github.com:DTStack/flinkx.git
   ```

   

2. 配置编译环境

   ```shell
   # 安装mvn
   brew install maven
   
   # 配置JAVA_HOME（使用jdk1.8时有问题，故切换到11）
   JAVA_VERSION=1.8
   JAVA_HOME=$(/usr/libexec/java_home -v $JAVA_VERSION)
   PATH=$JAVA_HOME/bin:$PATH
   
   java -version
   ```

3. 编译

   ```shell
   # 准备jar
   cd bin
   ## unix平台
   ./install_jars.sh
   
   # 编译
   cd ../
   mvn clean package -DskipTests
   ```

   

4. 运行

   ```shell
   FLINK_PROPERTIES="jobmanager.rpc.address: jobmanager"
   docker network create flink-network
   
   IMAGE=flink:1.11.3-scala_2.11-java8
   FLIB_DIR=/Users/hanlyjiang/Temps/flinkx-test/flink_lib
   
   # 不挂jar
   docker run \
       --rm \
       --name=jobmanager \
       --network flink-network \
       --publish 8081:8081 \
       --publish 6123:6123 \
       --publish 6124:6124 \
       --publish 6125:6125 \
       --env FLINK_PROPERTIES="${FLINK_PROPERTIES}" \
       $IMAGE jobmanager
   
   docker run \
       --rm \
       --name=jobmanager \
       --network flink-network \
       --publish 8081:8081 \
       --publish 6123:6123 \
       --publish 6124:6124 \
       --publish 6125:6125 \
       --env FLINK_PROPERTIES="${FLINK_PROPERTIES}" \
       --mount type=bind,source=$FLIB_DIR,target=/opt/flink/lib \
       $IMAGE jobmanager
   ```

5. fff

   ```shell
   FLINK_PROPERTIES="jobmanager.rpc.address: jobmanager"
   IMAGE=flink:1.11.3-scala_2.11-java8
   FLIB_DIR=/Users/hanlyjiang/Temps/flinkx-test/flink_lib
   
   # 不挂jar
   docker run \
       --rm \
       --name=taskmanager \
       --network flink-network \
       --env FLINK_PROPERTIES="${FLINK_PROPERTIES}" \
       $IMAGE taskmanager
   
   docker run \
       --rm \
       --name=taskmanager \
       --network flink-network \
       --env FLINK_PROPERTIES="${FLINK_PROPERTIES}" \
       --mount type=bind,source=$FLIB_DIR,target=/opt/flink/lib \
       $IMAGE taskmanager
   
   # 复制
   docker run --rm --entrypoint "" -v $PWD/flink_lib:/opt/flink_lib $IMAGE bash -c "cp -R /opt/flink/lib  /opt/flink_lib" 
   ```



6. flinkx

   ```shell
   # https://github.com/DTStack/flinkx/blob/1.10_release/docs/quickstart.md
   
   bin/flinkx \
   	-mode standalone \
       -job docs/example/stream_stream.json \
       -pluginRoot syncplugins \
       -flinkconf  ~/Temps/flinkx-test/
   ```

   