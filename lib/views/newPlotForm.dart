import 'package:flutter/material.dart';

class NewPlotRecordingPage extends StatefulWidget {
  const NewPlotRecordingPage({Key? key}) : super(key: key);

  @override
  State<NewPlotRecordingPage> createState() => _NewPlotRecordingPageState();
}

class _NewPlotRecordingPageState extends State<NewPlotRecordingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 32.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _nameController,
                  onChanged: (v) {
                    print('_nameController.text: ${_nameController.text}');
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Plot Number';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Plot Number',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Builder(builder: (context) {
                  return ElevatedButton(
                    // If onPressed is null, the button is disabled
                    // this is my goto temporary callback.
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        print('processing data');
                        _submitPlotNum(context);
                      }
                    },
                    child: Text('Ok'),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitPlotNum(BuildContext context) {
    print("routing to camera page with argument: ${_nameController.text}");
    Navigator.of(context)
        .popAndPushNamed('/camera', arguments: _nameController.text);
  }
}
