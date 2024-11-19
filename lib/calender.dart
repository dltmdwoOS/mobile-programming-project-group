import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  Map<String, Map<String, dynamic>> _notes = {};
  bool _isImageZoomed = false;
  LatLng? _selectedLocation;
  String? _selectedPlaceName;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notes = Map<String, Map<String, dynamic>>.from(
          jsonDecode(prefs.getString('notes') ?? '{}'));
    });
  }

  Future<void> _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes', jsonEncode(_notes));
  }

  Future<void> _fetchPlaceNameFromOSM(LatLng location) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}&zoom=18&addressdetails=1';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _selectedPlaceName = data['display_name'] ?? "Unknown location";
        });
      } else {
        setState(() {
          _selectedPlaceName = "Failed to fetch location";
        });
      }
    } catch (e) {
      setState(() {
        _selectedPlaceName = "Error fetching location";
      });
    }
  }

  void _openNoteDialog(DateTime date) {
    TextEditingController _textController = TextEditingController(
        text: _notes[date.toString()]?['text'] ?? '');
    String? imagePath = _notes[date.toString()]?['image'];
    _selectedLocation = _notes[date.toString()]?['latitude'] != null &&
        _notes[date.toString()]?['longitude'] != null
        ? LatLng(
      double.parse(_notes[date.toString()]!['latitude'].toString()),
      double.parse(_notes[date.toString()]!['longitude'].toString()),
    )
        : null;
    _selectedPlaceName = _notes[date.toString()]?['placeName'] ?? null;

    if (_selectedLocation != null && _selectedPlaceName == null) {
      _fetchPlaceNameFromOSM(_selectedLocation!);
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('${date.year}-${date.month}-${date.day}의 메모'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final pickedFile = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          setState(() {
                            imagePath = pickedFile.path;
                          });
                        }
                      },
                      onDoubleTap: () {
                        setState(() {
                          _isImageZoomed = !_isImageZoomed;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: _isImageZoomed ? 300 : 250,
                        width: _isImageZoomed ? 300 : 250,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: imagePath != null && imagePath!.isNotEmpty
                            ? (kIsWeb
                            ? Image.network(
                          imagePath!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text('이미지를 불러올 수 없습니다. (클릭하여 추가)'),
                            );
                          },
                        )
                            : Image.file(
                          File(imagePath!),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text('이미지를 불러올 수 없습니다. (클릭하여 추가)'),
                            );
                          },
                        ))
                            : Center(
                          child: Text('이미지 업로드 (클릭하여 선택)'),
                        ),
                      ),
                    ),

                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        LatLng? result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MapPage(selectedLocation: _selectedLocation)),
                        );
                        if (result != null) {
                          setState(() {
                            _selectedLocation = result;
                            _fetchPlaceNameFromOSM(result).then((_) {
                              _notes[date.toString()]?['placeName'] =
                                  _selectedPlaceName;
                            });
                          });
                        }
                      },
                      child: Text('지도에서 위치 선택'),
                    ),
                    SizedBox(height: 10),
                    if (_selectedLocation != null && _selectedPlaceName != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          '선택된 위치: $_selectedPlaceName',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _textController,
                      decoration: InputDecoration(hintText: '내용을 입력하세요'),
                      maxLines: null,
                      onChanged: (value) {
                        setState(() {
                          // 실시간 반영을 위해 textController의 값을 즉시 업데이트
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('저장'),
                  onPressed: () {
                    setState(() {
                      _notes[date.toString()] = {
                        'text': _textController.text,
                        'image': imagePath ?? '',
                        'latitude': _selectedLocation?.latitude,
                        'longitude': _selectedLocation?.longitude,
                        'placeName': _selectedPlaceName ?? '',
                      };
                      _saveNotes(); // 변경사항을 영구적으로 저장
                    });
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('취소'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('캘린더'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
              _openNoteDialog(selectedDay);
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _selectedDay = focusedDay;
            },
          ),
        ],
      ),
    );
  }
}

class MapPage extends StatefulWidget {
  final LatLng? selectedLocation;
  MapPage({this.selectedLocation});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late LatLng _initialPosition;
  LatLng? _selectedLocation;
  String? _selectedPlaceName;

  @override
  void initState() {
    super.initState();
    _initialPosition = widget.selectedLocation ?? LatLng(37.7749, -122.4194);
    _selectedLocation = widget.selectedLocation;
    if (_selectedLocation != null) {
      _fetchPlaceNameFromOSM(_selectedLocation!);
    }
  }

  Future<void> _fetchPlaceNameFromOSM(LatLng location) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}&zoom=18&addressdetails=1';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _selectedPlaceName = data['display_name'] ?? "Unknown location";
        });
      } else {
        setState(() {
          _selectedPlaceName = "Failed to fetch location";
        });
      }
    } catch (e) {
      setState(() {
        _selectedPlaceName = "Error fetching location";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('위치 선택'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: _initialPosition,
          zoom: 13.0,
          minZoom: 5.0,
          maxZoom: 18.0,
          onTap: (tapPosition, latLng) {
            setState(() {
              _selectedLocation = latLng;
              _fetchPlaceNameFromOSM(latLng);
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          if (_selectedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _selectedLocation!,
                  builder: (ctx) => Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, _selectedLocation);
        },
        child: Icon(Icons.check),
      ),
      bottomSheet: _selectedPlaceName != null
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '선택된 위치: $_selectedPlaceName',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      )
          : null,
    );
  }
}
