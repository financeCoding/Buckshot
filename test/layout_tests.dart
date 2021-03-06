library layout_tests_buckshot;

import 'dart:html';
import 'package:buckshot/buckshot_browser.dart';
import 'package:unittest/unittest.dart';

num measurementTolerance = 1;

/// Baseline measurements are taken using Dartium.
/// This set of tests takes sample measurements of layout elements and
/// compares them against expected values.
void run()
{

  // Milliseconds to wait for the layout to complete before performing
  // tests.
  final int layoutAllowance = 600;

  // Setting to true will cause the unit test run to pause after each layout
  // is drawn to allow for visual inspection.  Clicking in the browser window
  // will cause the test to proceed.
  final bool usePause = true;

  group('Layout', (){
    // Take measurements of reference layout to make sure they match
    // expected results.
    test('Border Layout', (){
      setView(new BorderDebug()).then(expectAsync1((_){}));

      window.setTimeout(expectAsync0((){

        namedElements.values.forEach((v)=> v.updateMeasurement());

        //references
        final bLorumIpsum = namedElements['bLorumIpsum'];
        final lblLorumIpsum = namedElements['lblLorumIpsum'];
        final bHL_VS = namedElements['bHL_VS'];
        final bHC_VS = namedElements['bHC_VS'];
        final bHR_VS = namedElements['bHR_VS'];
        final lblHL_VS = namedElements['lblHL_VS'];
        final lblHC_VS = namedElements['lblHC_VS'];
        final lblHR_VS = namedElements['lblHR_VS'];
        final bHS_VT = namedElements['bHS_VT'];
        final bHS_VC = namedElements['bHS_VC'];
        final bHS_VB = namedElements['bHS_VB'];
        final lblHS_VT = namedElements['lblHS_VT'];
        final lblHS_VC = namedElements['lblHS_VC'];
        final lblHS_VB = namedElements['lblHS_VB'];
        final bLT = namedElements['bLT'];
        final bCT = namedElements['bCT'];
        final bRT = namedElements['bRT'];
        final bRC = namedElements['bRC'];
        final bRB = namedElements['bRB'];
        final bCB = namedElements['bCB'];
        final bLB = namedElements['bLB'];
        final bLC = namedElements['bLC'];
        final bCC = namedElements['bCC'];

        window.requestLayoutFrame(expectAsync0((){

          /* Big paragraph, check wrapping and alignment. */
          //Container
          measureElement(bLorumIpsum, 11, 11, 280, 280);

          //TextBlock
          measureElement(lblLorumIpsum, 111, 21, 260, 80);

          /* Vertical Stretch, Horizontal Alignment */
          //HL_VS (Horizontal Left, Vertical Stretch)
          measureElement(bHL_VS, 303, 1, 40, 300);
          measureElement(lblHL_VS, 444.5, 1, 40, 17);

          //HC_VS (Horizontal Center, Vertical Stretch)
          measureElement(bHC_VS, 605, 130, 42, 300);
          measureElement(lblHC_VS, 746.5, 130, 42, 17);

          //HR_VS (Horizontal Right, Vertical Stretch)
          measureElement(bHR_VS, 907, 259, 42, 300);
          measureElement(lblHR_VS, 1048.5, 259, 42, 17);


          /* Horizontal Stretch, Vertical Alignment */
          //HS_VT (Horizontal Stretch, Vertical Top)
          measureElement(bHS_VT, 1209, 1, 300, 17);
          measureElement(lblHS_VT, 1209, 130.5, 42, 17);

          //HS_VC (Horizontal Stretch, Vertical Center)
          measureElement(bHS_VC, 1652.5, 1, 300, 17);
          measureElement(lblHS_VC, 1652.5, 130, 43, 17);

          //HS_VB (Horizontal Stretch, Vertical Bottom)
          measureElement(bHS_VB, 2096, 1, 300, 17);
          measureElement(lblHS_VB, 2096, 130.5, 41, 17);


          /* All Alignments, no stretch */
          //left, top
          measureElement(bLT, 2115, 1, 16, 17);

          //center, top
          measureElement(bCT, 2417, 141, 19, 17);

          //right, top
          measureElement(bRT, 2719, 283, 18, 17);

          //right, center
          measureElement(bRC, 3162.5, 282, 19, 17);

          //right, bottom
          measureElement(bRB, 3606, 282, 19, 17);

          //center, bottom
          measureElement(bCB, 3908, 142, 18, 17);

          //left, bottom
          measureElement(bLB, 4210, 1, 17, 17);

          //left, center
          measureElement(bLC, 4370.5, 1, 17, 17);

          //center, center
          measureElement(bCC, 4672.5, 141, 20, 17);

        }));

      }), layoutAllowance);

    });

    // Take measurements of reference layout to make sure they exactly match
    // expected results.
    test('Stack Layout', (){
      setView(new StackDebug())
      .then(expectAsync1((_){

      }));

      window.setTimeout(expectAsync0((){

        namedElements.values.forEach((v)=> v.updateMeasurement());

        //references
        final spRoot = namedElements['rootPanel'];
        final spChrome = namedElements['chromePanel'];
        final bBlack = namedElements['bBlack'];
        final bRed = namedElements['bRed'];
        final bGreen = namedElements['bGreen'];
        final bBlue = namedElements['bBlue'];
        final lblHCenter = namedElements['lblHCenter'];
        final lblRight = namedElements['lblRight'];
        final lblLeft = namedElements['lblLong'];
        final bCircle = namedElements['bCircle'];
        final spHorizontal = namedElements['spVerticalAlignment'];
        final lblTop = namedElements['lblTop'];
        final lblVCenter = namedElements['lblVCenter'];
        final lblBottom = namedElements['lblBottom'];

        window.requestLayoutFrame(
            expectAsync0((){
              /* root Stack */
              measureElement(spRoot, 10, 10, 333, 538);

              /* "chrome" Stack */
              measureElement(spChrome, 10, 116.5, 120, 30);

              /* dots inside the "chrome" Stack */
              //black
              measureElement(bBlack, 20, 126.5, 10, 10);

              //red
              measureElement(bRed, 20, 156.5, 10, 10);

              //green
              measureElement(bGreen, 20, 186.5, 10, 10);

              //blue
              measureElement(bBlue, 20, 216.5, 10, 10);


              /* Horizontal aligned elements in a vertical Stack */
              //centered
              measureElement(lblHCenter, 40, 134.5, 84, 17);

              //right aligned
              measureElement(lblRight, 57, 251, 92, 17);

              //left aligned
              measureElement(lblLeft, 72, 10, 275, 17);

              /* Circle (centered horizontally) */
              measureElement(bCircle, 88, 96.5, 160, 160);

              /* Horizontal Stack Container */
              //container Stack
              measureElement(spHorizontal, 248, 10, 333, 300);

              //now check the vertical alignment of elements within the horizontal Stack
              //container Stack
              measureElement(lblTop, 248, 10, 68, 17);

              //container Stack
              measureElement(lblVCenter, 390, 78, 128, 17);

              //container Stack
              measureElement(lblBottom, 532, 206, 137, 17);

            })
        );

      }), layoutAllowance);

    });


    // Take measurements of reference layout to make sure they match
    // expected results.
    test('Grid Layout', (){
      setView(new GridDebug())
      .then(expectAsync1((_){

      }));

      // Adding a delay to allow the layout to complete
      // otherwise some measurements will still be 0. Especially in JS.
      window.setTimeout(expectAsync0((){

        namedElements.values.forEach((v)=> v.updateMeasurement());

        //references
        final borderRoot = namedElements['borderContainer'];
        final gridTest = namedElements['gridTest'];
        final rectRow0 = namedElements['rectRow0'];
        final rectRow1 = namedElements['rectRow1'];
        final rectRow2 = namedElements['rectRow2'];
        final rectRow3 = namedElements['rectRow3'];
        final rectCol0 = namedElements['rectCol0'];
        final rectCol1 = namedElements['rectCol1'];
        final rectCol2 = namedElements['rectCol2'];
        final rectCol3 = namedElements['rectCol3'];
        final rectCol4 = namedElements['rectCol4'];
        final lblTitle = namedElements['lblTitle'];
        final borderCircle1 = namedElements['borderCircle1'];
        final borderCircle2 = namedElements['borderCircle2'];
        final borderCircle3 = namedElements['borderCircle3'];
        final borderCircle4 = namedElements['borderCircle4'];
        final lblLT = namedElements['lblLT'];
        final lblCT = namedElements['lblCT'];
        final lblRT = namedElements['lblRT'];
        final lblRC = namedElements['lblRC'];
        final lblRB = namedElements['lblRB'];
        final lblCB = namedElements['lblCB'];
        final lblLB = namedElements['lblLB'];
        final lblLC = namedElements['lblLC'];
        final lblCC = namedElements['lblCC'];

        window.requestLayoutFrame(

            expectAsync0((){
              /* Root Border */
              measureElement(borderRoot, 0, 0, 502, 502);

              /* Test Grid */
              measureElement(gridTest, 1, 1, 500, 500);

              /* Rows */
              measureElement(rectRow0, 1, 1, 500, 50);
              measureElement(rectRow1, 51, 1, 500, 100);
              measureElement(rectRow2, 151, 1, 500, 150);
              measureElement(rectRow3, 301, 1, 500, 200);

              /* Columns */
              measureElement(rectCol0, 1, 1, 50, 500);
              measureElement(rectCol1, 1, 51, 100, 500);
              measureElement(rectCol2, 1, 151, 200, 500);
              measureElement(rectCol3, 1, 351, 50, 500);
              measureElement(rectCol4, 1, 401, 100, 500);

              /* Title */
              measureElement(lblTitle, 10.5, 200, 102, 29);

              /* Circles */
              measureElement(borderCircle1, 1, 1, 50, 50);
              measureElement(borderCircle2, 1, 451, 50, 50);
              measureElement(borderCircle3, 451, 451, 50, 50);
              measureElement(borderCircle4, 451, 1, 50, 50);

              /* Alignment inside GridCell */
              measureElement(lblLT, 51, 51, 16, 17);
              measureElement(lblCT, 51, 216, 19, 17);
              measureElement(lblRT, 51, 383, 18, 17);
              measureElement(lblRC, 167.5, 382, 19, 17);
              measureElement(lblRB, 284, 382, 19, 17);
              measureElement(lblCB, 284, 217, 18, 17);
              measureElement(lblLB, 284, 51, 17, 17);
              measureElement(lblLC, 167.5, 51, 17, 17);
              measureElement(lblCC, 167.5, 216, 20, 17);
            })
        );
      }), layoutAllowance);
    });
  });
}


