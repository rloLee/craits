import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  /// the child widget for the button, this will be ignored if text is supplied
  final Text child;

  /// onChange is called when the selected option is changed.;
  /// It will pass back the value and the index of the option.
  final void Function(dynamic, dynamic) onChange;

  /// list of DropdownItems
  final Map<dynamic, dynamic> items;
  final DropdownStyle dropdownStyle;

  /// dropdownButtonStyles passes styles to OutlineButton.styleFrom()
  final DropdownButtonStyle dropdownButtonStyle;
  final DropdownItemStyle dropdownItemStyle;

  /// dropdown button icon defaults to caret
  final Widget icon;
  final bool hideIcon;

  /// if true the dropdown icon will as a leading icon, default to false
  final bool leadingIcon;
  CustomDropdown({
    Key key,
    this.hideIcon = false,
    @required this.child,
    @required this.items,
    this.dropdownStyle = const DropdownStyle(),
    this.dropdownButtonStyle = const DropdownButtonStyle(),
    this.dropdownItemStyle = const DropdownItemStyle(),
    this.icon,
    this.leadingIcon = false,
    this.onChange,
  }) : super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown>
    with TickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry _overlayEntry;
  bool _isOpen = false;
  dynamic _currentIndex = -1;
  AnimationController _animationController;
  Animation<double> _expandAnimation;
  Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _rotateAnimation = Tween(begin: 0.0, end: 0.5).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    var style = widget.dropdownButtonStyle;
    return CompositedTransformTarget(
      link: this._layerLink,
      child: Container(
        child: MaterialButton(
          onPressed: _toggleDropdown,
          child: Row(
            mainAxisAlignment: style.mainAxisAlignment ?? MainAxisAlignment.center,
            children: [
              if (_currentIndex == -1) ...[
                widget.child,
              ] else ...[
                Text(widget.items[_currentIndex], style: style.textStyle,),
              ],
              if (!widget.hideIcon)
                RotationTransition(
                  turns: _rotateAnimation,
                  child: widget.icon ?? Icon(Icons.arrow_downward),
                ),
            ],
          ),
        ),
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    // find the size and position of the current widget
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    
    var offset = renderBox.localToGlobal(Offset.zero);
    var topOffset = offset.dy + size.height + 5;
    return OverlayEntry(
      // full screen GestureDetector to register when a
      // user has clicked away from the dropdown
      builder: (context) => GestureDetector(
        onTap: () => _toggleDropdown(close: true),
        behavior: HitTestBehavior.translucent,
        // full screen container to register taps anywhere and close drop down
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Positioned(
                left: offset.dx,
                top: topOffset,
                width: widget.dropdownStyle.width ?? size.width,
                child: CompositedTransformFollower(
                  offset: widget.dropdownStyle.offset ?? Offset(0, size.height + 5),
                  link: this._layerLink,
                  showWhenUnlinked: false,
                  child: Material(
                    elevation: widget.dropdownStyle.elevation ?? 0,
                    borderRadius: widget.dropdownStyle.borderRadius ?? BorderRadius.zero,
                    color: widget.dropdownStyle.color,
                    child: SizeTransition(
                      axisAlignment: 1,
                      sizeFactor: _expandAnimation,
                      child: ConstrainedBox(
                        constraints: widget.dropdownStyle.constraints ??
                          BoxConstraints(
                            maxHeight: widget.dropdownStyle.height ?? MediaQuery.of(context).size.height - topOffset - 15
                            // maxHeight: MediaQuery.of(context).size.height - topOffset - 100,
                          ),
                        child: Scrollbar(
                          child: ListView(
                            padding: widget.dropdownStyle.padding ?? EdgeInsets.zero,
                            shrinkWrap: true,
                            children: widget.items.keys.map((key) {
                              return InkWell(
                                onTap: () {
                                  if(key == '')
                                    setState(() => _currentIndex = -1);
                                  else
                                    setState(() => _currentIndex = key);
                                    widget.onChange(widget.items[key], key);
                                    _toggleDropdown();
                                  },
                                highlightColor: widget.dropdownItemStyle.highlightColor,
                                child: Container( 
                                  height: widget.dropdownItemStyle.height,
                                  child: Text(widget.items[key], style: widget.dropdownItemStyle.textStyle,), alignment: Alignment.centerLeft,),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleDropdown({bool close = false}) async {
    if (_isOpen || close) {
      await _animationController.reverse();
      this._overlayEntry.remove();
      setState(() {
        _isOpen = false;
      });
    } else {
      this._overlayEntry = this._createOverlayEntry();
      Overlay.of(context).insert(this._overlayEntry);
      setState(() => _isOpen = true);
      _animationController.forward();
    }
  }
}

// class DropdownItem<T> extends StatelessWidget {
//   final T value;
//   final Widget child;

//   const DropdownItem({Key key, this.value, this.child}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return child;
//   }
// }

class DropdownButtonStyle {
  final MainAxisAlignment mainAxisAlignment;
  final TextStyle textStyle;
  final ShapeBorder shape;
  final Color backgroundColor;
  final EdgeInsets padding;
  final BoxConstraints constraints;
  final Color primaryColor;
  const DropdownButtonStyle({
    this.mainAxisAlignment,
    this.textStyle,
    this.backgroundColor,
    this.primaryColor,
    this.constraints,
    this.padding,
    this.shape,
  });
}

class DropdownStyle {
  final BorderRadius borderRadius;
  final double elevation;
  final Color color;
  final EdgeInsets padding;
  final BoxConstraints constraints;

  /// position of the top left of the dropdown relative to the top left of the button
  final Offset offset;

  ///button width must be set for this to take effect
  final double width;

  final double height;

  const DropdownStyle({
    this.constraints,
    this.offset,
    this.width,
    this.height,
    this.elevation,
    this.color,
    this.padding,
    this.borderRadius,
  });
}

class DropdownItemStyle{

  final double height;
  final TextStyle textStyle;
  final Color highlightColor;
  
  const DropdownItemStyle({
    this.height,
    this.textStyle,
    this.highlightColor,
  });
}