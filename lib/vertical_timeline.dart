import 'package:flutter/material.dart';

class TimelineItem {
  final String title;
  final String description;

  TimelineItem({required this.title, required this.description});
}

class TimelineScreen extends StatefulWidget {
  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Timeline Screen"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Tab 1"),
            Tab(text: "Tab 2"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Tab1Content(),
          Tab2Content(),
        ],
      ),
    );
  }
}

class Tab1Content extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Add the content for Tab 1 here
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

class Tab2Content extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Add content for Tab 2 here
    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: Text(
              "Content for Tab 2",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey, // Add your desired color for the bullet point
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
            SizedBox(width: 20,),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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