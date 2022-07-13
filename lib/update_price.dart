import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'oil_type_model.dart';

class UpdatePriceScreen extends StatefulWidget {
  const UpdatePriceScreen({Key? key}) : super(key: key);

  @override
  State<UpdatePriceScreen> createState() => _UpdatePriceScreenState();
}

class _UpdatePriceScreenState extends State<UpdatePriceScreen> {
  List<OilTypeModel> oilTypesModel = [];
  List<DetailsOilTypeModel> oilTypeDetails = [];
  var newPriceController = TextEditingController();
  String oilTypeName = '';
  String oilTypeNumber = '';
  String oilTypePrice = '';
  String oilTypeId = '';
  String oilTypeNumberId = '';
  bool _isLoading = false;
  bool _getOilTypesLoading = false;
  bool _getOilTypesDetailsLoading = false;

  void getAllOilTypes() {
    setState(() {
      _getOilTypesLoading = true;
    });
    oilTypesModel = [];
    FirebaseFirestore.instance.collection('oilType').get().then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        oilTypesModel.add(OilTypeModel(
          name: value.docs[i].data()['name'],
          id: value.docs[i].id,
        ));
      }
      setState(() {
        oilTypeName = oilTypesModel[0].name.toString();
        oilTypeId = oilTypesModel[0].id.toString();
        _getOilTypesLoading = false;
      });
      print(oilTypesModel.toString());
    }).catchError((error) {
      print(oilTypesModel.toString());
      setState(() {
        _getOilTypesLoading = false;
      });
      print(error.toString());
      Fluttertoast.showToast(msg: 'حدث خطأ ما');
    });
    // print(oilTypesModel[0]);
  }

  void getOilTypeDetails({
    required String type,
  }) {
    setState(() {
      _getOilTypesDetailsLoading = true;
    });
    FirebaseFirestore.instance
        .collection('oilType')
        .doc(type)
        .collection('types')
        .get()
        .then((value) {
      oilTypeDetails = [];
      for (var element in value.docs) {
        setState(() {
          oilTypeDetails.add(DetailsOilTypeModel(
            id: element.id,
            name: element.data()['name'],
            price: element.data()['price'],
          ));
          oilTypeNumber = oilTypeDetails[0].name.toString();
          oilTypePrice = oilTypeDetails[0].price.toString();
          oilTypeNumberId = oilTypeDetails[0].id.toString();
          _getOilTypesDetailsLoading = false;
        });
      }
      print(oilTypeDetails.toString());
    }).catchError((error) {
      print(oilTypeDetails.toString());
      setState(() {
        _getOilTypesDetailsLoading = false;
      });
      print(error.toString());
      Fluttertoast.showToast(msg: 'حدث خطأ ما');
    });
  }

  void updateOilPrice() {
    setState(() {
      _isLoading = true;
    });
    FirebaseFirestore.instance
        .collection('oilType')
        .doc(oilTypeId)
        .collection('types')
        .doc(oilTypeNumberId)
        .update({
      'price': newPriceController.text,
    }).then((value) {
      setState(() {
        Fluttertoast.showToast(
          msg: 'تم تحديث السعر بنجاح',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        getAllOilTypes();
        oilTypePrice = newPriceController.text;
        newPriceController.text = '';
        _isLoading = false;
      });
    }).catchError((error) {
      print(error.toString());
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: 'حدث خطأ ما');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllOilTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحديث سعر البنزين'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_getOilTypesLoading || _getOilTypesDetailsLoading)
              LinearProgressIndicator(color: Theme.of(context).primaryColor),
            Row(
              children: [
                Text(
                  'نوع الزيت:',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) {
                    return oilTypesModel.map((oilType) {
                      return PopupMenuItem(
                        value: oilType,
                        child: Text(
                          oilType.name.toString(),
                        ),
                        onTap: () {
                          setState(() {
                            oilTypeId = oilType.id.toString();
                            getOilTypeDetails(type: oilType.id.toString());
                            oilTypeName = oilType.name!;
                            print(oilTypeName);
                          });
                        },
                      );
                    }).toList();
                  },
                  tooltip: 'اختر نوع الزيت',
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width * 0.05,
                      ),
                      side: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05,
                        vertical: MediaQuery.of(context).size.width * 0.02,
                      ),
                      child: Text(
                        oilTypeName,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Row(
              children: [
                if (oilTypeDetails.isNotEmpty)
                  Text(
                    'كيلو متر:',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                if (oilTypeDetails.isNotEmpty)
                  PopupMenuButton(
                    itemBuilder: (context) {
                      return oilTypeDetails.map((oilType) {
                        return PopupMenuItem(
                          value: oilType,
                          child: Text(oilType.name.toString()),
                          onTap: () {
                            setState(() {
                              oilTypePrice = oilType.price!;
                              oilTypeNumber = oilType.name!;
                              oilTypeNumberId = oilType.id!;
                              print(oilTypeNumberId);
                            });
                          },
                        );
                      }).toList();
                    },
                    tooltip: 'اختر عدد الكيلو متر',
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width * 0.05,
                        ),
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.02),
                        child: Text(
                          oilTypeNumber,
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            if (oilTypePrice != '' && oilTypeDetails.isNotEmpty)
              Text('السعر: $oilTypePrice',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            if (oilTypePrice != '' && oilTypeDetails.isNotEmpty)
              TextFormField(
                controller: newPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'السعر الجديد',
                  labelStyle:
                      Theme.of(context).textTheme.headlineSmall!.copyWith(
                            color: Colors.black26,
                            fontWeight: FontWeight.bold,
                          ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width * 0.05,
                    ),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
              ),
            if (oilTypePrice != '' && oilTypeDetails.isNotEmpty)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
            if (oilTypePrice != '' && oilTypeDetails.isNotEmpty)
              Align(
                alignment: Alignment.center,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : MaterialButton(
                        onPressed: () {
                          updateOilPrice();
                        },
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          'تحديث',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
              ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
          ],
        ),
      ),
    );
  }
}
