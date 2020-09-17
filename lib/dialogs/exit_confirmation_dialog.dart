import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExitConfirmationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildChild(context),
    );
  }

  _buildChild(BuildContext context) => Container(
        height: 350,
        decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Column(
          children: <Widget>[
            Container(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  FontAwesomeIcons.frown,
                  size: 110.0,
                ),
              ),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12))),
            ),
            SizedBox(
              height: 24,
            ),
            Text(
              'Opps!',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 16),
              child: Text(
                'Select Atleast One Category  To Proceed',
                style: TextStyle(color: Colors.white, fontSize: 20.0),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 24,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    return Navigator.of(context).pop(true);
                  },
                  child: Text('Cancel'),
                  color: Colors.white,
                  textColor: Colors.black,
                )
              ],
            )
          ],
        ),
      );
}

// class UploadDialog extends StatelessWidget {
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text(
//         "Choose One!",
//         style: TextStyle(
//           color: Colors.amber[100],
//         ),
//         textAlign: TextAlign.center,
//       ),
//       backgroundColor: Colors.green[900],
//       content: SingleChildScrollView(
//         child: ListBody(
//           children: [
//             GestureDetector(
//               child: Icon(FontAwesomeIcons.video,
//                   size: 35.0, color: Colors.amber[50]),
//               onTap: () => null,
//             ),
//             Padding(
//               padding: EdgeInsets.all(10.0),
//             ),
//             GestureDetector(
//               child: Icon(FontAwesomeIcons.icons,
//                   size: 35.0, color: Colors.amber[50]),
//               onTap: () => null,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
