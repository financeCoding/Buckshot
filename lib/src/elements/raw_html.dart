part of core_buckshotui_org;

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

/**
* Renders raw html to the browser.
*
* In xml, the [htmlString] property must be assigned to directly, not in node form:
*
* ### Good:
*     <rawhtml htmlstring='<div style="width:100px"></div>'></rawhtml>
*
* ### Bad:
*     <rawhtml>
*         <htmlstring>
*             <!-- won't render -->
*             <div></div>
*         </htmlstring>
*     </rawhtml>
*/
class RawHtml extends FrameworkElement
{
  /// A framework property representing the raw html string.
  FrameworkProperty<String> htmlString;

  RawHtml()
  {
    Browser.appendClass(rawElement, "rawhtml");

    _initRawHtmlProperties();
  }

  RawHtml.register() : super.register();
  makeMe() => new RawHtml();

  void _initRawHtmlProperties(){

    htmlString = new FrameworkProperty(
      this,
      "htmlString",
      propertyChangedCallback: (String value){
        rawElement.innerHTML = value.toString();
      });
  }

  void createElement(){
    rawElement = new DivElement();
  }
}
