wei7 (wei7.com)
====

本repo及其所承载的项目皆名为wei7，但并非是指wei7格式（一种文本格式），而是指网站wei7.com。请务必先阅读LICENSE.md以理解版权及许可方式。

必备条件
----

要成功生成这个应用，您的开发环境必须满足下列全部条件：

- 已安装git。

- 已安装node.js。

- 在node.js中已安装CoffeeScript（注意：包名是coffee-script，必须使用npm命令的全局模式安装）。

怎样生成
----

首先，使用git命令clone本repo。下文中假定它在本地存放的目录是~/projects/wei7。
（注意：该步骤只应在第一次生成时执行，以后应该使用其他相应的git命令）

确保当前目录为这个目录。

然后，使用npm命令，以非全局模式安装MongoDB native drivers（包名是mongodb）。
（注意：该步骤只应在第一次生成时执行）

然后，输入：

```bash
cake build
```
