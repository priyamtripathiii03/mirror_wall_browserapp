import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:mirror_wall_browserapp/browser_controller.dart';


// final MenuController menuController = Get.put(MenuController());
final BrowserController browserController = Get.put(BrowserController());
late final InAppWebViewController? webViewController;
final TextEditingController searchController = TextEditingController();
final SearchEngineController searchEngineController =
Get.put(SearchEngineController());

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff1E1F22),
        leading: IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.home_rounded,
            color: Colors.white,
          ),
        ),
        actions: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.white,
            child: Text('P'),
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              webViewController?.reload();
            },
          ),
          IconButton(
            icon: const Icon(
              color: Colors.white,
              Icons.arrow_back,
            ),
            onPressed: () {
              webViewController?.goBack();
            },
          ),
          IconButton(
            icon: const Icon(
              color: Colors.white,
              Icons.arrow_forward,
            ),
            onPressed: () {
              webViewController?.goForward();
            },
          ),
          _buildPopUpMenuButton(),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildWebView(),
          _buildLoadingIndicator(),
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

//text form field
Widget _buildSearchBar() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: 'Search or type URL...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onSubmitted: (query) {
        if (query.isNotEmpty) {
          String url = query.startsWith('http')
              ? query
              : '${browserController.currentSearchEngine.value}$query';
          webViewController?.loadUrl(
            urlRequest: URLRequest(url: WebUri.uri(Uri.parse(url))),
          );
          browserController.addToHistory(url);
        }
      },
    ),
  );
}

Widget _buildWebView() {
  return Expanded(
    child: InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri.uri(
          Uri.parse('https://www.google.com'),
        ),
      ),
      onWebViewCreated: (controller) {
        webViewController = controller;
      },
      onLoadStart: (controller, url) {
        searchController.text = url.toString();
        browserController.addToHistory(url.toString());
      },
      onLoadStop: (controller, url) {
        searchController.text = url.toString();
      },
      onProgressChanged: (controller, progress) {
        browserController.updateProgress(progress / 100);
      },
    ),
  );
}

Widget _buildLoadingIndicator() {
  return Obx(() => browserController.progress.value < 1.0
      ? LinearProgressIndicator(value: browserController.progress.value)
      : const SizedBox.shrink());
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
          Get.back();
        }
      },
    );
  });
}
