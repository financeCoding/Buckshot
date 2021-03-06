part of core_buckshotui_org;

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.


/**
 * Event arguments for drag events
 */
class DragEventArgs extends RoutedEventArgs
{
  Clipboard _dataTransfer;

  DragEventArgs(this._dataTransfer);

  Clipboard get dataTransfer => _dataTransfer;
}
