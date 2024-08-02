import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/models/myModels/userRecordModel.dart';

class UserWithRecord {
  final User userModel;
  final UserRecord userRecordModel;

  UserWithRecord({required this.userModel, required this.userRecordModel});
}
