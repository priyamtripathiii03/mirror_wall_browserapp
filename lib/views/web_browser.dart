import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:mirror_wall_browserapp/browser_controller.dart';

final BrowserController browserController = Get.put(BrowserController());
late final InAppWebViewController? webViewController;
final TextEditingController searchController = TextEditingController();
final SearchEngineController searchEngineController =
Get.put(SearchEngineController());

class CustomWebBrowser extends StatelessWidget {
  const CustomWebBrowser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff1E1F22),
        leading: IconButton(
          onPressed: () {
            // webViewController.
          },
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
      Get.to(() => BookmarksPage());
      break;
    case 3:
      Get.to(() => HistoryPage());
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
  return
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        // controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search or type URL...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onSubmitted: (query) {
          if (query.isNotEmpty) {
            // Check if the input is a URL or a search query
            String url = query.startsWith('http')
                ? query
                : '${browserController.currentSearchEngine.value}${Uri.encodeComponent(query)}'; // Use encodeComponent to avoid invalid URL characters

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
      onLoadError: (controller, url, code, message) {
        print("Load Error: $message"); // Print error message
        // You can show a snackbar or alert dialog here to inform the user
      },
      onLoadHttpError: (controller, url, statusCode, statusText) {
        print("HTTP Error: $statusCode, $statusText"); // Print HTTP error
        // Handle the HTTP error as needed
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
          Get.back(); // Close the dialog after selection
        }
      },
    );
  });
}

// Bookmarks Page
class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookmarks"),
      ),
      body: Obx(() {
        if (browserController.bookmarks.isEmpty) {
          return const Center(child: Text("No bookmarks yet."));
        }
        return ListView.builder(
          itemCount: browserController.bookmarks.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(browserController.bookmarks[index]),
              onTap: () {
                webViewController?.loadUrl(
                  urlRequest: URLRequest(
                    url: WebUri.uri(
                        Uri.parse(browserController.bookmarks[index])),
                  ),
                );
                Get.back(); // Go back to the home page after selection
              },
            );
          },
        );
      }),
    );
  }
}

// History Page
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
      ),
      body: Obx(() {
        if (browserController.history.isEmpty) {
          return const Center(child: Text("No history yet."));
        }
        return ListView.builder(
          itemCount: browserController.history.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                browserController.history[index],
                maxLines: 1,
              ),
              onTap: () {
                webViewController?.loadUrl(
                  urlRequest: URLRequest(
                    url:
                    WebUri.uri(Uri.parse(browserController.history[index])),
                  ),
                );
                Get.back(); // Go back to the home page after selection
              },
            );
          },
        );
      }),
    );
  }
}
