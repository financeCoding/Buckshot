part of core_buckshotui_org;

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.
/**
* Enumrates supported binding modes in a [Binding]. */
class BindingMode
{
  final int _val;
  const BindingMode(this._val);
  
  /// Indicates a [Binding] where changes only flow in one direction.
  static const OneWay = const BindingMode(1);
  
  /// Indicates a [Binding] where changes flow in both directions.
  static const TwoWay = const BindingMode(2);
  
  /// Indicates a [Binding] that fires once and then unregisters automatically.
  static const OneTime = const BindingMode(3);
  
  String toString() {
    switch (_val){
    case 1:
      return "OneWay";
    case 2:
      return "TwoWay";
    case 3:
      return "OneTime";
    default:
      return "";
    }
  }
}
