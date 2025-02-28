import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:mirror_wall_browserapp/views/home_page.dart';

late InAppWebViewController webViewController;
TextEditingController searchController = TextEditingController();
String homepageUrl = "https://www.google.com";
List<String> bookmarks = [];

class CustomWebBrowser2 extends StatefulWidget {
  const CustomWebBrowser2({super.key});

  @override
  _CustomWebBrowserState createState() => _CustomWebBrowserState();
}

class _CustomWebBrowserState extends State<CustomWebBrowser2> {
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1E1F22),
        centerTitle: true,

        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              webViewController.reload();
            },
          ),
          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: () {
              webViewController.loadUrl(
                urlRequest: URLRequest(url: WebUri.uri(Uri.parse(homepageUrl))),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.bookmark, color: Colors.white),
            onPressed: () {
              String? currentUrl = webViewController.getUrl().toString();
              if (!bookmarks.contains(currentUrl)) {
                bookmarks.add(currentUrl);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Page bookmarked!')),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              webViewController.goBack();
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () {
              webViewController.goForward();
            },
          ),
          _buildPopUpMenuButton(),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: SizedBox(
            height: h * 0.065,
            width: w * 0.92,
            child: TextField(
              style: TextStyle(color: Colors.white),
              autocorrect: true,
              controller: searchController,
              cursorColor: Colors.white,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.white),
                hintText: "Search or type URL...",
                hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.white)),
                filled: true,
                fillColor: Color(0xff939393),
              ),
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  String url = query.startsWith('http')
                      ? query
                      : Uri.https('www.google.com', '/search', {'q': query})
                      .toString();
                  webViewController.loadUrl(
                    urlRequest: URLRequest(url: WebUri.uri(Uri.parse(url))),
                  );
                }
              },
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest:
            URLRequest(url: WebUri.uri(Uri.parse(homepageUrl))),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                searchController.text = url.toString();
              });
            },
            onLoadStop: (controller, url) async {
              setState(() {
                searchController.text = url.toString();
              });
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                this.progress = progress / 100;
              });
            },
          ),
          progress < 1.0
              ? LinearProgressIndicator(value: progress)
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}

Widget _buildPopUpMenuButton() {
  return PopupMenuButton<int>(
    icon: const Icon(
      Icons.more_vert,
      color: Colors.white,
    ),
    onSelected: (value) {
      _handleMenuOption(value);
    },
    itemBuilder: (context) => [
      const PopupMenuItem(
        value: 1,
        child: Text("New Tab"),
      ),
      const PopupMenuItem(
        value: 2,
        child: Text("Bookmarks"),
      ),
      const PopupMenuItem(
        value: 3,
        child: Text("History"),
      ),
      const PopupMenuItem(
        value: 4,
        child: Text("Settings"),
      ),
      const PopupMenuItem(
        value: 5,
        child: Text("Select Search Engine"),
      ),
    ],
  );
}

void _handleMenuOption(int value) {
  switch (value) {
    case 1:
      Get.snackbar("New Tab", "Opening a new tab...");
      break;
    case 2:
      Get.snackbar("Bookmarks", "Navigating to bookmarks...");
      break;
    case 3:
      Get.snackbar("History", "Navigating to history...");
      break;
    case 4:
      Get.snackbar("Settings", "Opening settings...");
      break;
    case 5:
      _showSearchEngineDialog();
      break;
    default:
      break;
  }
}
void _showSearchEngineDialog() {
  Get.dialog(
    AlertDialog(
      title: const Text("Select Search Engine"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRadioButton("Google", 'https://www.google.com/search?q='),
          _buildRadioButton("Brave", 'https://search.brave.com/search?q='),
          _buildRadioButton("Yahoo", 'https://search.yahoo.com/search?p='),
          _buildRadioButton("Bing", 'https://www.bing.com/search?q='),
          _buildRadioButton("DuckDuckGo", 'https://duckduckgo.com/?q='),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // Close the dialog
          },
          child: const Text("Close"),
        ),
      ],
    ),
  );
}

Widget _buildRadioButton(String engine, String url) {
  return Obx(() {
    return RadioListTile<String>(
      title: Text(engine),
      value: url,
      groupValue: browserController.currentSearchEngine.value,
      onChanged: (value) {
        if (value != null) {
          browserController.setSearchEngine(value);
          Get.back(); // Close the dialog after selection
        }
      },
    );
  });
}
