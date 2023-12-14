import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_app/models/recording.dart';

class HiveDatabaseHandler {
  static late Box<Recording> box;

  static Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(RecordingAdapter());
    box = await Hive.openBox<Recording>('recordingsbox');
  }

  static Future<void> generateData() async {
    for (int i = 0; i < 5; i++) {
      box.add(Recording(
        id: i,
        title: 'title$i',
        description: 'description$i',
        transcribedText: 'transcribedText$i',
        summarizedText: 'summarizedText$i',
        path: 'path$i',
        date: DateTime.now(),
        duration: '0',
      ));
    }
  }

  static Future<void> addRecording(Recording recording) async {
    box.add(recording);
  }

  static Future<void> deleteRecording(int index) async {
    box.deleteAt(index);
  }

  static Future<void> updateRecording(int index, Recording recording) async {
    box.putAt(index, recording);
  }

  static Future<List<Recording>> getRecordings() async {
    return box.values.toList();
  }

  static int getRecordingCount() {
    return box.values.length;
  }

  static Future<void> clearrecordingsbox() async {
    await box.clear();
  }

  static Future<void> closeBox() async {
    await box.close();
  }

  static Future<void> deleteBox() async {
    await box.deleteFromDisk();
  }
}





// Non static implementation

// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:my_app/models/recording.dart';

// class HiveDatabaseHandler {
//   late Box<Recording> box;
//   List<Recording> recordings = [];

//   Future<void> initHive() async {
//     await Hive.initFlutter();
//     Hive.registerAdapter(RecordingAdapter());
//     box = await Hive.openBox<Recording>('recordingsbox');
//     recordings = box.values.toList();
//   }

//   Future<void> generateData() async {
//     for (int i = 0; i < 5; i++) {
//       box.add(Recording(
//         id: i,
//         title: 'title$i',
//         description: 'description$i',
//         transcribedText: 'transcribedText$i',
//         summarizedText: 'summarizedText$i',
//         path: 'path$i',
//         date: DateTime.now(),
//         duration: '0',
//       ));
//     }
//   }

//   Future<void> addRecording(Recording recording) async {
//     box.add(recording);
//   }

//   Future<void> deleteRecording(int index) async {
//     box.deleteAt(index);
//   }

//   Future<void> updateRecording(int index, Recording recording) async {
//     box.putAt(index, recording);
//   }

//   Future<List<Recording>> getRecordings() async {
//     return box.values.toList();
//   }

//   int getRecordingCount() {
//     return box.values.length;
//   }

//   Future<void> clearrecordingsbox() async {
//     await box.clear();
//   }

//   Future<void> closeBox() async {
//     await box.close();
//   }

//   Future<void> deleteBox() async {
//     await box.deleteFromDisk();
//   }
// }


// Old code

// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:my_app/models/recording.dart';
// import 'package:hive_flutter/adapters.dart';

// class HiveDatabaseHandler {
//   List<Recording> recordings = [];

//   Future<void> initHive() async {
//     await Hive.initFlutter();
//     Hive.registerAdapter(RecordingAdapter());
//     await Hive.openBox<Recording>('recordingsbox');

//     recordings = Hive.box<Recording>('recordingsbox').values.toList();
//   }

//   Future<void> generateData() async {
//     for (int i = 0; i < 5; i++) {
//       var box = await Hive.openBox<Recording>('recordingsbox');
//       box.add(
//         Recording(
//             id: i,
//             title: 'title$i',
//             description: 'description$i',
//             transcribedText: 'transcribedText$i',
//             summarizedText: 'summarizedText$i',
//             path: 'path$i',
//             date: DateTime.now(),
//             duration: '0'),
//       );
//     }
//   }

//   Future<void> addRecording(Recording recording) async {
//     var box = Hive.box<Recording>('recordingsbox');
//     box.add(recording);
//     recordings = box.values.toList();
//   }

//   Future<void> deleteRecording(int index) async {
//     var box = await Hive.openBox<Recording>('recordingsbox');
//     box.deleteAt(index);
//     recordings = box.values.toList();
//   }

//   Future<void> updateRecording(int index, Recording recording) async {
//     var box = await Hive.openBox<Recording>('recordingsbox');
//     box.putAt(index, recording);
//     recordings = box.values.toList();
//   }

//   Future<void> getrecordingsbox() async {
//     var box = await Hive.openBox<Recording>('recordingsbox');
//     recordings = box.values.toList();
//   }

//   Future<List> getRecordings() async {
//     var box = await Hive.openBox<Recording>('recordingsbox');
//     recordings = box.values.toList();
//     return recordings;
//   }

//   Future<int> getRecordingCount() async {
//     var box = await Hive.openBox<Recording>('recordingsbox');
//     return box.values.length;
//   }

//   Future<void> clearrecordingsbox() async {
//     var box = await Hive.openBox<Recording>('recordingsbox');
//     box.clear();
//     recordings = box.values.toList();
//   }

//   Future<void> deleteBox() async {
//     var box = await Hive.openBox<Recording>('recordingsbox');
//     box.deleteFromDisk();
//     recordings = box.values.toList();
//   }
// }
