import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

class TimelineItem {
  final String title;
  final String description;

  TimelineItem({required this.title, required this.description});
}

class VerticalTimeline extends StatefulWidget {
  @override
  _VerticalTimelineState createState() => _VerticalTimelineState();
}

class _VerticalTimelineState extends State<VerticalTimeline> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Keywords", // Add your desired title for the keyword list
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Chip(label: Text("Keyword 1")), // Replace "Keyword 1" with your actual keyword
                SizedBox(width: 8),
                Chip(label: Text("Keyword 2")), // Replace "Keyword 2" with your actual keyword
                // Add more Chip widgets for additional keywords
              ],
            ),
          ),
          SizedBox(height: 16), // Add some spacing between the keyword list and the timeline
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: timelineData.length,
            itemBuilder: (context, index) {
              return TimelineTile(
                title: timelineData[index].title,
                description: timelineData[index].description,
              );
            },
          ),
        ],
      ),
    );
  }
}




class TimelineTile extends StatefulWidget {
  final String title;
  final String description;

  TimelineTile({required this.title, required this.description});

  @override
  _TimelineTileState createState() => _TimelineTileState();
}

class _TimelineTileState extends State<TimelineTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Set mainAxisSize to MainAxisSize.min
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  margin: EdgeInsets.only(top: 8),
                ),
                Container(
                  width: 2,
                  height: 100, // Adjust the height of the vertical line as needed
                  color: Colors.grey, // Add your desired color for the vertical line
                ),
              ],
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5,),
                  Text(
                    widget.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: TextStyle(fontSize: 16),
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




List<TimelineItem> timelineData = [
  TimelineItem(title: "Event 1", description: "Description 1"),
  TimelineItem(title: "Event 2", description: "Description 2"),
  // Add more items as needed
];