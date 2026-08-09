import 'package:flutter/material.dart';
import 'package:mobile/mera/turkish_sea_fish_catalog.dart';
import 'package:mobile/named_entity_manager.dart';

import 'app_manager.dart';
import 'catch_manager.dart';
import 'model/gen/anglers_log.pb.dart';
import 'utils/protobuf_utils.dart';

class SpeciesManager extends NamedEntityManager<Species> {
  static SpeciesManager of(BuildContext context) =>
      AppManager.get.speciesManager;

  SpeciesManager(super.app);

  @override
  Species entityFromBytes(List<int> bytes) => Species.fromBuffer(bytes);

  @override
  Id id(Species entity) => entity.id;

  @override
  String name(Species entity) => entity.name;

  @override
  String get tableName => "species";

  @override
  Future<void> init() async {
    await super.init();
    await ensureTurkishSeaSpecies();
  }

  /// Seeds Akdeniz / Ege / Marmara / Karadeniz species once if missing.
  Future<void> ensureTurkishSeaSpecies() async {
    for (final fish in TurkishSeaFishCatalog.all) {
      if (nameExists(fish.name)) continue;
      await addOrUpdate(
        Species()
          ..id = randomId()
          ..name = fish.name,
        notify: false,
      );
    }
  }

  @override
  Future<bool> delete(Id entityId, {bool notify = true}) async {
    // Species is a required field of Catch, so do not allow users to delete
    // species that are attached to any catches.
    if (CatchManager.get.existsWith(speciesId: entityId)) {
      return false;
    }
    return super.delete(entityId, notify: notify);
  }

  int numberOfCatches(Id? speciesId) => numberOf<Catch>(
    speciesId,
    CatchManager.get.list(),
    (cat) => cat.speciesId == speciesId,
  );
}
