import 'package:app_assets_picker/app_assets_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<AssetEntity> _result = <AssetEntity>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          final AssetEntity item = _result[index];
          return Column(
            children: <Widget>[
              if (item.type == AssetType.image)
                Image(
                  image: AssetEntityImageProvider(
                    item,
                    isOriginal: false,
                  ),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  '$index\n${item.type.name}/${item.title}',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
        itemCount: _result.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onPickAssetsPressed,
        tooltip: 'Pick Assets',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _onPickAssetsPressed() {
    final ThemeData theme = Theme.of(context);

    final AssetPickerConfigBuilder pickerConfigBuilder =
        AssetPickerConfigBuilder(
      selectedAssets: _result,
      maxAssets: 3,
      themeColor: theme.primaryColor,
      requestType: RequestType.image,
    );

    AppAssetPicker.pickAssets(
      context,
      pickerConfigBuilder: pickerConfigBuilder,
    ).then((List<AssetEntity>? result) {
      if (result == null) {
        return;
      }

      setState(() {
        _result
          ..clear()
          ..addAll(result);
      });
    });
  }
}
