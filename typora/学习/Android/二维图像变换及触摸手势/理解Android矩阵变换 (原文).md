# [Understanding Android Matrix transformations](https://medium.com/a-problem-like-maria/understanding-android-matrix-transformations-25e028f56dc7)

[![Maria Neumayer](https://miro.medium.com/fit/c/96/96/1*uSF1d9WvS9zGy2xTiPFAgg.jpeg)](https://medium.com/@marianeum?source=post_page-----25e028f56dc7--------------------------------)

[Maria Neumayer](https://medium.com/@marianeum?source=post_page-----25e028f56dc7--------------------------------)Follow

[Nov 28, 2018](https://medium.com/a-problem-like-maria/understanding-android-matrix-transformations-25e028f56dc7?source=post_page-----25e028f56dc7--------------------------------) · 7 min read

![Image for post](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210301100933.jpeg)

Many years ago in school I was learning about matrices. I don’t remember much of it, but what I do remember was thinking, “but… what do you actually *do* with that knowledge?”

Fast forward a few years and I started working as an Android Developer and had to work with `ImageView`'s `scaleType` — if you ever looked at all the [possible types](https://developer.android.com/reference/android/widget/ImageView.ScaleType) you’d have noticed that one of them is `matrix`. For many years I shied away from it, using the other scale types or working around the issue otherwise. However a few weeks ago I was working on a design where the background image of a component should be aligned to the top-left of the view, without performing any scaling, like this:

![Image for post](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210301101135.png)

So I went ahead and added an `ImageView` and went through all the scale types again — hoping there was a type I missed, but none of them was quite right until I tried `scaleType="matrix"` and it did exactly what I wanted. But *why* is this working? What does it actually *do*?

So I had a look at the matrix documentation:

> *The Matrix class holds a 3x3 matrix for transforming coordinates.*

Well… not very helpful. Luckily I wasn’t the only one lost with this and [Arnaud Bos](https://twitter.com/arnaud_bos) wrote a great [article](http://i-rant.arnaudbos.com/matrices-for-developers/) explaining the maths behind it in detail (warning: if you’re planning on reading it — get a coffee (or two) beforehand). If you get lost halfway through that article I can’t blame you — it’s quite complicated, but the good news is that you don’t *really* have to understand the maths to understand what you can do with the matrix (although it can help).

## How can we use the matrix?

As I mentioned before we have to set `scaleType="matrix"` on the `ImageView`. But to really be able to make use of it we have to set the `imageMatrix` in code:

```
imageView.imageMatrix = Matrix().apply {
    // perform transformations
}
```

Now that we have this — what can we do with it? The matrix supports a bunch of different transformations like `translate`, `scale`,`rotate` and `skew`. If those sound familiar it’s because they’re (mostly) the same as on a view, an animation or the canvas.

You’ll find that for each of these operations there’s a `set`, `pre` and `post` version. I’ll get to that a bit later, but for now we’ll just use the `set` version.

So what can we do?

## Translating

![Image for post](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210301101018.gif)

Setting the translation means moving the image to a different location. All you have to do is call `setTranslate` with the desired `x` and `y` coordinates on the `Matrix`:

```
val dWidth = imageView.drawable.intrinsicWidth
val dHeight = imageView.drawable.intrinsicHeight

val vWidth = imageView.measuredWidth
val vHeight = imageView.measuredHeightsetTranslate(
    round((vWidth - dWidth) * 0.5f),
    round((vHeight - dHeight) * 0.5f)
)
```

In this example we’re just centring the drawable in the View, which results in the same behaviour as setting `scaleType="center"` on an `ImageView`. So let’s take a look at how `ImageView` does this:

```
mDrawMatrix.setTranslate(Math.round((vwidth - dwidth) * 0.5f),
                         Math.round((vheight - dheight) * 0.5f));
```

It’s exactly the same! So without knowing it we’ve already been using matrix transformations.

## Scaling

![Image for post](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210301101036.gif)

Scaling (as you might’ve guessed by the name) defines the size of the image. You can define two values — one for the x-axis and the other for the y-axis. But with scale you can also set a pivot point.

The pivot point defines which point will be unchanged by the transformation. By default it is at `0, 0` — the top-left point — meaning the image will stretch to the right and bottom, leaving the top-left unchanged — just like in the above gif on the left.

If you want to scale the image from the centre (like the gif on the right), you can set the pivot to the centre of the image, like this:

```
setScale(0.5f, 0.5f, dWidth / 2f, dHeight / 2f)
```

This will scale the image to half of its size with a pivot point of its centre. If you want to just scale it from the top-left you can just omit the last two parameters, like this:

```
setScale(0.5f, 0.5f)
```

But there’s more you can do with scaling. If you provide negative scale values you can essentially mirror the image around an axis (or two). Quite nifty!

![Image for post](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210301101052.gif)

## Rotation

![Image for post](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210301101103.gif)

You guessed right! With rotation you can rotate the image. Here we provide the angle we want to rotate by, as well as an optional pivot point, similar to scale.

```
setRotate(45f, dWidth / 2f, dHeight / 2f)
```

This will rotate the image by 45 degrees around the centre of the image. If you rotate it by -45 degrees it’ll rotate to the left.

## Skewing

![Image for post](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210301101314.gif)

Skewing might be the transformation you haven’t heard of before. Skewing will kind of stretch your image along an axis (or two), like in the gif above. Let’s look at an example:

```
setSkew(1f, 0f, dWidth / 2f, dHeight / 2f)
```

This will skew the image across the x-axis (and around the centre point) by 1, which is the width of the image, resulting in a 45 degree tilt of the image, like in the gif above.

## Applying multiple transformations

We can now translate, scale, rotate and skew images, but what if we want to combine them? The obvious thing might be calling multiple `set` methods in a row. This, however, will only apply the last transformation — all the previous ones will be overwritten. This is because the `set` method essentially resets the matrix.

But as I mentioned before there’s also a `pre` and `post` version of each transformation. By using these we can apply multiple transformations and really make use of the magic of the matrix.

But what’s the difference between `pre` and `post`? For the first transformation it makes no difference which of the three versions to use, but for any future transformation it can make a big difference.

Let’s say we want to translate an image to the centre of the view and scale it to half the size. These two versions will result in the desired effect:

```
val drawableLeft = round((vWidth - dWidth) * 0.5f)
val drawableTop = round((vHeight - dHeight) * 0.5f)// Version 1
setTranslate(drawableLeft, drawableTop)
val (viewCenterX, viewCenterY) = vWidth / 2f to vHeight / 2f
postScale(0.5f, 0.5f, viewCenterX, viewCenterY)// Version 2
setTranslate(drawableLeft, drawableTop)
val (drawableCenterX, drawableCenterY) = dWidth / 2f to dHeight / 2f
preScale(0.5f, 0.5f, drawableCenterX, drawableCenterY)
```

Note that in the first version we use `postScale` and the centre of the *view*, whereas in the second version we use `preScale` and the centre of the *drawable*.

So how does that work? The maths behind this is described by Arnauld Bos in a [follow up article](http://i-rant.arnaudbos.com/2d-transformations-android-java/#ambiguous). But what does it mean in this case?

With `postScale` the scale transformation will be applied *after* the translation. As the image is already centred in the view we have to use the *view’s* centre point as the pivot.

```
val (viewCenterX, viewCenterY) = vWidth / 2f to vHeight / 2f
postScale(0.5f, 0.5f, viewCenterX, viewCenterY)
```

When using `preScale` the scale transformation will be applied *before* the translation. At this point the image will still be positioned at `0, 0` and we have to use the centre point of the *drawable*.

```
val (drawableCenterX, drawableCenterY) = dWidth / 2f to dHeight / 2f
preScale(0.5f, 0.5f, drawableCenterX, drawableCenterY)
```

So looking back at the example from the beginning — why does applying the `scaleType="matrix"` simply work? Well with a default matrix the scale will be 1, the translation, rotation and skew will be 0, therefore the image will be drawn at the top left corner. So it does exactly what I needed!

Next time you have to lay out an image in a way where the default scale types don’t work — give the matrix a try!