# qyer-mobile-app

[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/icyleaf/qyer-mobile-app/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/qyer-mobile-app.svg?style=flat)](http://rubygems.org/gems/qyer-mobile-app)
[![Build Status](https://travis-ci.org/icyleaf/qyer-mobile-app.svg)](https://travis-ci.org/icyleaf/qyer-mobile-app)
[![Circle CI](https://circleci.com/gh/icyleaf/qyer-mobile-app/tree/develop.svg?style=svg)](https://circleci.com/gh/icyleaf/qyer-mobile-app/tree/develop)

穷游移动应用命令行工具

安装
----

打开终端执行如下命令

```bash
$ gem install qyer-mobile-app
```

用法
----

```bash
$ qma --help

qma

穷游移动应用命令行工具：App 打包，上传等

Commands:
  config  配置命令需求的参数
  help    Display global or [command] help documentation
  info    查看 app 的数据信息
  pac     上报本机 IP 用于自动代理使用
  publish 发布 iOS 或 Android 应用至穷游分发内测系统 (仅限 ipa/apk 文件)

Global Options:
  --slince
  --verbose
  -h, --help           Display help documentation
  -v, --version        Display version information
  -t, --trace          Display backtrace when an error occurs

Author:
  {"icyleaf"=>"icyleaf.cn@gmail.com"}

Website:
  http://icyleaf.com
```

配置文件
--------

由于该工具仅限公司内部使用，涉及服务器配置的信息必须从配置文件读取。

其余的自己看帮助吧！不再解释！

共享代码
--------

1.	Fork it ( https://github.com/[my-github-username]/qyer-mobile-app/fork )
2.	Create your feature branch (`git checkout -b my-new-feature`\)
3.	Commit your changes (`git commit -am 'Add some feature'`\)
4.	Push to the branch (`git push origin my-new-feature`\)
5.	Create a new Pull Request
