import 'package:flutter/material.dart';

class LoadingContainer extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final bool cover; // whether this widget is on top of child

  const LoadingContainer(
      {Key key,
      @required this.isLoading,
      this.cover = false,
      @required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return !cover
        ? !isLoading
            ? child
            : _loadingView
        : Stack(
            children: [child, isLoading ? _loadingView : null],
          );
  }

  Widget get _loadingView {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
