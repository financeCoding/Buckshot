//   Copyright (c) 2012, John Evans & LUCA Studios LLC
//
//   http://www.lucastudios.com/contact
//   John: https://plus.google.com/u/0/115427174005651655317/about
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

#import('dart:html');

#import('../../../src/dart/client/testing/unittest/unittest_html.dart');

#import('../core/Buckshot.dart');

#source('InitializationTests.dart');
#source('FrameworkFundamentalsTests.dart');
#source('FrameworkPropertyTests.dart');
#source('FrameworkElementTests.dart');
#source('BindingTests.dart');
#source('BorderTests.dart');
#source('ButtonTests.dart');
#source('ControlTests.dart');
#source('FrameworkEventTests.dart');
#source('FrameworkExceptionTests.dart');
#source('FrameworkObjectTests.dart');
#source('LayoutCanvasTests.dart');
#source('ObservableListTests.dart');
#source('PanelTests.dart');
#source('StackPanelTests.dart');
#source('TextBlockTests.dart');
#source('GridTests.dart');
#source('GridCellTests.dart');
#source('TextBoxTests.dart');
#source('RadioButtonGroupTests.dart');
#source('DomHelpersTests.dart');
#source('StyleTemplateTests.dart');
#source('BuckshotTemplateProviderTests.dart');
#source('StringToGridLengthConverterTests.dart');
#source('ResourceTests.dart');
#source('VarResourceTests.dart');

void main() {
  final List<TestGroupBase> _tList = new List<TestGroupBase>();
  
  
//  try{
    new BuckshotSystem();
//    }
//    catch(FrameworkException e){
//      window.alert("Buckshot Framework initialization failed: ${e}");
//      return;
//    }
//    catch(Exception e, final stack){
//      window.alert("General system exception: ${e} $stack");
//      return;
//    }
    
  _tList.add(new InitializationTests());
  _tList.add(new FrameworkFundamentalsTests());
  _tList.add(new FrameworkElementTests());
  _tList.add(new FrameworkPropertyTests());
  _tList.add(new FrameworkEventTests());
  _tList.add(new FrameworkExceptionTests());
  _tList.add(new BindingTests());
  _tList.add(new BuckshotTemplateProviderTests());
  _tList.add(new TextBoxTests());
  _tList.add(new BorderTests());
  _tList.add(new ButtonTests());
  _tList.add(new ControlTests());
  _tList.add(new FrameworkObjectTests());
  _tList.add(new ObservableListTests());
  _tList.add(new PanelTests());
  _tList.add(new StackPanelTests());
  _tList.add(new TextBlockTests());
  _tList.add(new LayoutCanvasTests());
  _tList.add(new RadioButtonGroupTests());
  _tList.add(new GridTests());
  _tList.add(new GridCellTests());
  _tList.add(new DomHelpersTests());
  _tList.add(new StyleTemplateTests());
  _tList.add(new StringToGridLengthConverterTests());
  _tList.add(new ResourceTests());
  _tList.add(new VarResourceTests());
  
  _tList.forEach((TestGroupBase t){
    group(t.testGroupName, (){
      t.testList.forEach((String name, Function testFunc){
        test(name, testFunc);
      });
    });
  });
  

}


//TODO:  This is an artifact from the old unit testing system and should be removed
// at some point.
/**
* A base class for defining groups of tests to be performed. */
class TestGroupBase {
  
  final LinkedHashMap<String, Function> testList;
  String testGroupName;
  
  TestGroupBase() : testList = new LinkedHashMap<String, Function>()
  {
    registerTests();
  }
  
  abstract void registerTests();
  
}
