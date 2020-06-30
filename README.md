# flutter_book
一款可以自定义来源阅读网络内容的工具

第一日：
完成dart语言flutter UIdemo

成果:
+ 了解Flutter应用程序的基本结构  
+ 查找和使用packages来扩展功能  
+ 使用热重载加快开发周期  
+ 如何实现有状态的widget  
+ 如何创建一个无限的、延迟加载的列表  

坑：
+ Column嵌套无限高度ListView不能自适应，解决方案=》利用Expanded嵌套，类似清除浮动

第二日：
完成看书软件书架模板和搜索模板

成果:
+ 了解Flutter路由和流式布局
+ 利用有状态的widget完成搜索页面交互
+ 解决路由传参问题

坑:网上对于静态路由传参没有博客(官网访问太卡):
+ 通过查看dart路由 pushNamed 实现，声明需要传递参数的结构体并传参

第三日:
完成搜索模板交互

成果：
+ 完成小动画制作
+ 完成模板弹窗 弹窗原理是开辟一个临时路由

总结：
    动画封装需要考虑资源回收，封装需要state类，预留api需要通过control类操作。后期优化可以提升代码可读性
    
第四日：
完成http请求

成果:  
    自动识别编码并转为utf8  
    flutter自带的两个xpath库都有问题，需要自己实现
    
第五日：
完成dom操作以及xpath解析规则部分，明日更新xpath的dom操作

第六日：
完成xpath选择器，明日需要更新选择器函数操作、

第七日:
完成xpath基础操作，可以通过如下操作取值  
  
```dom:  
<div class="result-item result-game-item">
    <div class="result-game-item-pic">
        <a cpos="img" href="https://www.booktxt.com/28_28228/" class="result-game-item-pic-link" target="_blank" style="width:110px;height:150px;">
            <img src="https://www.booktxt.com/files/article/image/28/28228/28228s.jpg" class="result-game-item-pic-link-img" onerror="$(this).attr('src', '/static/img/novel-noimg.jpg')">
        </a>
    </div>
    <div class="result-game-item-detail">
        <h3 class="result-item-title result-game-item-title">
            <a cpos="title" href="https://www.booktxt.com/28_28228/" title="小阁老" class="result-game-item-title-link" target="_blank">
                <span>小阁老</span>
            </a>
        </h3>
        <p class="result-game-item-desc">站在你面前的是：大明王朝的守护者，万历皇帝的亲密战友，内阁首辅的好儿子，人类文明史上最富有的人。控制吏部三十年的幕后黑手，宗藩制度的掘墓人，东林党口中的严世藩第二，张居正高呼不可战胜。海瑞的知己，徐渭...</p>
        <div class="result-game-item-info">

            <p class="result-game-item-info-tag">
                <span class="result-game-item-info-tag-title preBold">作者：</span>
                <span>
                    三戒大师
                </span>
            </p>
            <p class="result-game-item-info-tag">
                <span class="result-game-item-info-tag-title preBold">类型：</span>
                <span class="result-game-item-info-tag-title">历史小说</span>
            </p>

            <p class="result-game-item-info-tag">
                <span class="result-game-item-info-tag-title preBold">更新时间：</span>
                <span class="result-game-item-info-tag-title">2020-06-14</span>
            </p>

            <p class="result-game-item-info-tag">
                <span class="result-game-item-info-tag-title preBold">最新章节：</span>
                <a cpos="newchapter" href=" https://www.booktxt.com/28_28228/360514.html " class="result-game-item-info-tag-item" target="_blank"> 第二百六十七章 谈判 </a>
            </p>
        </div>
    </div>
</div>
```

```example1:
xpath:"//div[@class="result-game-item-pic"]/a:href"  
  
print : https://www.booktxt.com/28_28228/  

```

```example2:
xpath:"//div[@class="result-game-item-pic"]/a/img:src"  
  
print : https://www.booktxt.com/files/article/image/28/28228/28228s.jpg  
  
```  

```example3:
xpath:"//div[@class="result-game-item-detail"]/h3/a/span/text()"  

print : 小阁老

```

```example4:
xpath:"//div[@class="result-game-item-desc"]/text()"

print : 站在你面前的是：大明王朝的守护者，万历皇帝的亲密战友，内阁首辅的好儿子，人类文明史上最富有的人。控制吏部三十年的幕后黑手，宗藩制度的掘墓人，东林党口中的严世藩第二，张居正高呼不可战胜。海瑞的知己，徐渭...

```

```example5:
xpath:"//div[@class="result-game-item-info"]/p[1]/span[2]/text()"

print : 三戒大师

```

```example6:
xpath:"//div[@class="result-game-item-info"]/p[last()]/a/text()"

print : 第二百六十七章 谈判

```

第八日：
异步初体验，反复嵌套多重async/await有坑，应该用async/await进行io操作，回调可以用futrue进行表达。  
打通搜索页面和api

第九日：
优化UI占位图  
优化数据结构  
完成搜索页面菜单操作，预留多源切换口子  
完成搜索历史数据持久化  

第十日：
完成小说加入书架工作  
发现多层map嵌套的json  flutter支持不是很好  

第十一日：  
完成异步读取多个章节小说，dart异步有点意思

第十二日：
可能需要获取widget高度来适配小说详情页面分页面  

第十三日：  
完成切换章节预留接口，flutter获取页面高度需要考虑刘海屏和全面屏，适配有坑！  
更新章节名提示和切页提示

第十四日：  
完成小说连续阅读  

目前已知需要优化的点：
+ 连续阅读除了缓存未读，还需要缓存部分已读，加速回到上一章的体验
+ 阅读返回书架时，书架及时更新
+ 切换书源包括书源json化，以及多个书源相关api修改

第十五日:
完成选择指定章节
阅读返回书架时，书架及时更新阅读记录

第十六日：  
完成多书源并行工作  
完成书源列表页，起步书源的增删改查还是要自己利用xpath完成第一批，所以暂时放松书源管理
着重完善书源采集

第十七日：  
完成多书源新增书源 --- 考虑搜索api表单令牌处理

第十八日：  
新增xpath 规则 position函数  
新增一个书源  
修复一个html库不支持css选择器多种选择方式引发的bug  
着手修改搜索为多源操作

第十九日：
完成搜索页面多源切换功能，以及后续阅读页面阅读源更替。  
后续将拓展阅读页面换源  

第二十日：
朋友反馈1.0：  
目录检索需要优化  
章节列表应该具备倒序显示功能  
阅读页面需要去掉头部导航更清爽（就要考虑点击显示顶部或底部菜单栏）  

自我反思：  
章节名（可能重复）作为阅读记录不合理，遇到重复章节名恰好为存档点可能引发存储问题，需要增加阅读章节数字段双重校验
书源添加需要自己做一套工具才行，Android studio 调试面板无法全部显示当前json书源（最后处理，如果不处理也没关系，一般五个书源就够用了，重在优化用户体验）  
启动app应刷新书架书籍,显示未读章节数,第一次启动app应自行加载资源库内的书源。  
阅读页面添加换源操作

今日完成：  
存储增加阅读章节数字段  
启动app应刷新书架书籍,显示未读章节数,第一次启动app应自行加载资源库内的书源。  
阅读页面添加换源操作  