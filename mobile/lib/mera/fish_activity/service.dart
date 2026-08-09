import 'package:mobile/mera/fish_activity/engine.dart';
import 'package:mobile/mera/fish_activity/env_provider.dart';
import 'package:mobile/mera/fish_activity/models.dart';
import 'package:mobile/mera/fish_activity/species_profiles.dart';

/// UI-facing façade: env fetch + activity calculation + cache.
class FishActivityService {
  FishActivityService({
    FishEnvProvider? envProvider,
    FishActivityEngine? engine,
  })  : _env = envProvider ?? FishEnvProvider.instance,
        _engine = engine ?? const FishActivityEngine();

  final FishEnvProvider _env;
  final FishActivityEngine _engine;

  FishEnvSnapshot? lastEnv;
  FishActivityResult? lastResult;

  Future<({FishEnvSnapshot env, FishActivityResult activity})> load({
    required double lat,
    required double lng,
    required SpeciesActivityProfile species,
    bool forceRefresh = false,
  }) async {
    final env = await _env.fetch(lat: lat, lng: lng, force: forceRefresh);
    final activity = _engine.calculate(species: species, env: env);
    lastEnv = env;
    lastResult = activity;
    return (env: env, activity: activity);
  }

  FishActivityResult recalculate(SpeciesActivityProfile species) {
    final env = lastEnv;
    if (env == null) {
      throw StateError('Call load() first');
    }
    final activity = _engine.calculate(species: species, env: env);
    lastResult = activity;
    return activity;
  }
}
