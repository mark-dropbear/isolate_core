import 'package:get_it/get_it.dart';
import 'package:rdf_dart/rdf_dart.dart';

import '../../api/models/thing.dart';
import '../../api/models/vocab.dart';
import '../../transport/isolate_transport_client.dart';
import '../../transport/transport_client.dart';

import '../../data/services/standard_resource_api_service.dart';
import '../../data/repositories/standard_resource_repository_impl.dart';
import '../../domain/repositories/standard_resource_repository.dart';
import '../../domain/usecases/standard_usecases.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Transport
  getIt.registerLazySingleton<TransportClient>(() => IsolateTransportClient());

  // Thing Domain
  getIt.registerLazySingleton<StandardResourceApiService<Thing>>(
    () => StandardResourceApiService<Thing>(
      client: getIt<TransportClient>(),
      collectionPath: 'things',
      fromDataset: Thing.fromDataset,
      listFromDataset: (dataset) {
        final List<Thing> things = [];
        final graphNames = dataset
            .map((q) => q.graph)
            .whereType<NamedNode>()
            .toSet();

        for (final graphName in graphNames) {
          final resourceName = Vocab.getResourceName(graphName);
          things.add(Thing.fromDataset(dataset, resourceName));
        }
        return things;
      },
      toDataset: (t) => t.toDataset(),
      getName: (t) => t.name,
    ),
  );

  getIt.registerLazySingleton<StandardResourceRepository<Thing>>(
    () => StandardResourceRepositoryImpl<Thing>(
      getIt<StandardResourceApiService<Thing>>(),
    ),
  );

  getIt.registerLazySingleton(
    () =>
        ListResourcesUseCase<Thing>(getIt<StandardResourceRepository<Thing>>()),
  );
  getIt.registerLazySingleton(
    () => GetResourceUseCase<Thing>(getIt<StandardResourceRepository<Thing>>()),
  );
  getIt.registerLazySingleton(
    () =>
        SaveResourceUseCase<Thing>(getIt<StandardResourceRepository<Thing>>()),
  );
  getIt.registerLazySingleton(
    () => DeleteResourceUseCase<Thing>(
      getIt<StandardResourceRepository<Thing>>(),
    ),
  );
}
