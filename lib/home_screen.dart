import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<DataModel> _data;
  bool _isLoading = false;

  void _getData() async {
    setState(() {
      _data = [];
      _isLoading = true;
    });
    FirebaseFirestore.instance
        .collection('data')
        .orderBy('date')
        .get()
        .then((value) {
      setState(() {
        for (var element in value.docs) {
          setState(() {
            _data.add(DataModel.fromJson(element.id, element.data()));
          });
        }
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: 'تم تحديث البيانات',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }).catchError((error) {
      setState(() {
        print(error.toString());
        Fluttertoast.showToast(msg: 'حدث خطأ ما');
        _isLoading = false;
      });
    });
  }

  void _deleteData(String id) async {
    setState(() {
      _isLoading = true;
    });
    FirebaseFirestore.instance
        .collection('data')
        .doc(id)
        .delete()
        .then((value) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: 'تم حذف البيانات بنجاح',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      _getData();
    }).catchError((error) {
      setState(() {
        print(error.toString());
        Fluttertoast.showToast(msg: 'حدث خطأ ما');
        _isLoading = false;
      });
    });
  }

  void _openLocation(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch';
    }
  }

  void _openDialog(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('هل تريد حذف البيانات؟'),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('حذف'),
              onPressed: () {
                _deleteData(id);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _data = [];
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masoud Oil Admin'),
        actions: [
          if (_data.isEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _getData,
            ),
        ],
        centerTitle: true,
      ),
      body: _data.isEmpty
          ? Center(
              child: Text(
                'لا يوجد طلبات حتى الان',
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : RefreshIndicator(
                  onRefresh: () {
                    _getData();
                    return Future.delayed(
                      const Duration(seconds: 2),
                    );
                  },
                  child: ListView.separated(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.05),
                    itemCount: _data.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.05),
                          child: Column(
                            children: [
                              Text(
                                'الاسم: ${_data[index].name}',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'رقم الموبايل: ${_data[index].phone}',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'الوقت والتاريخ: ${_data[index].date!.substring(0, 16).trim()}',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'نوع الزيت: ${_data[index].oilType}',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                ' يحتاج فلتر: ${_data[index].carType != '' ? 'نعم' : 'لا'}',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              if (_data[index].carType != '')
                                Text(
                                  'نوع العربية: ${_data[index].carType}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              Text(
                                'العنوان: ${_data[index].address}',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'الملاحظات: ${_data[index].notes}',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              MaterialButton(
                                onPressed: () {
                                  _openLocation(
                                      _data[index].latitude!.toDouble(),
                                      _data[index].longitude!.toDouble());
                                },
                                color: Theme.of(context).primaryColor,
                                child: const Text('موقع العميل'),
                              ),
                              MaterialButton(
                                onPressed: () {
                                  _openDialog(_data[index].id);
                                },
                                color: Colors.red,
                                child: const Text(
                                  'مسح البيانات',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 10,
                    ),
                  ),
                ),
    );
  }
}
