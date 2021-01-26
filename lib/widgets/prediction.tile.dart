import 'package:cabify/providers/appstate_provider.dart';
import 'package:flutter/material.dart';
import 'package:cabify/shared/api_keys.dart';
import 'package:cabify/shared/endpoints.dart';
import 'package:cabify/models/address_model.dart';
import 'package:cabify/models/prediction_model.dart';
import 'package:cabify/services/request_helper.dart';
import 'package:cabify/widgets/progress_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PredictionTile extends StatelessWidget {
  const PredictionTile({
    this.prediction,
    Key key,
  }) : super(key: key);

  final Prediction prediction;

  void getPlaceDetails(String placeId, BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(status: 'Please wait...'),
    );

    String url =
        '$placeDetailsEndpoint?place_id=$placeId&key=${APIKeys.googleMaps}';

    var response = await RequestHelper.getRequest(url);

    Navigator.pop(context);

    if (response == 'failed') {
      return;
    }

    if (response['status'] == 'OK') {
      Address thisPlace = Address(
        placeId: placeId,
        placeName: response['result']['name'],
        latitude: response['result']['geometry']['location']['lat'],
        longitude: response['result']['geometry']['location']['lng'],
      );

      context.read(appStateProvider).updateDestinationAddress(thisPlace);

      print(thisPlace.placeName);

      // Navigator.pop(context, 'getDirection');

      Navigator.pushNamed(
        context,
        '/requestcab',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: () => getPlaceDetails(prediction.placeId, context),
      child: Container(
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: Colors.green,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prediction.mainText,
                    style: TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: 2),
                  Text(
                    prediction.secondaryText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
