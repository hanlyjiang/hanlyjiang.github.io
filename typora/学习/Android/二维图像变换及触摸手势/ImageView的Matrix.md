# ImageView的Matrix

## ImageView的matrix如何影响drawable？

ImageView有个 Matrix：

* `setImageMatrix`

* `getImageMatrix`

  这个Matrix是如何与Canvas联合起来对ImageView产生影响的呢？

```java
private void configureBounds() {
        if (mDrawable == null || !mHaveFrame) {
            return;
        }
		// 获取图像的宽度
        final int dwidth = mDrawableWidth;
        // 获取图像的高度
        final int dheight = mDrawableHeight;

        // 获取视图的宽度
        final int vwidth = getWidth() - mPaddingLeft - mPaddingRight;
        // 视图高度区域
        final int vheight = getHeight() - mPaddingTop - mPaddingBottom;
		// drawable宽高和view宽高正好相等，或者无法获取到drawable的宽高
        final boolean fits = (dwidth < 0 || vwidth == dwidth)
                && (dheight < 0 || vheight == dheight);

        if (dwidth <= 0 || dheight <= 0 || ScaleType.FIT_XY == mScaleType) {
            /* If the drawable has no intrinsic size, or we're told to
                scaletofit, then we just fill our entire view.
            */
            mDrawable.setBounds(0, 0, vwidth, vheight);
            mDrawMatrix = null;
        } else {
            // We need to do the scaling ourself, so have the drawable
            // use its native size.
            // 设置drawable的绘制区域
            mDrawable.setBounds(0, 0, dwidth, dheight);

            if (ScaleType.MATRIX == mScaleType) {
                // Use the specified matrix as-is.
                if (mMatrix.isIdentity()) {
                    // 如果是单位矩阵
                    mDrawMatrix = null;
                } else {
                    mDrawMatrix = mMatrix;
                }
            } else if (fits) {
                // The bitmap fits exactly, no transform needed.
                mDrawMatrix = null;
            } else if (ScaleType.CENTER == mScaleType) {
                // Center bitmap in view, no scaling.
                // 居中展示
                mDrawMatrix = mMatrix;
                mDrawMatrix.setTranslate(Math.round((vwidth - dwidth) * 0.5f),
                                         Math.round((vheight - dheight) * 0.5f));
            } else if (ScaleType.CENTER_CROP == mScaleType) {
                mDrawMatrix = mMatrix;

                float scale;
                float dx = 0, dy = 0;
				// 判断哪个方向需要拉满
                if (dwidth * vheight > vwidth * dheight) {
                    scale = (float) vheight / (float) dheight;
                    dx = (vwidth - dwidth * scale) * 0.5f;
                } else {
                    scale = (float) vwidth / (float) dwidth;
                    dy = (vheight - dheight * scale) * 0.5f;
                }
				// set 会重制，所以需要再执行translate
                mDrawMatrix.setScale(scale, scale);
                mDrawMatrix.postTranslate(Math.round(dx), Math.round(dy));
            } else if (ScaleType.CENTER_INSIDE == mScaleType) {
                mDrawMatrix = mMatrix;
                float scale;
                float dx;
                float dy;

                if (dwidth <= vwidth && dheight <= vheight) {
                    scale = 1.0f;
                } else {
                    scale = Math.min((float) vwidth / (float) dwidth,
                            (float) vheight / (float) dheight);
                }

                dx = Math.round((vwidth - dwidth * scale) * 0.5f);
                dy = Math.round((vheight - dheight * scale) * 0.5f);

                mDrawMatrix.setScale(scale, scale);
                mDrawMatrix.postTranslate(dx, dy);
            } else {
                // Generate the required transform.
                mTempSrc.set(0, 0, dwidth, dheight);
                mTempDst.set(0, 0, vwidth, vheight);

                mDrawMatrix = mMatrix;
                mDrawMatrix.setRectToRect(mTempSrc, mTempDst, scaleTypeToScaleToFit(mScaleType));
            }
        }
    }
```

从代码中可以看到，其他很多缩放类型实际上底下也是使用matrix变换来实现的。以上只是为matrix设置了变换，那么这个`mDrawMatrix`到底如何和绘制过程关联起来了？

```java
@Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        if (mDrawable == null) {
            return; // couldn't resolve the URI
        }

        if (mDrawableWidth == 0 || mDrawableHeight == 0) {
            return;     // nothing to draw (empty bounds)
        }
		// 没有drawMatrix且没有Padding的情况下，直接绘制
        if (mDrawMatrix == null && mPaddingTop == 0 && mPaddingLeft == 0) {
            mDrawable.draw(canvas);
        } else {
            final int saveCount = canvas.getSaveCount();
            canvas.save();

            if (mCropToPadding) {
                final int scrollX = mScrollX;
                final int scrollY = mScrollY;
                canvas.clipRect(scrollX + mPaddingLeft, scrollY + mPaddingTop,
                        scrollX + mRight - mLeft - mPaddingRight,
                        scrollY + mBottom - mTop - mPaddingBottom);
            }

            canvas.translate(mPaddingLeft, mPaddingTop);

            if (mDrawMatrix != null) {
            // 应用mDrawMatrix 
                canvas.concat(mDrawMatrix);
            }
            mDrawable.draw(canvas);
            canvas.restoreToCount(saveCount);
        }
    }
```

