import 'dart:convert';

import 'package:cobox_sv_mobile/core/storage/local_storage.dart';
import 'package:cobox_sv_mobile/features/planning/data/models/plan_model.dart';

class PlanningLocalDataSource {
  static const String _plansKey = 'cached_plans';
  static const String _planPrefix = 'cached_plan_';

  final LocalStorage _storage;

  PlanningLocalDataSource(this._storage);

  Future<void> cachePlans(List<PlanModel> plans) async {
    final jsonList = plans.map((p) => p.toJson()).toList();
    await _storage.save(_plansKey, jsonEncode(jsonList));
  }

  Future<List<PlanModel>?> getCachedPlans() async {
    final cached = _storage.getString(_plansKey);
    if (cached == null) return null;

    final jsonList = jsonDecode(cached) as List<dynamic>;
    return jsonList
        .map((json) => PlanModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> cachePlanDetail(PlanModel plan) async {
    await _storage.save('$_planPrefix${plan.id}', jsonEncode(plan.toJson()));
  }

  Future<PlanModel?> getCachedPlanDetail(String id) async {
    final cached = _storage.getString('$_planPrefix$id');
    if (cached == null) return null;

    return PlanModel.fromJson(jsonDecode(cached) as Map<String, dynamic>);
  }

  Future<void> clearCache() async {
    await _storage.delete(_plansKey);
  }
}
