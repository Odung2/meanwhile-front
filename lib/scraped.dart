import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

String baseUrl = "http://172.10.5.81:443";

class Bookmark {
  final String refLink;
  final String refTitle;

  Bookmark({required this.refLink, required this.refTitle});

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      refLink: json['refLink'],
      refTitle: json['refTitle'],
    );
  }
}
//

class ScrapScreen extends StatefulWidget {
  @override
  _ScrapScreenState createState() => _ScrapScreenState();
}

class _ScrapScreenState extends State<ScrapScreen> {

  void updateBookmarks() {
    fetchBookmarks();
  }

  Future<String?> getJwtToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  Future<List<Bookmark>> fetchBookmarks() async {
    final jwtToken = await getJwtToken();
    final request =  Uri.parse("$baseUrl/bookmarks");
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $jwtToken'
    };
    var response = await http.get(request, headers:headers);
    var json = jsonDecode(response.body);
    List<Bookmark> bookmarks = [];
    // for(var bookmarkJson in json)
    // {
    //   bookmarks.add(Bookmark.fromJson(bookmarkJson));
    // }
    setState(() {
      for(var bookmarkJson in json)
      {
        bookmarks.add(Bookmark.fromJson(bookmarkJson));
      }
    });
    return bookmarks;

  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, height *0.02, 0, height *0.02),
                  child: Text(
                    "My bookmark list 😽",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          FutureBuilder<List<Bookmark>>(
            future:fetchBookmarks(),
            builder: (BuildContext context, AsyncSnapshot<List<Bookmark>> snapshot){
              if(snapshot.hasData) {
                List<Bookmark> bookmarks = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: bookmarks.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = bookmarks[index];
                    return GestureDetector(
                      onTap: ()  {
                        // Navigator.push(
                        // context,
                        // MaterialPageRoute(builder: (context) => (item)),
                        // );
                      },

                      child: Container(
                        width: width*0.9,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(8.0),
                          // image: DecorationImage(
                          //   image: AssetImage('assets/images/beforeselect.jpg'),
                          //   fit: BoxFit.cover,
                          // ),
                        ),
                        padding: const EdgeInsets.all(10),

                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start, // Adjust crossAxisAlignment
                              children: [
                                Flexible(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${item.refTitle}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: height * 0.005),
                                      Text(
                                        "${item.refLink}",
                                        style: const TextStyle(
                                        // fontWeight: FontWeight.bold,
                                        fontSize: 16
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return CircularProgressIndicator();
              }
            }

    ),
              // Container(
              //   child: ElevatedButton(
              //       onPressed: fetchBookmarks,
              //       child: Icon(Icons.refresh),
              //   )
              // )

            ],
          )
        )
      ],

    );
  }
}