class BorderDebug extends View {
  BorderDebug() : super.fromResource('templates/border.xml');
}

class StackDebug extends View {
  StackDebug() : super.fromResource('templates/stack.xml');
}

class GridDebug extends View
{
  GridDebug() : super.fromResource('templates/grid.xml');
}

/// Tests the given measurements against the bounding measurements of a given element.
void measureElement(FrameworkElement element, num top, num left, num width, num height){
//  dumpMeasurements(element);
//  Expect.approxEquals(top, element.mostRecentMeasurement.bounding.top, tolerance:1.5, reason:'${element.name.value} top');
  Expect.approxEquals(top, element.mostRecentMeasurement.bounding.top, measurementTolerance, '${element.name.value} top');
  Expect.approxEquals(left, element.mostRecentMeasurement.bounding.left, measurementTolerance, '${element.name.value} left');
  Expect.approxEquals(width, element.mostRecentMeasurement.bounding.width, measurementTolerance, '${element.name.value} Width');
  Expect.approxEquals(height, element.mostRecentMeasurement.bounding.height, measurementTolerance, '${element.name.value} Height');
}

/// Performs a stdio dump of [FrameworkElement] measurement.
void dumpMeasurements(FrameworkElement element){
  if (element.mostRecentMeasurement == null){
    print('Measurement not available.');
    return;
  }

  print('${element.name}');
  print('   bounding.top: ${element.mostRecentMeasurement.bounding.top}');
  print('   bounding.left: ${element.mostRecentMeasurement.bounding.left}');
  print('   bounding.right: ${element.mostRecentMeasurement.bounding.right}');
  print('   bounding.width: ${element.mostRecentMeasurement.bounding.width}');
  print('   bounding.height: ${element.mostRecentMeasurement.bounding.height}');
  print('   client.top: ${element.mostRecentMeasurement.client.top}');
  print('   client.left: ${element.mostRecentMeasurement.client.left}');
  print('   client.width: ${element.mostRecentMeasurement.client.width}');
  print('   client.height: ${element.mostRecentMeasurement.client.height}');
  print('   offset.top: ${element.mostRecentMeasurement.offset.top}');
  print('   offset.left: ${element.mostRecentMeasurement.offset.left}');
  print('   offset.width: ${element.mostRecentMeasurement.offset.width}');
  print('   offset.height: ${element.mostRecentMeasurement.offset.height}');
  print('   scroll.top: ${element.mostRecentMeasurement.scroll.top}');
  print('   scroll.left: ${element.mostRecentMeasurement.scroll.left}');
  print('   scroll.width: ${element.mostRecentMeasurement.scroll.width}');
  print('   scroll.height: ${element.mostRecentMeasurement.scroll.height}');


}
