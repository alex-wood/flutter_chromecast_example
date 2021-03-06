import 'package:dart_chromecast/casting/cast_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chromecast_example/service_discovery.dart';
import 'package:flutter_mdns_plugin/flutter_mdns_plugin.dart';
import 'package:observable/observable.dart';

class DevicePicker extends StatefulWidget {

  final ServiceDiscovery serviceDiscovery;
  final Function(CastDevice) onDevicePicked;

  DevicePicker({ this.serviceDiscovery, this.onDevicePicked });

  @override
  _DevicePickerState createState() => _DevicePickerState();

}

class _DevicePickerState extends State<DevicePicker> {

  List<CastDevice> _devices = [];

  void initState() {
    super.initState();
    widget.serviceDiscovery.changes.listen((List<ChangeRecord> _) {
      _updateDevices();
    });
    _updateDevices();
  }

  _updateDevices() {
    // No: not good!
    // We do want to cache the found devices...
    _devices = widget.serviceDiscovery.foundServices.map((ServiceInfo serviceInfo) {
      return CastDevice(name: serviceInfo.name, type: serviceInfo.type, host: serviceInfo.hostName, port: serviceInfo.port);
    }).toList();
  }

  Widget _buildListViewItem(BuildContext context, int index) {
    CastDevice castDevice = _devices[index];
    return ListTile(
      title: Text(castDevice.friendlyName),
      onTap: () {
        if (null != widget.onDevicePicked) {
          widget.onDevicePicked(castDevice);
          Navigator.of(context).pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 200.0,
        width: 100.0,
        child: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Pick a casting device', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),),
          ),
          Divider(height: 0.0, color: Colors.black,),
          Expanded(
            child: ListView.builder(
              key: Key('devices-list'),
              itemBuilder: _buildListViewItem,
              itemCount: _devices.length,
            ),
          )
        ],),
      ),
    );
  }
}
