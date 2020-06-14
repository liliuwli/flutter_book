# flutter_book
一款可以自定义来源阅读网络内容的工具

第一日：
完成dark语言flutter UIdemo

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
+ 通过查看dark路由 pushNamed 实现，声明需要传递参数的结构体并传参

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