# TBPlayer

>添加cocoapods 中，请下载[1.0tag](https://github.com/suifengqjn/TBPlayer/archive/1.0.zip)(https://github.com/suifengqjn/TBPlayer/archive/1.0.zip)


视频变下变播，把播放器播放过的数据流缓存到本地，支持拖动。采用avplayer

实现avplayer状态的捕获和细节的处理

关于这个dome写的一篇文章：[文章地址：http://www.jianshu.com/p/990ee3db0563](http://www.jianshu.com/p/990ee3db0563)
<br />
 
* 如果你觉得不错，还请为我star一个，
* 如果在使用过程中遇到BUG，希望你能Issues我，谢谢

###用法

需要的变量
url：视频网址
showView:放视频的视图
```
[[TBPlayer sharedInstance] playWithUrl:url2 showView:self.view];
```

另外自己可以在` TBVideoRequestTask ` 中设置视频的缓存路径，下次播放直接从缓冲读取即可。