可以看到，最终绘制的时候，是通过 `canvas.concat(mDrawMatrix)` 来应用`mDrawMatrix`的效果的，**所以实际上Matrix是应用于canvas上**。

> 虽然后续使用呢 `mDrawable.draw(canvas)` 来使用canvas，但是继续查找任意一种特定类型Drawable实现查看其源码，可以发现并为对前期的效果做修改。（实际上由于drawable是一个抽象类，而其子类众多，所以为了能让matrix的效果一致的应用到各个子类上，子类的实现中定不能有决定性使用matrix的实现逻辑）



通过上述源码分析，我们基本可以确认，ImageView的ImageMatrix最终是作用于视图的 canvas 上的。

##  `ImageMatrix` 执行平移变换时，应该如何传递 `dx` 和 `dy` 呢？



### 如何将Drawable在ImageView中居中展示

实际上，从源码中我可以看到，将图片使用centerInside居中显示时，使用的也是Matrix来实现的，具体代码如下：

```java
else if (ScaleType.CENTER_INSIDE == mScaleType) {
    mDrawMatrix = mMatrix;
    float scale;
    float dx;
    float dy;

    if (dwidth <= vwidth && dheight <= vheight) {
    	scale = 1.0f;
    } else {
        scale = Math.min((float) vwidth / (float) dwidth,
        (float) vheight / (float) dheight);
    }

    dx = Math.round((vwidth - dwidth * scale) * 0.5f);
    dy = Math.round((vheight - dheight * scale) * 0.5f);

    mDrawMatrix.setScale(scale, scale);
    mDrawMatrix.postTranslate(dx, dy);
}
```

可见，实际上执行了两次matrix的变换方法：1）缩放；2）平移；

我们手动将这两个过程分开说明：

* **缩放**

  缩放过程中

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210303102743.gif" alt="ImageView变换" style="zoom:67%;" />

* **平移**

  <img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210303202648.gif" alt="ImageView变换-平移" style="zoom:67%;" />

  <img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210303114347.png" alt="image-20210303114347279" style="zoom:67%;" />

  平移的dy如上图所示，顶部浅色的 <a style="background:#E4C2B1">  </a> 为平移前的，深色的 <a style="background:#EF6F65">  </a> 平移之后的，那么y轴方向的平移距离`dy`为 
  $$
  dy = viewHeight/2 - drawableHeight*scale/2 \\
     = (viewHeight - drawableHeight*scale) * 0.5f
  $$

## PhotoView的源码分析

### `getDisplayRect`

getDisplayRect 用于获取图片的真正显示区域

```kotlin
    public RectF getDisplayRect() {
        checkMatrixBounds();
        return getDisplayRect(getDrawMatrix());
    }
```

checkMatrixBounds方法：

```java
    private boolean checkMatrixBounds() {
        // 获取如果应用matrix之后，drawable的显示需要的容纳矩形
        final RectF rect = getDisplayRect(getDrawMatrix());
        if (rect == null) {
            return false;
        }
        // 获取容纳矩形的高和宽
        final float height = rect.height(), width = rect.width();
        float deltaX = 0, deltaY = 0;
        // 获取ImageView的高
        final int viewHeight = getImageViewHeight(mImageView);
        // 如果Drawable应用matrix变换之后的高度比View的小
        if (height <= viewHeight) {
            switch (mScaleType) {
                    // 计算时，将DrawableRect移动到最终效果，然后根据重叠关系进行计算
                case FIT_START: //top
                    deltaY = -rect.top; // Drawable的 top 需要和View的Top对齐，所以deltaY=-rect.top ,可参考下方图片
                    break;
                case FIT_END: // bottom ，drawable的bottom需要和View的bottom对齐，
                    deltaY = viewHeight - height - rect.top;
                    break;
                default:
                    // 居中时Y方向要移动的距离
                    deltaY = (viewHeight - height) / 2 - rect.top;
                    break;
            }
            // 比视图高度小的时候，上下都可以滑动
            mVerticalScrollEdge = VERTICAL_EDGE_BOTH;
        } else if (rect.top > 0) { // drawable在view的top之下
            mVerticalScrollEdge = VERTICAL_EDGE_TOP;
            deltaY = -rect.top; // 往上移动即可
        } else if (rect.bottom < viewHeight) {
            // drawable bottom底部在View bottom之上
            mVerticalScrollEdge = VERTICAL_EDGE_BOTTOM;
            // Y方向的差距
            deltaY = viewHeight - rect.bottom;
        } else {
            mVerticalScrollEdge = VERTICAL_EDGE_NONE;
        }
        final int viewWidth = getImageViewWidth(mImageView);
        if (width <= viewWidth) {
            switch (mScaleType) {
                case FIT_START:
                    deltaX = -rect.left;
                    break;
                case FIT_END:
                    deltaX = viewWidth - width - rect.left;
                    break;
                default:
                    deltaX = (viewWidth - width) / 2 - rect.left;
                    break;
            }
            mHorizontalScrollEdge = HORIZONTAL_EDGE_BOTH;
        } else if (rect.left > 0) {
            mHorizontalScrollEdge = HORIZONTAL_EDGE_LEFT;
            deltaX = -rect.left;
        } else if (rect.right < viewWidth) {
            deltaX = viewWidth - rect.right;
            mHorizontalScrollEdge = HORIZONTAL_EDGE_RIGHT;
        } else {
            mHorizontalScrollEdge = HORIZONTAL_EDGE_NONE;
        }
        // Finally actually translate the matrix
        mSuppMatrix.postTranslate(deltaX, deltaY);
        return true;
    }
```

