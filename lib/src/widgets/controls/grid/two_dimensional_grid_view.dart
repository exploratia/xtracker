import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../model/column_profile/column_profile.dart';

// adjusted from https://dartpad.dev/?id=4424936c57ed13093eb389123383e894
class TwoDimensionalGridView extends TwoDimensionalScrollView {
  final int lineHeight;
  final ColumnProfile tableColumnProfile;
  final Key viewportSizeKey;
  final double bottomScrollExtend;

  TwoDimensionalGridView(
    this.lineHeight,
    this.tableColumnProfile,
    this.viewportSizeKey, {
    super.key,
    super.primary,
    super.mainAxis = Axis.vertical,
    required TwoDimensionalChildBuilderDelegate delegate,
    super.cacheExtent,
    super.diagonalDragBehavior = DiagonalDragBehavior.none,
    super.dragStartBehavior = DragStartBehavior.start,
    super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.clipBehavior = Clip.hardEdge,
    required ScrollController verticalController,
    required ScrollController horizontalController,
    this.bottomScrollExtend = 0,
  }) : super(
          delegate: delegate,
          verticalDetails: ScrollableDetails.vertical(controller: verticalController),
          horizontalDetails: ScrollableDetails.horizontal(controller: horizontalController),
        );

  @override
  Widget buildViewport(
    BuildContext context,
    ViewportOffset verticalOffset,
    ViewportOffset horizontalOffset,
  ) {
    return TwoDimensionalGridViewport(
      lineHeight,
      tableColumnProfile,
      key: viewportSizeKey,
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalDetails.direction,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalDetails.direction,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
      bottomScrollExtend: bottomScrollExtend,
    );
  }
}

class TwoDimensionalGridViewport extends TwoDimensionalViewport {
  final int lineHeight;
  final ColumnProfile tableColumnProfile;
  final double bottomScrollExtend;

  const TwoDimensionalGridViewport(
    this.lineHeight,
    this.tableColumnProfile, {
    super.key,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required TwoDimensionalChildBuilderDelegate super.delegate,
    required super.mainAxis,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
    this.bottomScrollExtend = 0,
  });

  @override
  RenderTwoDimensionalViewport createRenderObject(BuildContext context) {
    return RenderTwoDimensionalGridViewport(lineHeight, tableColumnProfile,
        horizontalOffset: horizontalOffset,
        horizontalAxisDirection: horizontalAxisDirection,
        verticalOffset: verticalOffset,
        verticalAxisDirection: verticalAxisDirection,
        mainAxis: mainAxis,
        delegate: delegate as TwoDimensionalChildBuilderDelegate,
        childManager: context as TwoDimensionalChildManager,
        cacheExtent: cacheExtent,
        clipBehavior: clipBehavior,
        bottomScrollExtend: bottomScrollExtend);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTwoDimensionalGridViewport renderObject,
  ) {
    renderObject
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..mainAxis = mainAxis
      ..delegate = delegate
      ..cacheExtent = cacheExtent
      ..clipBehavior = clipBehavior;
  }
}

class RenderTwoDimensionalGridViewport extends RenderTwoDimensionalViewport {
  final int lineHeight;
  final ColumnProfile tableColumnProfile;
  final double bottomScrollExtend;

  /// [bottomScrollExtend] additional empty space at the bottom of the scroll area
  RenderTwoDimensionalGridViewport(
    this.lineHeight,
    this.tableColumnProfile, {
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required TwoDimensionalChildBuilderDelegate delegate,
    required super.mainAxis,
    required super.childManager,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
    this.bottomScrollExtend = 0,
  }) : super(delegate: delegate);

  @override
  void layoutChildSequence() {
    final double horizontalPixels = horizontalOffset.pixels;
    final double verticalPixels = verticalOffset.pixels;
    final double viewportWidth = viewportDimension.width + cacheExtent;
    final double viewportHeight = viewportDimension.height + cacheExtent;
    final TwoDimensionalChildBuilderDelegate builderDelegate = delegate as TwoDimensionalChildBuilderDelegate;

    final int maxRowIndex = builderDelegate.maxYIndex!;
    final int maxColumnIndex = builderDelegate.maxXIndex!;

    int leadingColumnIdx = 0;
    int trailingColumnIdx = maxColumnIndex;

    double summedColumnPixels = 0;
    for (var tableColumn in tableColumnProfile.columns) {
      if (summedColumnPixels < horizontalPixels + viewportWidth) {
        trailingColumnIdx++;
      }
      summedColumnPixels += tableColumn.minWidthScaled;
      if (summedColumnPixels < horizontalPixels) {
        leadingColumnIdx++;
      }
    }
    trailingColumnIdx = math.min(maxColumnIndex, trailingColumnIdx);

    final int leadingRow = math.max((verticalPixels / lineHeight).floor(), 0);
    final int trailingRow = math.min(
      ((verticalPixels + viewportHeight) / lineHeight).ceil(),
      maxRowIndex,
    );

    double leadingColumnPixels = 0;
    for (var idx = 0; idx < leadingColumnIdx; ++idx) {
      leadingColumnPixels += tableColumnProfile.getColumnAt(idx).minWidthScaled;
    }

    double xLayoutOffset = leadingColumnPixels - horizontalOffset.pixels;
    for (int columnIdx = leadingColumnIdx; columnIdx <= trailingColumnIdx; columnIdx++) {
      double yLayoutOffset = (leadingRow * lineHeight) - verticalOffset.pixels;
      for (int row = leadingRow; row <= trailingRow; row++) {
        final ChildVicinity vicinity = ChildVicinity(xIndex: columnIdx, yIndex: row);
        final RenderBox child = buildOrObtainChildFor(vicinity)!;
        child.layout(constraints.loosen());

        // Subclasses only need to set the normalized layout offset. The super
        // class adjusts for reversed axes.
        parentDataOf(child).layoutOffset = Offset(xLayoutOffset, yLayoutOffset);
        yLayoutOffset += lineHeight;
      }
      xLayoutOffset += tableColumnProfile.getColumnAt(columnIdx).minWidthScaled;
    }

    // Set the min and max scroll extents for each axis.
    final double verticalExtent = lineHeight * (maxRowIndex + 1) + bottomScrollExtend;
    verticalOffset.applyContentDimensions(
      0.0,
      clampDouble(verticalExtent - viewportDimension.height, 0.0, double.infinity),
    );

    final double horizontalExtent = tableColumnProfile.minWidthScaled().toDouble();
    horizontalOffset.applyContentDimensions(
      0.0,
      clampDouble(horizontalExtent - viewportDimension.width, 0.0, double.infinity),
    );
    // Super class handles garbage collection too!
  }
}
