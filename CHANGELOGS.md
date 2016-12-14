# Changelogs

## v0.10.0

- [FEATURE] qma publish 新增上传超时时间（默认 600s）
- [BREAK_CHANGE] qma publish 上传默认使用 v2 接口

## v0.9.0

- [FEATURE] qma publish 支持服务器端 v2 版本的接口同时兼容 v1 版本
- [FEATURE] 优化 qma publish 上传失败后的错误输出

## v0.8.5

- [BUGFIX] 修复 qma publish 输出地址参数错误

## v0.8.4

- [BUGFIX] 修复 qma publish 输出地址的问题
- [UPDATE] 优化 qma publish 输出样式

## v0.8.3

- [BUGFIX] 修复 qma publish 上传解析参数的异常

## v0.8.2

- [UPDATE] 更新 gems 的依赖版本

## v0.8.0

- [FEATURE] 抽离解析 App 为独立 Gem app_info，并添加移动设备的支持

## v0.7.4

- [BUGFIX] 修复发布二进制包的时候选择 host 错误的情况并修改为 --host-type 来消除歧义

## v0.7.3

- [FEATURE] MobileProvision 增加 empty? 方法来判断是否为空或解析错误

## v0.7.2

- [BUGFIX] qma publish 上传时错误初始化 json_data 导致无法解析和上传

## v0.7.1

- [FEATURE] ipa 拆分 InfoPlist 和 MobileProvision 两个类便于直接解析不同的文件
- [FEATURE] qma info 支持 mobileprovision 识别和信息输出

## v0.6.3

- [FEATURE] qma info 在显示 ipa 资源的时候，如果单项包含多个条目会显示总数

## v0.6.2

- [FEATURE] apk 解析关联 device_type 实为调用 os 方法

## v0.6.1

- [BUGFIX] 降低 terminal-table 的依赖版本，已兼容 fastlane

## v0.6.0

- [FEATURE] qma publish 新增 --json-data 参数接收租装全部参数和额外更多参数
- [BUGFIX] 处理 spec 在非 mac 环境规避相关测试用例

## v0.5.3

- [BUGFIX] 处理在非 osx 环境下获取 ipa 的 mobileprovision 属性会报异常

## v0.5.2

- [STAGE] 处理 ipa 的图标暂不做还原处理

## v0.5.1

- [BUGFIX] 修复无法获取 iPad 图标的问题
- [BUGFIX] 忘记引入 table-terminal gem
- [BUGFIX] 优化判断 ipa mobileprovision 的方法
- [BUGFIX] 修复判断 ipa device_type 有误的问题
- [STYLE] 格式化 Android/iOS/iPad/iPhone/Universal 等专有名词的大小写

## v0.5.0

- [FEATURE] 增加上报本机 IP 的功能

## 0.4.0

- [FEATURE] 抽离解析 app、配置类、上传 app 并重构核心代码
- [CHANGE] 修改 qma config 的存储结构并会自动升级修改配置文件

## 0.3.0

- [FEATURE] qma publish 支持上传 git 信息和上传渠道信息

## 0.2.0

- [FEATURE] qma publish 兼容服务器判断之前是否已经上传的返回话术
- [FEATURE] 解析 ipa 更多的数据信息

## 0.1.2

- [FEATURE] 清理代码，移除暂时不用的 gems

## 0.1.1

- [BUGFIX] 使用 ruby_android 替换 ruby_apk 修复解析问题

## 0.1.0

- [FEATURE] 实现 qma config/publish 的核心功能

