# SpringBoot外部化配置读取策略



Spring Boot 可以让您的配置外部化，以便可以在不同环境中使用相同的应用程序代码。您可以使用 properties 文件、YAML 文件、环境变量或者命令行参数来外部化配置。可以使用 @Value 注解将属性值直接注入到 bean 中，可通过 Spring 的 Environment 访问，或者通过 @ConfigurationProperties 绑定到[结构化对象](https://www.bookstack.cn/read/springboot/spilt.2.pages-spring-boot-features.md#boot-features-external-config-typesafe-configuration-properties)。

Spring Boot 使用了一个非常特别的 PropertySource 指令，用于智能覆盖默认值。属性将按照以下顺序处理：**（重点关注加粗的四个- 3，5，6，11）**

1. 默认属性 (通过 SpringApplication.setDefaultProperties 设置). 
2. @Configuration 类上的 @PropertySource 注解. （Please note that such property sources are not added to the Environment until the application context is being refreshed. This is too late to configure certain properties such as logging.* and spring.main.* which are read before refresh begins. ）
3. **配置数据**（Config data） (如 application.properties 类似的文件) 
4. A RandomValuePropertySource     that has properties only in random.*. 
5. **操作系统环境变量** （OS environment variables ）； 
6. **Java系统属性** - Java System     properties (System.getProperties()). 
7. JNDI attributes from java:comp/env. 
8. ServletContext init parameters. 
9. ServletConfig init parameters. 
10. Properties from SPRING_APPLICATION_JSON (inline JSON embedded in an environment variable or system property). 
11. **命令行参数** - Command line arguments. 
12. properties attribute on your tests. Available on @SpringBootTest and the test annotations for testing a particular     slice of your application. 
13. @TestPropertySource     annotations on your tests. 
14. Devtools global settings properties in the $HOME/.config/spring-boot directory when devtools is active. 

 

# 配置数据件加载位置与优先级

| springboot版本： 2.4.1 |
| ---------------------- |
| 日期： 2021/1/13       |

**配置数据**文件默认的加载的顺序如下 - Config data files are considered in the following order:

1.  Application properties packaged inside your jar (application.properties and YAML variants). 

2.  Profile-specific application properties packaged inside your jar (application- {profile}.properties and YAML variants). 
3.  Application     properties outside of your packaged jar (application.properties     and YAML variants). 
4.  Profile-specific     application properties outside of your packaged jar (application-     {profile}.properties and YAML variants). 

## 默认加载位置

springboot 启动会扫描以下位置的 `application.properties` 和 `application.yam`  文件作为Spring boot的默认配置文件

1. classpath root （`optional:classpath:/`）
2. classpath config包（`optional:classpath:/config/` ）
3. 当前目录（`optional:file:./` ）
4. 当前目录的 config 子目录（`optional:file:./config/`）
5. config 子目录的直接子目录（`optional:file:./config/*/`）

优先级由低到高，高优先级的配置会覆盖低优先级的配置；SpringBoot会从这几个位置全部加载主配置文件；互补配置；

> ⚠️注意：`optional:classpath:/` 等为该位置在`spring.config.location`配置中指定文件位置的写法  

 

## 自定义加载位置

可以通过 `pring.config.location`  属性来显式的指定配置文件的位置，通过 `spring.config.name`  来指定要查找的文件名称（不需要后缀名）

```shell
java -jar myproject.jar  --spring.config.location=optional:classpath:/default.properties,optional:classpath:/ov      erride.properties  
```

> ⚠️注意：因为需要很早被读取，这两个参数必须设置为 **环境属性**；  环境属性指： environment property (typically an OS environment variable, a  system property, or a command-line argument).   



### **详细规则**

- 目录需要以 / 结尾，运行时会拼接 spring.config.name 指定的文件名；

- 直接指定文件的不会做修改及不全，将直接使用；

- 不论是在目录中还是直接指定文件，文件都必须包含文件名后缀（.properties, .yaml, 及 .yml )；

- 当指定多个位置（通过","分割）时，最后面的会覆盖前面的；

- spring.config.location  指定的路径会 **替代**     默认的位置；

- 如果不想替换，则使用 spring.config.additional-location  属性来指定，通过此属性指定的位置的配置会覆盖默认位置的配置；

- optional: 表示允许指定的位置不存在；

- **通配规则：**

- - 如果最后一个路径段包含 * ，则会以通配模式加载，通配模式下除了搜索当前目录之外，还会搜索当前目录的直接子目录；如：config/*/  可以加载到 /config/redis/application.properties，/config/mysql/application.properties      
  - 一个通配位置仅可包含一个 * 并且以 */ 结尾，搜索时会检索f */<filename>的文件并加载
  - 通配的文件会按字母顺序进行排序
  - 通配位置仅可在外部目录中使用，无法使用于 classpath: 

 

> ⚠️注意：如通过环境变量来指定属性配置，因为操作系统一般不允许使用 xxx.xxx 的格式，可以使用XXX_XXX的形式来设置（例如： 使用 SPRING_CONFIG_NAME 替换 spring.config.name).  可参考 Binding from Environment Variables ）  