以上方法，主要是计算deltaX，deltaY，还有确定两个方向的滑动方式；

* deltaX： X方向的滑动增量；
* deltaY： Y方向的滑动增量；
* mHorizontalScrollEdge：水平方向滚动的边界（左，右，两边皆有滑动距离）
* mHorizontalScrollEdge：垂直方向滚动的边界（上，下，上下皆有滑动距离）

计算完毕之后，还使用postTranslate对Matrix进行了两个方向的平移，根据所需要的scaleType方式计算出平移的X，Y的值。

**`getDisplayRect(Matrix)`:**

`RectF` 代表一个矩形区域，右四个边界定义（left,top,right,bottom)

```java
    /**
     * Helper method that maps the supplied Matrix to the current Drawable
     *
     * @param matrix - Matrix to map Drawable against
     * @return RectF - Displayed Rectangle
     */
    private RectF getDisplayRect(Matrix matrix) {
        Drawable d = mImageView.getDrawable();
        if (d != null) {
            // 将mDisplayRect设置为drawable的原始大小对应的区域
            mDisplayRect.set(0, 0, d.getIntrinsicWidth(),
                d.getIntrinsicHeight());
            // 将矩阵的变换效果应用到DisplayRect上，应用之后的RECT效果即发生了改变
            matrix.mapRect(mDisplayRect);
            return mDisplayRect;
        }
        return null;
    }
```

变换之后的Rect 实际上是经历此变换之后，图片绘制所需要的最大矩形范围；如旋转-45度：`(0.0, 0.0, 100.0, 100.0)` -> `(0.0, -70.71068, 141.42136, 70.71068)`，如下图所示，深色的为旋转之后的，粗灰色边宽即为旋转应用之后的Rect：

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210303221353.png" alt="image-20210303221352982" style="zoom:45%;" />

### Fling的实现方式

```java
public void fling(int viewWidth, int viewHeight, int velocityX,
            int velocityY) {
		    //  计算Rect并调整suppMatrix的平移使符合声明的scaleType，不过Rect还是调整前的
            final RectF rect = getDisplayRect();
            if (rect == null) {
                return;
            }
    		// startX = Drawable的Rect的Left同View的Left对齐时需要移动的距离	
            final int startX = Math.round(-rect.left);
            final int minX, maxX, minY, maxY;
            if (viewWidth < rect.width()) {
                minX = 0;
                // drawable比View宽时，宽出的距离就是可设置的最大值
                maxX = Math.round(rect.width() - viewWidth);
            } else {
                // 否则，最大最小都一样，无法滑动
                minX = maxX = startX;
            }
	    	// startX = Drawable的Rect的Top同View的Top对齐时需要移动的距离
            final int startY = Math.round(-rect.top);
            if (viewHeight < rect.height()) {
                minY = 0;
                // drawble 比View高时，最大的值是高出的距离
                maxY = Math.round(rect.height() - viewHeight);
            } else {
                // drawble 比View低，最大最小都一样，无法滑动
                minY = maxY = startY;
            }
    		// 设置当前的起始点到全局变量
            mCurrentX = startX;
            mCurrentY = startY;
            // If we actually can move, fling the scroller
            if (startX != maxX || startY != maxY) {
                mScroller.fling(startX, startY, velocityX, velocityY, minX,
                    maxX, minY, maxY, 0, 0);
            }
        }

		@Override
        public void run() {
            if (mScroller.isFinished()) {
                return; // remaining post that should not be handled
            }
            if (mScroller.computeScrollOffset()) {
                // 获取计算出的值 minX <- newX <- startX -> newX -> maxX
                final int newX = mScroller.getCurrX();
                final int newY = mScroller.getCurrY();
                // 使用当前值 - 新值 以获取增量变换值
                mSuppMatrix.postTranslate(mCurrentX - newX, mCurrentY - newY);
                checkAndDisplayMatrix();
                // 更新当前值到最新
                mCurrentX = newX;
                mCurrentY = newY;
                // Post On animation
                // 更新视图显示
                Compat.postOnAnimation(mImageView, this);
            }
        }
```

