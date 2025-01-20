import 'package:flutter/material.dart';

class TabbedScaffold extends StatelessWidget {
  final List<String> tabTitles;
  final List<Widget> tabViews;
  final VoidCallback onEditPressed;
  final bool isUser;
  final bool isLoading;
  final bool isEditing;
  final Color activeTabColor;
  final Color inactiveTabColor;

  const TabbedScaffold({
    Key? key,
    required this.tabTitles,
    required this.tabViews,
    required this.onEditPressed,
    this.isUser = true,
    this.isLoading = false,
    this.isEditing = false,
    this.activeTabColor = Colors.red,
    this.inactiveTabColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabTitles.length,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: TabBar(
            dividerColor: Colors.transparent,
            labelColor: activeTabColor,
            unselectedLabelColor: inactiveTabColor,
            unselectedLabelStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            indicatorColor: activeTabColor,
            tabs: tabTitles.map((title) => Tab(text: title)).toList(),
          ),
        ),
        floatingActionButton: !isUser
            ? isLoading
                ? const FloatingActionButton(
                    onPressed: null,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : FloatingActionButton(
                    tooltip: isEditing ? 'Save Changes' : 'Edit',
                    onPressed: onEditPressed,
                    child: Icon(isEditing ? Icons.save : Icons.edit),
                  )
            : null,
        body: TabBarView(
          children: tabViews,
        ),
      ),
    );
  }
}