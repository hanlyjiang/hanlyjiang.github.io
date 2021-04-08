# 理解Android矩阵变换

> 原文链接：[Understanding Android Matrix transformations-Maria Neumayer](https://medium.com/a-problem-like-maria/understanding-android-matrix-transformations-25e028f56dc7)

![Image for post](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210301100933.jpeg)

之前在学校学习矩阵，现在已经忘得差不多了，不过我记得当时一直有个疑问：这个东西到底可以做什么呢？

工作以后，从事Android开发，使用ImageView的scaleType时，发现其中有一种类型是matrix-矩阵。不过之前我一直都使用的其他scaleType类型，没有使用matrix缩放类型（因为不了解matrix）；不过几周前，我要实现一个功能，组件的背景图像应与视图的左上角对齐，但是不需执行任何缩放，效果就是下面这种： 

![Image for post](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210301101135.png)

于是我又一一尝试了各种scaleType的值，希望找到之前没有注意到的但是能解决当前问题的，不过只有使用 `scaleType="matrix"` 的时候实现了我想要的效果；于是我决定花点时间搞清楚：为什么matrix能实现我需要的效果，matrix的scaleType是如何工作的？

首先，我查看了matrix的文档

> *The Matrix class holds a 3x3 matrix for transforming coordinates.*

很显然，上面这句话提供不了太多有用的信息。 我发现很多人都像我一样对matrix感到疑惑，幸运的是我找到了 [Arnaud Bos](https://twitter.com/arnaud_bos) 写的一篇 [文章](http://i-rant.arnaudbos.com/matrices-for-developers/) ，详细解释了背后的数学原理。因为涉及到太多数学知识，这篇文章可能有点难懂，不过实际上即使不了解背后的数学原理，我们也依然可以用好matrix。

## 如何使用matrix？

当给 `ImageView`设置了 `scaleType="matrix"` 属性之后，还需通过代码设置 `imageMatrix` :

```
imageView.imageMatrix = Matrix().apply {
    // perform transformations
}
```

接下来，我们就可以通过matrix执行一系列的变换操作，matrix支持多种不同的变换，如：`translate-平移`, `scale-缩放`,`rotate-旋转` 和 `skew-变形及透视`。其中大部分的变换实际上都可以用于view, animation 和 canvas。

通过文档可以发现，每种变换都有 `set`, `pre` 和 `post` 三个版本。后面我会一一介绍这些，现在我们先专注于`set`版本的变换方法。

So what can we do?

## Translating-移动

![Image for post](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210301101018.gif)

设置 translation 意味着将图片移动到不同的位置。 要实现这种变换，我们只需要调用`Matrix` 的 `setTranslate` 方法，并传递期望的 `x` 和 `y` 坐标 :

```kotlin
val dWidth = imageView.drawable.intrinsicWidth
val dHeight = imageView.drawable.intrinsicHeight

val vWidth = imageView.measuredWidth
val vHeight = imageView.measuredHeight
setTranslate(
    round((vWidth - dWidth) * 0.5f),
    round((vHeight - dHeight) * 0.5f)
)
```

上面的示例代码中，我们将drawable放置在了View的中心, 产生的效果和在`ImageView`上设置 `scaleType="center"`一样 . 我们看下 `ImageView` 上使用 matrix 如何实现:

```kotlin
mDrawMatrix.setTranslate(Math.round((vwidth - dwidth) * 0.5f),
                         Math.round((vheight - dheight) * 0.5f));
```

以上代码使用matrix实现了相同的效果。

## Scaling

![Image for post](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210301101036.gif)

Scaling 定义了图片的大小。 你可以用两个值分别定义x轴和y轴上的缩放，另外还可以设置一个缩放的轴点（pivot point）。

轴点是变换过程中保持不变的点，默认情况下将使用`0, 0` 及左上顶点作为轴点，也就是说默认情况下，图像将会向右方和下方伸缩，而左上方保持不变；（参考上面坐边的动画 ）

如果想让图片从中间开始缩放(效果如右边的动画), 可以使用类似下方的代码将轴点设置为图片中心；

```kotlin
setScale(0.5f, 0.5f, dWidth / 2f, dHeight / 2f)
```

上面的代码将会从图片中点把图片缩放到其原始大小的一半。如果你需要的就是从左上顶点缩放图片，那么可以省略后面两个参数；

```kotlin
setScale(0.5f, 0.5f)
```

实际上通过scaling还可以实现更多有趣的效果，如：如果setScale时提供负值，则可以让图片围绕轴线镜像翻转；

![Image for post](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210301101052.gif)

## Rotation-旋转

![Image for post](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210301101103.gif)

上面就是旋转的效果，setRotate需要提供一个旋转的角度和一个可选的 pivot 点；

```
setRotate(45f, dWidth / 2f, dHeight / 2f)
```

以上示例代码将使图片围绕其中心点旋转45度角；如果将角度设置为-45，则图片会向左旋转；

## Skewing-偏斜

![Image for post](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210301101314.gif)

Skewing的效果可能并不常见（如上gif图所示），Skewing 使沿着一个轴或者两个轴拉伸图像。下面的示例展示了Matrix的setSkew的用法：

```
setSkew(1f, 0f, dWidth / 2f, dHeight / 2f)
```

以上方法将会在x轴方向上围绕着图片的中点拉伸图像，拉升的比例为1（拉长距离为图片的宽度），看起来的效果就是上面的gif图，图片倾斜了45度。

## 应用多种变换

现在我们单独应用了translate，scale，rotate及skew等方法到图像上，但是如果我们需要其中的几种效果，如何将他们一起应用到图像上呢？你可能会想，我们多次调用matrix的不同的set方法就可以，但是多次调用set方法的结果是，最终只有最后一个set方法的变换会生效，所有之前的变换都会被最后一个覆盖；这是因为set方法实质上是重置矩阵。 

实际上，我们之前提到过，每种变换都有三个变体方法，除了`set`之外，一种变换还有对应的 `pre` 及`post`方法，使用这两个方法我们就可以将多个效果结合到一起。

那么 `pre` 及 `post` 的区别是什么呢？

首先，无论使用三个方法的哪一个，都不会影响第一个变换；不过会影响后续的变换，不同的方法，对后续变换的影响不同；

假设我们想要将图片平移到View的中间，并且缩放到一半大小，以下两个版本的代码都能实现我们需要的效果：

```kotlin
val drawableLeft = round((vWidth - dWidth) * 0.5f)
val drawableTop = round((vHeight - dHeight) * 0.5f)

// 版本一
setTranslate(drawableLeft, drawableTop)
val (viewCenterX, viewCenterY) = vWidth / 2f to vHeight / 2f
postScale(0.5f, 0.5f, viewCenterX, viewCenterY)

// 版本二
setTranslate(drawableLeft, drawableTop)
val (drawableCenterX, drawableCenterY) = dWidth / 2f to dHeight / 2f
preScale(0.5f, 0.5f, drawableCenterX, drawableCenterY)
```

注意，在第一个版本中，我们使用了 `postScale` 并传入了View的中心点作为参数，但是在第二个版本中，我们使用了`preScale`但使用drawable的中心点作为参数；

那么，他们是怎么工作的呢？背后的数学背景可以通过阅读 [Arnauld Bos 的文章](http://i-rant.arnaudbos.com/2d-transformations-android-java/#ambiguous)来详细了解。

不过，在我们当下的情景中，这意味着什么呢？

* 使用 `postScale` 时，缩放变换将会在平移变换被应用之后才应用；因为图像已经居中了，所以我们可以直接使用View的中点作为pivot。

```kotlin
val (viewCenterX, viewCenterY) = vWidth / 2f to vHeight / 2f
postScale(0.5f, 0.5f, viewCenterX, viewCenterY)
```

* 当使用 `preScale`时， 缩放变换将会在平移之前被应用，在这种情况下，图片依然被放置于`0,0`，所以我们需要使用drawable的中心点作为缩放的pivot。

```kotlin
val (drawableCenterX, drawableCenterY) = dWidth / 2f to dHeight / 2f
preScale(0.5f, 0.5f, drawableCenterX, drawableCenterY)
```

现在，让我们从头开始回顾最初的示例-为什么应用scaleType =“ matrix”简单有效？ 在默认矩阵的情况下，scale将为1，平移，旋转和偏斜将为0，因此图像将绘制在左上角。所以它正是我所需要的！下次当其他scale类型无法按你所需要的方式放置图像时，可以尝试一下矩阵！ 