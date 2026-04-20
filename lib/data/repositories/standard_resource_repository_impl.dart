import '../../domain/repositories/standard_resource_repository.dart';
import '../services/standard_resource_api_service.dart';

final class StandardResourceRepositoryImpl<T>
    implements StandardResourceRepository<T> {
  final StandardResourceApiService<T> _apiService;

  StandardResourceRepositoryImpl(this._apiService);

  @override
  Future<List<T>> listResources({int? pageSize, String? pageToken}) {
    return _apiService.listResources(pageSize: pageSize, pageToken: pageToken);
  }

  @override
  Future<T> getResource(String name) {
    return _apiService.getResource(name);
  }

  @override
  Future<T> createResource(T resource, {String? resourceId}) {
    return _apiService.createResource(resource, resourceId: resourceId);
  }

  @override
  Future<T> updateResource(T resource, {List<String>? updateMask}) {
    return _apiService.updateResource(resource, updateMask: updateMask);
  }

  @override
  Future<void> deleteResource(String name) {
    return _apiService.deleteResource(name);
  }
}
