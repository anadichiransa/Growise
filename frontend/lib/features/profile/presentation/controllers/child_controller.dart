import 'package:get/get.dart';
import 'package:growise/shared/services/child_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChildController extends GetxController {
  final _child = Rx<Map<String, dynamic>?>(null);
  final _allChildren = RxList<Map<String, dynamic>>([]);
  final isLoading = true.obs;

  Map<String, dynamic>? get child => _child.value;
  List<Map<String, dynamic>> get allChildren => _allChildren;
  String get childName => _child.value?['name'] ?? 'Your Child';
  String get childGender => _child.value?['gender'] ?? 'Boy';
  String get childId => _child.value?['id'] ?? '';

  @override
  void onInit() {
    super.onInit();
    loadChildren();
  }

  Future<void> loadChildren() async {
    isLoading.value = true;
    final first = await ChildService.getFirstChild();
    final all = await ChildService.getAllChildren();
    _child.value = first;
    _allChildren.value = all;
    isLoading.value = false;
  }

  Future<void> switchChild(String childId) async {
    final selected = _allChildren.firstWhere(
      (c) => c['id'] == childId,
      orElse: () => {},
    );
    if (selected.isNotEmpty) {
      _child.value = selected;
    }
  }

  Future<bool> updateCurrentChild({
    required String name,
    required DateTime birthDate,
    required String gender,
  }) async {
    if (childId.isEmpty) return false;
    final success = await ChildService.updateChild(
      childId: childId,
      name: name,
      birthDate: birthDate,
      gender: gender,
    );
    if (success) {
      // Update local state immediately
      _child.value = {
        ..._child.value!,
        'name': name,
        'gender': gender,
        'birthDate': Timestamp.fromDate(birthDate),
      };
      // Also update in allChildren list
      final index = _allChildren.indexWhere((c) => c['id'] == childId);
      if (index != -1) {
        _allChildren[index] = {
          ..._allChildren[index],
          'name': name,
          'gender': gender,
        };
      }
    }
    return success;
  }
}
