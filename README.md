title: 从一个预加载动画想起
date: 2016-09-08 16:27:45
tags:
	- iOS
categories:
	- iOS Tips
	
---

魔兽开了 "军团再临"，iPhone 7 也发布了。算下来好久没写博客了，又疏于学习了。

公司项目的新版本 on the way。前几日给新版本做了个下拉刷新动画，模仿了 `Enjoy` 的下拉刷新。效果如图

![效果如图](http://7xie11.com1.z0.glb.clouddn.com/refresh.gif)

既然做了下拉刷新，当页面第一进入，也应当有个预加载的动画。这样当数据加载完成，将这个预加载动画隐藏掉，用户体验会好很多。于是又搞了一个预加载动画，如下

![预加载](http://7xie11.com1.z0.glb.clouddn.com/preload.gif)

## 动画实现简单总结

### 下拉刷新动画

下拉刷新的动画，在多次观察了 `Enjoy` 的动画之后，起初认为可以通过修改 `CAShapeLayer` 的 `lineWidth` 属性来实现圆环由粗变细的效果。在第一次尝试了使用该方法后，发现效果并不理想，而且在快速上下拖动 `table view` 的情况下，圆会出现漂移的情况。

由于圆由小变大的效果，已经完成了，想到了使用相同的方法，在原有的圆上面添加一个 `view`，把这个 `view` 的背景色设置成下拉区域背景色，就可以得到一种圆环变化的假象，如下图所示

![示意](http://7xie11.com1.z0.glb.clouddn.com/refresh.png)

通过 Reveal 直观的看一下

![Reveal](http://7xie11.com1.z0.glb.clouddn.com/reveal.png)

根据 `table view` 下拉的距离计算出底层圆和上层圆的 size。实时重绘 layer 的 path 的就行了

### 预加载动画

预加载动画，拆解下来就是一个上下跳动的图片加上一个宽度随跳动状态变化的阴影图片。

使用 `CABasicAnimation` 制作一种状态的动画，通过 `CAAnimationGroup` 进行动画的组装。

例如上下跳动动画的实现代码，如下

	let upAnimation = CABasicAnimation(keyPath: "position.y")
	upAnimation.fromValue = self.markedImageView!.center.y
	upAnimation.toValue = self.markedImageView!.center.y - JESRefreshIconConstants.maxOffsetY
	upAnimation.duration = JESRefreshIconConstants.jumpDuration
	upAnimation.beginTime = 0
	upAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
	let downAnimation = CABasicAnimation(keyPath: "position.y")
	downAnimation.fromValue = self.markedImageView!.center.y - JESRefreshIconConstants.maxOffsetY
	downAnimation.toValue = self.markedImageView!.center.y
	downAnimation.duration = JESRefreshIconConstants.downDuration
	downAnimation.beginTime = JESRefreshIconConstants.jumpDuration
	downAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
	let animationGroup = CAAnimationGroup()
	animationGroup.animations = [upAnimation, downAnimation]
	animationGroup.duration = JESRefreshIconConstants.jumpDuration + JESRefreshIconConstants.downDuration
	animationGroup.beginTime = self.state.animationBeginTime()
	animationGroup.fillMode = kCAFillModeForwards
	animationGroup.repeatCount = Float.infinity
	animationGroup.removedOnCompletion = false
	animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
	self.markedImageView!.layer.addAnimation(animationGroup, forKey: "image.animation.key")

> 如果动画在 App 退至后台在进入前台之后动画停止了，请将 `removedOnCompletion` 设置成 false

阴影的动画与上下跳动动画类似，在此不再赘述。

### 动画完成之后对于使用的思考

完成了理想的效果，如何使用，就该好好考虑下了。在每一个需要用到的 VC 里写代码？这恐怕并不让人满意，重复写如此多的代码，确实让人心里有些许的别扭。想到了之前看到的 `SwiftGG` 翻译的一篇文章，[用 Swift 编写面向协议的视图](http://swift.gg/2016/06/01/protocol-oriented-views-in-swift/)

举一反三，为 table view 统一添加下拉刷新事件，原理文章中有讲，看代码

	typealias RefreshHandler = () -> Void

	protocol Refreshable { }

	extension Refreshable where Self: UIScrollView {
    
		func refresh(withActionHandler actionHandler: RefreshHandler) {
			let loadingView = JESPullToRefreshLoadingViewCircle(fillColor: UIColor(red: 224/255.0, green: 231/255.0, blue: 235/255.0, alpha: 1.0))
			loadingView.tintColor = UIColor.whiteColor()
        	self.jes_addPullToRefreshWithActionHandler(actionHandler, loadingView: loadingView, logoImage: "refresh_logo")
        	self.jes_setPullToRefreshFillColor(UIColor(red: 224/255.0, green: 231/255.0, blue: 235/255.0, alpha: 1.0))
        	self.jes_setPullToRefreshBackgroundColor(self.backgroundColor!)
    	}  
	}

	class JESPullToRefreshTableView: UITableView, Refreshable {
    
	}

这样让需要实现下拉刷新的 table view 继承资 `JESPullToRefreshTableView` 通过 

	tableView.refresh {
		// 下拉刷新后操作
	}
	
就可以实现下拉刷新操作。

预加载的动画，则选择使用 `UIViewController` 的 extension 来实现，首先需要定义一个私有的背景 view 用来覆盖原视图，放置动画视图
    
    private var loadingBgView: UIView? {
        get {
            return objc_getAssociatedObject(self, &Constants.loadingKey) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &Constants.loadingKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func showPreLoading(backgroundColor: UIColor = UIColor.whiteColor()) {
        if self.loadingBgView == nil {
            let loadingBgView = UIView(frame: self.view.bounds)
            self.loadingBgView = loadingBgView
            loadingBgView.backgroundColor = backgroundColor
            self.view.addSubview(loadingBgView)
            
            let loadingView = JESRefreshView(frame: CGRect(x: 0, y: 0, width: Constants.loadingWidth, height: Constants.loadingHeight))
            loadingView.center = CGPoint(x: self.view.bounds.width / 2.0, y: (self.view.bounds.height - Constants.loadingHeight) / 2.0)
            
            loadingBgView.addSubview(loadingView)
            
            loadingView.animate()
        }
    }
    
    public func dismissPreLoading() {
        // Remove Animation and background view
        UIView.animateWithDuration(0.375, animations: {
            self.loadingBgView?.alpha = 0.0
        }) { _ in
            self.loadingBgView?.removeFromSuperview()
            self.loadingBgView = nil
        }
    }

这样就实现了为每一个 vc 添加预加载动画了。

