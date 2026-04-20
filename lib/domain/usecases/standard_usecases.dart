import '../repositories/standard_resource_repository.dart';

final class ListResourcesUseCase<T> {
  final StandardResourceRepository<T> _repository;
  ListResourcesUseCase(this._repository);
  Future<List<T>> execute({int? pageSize, String? pageToken}) =>
      _repository.listResources(pageSize: pageSize, pageToken: pageToken);
}

final class GetResourceUseCase<T> {
  final StandardResourceRepository<T> _repository;
  GetResourceUseCase(this._repository);
  Future<T> execute(String name) => _repository.getResource(name);
}

final class SaveResourceUseCase<T> {
  final StandardResourceRepository<T> _repository;
  SaveResourceUseCase(this._repository);

  Future<T> execute(
    T resource, {
    bool isCreate = false,
    String? resourceId,
    List<String>? updateMask,
  }) {
    if (isCreate) {
      return _repository.createResource(resource, resourceId: resourceId);
    } else {
      return _repository.updateResource(resource, updateMask: updateMask);
    }
  }
}

final class DeleteResourceUseCase<T> {
  final StandardResourceRepository<T> _repository;
  DeleteResourceUseCase(this._repository);
  Future<void> execute(String name) => _repository.deleteResource(name);
}
