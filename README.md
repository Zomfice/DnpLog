# DnpLog

[![CI Status](https://img.shields.io/travis/Zomfice/DnpLog.svg?style=flat)](https://travis-ci.org/Zomfice/DnpLog)
[![Version](https://img.shields.io/cocoapods/v/DnpLog.svg?style=flat)](https://cocoapods.org/pods/DnpLog)
[![License](https://img.shields.io/cocoapods/l/DnpLog.svg?style=flat)](https://cocoapods.org/pods/DnpLog)
[![Platform](https://img.shields.io/cocoapods/p/DnpLog.svg?style=flat)](https://cocoapods.org/pods/DnpLog)

## Description

拦截网络请求，并将请求日志显示在列表和终端输出，查看接口的详细的请求信息，便于接口调试和日志查看

## Getting Started

### Install

```ruby
pod 'DnpLog'
```
### How-to

是否开启终端日志输出

```
DnpLogManager.terminalPrint = true
```

拦截所有网络请求，并将日志输出

```
DnpLogManager.startMonitor()
```

添加域名或者请求白名单, 只拦截白名单接口请求

```
DnpLogManager.startMonitor {
    [
        "https://www.baidu.com/"
    ]
}
```

### Example 

<img src="https://github.com/Zomfice/DnpLog/blob/master/Resource/20210522-111820%402x.png" width="50%" height="50%">

<img src="https://github.com/Zomfice/DnpLog/blob/master/Resource/Simulator%20Screen%20Shot1.png" width="50%" height="50%">

<img src="https://github.com/Zomfice/DnpLog/blob/master/Resource/Simulator%20Screen%20Shot2.png" width="50%" height="50%">

## Author

Zomfice@gmail.com

## License

DnpLog is available under the MIT license. See the LICENSE file for more info.
