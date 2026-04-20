abstract interface class StandardResourceRepository<T> {
  Future<List<T>> listResources({int? pageSize, String? pageToken});
  Future<T> getResource(String name);
  Future<T> createResource(T resource, {String? resourceId});
  Future<T> updateResource(T resource, {List<String>? updateMask});
  Future<void> deleteResource(String name);
}
