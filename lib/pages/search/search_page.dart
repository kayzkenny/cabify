import 'package:flutter/material.dart';
import 'package:cabify/shared/api_keys.dart';
import 'package:cabify/shared/endpoints.dart';
import 'package:cabify/widgets/prediction.tile.dart';
import 'package:cabify/models/prediction_model.dart';
import 'package:cabify/services/request_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabify/providers/appstate_provider.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final focusDestination = FocusNode();
  final pickupController = TextEditingController();
  final destinationController = TextEditingController();

  bool focused = false;

  void setFocus() {
    if (!focused) {
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }

  List<Prediction> destinationPredictionList = [];

  Future<void> searchPlace(String placeName) async {
    if (placeName.length > 1) {
      String url =
          '$placesEndpoint?input=$placeName&key=${APIKeys.googleMaps}&sessiontoken=1234567890&components=country:ng';
      var response = await RequestHelper.getRequest(url);

      if (response == 'failed') {
        return;
      }

      if (response['status'] == 'OK') {
        List predicitionJson = response['predictions'];

        List<Prediction> thisList =
            predicitionJson.map((e) => Prediction.fromJson(e)).toList();

        setState(() => destinationPredictionList = thisList);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    pickupController.text =
        context.read(appStateProvider).pickupAddress?.placeName;
    setFocus();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Set Destination',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Brand-Bold',
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData().copyWith(
          color: Colors.black,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.place,
                          color: Colors.red,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: TextFormField(
                                controller: pickupController,
                                decoration: InputDecoration(
                                  filled: true,
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: 'Pickup Location',
                                  contentPadding: EdgeInsets.all(8),
                                  fillColor: Colors.black12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.place,
                          color: Colors.green,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: TextFormField(
                                onChanged: (value) => searchPlace(value),
                                focusNode: focusDestination,
                                controller: destinationController,
                                decoration: InputDecoration(
                                  filled: true,
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: 'Where to?',
                                  contentPadding: EdgeInsets.all(8),
                                  fillColor: Colors.black12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (destinationPredictionList.isNotEmpty)
                ListView.separated(
                  padding: EdgeInsets.all(16),
                  itemBuilder: (context, index) => PredictionTile(
                    prediction: destinationPredictionList[index],
                  ),
                  separatorBuilder: (context, index) => Divider(
                    indent: 32.0,
                  ),
                  itemCount: destinationPredictionList.length,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                )
            ],
          ),
        ),
      ),
    );
  }
}
